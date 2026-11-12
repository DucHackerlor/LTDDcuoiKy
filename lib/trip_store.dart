import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_validation.dart';
import 'local_account.dart';
import 'models.dart';

const _accountsKey = 'travelmate_accounts_v5';
const _sessionKey = 'travelmate_session_v5';
const _manualSignInMigrationKey = 'travelmate_manual_signin_v53';

class TripStore extends ChangeNotifier {
  final List<Trip> trips = [];
  final List<LocalAccount> _accounts = [];
  bool english = false;
  bool loaded = false;
  String? currentUser;
  String? error;

  bool get hasRegisteredAccount => _accounts.isNotEmpty;
  int get registeredAccountCount => _accounts.length;
  String tr(String vi, String en) => english ? en : vi;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      english = prefs.getBool('english') ?? false;
      final data = prefs.getString('trips');
      if (data != null) {
        trips
          ..clear()
          ..addAll((jsonDecode(data) as List).map(
            (x) => Trip.fromJson(Map<String, dynamic>.from(x as Map)),
          ));
      }

      final savedAccounts = prefs.getString(_accountsKey);
      _accounts.clear();
      if (savedAccounts != null) {
        _accounts.addAll((jsonDecode(savedAccounts) as List).map(
          (x) => LocalAccount.fromJson(Map<String, dynamic>.from(x as Map)),
        ));
      }

      if (prefs.getBool(_manualSignInMigrationKey) != true) {
        await prefs.remove(_sessionKey);
        await prefs.setBool(_manualSignInMigrationKey, true);
      }
      final savedSession = prefs.getString(_sessionKey);
      currentUser = _accounts.any((a) => a.gmail == savedSession)
          ? savedSession
          : null;
      error = null;
    } catch (e) {
      currentUser = null;
      error = 'Không thể đọc dữ liệu đã lưu: $e';
    } finally {
      loaded = true;
      notifyListeners();
    }
  }

  Future<void> persist() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTrips = await prefs.setString(
        'trips', jsonEncode(trips.map((x) => x.toJson()).toList()),
      );
      final savedLanguage = await prefs.setBool('english', english);
      if (!savedTrips || !savedLanguage) {
        error = 'Không thể lưu dữ liệu trên thiết bị.';
      } else {
        error = null;
      }
    } catch (e) {
      error = 'Không thể lưu dữ liệu: $e';
    }
    notifyListeners();
  }

  String _digest(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  String _newSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  Future<void> registerLocal({
    required String gmail,
    required String phone,
    required String password,
  }) async {
    final email = gmail.trim().toLowerCase();
    final number = normalizePhone(phone);
    if (!isValidGmail(email)) throw const LocalAccountException('invalid_gmail');
    if (!isValidPhone(number)) throw const LocalAccountException('invalid_phone');
    if (!isValidPassword(password)) {
      throw const LocalAccountException('invalid_password');
    }
    if (_accounts.any((a) => a.gmail == email || a.phone == number)) {
      throw const LocalAccountException('already_registered');
    }
    final salt = _newSalt();
    final account = LocalAccount(
      gmail: email,
      phone: number,
      salt: salt,
      passwordDigest: _digest(password, salt),
    );
    final prefs = await SharedPreferences.getInstance();
    final updated = [..._accounts, account];
    final savedAccounts = await prefs.setString(
      _accountsKey,
      jsonEncode(updated.map((a) => a.toJson()).toList()),
    );
    if (!savedAccounts) throw const LocalAccountException('save_failed');
    _accounts.add(account);
    final cleared = await prefs.remove(_sessionKey);
    if (!cleared) throw const LocalAccountException('save_failed');
    currentUser = null;
    notifyListeners();
  }

  Future<void> signInLocal({
    required String identifier,
    required String password,
  }) async {
    final input = identifier.trim().toLowerCase();
    final phone = normalizePhone(input);
    LocalAccount? account;
    for (final candidate in _accounts) {
      if (candidate.gmail == input || candidate.phone == phone) {
        account = candidate;
        break;
      }
    }
    if (account == null ||
        !isValidPassword(password) ||
        _digest(password, account.salt) != account.passwordDigest) {
      throw const LocalAccountException('invalid_credentials');
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_sessionKey, account.gmail);
    if (!saved) throw const LocalAccountException('save_failed');
    currentUser = account.gmail;
    notifyListeners();
  }

  LocalAccount _recoveryAccount({
    required String gmail,
    required String phone,
  }) {
    final email = gmail.trim().toLowerCase();
    final number = normalizePhone(phone);
    if (!isValidGmail(email)) {
      throw const LocalAccountException('invalid_gmail');
    }
    if (!isValidPhone(number)) {
      throw const LocalAccountException('invalid_phone');
    }
    for (final account in _accounts) {
      if (account.gmail == email && account.phone == number) return account;
    }
    throw const LocalAccountException('recovery_not_found');
  }

  bool verifyRecoveryDetails({required String gmail, required String phone}) {
    _recoveryAccount(gmail: gmail, phone: phone);
    return true;
  }

  Future<void> resetPasswordLocal({
    required String gmail,
    required String phone,
    required String newPassword,
  }) async {
    final account = _recoveryAccount(gmail: gmail, phone: phone);
    if (!isValidPassword(newPassword)) {
      throw const LocalAccountException('invalid_password');
    }

    final salt = _newSalt();
    final updatedAccount = LocalAccount(
      gmail: account.gmail,
      phone: account.phone,
      salt: salt,
      passwordDigest: _digest(newPassword, salt),
    );
    final index = _accounts.indexOf(account);
    final updatedAccounts = [..._accounts];
    updatedAccounts[index] = updatedAccount;

    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _accountsKey,
      jsonEncode(updatedAccounts.map((a) => a.toJson()).toList()),
    );
    if (!saved) throw const LocalAccountException('save_failed');
    _accounts[index] = updatedAccount;

    if (currentUser == account.gmail) {
      await prefs.remove(_sessionKey);
      currentUser = null;
    }
    notifyListeners();
  }

  Future<void> signOutLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove('travelmate_local_user');
    await prefs.remove('travelmate_demo_user');
    currentUser = null;
    notifyListeners();
  }

  Future<void> setEnglish(bool value) async {
    english = value;
    await persist();
  }
}
