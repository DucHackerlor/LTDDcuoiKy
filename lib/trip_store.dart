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
