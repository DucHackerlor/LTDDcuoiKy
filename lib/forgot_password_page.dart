import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_validation.dart';
import 'local_account.dart';
import 'trip_store.dart';

const _green = Color(0xFF06A65F);
const _dark = Color(0xFF12352A);
const _muted = Color(0xFF73857B);

class ForgotPasswordPage extends StatefulWidget {
  final TripStore store;

  const ForgotPasswordPage({super.key, required this.store});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _gmail = TextEditingController();
  final _phone = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _verified = false;
  bool _busy = false;
  bool _showPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _gmail.dispose();
    _phone.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String _errorText(LocalAccountException exception) {
    final s = widget.store;
    switch (exception.code) {
      case 'invalid_gmail':
        return s.tr('Gmail chưa đúng định dạng.', 'Invalid Gmail format.');
      case 'invalid_phone':
        return s.tr('Số điện thoại chưa đúng định dạng.', 'Invalid phone number.');
      case 'recovery_not_found':
        return s.tr(
          'Gmail và số điện thoại không khớp với cùng một tài khoản đã đăng ký.',
          'Gmail and phone number do not match the same registered account.',
        );
      case 'invalid_password':
        return s.tr('Mật khẩu cần 6–64 ký tự, không có dấu cách.',
            'Password must be 6–64 characters without spaces.');
      default:
        return s.tr('Không thể lưu mật khẩu mới. Vui lòng thử lại.',
            'Could not save the new password. Please try again.');
    }
  }

  void _checkAccount() {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    try {
      widget.store.verifyRecoveryDetails(
        gmail: _gmail.text,
        phone: _phone.text,
      );
      setState(() {
        _verified = true;
        _errorMessage = null;
        _newPassword.clear();
        _confirmPassword.clear();
      });
    } on LocalAccountException catch (e) {
      setState(() => _errorMessage = _errorText(e));
    }
  }

  Future<void> _resetPassword() async {
    if (!_verified || _busy || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      await widget.store.resetPasswordLocal(
        gmail: _gmail.text,
        phone: _phone.text,
        newPassword: _newPassword.text,
      );
      if (mounted) {
        Navigator.of(context).pop(_gmail.text.trim().toLowerCase());
      }
    } on LocalAccountException catch (e) {
      if (mounted) setState(() => _errorMessage = _errorText(e));
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = widget.store.tr(
          'Có lỗi khi lưu dữ liệu. Vui lòng thử lại.',
          'Could not save data. Please try again.',
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    return Scaffold(
      appBar: AppBar(title: Text(s.tr('Quên mật khẩu', 'Forgot password'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFFE2F7EB),
                    child: Icon(Icons.lock_reset_rounded, size: 37, color: _green),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _verified
                      ? s.tr('Tạo mật khẩu mới', 'Create a new password')
                      : s.tr('Khôi phục tài khoản', 'Recover your account'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _dark, fontSize: 24, fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _verified
                      ? s.tr('Nhập mật khẩu mới cho tài khoản ${_gmail.text.trim().toLowerCase()}.',
                          'Set a new password for ${_gmail.text.trim().toLowerCase()}.')
                      : s.tr('Nhập đúng Gmail và số điện thoại đã dùng khi đăng ký.',
                          'Enter the Gmail and phone number used to register.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, height: 1.4),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_verified) ...[
                            TextFormField(
                              key: const ValueKey('recovery-gmail'),
                              controller: _gmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Gmail',
                                hintText: 'ban@gmail.com',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                              validator: (value) => isValidGmail(value ?? '')
                                  ? null
                                  : s.tr('Nhập Gmail đúng định dạng @gmail.com.',
                                      'Enter a valid @gmail.com address.'),
                            ),
                            const SizedBox(height: 13),
                            TextFormField(
                              key: const ValueKey('recovery-phone'),
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _checkAccount(),
                              inputFormatters: [FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+ .\-]'),
                              )],
                              decoration: InputDecoration(
                                labelText: s.tr('Số điện thoại', 'Phone number'),
                                hintText: '0912345678',
                                prefixIcon: const Icon(Icons.phone_outlined),
                              ),
                              validator: (value) => isValidPhone(value ?? '')
                                  ? null
                                  : s.tr('Nhập số điện thoại Việt Nam hợp lệ.',
                                      'Enter a valid Vietnamese phone number.'),
                            ),
                          ] else ...[
                            TextFormField(
                              key: const ValueKey('recovery-new-password'),
                              controller: _newPassword,
                              obscureText: !_showPassword,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: s.tr('Mật khẩu mới', 'New password'),
                                helperText: s.tr('6–64 ký tự, không có dấu cách',
                                    '6–64 characters, no spaces'),
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  tooltip: _showPassword
                                      ? s.tr('Ẩn mật khẩu', 'Hide password')
                                      : s.tr('Hiện mật khẩu', 'Show password'),
                                  onPressed: () => setState(
                                      () => _showPassword = !_showPassword),
                                  icon: Icon(_showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined),
                                ),
                              ),
                              validator: (value) => isValidPassword(value ?? '')
                                  ? null
                                  : s.tr('Mật khẩu cần 6–64 ký tự, không có dấu cách.',
                                      'Password must be 6–64 characters without spaces.'),
                            ),
                            const SizedBox(height: 13),
                            TextFormField(
                              key: const ValueKey('recovery-confirm-password'),
                              controller: _confirmPassword,
                              obscureText: !_showPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _resetPassword(),
                              decoration: InputDecoration(
                                labelText: s.tr('Nhập lại mật khẩu mới',
                                    'Confirm new password'),
                                prefixIcon: const Icon(Icons.verified_user_outlined),
                              ),
                              validator: (value) => value == _newPassword.text
                                  ? null
                                  : s.tr('Hai mật khẩu chưa trùng nhau.',
                                      'Passwords do not match.'),
                            ),
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 13),
                            Text(_errorMessage!,
                                style: const TextStyle(color: Colors.red)),
                          ],
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            key: ValueKey(_verified
                                ? 'recovery-reset-button'
                                : 'recovery-verify-button'),
                            onPressed: _busy
                                ? null
                                : (_verified ? _resetPassword : _checkAccount),
                            icon: _busy
                                ? const SizedBox(width: 17, height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white,
                                    ))
                                : const Icon(Icons.arrow_forward_rounded),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Text(_verified
                                  ? s.tr('Đặt lại mật khẩu', 'Reset password')
                                  : s.tr('Kiểm tra thông tin', 'Verify details')),
                            ),
                          ),
                          if (_verified) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _busy ? null : () => setState(() {
                                _verified = false;
                                _errorMessage = null;
                                _newPassword.clear();
                                _confirmPassword.clear();
                              }),
                              child: Text(s.tr('Thay đổi Gmail / số điện thoại',
                                  'Change Gmail / phone number')),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(s.tr('Quay lại đăng nhập', 'Back to sign in')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
