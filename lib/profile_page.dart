import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_validation.dart';
import 'forgot_password_page.dart';
import 'local_account.dart';
import 'trip_store.dart';

export 'auth_validation.dart' show isValidGmail, isValidPhone, isValidPassword;

const _green = Color(0xFF06A65F);
const _dark = Color(0xFF12352A);
const _muted = Color(0xFF73857B);

class ProfilePage extends StatelessWidget {
  final TripStore store;
  final VoidCallback onTeam;
  const ProfilePage({super.key, required this.store, required this.onTeam});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
      children: [
        Text(store.tr('Tài khoản của tôi', 'My account'),
          style: const TextStyle(color: _dark, fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(store.tr('Thông tin đăng nhập và thiết lập ứng dụng.',
          'Your sign-in details and app preferences.'),
          style: const TextStyle(color: _muted)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF08A965), Color(0xFF057D50)]),
            borderRadius: BorderRadius.circular(27)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CircleAvatar(radius: 29, backgroundColor: Color(0x44FFFFFF),
              child: Icon(Icons.person_outline, color: Colors.white, size: 32)),
            const SizedBox(height: 14),
            Text(store.tr('Xin chào, người yêu du lịch!', 'Hello, traveler!'),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(store.currentUser ?? '',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 22),
        Text(store.tr('Tùy chỉnh', 'Preferences'),
          style: const TextStyle(color: _dark, fontWeight: FontWeight.w900, fontSize: 17)),
        const SizedBox(height: 10),
        Card(child: Column(children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            secondary: const Icon(Icons.translate_rounded, color: _green),
            title: Text(store.tr('Giao diện tiếng Anh', 'English interface')),
            subtitle: Text(store.tr('Chuyển ngôn ngữ Việt / Anh', 'Switch language')),
            value: store.english,
            onChanged: store.setEnglish,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.groups_outlined, color: _green),
            title: Text(store.tr('Thông tin nhóm', 'Team information')),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTeam,
          ),
        ])),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () async {
            await store.signOutLocal();
          },
          icon: const Icon(Icons.logout_rounded),
          label: Text(store.tr('Đăng xuất', 'Sign out')),
        ),
      ],
    );
  }
}

class AuthPage extends StatefulWidget {
  final TripStore store;
  const AuthPage({super.key, required this.store});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _gmail = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _identifier = TextEditingController();
  late bool _register;
  bool _submitting = false;
  bool _showPassword = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _register = !widget.store.hasRegisteredAccount;
  }

  @override
  void dispose() {
    _gmail.dispose();
    _phone.dispose();
    _password.dispose();
    _identifier.dispose();
    super.dispose();
  }

  void _switchMode(bool register) {
    if (_register == register) return;
    setState(() {
      _register = register;
      _password.clear();
      _errorMessage = null;
      _successMessage = null;
      _showPassword = false;
    });
  }

  Future<void> _openForgotPassword() async {
    if (_submitting) return;
    final recoveredGmail = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordPage(store: widget.store),
      ),
    );
    if (!mounted || recoveredGmail == null) return;
    setState(() {
      _register = false;
      _identifier.text = recoveredGmail;
      _password.clear();
      _errorMessage = null;
      _showPassword = false;
      _successMessage = widget.store.tr(
        'Đặt lại mật khẩu thành công! Hãy đăng nhập bằng mật khẩu mới.',
        'Password reset successfully! Please sign in with your new password.',
      );
    });
  }

  String _errorText(LocalAccountException e) {
    final s = widget.store;
    switch (e.code) {
      case 'invalid_gmail':
        return s.tr('Gmail chưa đúng định dạng.', 'Invalid Gmail format.');
      case 'invalid_phone':
        return s.tr('Số điện thoại chưa đúng định dạng.', 'Invalid phone number.');
