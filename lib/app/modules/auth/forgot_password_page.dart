// ForgotPasswordPage: 3 method cards for password reset.
// Method 1 (primary, left-accented) — email reset: send code → enter code + new password.
// Method 2 — device verify: send code → enter code + new password (also binds email).
// Method 3 — contact developer: navigates to the existing FeedbackPage.
// An InfoBanner at the top prompts the user to pick a method.

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/auth/login_page.dart';
import 'package:chaldea/app/modules/auth/validators.dart';
import 'package:chaldea/app/modules/home/subpage/feedback_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController _emailController;

  // Method 1 state
  bool _emailCodeSent = false;
  bool _emailResetSuccess = false;
  String _emailCode = '';
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePwd = true;
  int _emailResendCountdown = 0;
  bool _emailResendTimerActive = false;

  late final TextEditingController _usernameController;
  late final TextEditingController _deviceIdController;
  late final TextEditingController _newEmailController;

  // Method 2 state
  bool _deviceCodeSent = false;
  bool _deviceResetSuccess = false;
  String _deviceCode = '';
  final _deviceNewPasswordController = TextEditingController();
  final _deviceConfirmPasswordController = TextEditingController();
  bool _deviceObscurePwd = true;
  int _deviceResendCountdown = 0;
  bool _deviceResendTimerActive = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _deviceIdController = TextEditingController();
    _newEmailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _deviceIdController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deviceNewPasswordController.dispose();
    _deviceConfirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isEmailResetAvailable => _emailController.text.isNotEmpty && validateEmail(_emailController.text) == null;

  bool get _isEmailResetSubmitAvailable {
    return _emailCodeSent &&
        _emailCode.length == 6 &&
        _newPasswordController.text.isNotEmpty &&
        validatePassword(_newPasswordController.text) == null &&
        _confirmPasswordController.text == _newPasswordController.text;
  }

  bool get _isDeviceVerifyAvailable {
    return _usernameController.text.isNotEmpty &&
        _deviceIdController.text.isNotEmpty &&
        validateEmail(_newEmailController.text) == null &&
        _newEmailController.text.isNotEmpty;
  }

  bool get _isDeviceResetSubmitAvailable {
    return _deviceCodeSent &&
        _deviceCode.length == 6 &&
        _deviceNewPasswordController.text.isNotEmpty &&
        validatePassword(_deviceNewPasswordController.text) == null &&
        _deviceConfirmPasswordController.text == _deviceNewPasswordController.text;
  }

  // ===================== Method 1 handlers =====================

  Future<void> _sendEmailCode() async {
    if (!_isEmailResetAvailable || _emailResendTimerActive) {
      return;
    }
    final ok = await showEasyLoading(() => ChaldeaServerApi.forgotPassword(email: _emailController.text));
    if (ok == true) {
      setState(() => _emailCodeSent = true);
      _startEmailResendCountdown();
      EasyLoading.showSuccess('${S.current.auth_send_code}: ${S.current.success}');
    }
    db.notifySettings();
  }

  void _startEmailResendCountdown() {
    _emailResendCountdown = 60;
    _emailResendTimerActive = true;
    _tickEmailCountdown();
  }

  void _tickEmailCountdown() {
    if (!mounted) return;
    if (_emailResendCountdown <= 0) {
      setState(() => _emailResendTimerActive = false);
      return;
    }
    setState(() => _emailResendCountdown--);
    Future.delayed(const Duration(seconds: 1), _tickEmailCountdown);
  }

  Future<void> _submitEmailReset() async {
    if (!_isEmailResetSubmitAvailable) return;
    final ok = await showEasyLoading(
      () => ChaldeaServerApi.resetPassword(
        email: _emailController.text,
        code: _emailCode,
        newPassword: _newPasswordController.text,
      ),
    );
    if (ok == true) {
      setState(() => _emailResetSuccess = true);
      EasyLoading.showSuccess(S.current.success);
    }
    db.notifySettings();
  }

  // ===================== Method 2 handlers =====================

  Future<void> _sendDeviceCode() async {
    if (!_isDeviceVerifyAvailable || _deviceResendTimerActive) {
      return;
    }
    final ok = await showEasyLoading(
      () => ChaldeaServerApi.recoverByDevice(
        username: _usernameController.text,
        deviceId: _deviceIdController.text,
        newEmail: _newEmailController.text,
      ),
    );
    if (ok == true) {
      setState(() => _deviceCodeSent = true);
      _startDeviceResendCountdown();
      EasyLoading.showSuccess('${S.current.auth_send_code}: ${S.current.success}');
    }
    db.notifySettings();
  }

  void _startDeviceResendCountdown() {
    _deviceResendCountdown = 60;
    _deviceResendTimerActive = true;
    _tickDeviceCountdown();
  }

  void _tickDeviceCountdown() {
    if (!mounted) return;
    if (_deviceResendCountdown <= 0) {
      setState(() => _deviceResendTimerActive = false);
      return;
    }
    setState(() => _deviceResendCountdown--);
    Future.delayed(const Duration(seconds: 1), _tickDeviceCountdown);
  }

  Future<void> _submitDeviceReset() async {
    if (!_isDeviceResetSubmitAvailable) return;
    final ok = await showEasyLoading(
      () => ChaldeaServerApi.resetPasswordByDevice(
        username: _usernameController.text,
        code: _deviceCode,
        newEmail: _newEmailController.text,
        newPassword: _deviceNewPasswordController.text,
      ),
    );
    if (ok == true) {
      setState(() => _deviceResetSuccess = true);
      EasyLoading.showSuccess(S.current.success);
    }
    db.notifySettings();
  }

  // ===================== Build =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.auth_forgot_password_title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            InfoBanner(variant: InfoBannerVariant.info, text: S.current.auth_forgot_password_hint),
            const SizedBox(height: 16),
            _buildEmailResetCard(),
            const SizedBox(height: 16),
            _buildDeviceVerifyCard(),
            const SizedBox(height: 16),
            _buildContactDeveloperCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailResetCard() {
    if (_emailResetSuccess) {
      return _MethodCard(
        primary: true,
        icon: Icons.check_circle_outline,
        title: S.current.success,
        desc: S.current.auth_forgot_password_hint,
        children: [
          PrimaryButton(
            label: S.current.login_login,
            onPressed: () => router.popDetailAndPush(child: LoginPage()),
          ),
        ],
      );
    }

    return _MethodCard(
      primary: true,
      icon: Icons.email_outlined,
      title: S.current.auth_method_email_reset_title,
      desc: S.current.auth_method_email_reset_desc,
      children: [
        FormInput(
          hint: S.current.email,
          controller: _emailController,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          validator: validateEmail,
          errorDisplayMode: ErrorDisplayMode.onBlur,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: _emailResendTimerActive
              ? '${S.current.auth_resend_code} (${_emailResendCountdown}s)'
              : S.current.auth_send_code,
          onPressed: _isEmailResetAvailable && !_emailResendTimerActive ? _sendEmailCode : null,
        ),
        if (_emailCodeSent) ...[
          const SizedBox(height: 16),
          InfoBanner(
            variant: InfoBannerVariant.info,
            text: '${S.current.auth_verification_code_sent} ${_emailController.text}',
          ),
          const SizedBox(height: 12),
          CodeInput(length: 6, onChanged: (v) => setState(() => _emailCode = v)),
          const SizedBox(height: 16),
          FormInput(
            label: S.current.login_new_password,
            prefixIcon: Icons.lock_outline,
            hint: S.current.login_new_password,
            controller: _newPasswordController,
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
          const SizedBox(height: 12),
          FormInput(
            label: S.current.login_confirm_password,
            prefixIcon: Icons.lock_outline,
            hint: S.current.login_confirm_password,
            controller: _confirmPasswordController,
            obscure: _obscurePwd,
            autocorrect: false,
            validator: (v) => v.isNotEmpty && v != _newPasswordController.text
                ? S.current.login_password_error_confirm_mismatch
                : null,
            errorDisplayMode: ErrorDisplayMode.onBlur,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
              icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
              tooltip: _obscurePwd ? 'Show' : 'Hide',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: S.current.auth_admin_reset_password,
            onPressed: _isEmailResetSubmitAvailable ? _submitEmailReset : null,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isEmailResetAvailable && !_emailResendTimerActive ? _sendEmailCode : null,
            child: Text(
              _emailResendTimerActive
                  ? '${S.current.auth_resend_code} (${_emailResendCountdown}s)'
                  : S.current.auth_resend_code,
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
        ],
      ],
    );
  }

  Widget _buildDeviceVerifyCard() {
    if (_deviceResetSuccess) {
      return _MethodCard(
        icon: Icons.check_circle_outline,
        title: S.current.success,
        desc: S.current.auth_forgot_password_hint,
        children: [
          PrimaryButton(
            label: S.current.login_login,
            onPressed: () => router.popDetailAndPush(child: LoginPage()),
          ),
        ],
      );
    }

    return _MethodCard(
      icon: Icons.smartphone_outlined,
      title: S.current.auth_method_device_verify_title,
      desc: S.current.auth_method_device_verify_desc,
      children: [
        FormInput(
          hint: S.current.login_username,
          prefixIcon: Icons.person_outline,
          controller: _usernameController,
          autocorrect: false,
          validator: (_) => null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        FormInput(
          hint: S.current.auth_device_id,
          prefixIcon: Icons.devices_outlined,
          controller: _deviceIdController,
          autocorrect: false,
          validator: (_) => null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        FormInput(
          hint: S.current.auth_new_email,
          prefixIcon: Icons.email_outlined,
          controller: _newEmailController,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v.isNotEmpty ? validateEmail(v) : null,
          errorDisplayMode: ErrorDisplayMode.onBlur,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: _deviceResendTimerActive
              ? '${S.current.auth_resend_code} (${_deviceResendCountdown}s)'
              : S.current.auth_send_code,
          onPressed: _isDeviceVerifyAvailable && !_deviceResendTimerActive ? _sendDeviceCode : null,
        ),
        if (_deviceCodeSent) ...[
          const SizedBox(height: 16),
          InfoBanner(
            variant: InfoBannerVariant.info,
            text: '${S.current.auth_verification_code_sent} ${_newEmailController.text}',
          ),
          const SizedBox(height: 12),
          CodeInput(length: 6, onChanged: (v) => setState(() => _deviceCode = v)),
          const SizedBox(height: 16),
          FormInput(
            label: S.current.login_new_password,
            prefixIcon: Icons.lock_outline,
            hint: S.current.login_new_password,
            controller: _deviceNewPasswordController,
            obscure: _deviceObscurePwd,
            autocorrect: false,
            validator: validatePassword,
            errorDisplayMode: ErrorDisplayMode.onBlur,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _deviceObscurePwd = !_deviceObscurePwd),
              icon: Icon(_deviceObscurePwd ? Icons.visibility_off : Icons.visibility),
              tooltip: _deviceObscurePwd ? 'Show' : 'Hide',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          FormInput(
            label: S.current.login_confirm_password,
            prefixIcon: Icons.lock_outline,
            hint: S.current.login_confirm_password,
            controller: _deviceConfirmPasswordController,
            obscure: _deviceObscurePwd,
            autocorrect: false,
            validator: (v) => v.isNotEmpty && v != _deviceNewPasswordController.text
                ? S.current.login_password_error_confirm_mismatch
                : null,
            errorDisplayMode: ErrorDisplayMode.onBlur,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _deviceObscurePwd = !_deviceObscurePwd),
              icon: Icon(_deviceObscurePwd ? Icons.visibility_off : Icons.visibility),
              tooltip: _deviceObscurePwd ? 'Show' : 'Hide',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: S.current.auth_admin_reset_password,
            onPressed: _isDeviceResetSubmitAvailable ? _submitDeviceReset : null,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isDeviceVerifyAvailable && !_deviceResendTimerActive ? _sendDeviceCode : null,
            child: Text(
              _deviceResendTimerActive
                  ? '${S.current.auth_resend_code} (${_deviceResendCountdown}s)'
                  : S.current.auth_resend_code,
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
        ],
      ],
    );
  }

  Widget _buildContactDeveloperCard() {
    return _MethodCard(
      icon: Icons.support_agent_outlined,
      title: S.current.auth_method_contact_developer_title,
      desc: S.current.auth_method_contact_developer_desc,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            S.current.auth_contact_required_info_hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ),
        Row(
          children: [
            Flexible(child: Text(S.current.auth_contact_device_uuid_hint)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(AppInfo.uuid, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => copyToClipboard(AppInfo.uuid, toast: true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SecondaryButton(
          label: S.current.auth_open_feedback,
          onPressed: () => router.push(child: FeedbackPage(prefilledContext: {'source': 'forgot_password'})),
        ),
      ],
    );
  }
}

/// Method card with optional left accent for the primary variant.
class _MethodCard extends StatelessWidget {
  final bool primary;
  final IconData icon;
  final String title;
  final String desc;
  final List<Widget> children;

  const _MethodCard({
    this.primary = false,
    required this.icon,
    required this.title,
    required this.desc,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AccentContainer(
      primary: primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary ? cs.primary.withAlpha(30) : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: primary ? cs.primary : cs.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
