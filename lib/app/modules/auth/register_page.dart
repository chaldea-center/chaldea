// RegisterPage: 2-step registration flow.
// Step 1: collect username/email/password/confirm → call `register` to send code.
// Step 2: enter the email code → call `verifyRegister` to create the account.
// On success: persist the returned user, then pop back to the profile hub.

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/auth/profile_page.dart';
import 'package:chaldea/app/modules/auth/validators.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _step = 1;
  String _code = '';

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _pwdController;
  late final TextEditingController _confirmController;
  bool _obscurePwd = true;

  final secrets = db.settings.secrets;

  // Resend countdown: counts down from 60 after sending code.
  int _resendCountdown = 0;
  bool _resendTimerActive = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _pwdController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pwdController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isStep1Available {
    final name = _nameController.text;
    final email = _emailController.text;
    final pwd = _pwdController.text;
    final confirm = _confirmController.text;
    return isLoginAvailable(name, pwd) && email.isNotEmpty && validateEmail(email) == null && confirm == pwd;
  }

  bool get _isStep2Available => _code.length == 6;

  Future<void> _sendCode() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final pwd = _pwdController.text;
    if (!_isStep1Available || _resendTimerActive) return;
    final ok = await showEasyLoading(() => ChaldeaServerApi.register(username: name, email: email, password: pwd));
    if (ok == true) {
      setState(() => _step = 2);
      _startResendCountdown();
      EasyLoading.showSuccess('${S.current.auth_send_code}: ${S.current.success}');
    }
    db.notifySettings();
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    _resendTimerActive = true;
    _tickCountdown();
  }

  void _tickCountdown() {
    if (!mounted) return;
    if (_resendCountdown <= 0) {
      setState(() => _resendTimerActive = false);
      return;
    }
    setState(() => _resendCountdown--);
    Future.delayed(const Duration(seconds: 1), _tickCountdown);
  }

  Future<void> _verify() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final pwd = _pwdController.text;
    if (!_isStep2Available) return;
    final user = await showEasyLoading(
      () => ChaldeaServerApi.verifyRegister(username: name, email: email, password: pwd, code: _code),
    );
    if (user != null) {
      secrets.user.updateFromLoginResponse(user);
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      router.popDetailAndPush(child: const ProfilePage());
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.auth_register_title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            StepIndicator(current: _step, total: 2),
            const SizedBox(height: 24),
            if (_step == 1) ..._buildStep1(),
            if (_step == 2) ..._buildStep2(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      FormInput(
        label: S.current.login_username,
        prefixIcon: Icons.person_outline,
        hint: S.current.login_username,
        controller: _nameController,
        autocorrect: false,
        helperText: S.current.auth_username_helper,
        validator: validateUsername,
        errorDisplayMode: ErrorDisplayMode.onBlur,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 16),
      FormInput(
        label: S.current.email,
        prefixIcon: Icons.email_outlined,
        hint: 'example@email.com',
        controller: _emailController,
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
        errorDisplayMode: ErrorDisplayMode.onBlur,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 16),
      FormInput(
        label: S.current.login_password,
        prefixIcon: Icons.lock_outline,
        hint: S.current.login_password,
        controller: _pwdController,
        obscure: _obscurePwd,
        autocorrect: false,
        validator: validatePassword,
        errorDisplayMode: ErrorDisplayMode.onBlur,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
          icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
          tooltip: _obscurePwd ? 'Show' : 'Hide',
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 16),
      FormInput(
        label: S.current.login_confirm_password,
        prefixIcon: Icons.lock_outline,
        hint: S.current.login_confirm_password,
        controller: _confirmController,
        obscure: _obscurePwd,
        autocorrect: false,
        validator: (v) =>
            v.isNotEmpty && v != _pwdController.text ? S.current.login_password_error_confirm_mismatch : null,
        errorDisplayMode: ErrorDisplayMode.onBlur,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
          icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
          tooltip: _obscurePwd ? 'Show' : 'Hide',
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 24),
      PrimaryButton(label: S.current.auth_send_code, onPressed: _isStep1Available ? _sendCode : null),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      InfoBanner(
        variant: InfoBannerVariant.info,
        text: '${S.current.auth_verification_code_sent} ${_emailController.text}',
      ),
      const SizedBox(height: 16),
      CodeInput(length: 6, onChanged: (v) => setState(() => _code = v)),
      const SizedBox(height: 24),
      PrimaryButton(label: S.current.confirm, onPressed: _isStep2Available ? _verify : null),
      const SizedBox(height: 8),
      TextButton(
        onPressed: _isStep1Available && !_resendTimerActive ? _sendCode : null,
        child: Text(
          _resendTimerActive ? '${S.current.auth_resend_code} (${_resendCountdown}s)' : S.current.auth_resend_code,
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          S.current.auth_email_not_received_hint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }
}
