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
      case 'invalid_password':
        return s.tr('Mật khẩu cần 6–64 ký tự và không có dấu cách.',
            'Password must be 6–64 characters without spaces.');
      case 'already_registered':
        return s.tr('Gmail hoặc số điện thoại này đã được đăng ký trên thiết bị.',
            'Gmail or phone is already registered on this device.');
      case 'invalid_credentials':
        return s.tr('Thông tin đăng nhập hoặc mật khẩu không đúng.',
            'Incorrect account or password.');
      default:
        return s.tr('Không thể lưu tài khoản. Vui lòng thử lại.',
            'Could not save the account. Please try again.');
    }
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false) || _submitting) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      if (_register) {
        await widget.store.registerLocal(
          gmail: _gmail.text,
          phone: _phone.text,
          password: _password.text,
        );
        if (mounted) {
          setState(() {
            _identifier.text = _gmail.text.trim().toLowerCase();
            _gmail.clear();
            _phone.clear();
            _password.clear();
            _register = false;
            _showPassword = false;
            _successMessage = widget.store.tr(
              'Đăng ký thành công! Hãy nhập mật khẩu và nhấn Đăng nhập để vào ứng dụng.',
              'Registration successful! Enter your password and sign in to continue.',
            );
          });
        }
      } else {
        await widget.store.signInLocal(
          identifier: _identifier.text,
          password: _password.text,
        );
      }
    } on LocalAccountException catch (e) {
      if (mounted) setState(() => _errorMessage = _errorText(e));
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = widget.store.tr(
          'Có lỗi khi lưu dữ liệu. Hãy thử lại.',
          'Could not save data. Please try again.',
        ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
              children: [
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10BA70), Color(0xFF087D51)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(
                        color: Color(0x2200A35E), blurRadius: 18, offset: Offset(0, 8),
                      )],
                    ),
                    child: const Icon(Icons.flight_takeoff_rounded,
                        color: Colors.white, size: 38),
                  ),
                ),
                const SizedBox(height: 14),
                const Center(child: Text('TravelMate',
                    style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900,
                        letterSpacing: -.7, color: _dark))),
                const SizedBox(height: 6),
                Text(s.tr('Lịch trình trong tay, an tâm khám phá',
                    'Plan your journey, enjoy the adventure'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, fontSize: 13)),
                const SizedBox(height: 10),
                const Center(child: Text('🌴  ✈️  🎒  📸',
                    style: TextStyle(fontSize: 22, letterSpacing: 2))),
                const SizedBox(height: 18),
                Text(_register ? s.tr('Tạo tài khoản', 'Create account')
                    : s.tr('Chào mừng trở lại', 'Welcome back'),
                    style: const TextStyle(color: _dark,
                        fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(_register
                    ? s.tr('Đăng ký một lần để bắt đầu lên kế hoạch du lịch.',
                        'Sign up once to start planning your trips.')
                    : s.tr('Đăng nhập bằng Gmail hoặc số điện thoại đã đăng ký.',
                        'Use your registered Gmail or phone number.'),
                    style: const TextStyle(color: _muted, height: 1.4)),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDB8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(children: [
                    Expanded(child: _modeButton(s.tr('Đăng ký', 'Sign up'), true)),
                    Expanded(child: _modeButton(s.tr('Đăng nhập', 'Sign in'), false)),
                  ]),
                ),
                const SizedBox(height: 18),
                if (_successMessage != null) ...[
                  Container(
                    key: const ValueKey('registration-success'),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F7EB),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFB5E2C5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: _green),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_successMessage!,
                            style: const TextStyle(color: _dark, height: 1.35))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _form,
