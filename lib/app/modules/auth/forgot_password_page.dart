// ForgotPasswordPage: 3 method cards for password reset.
// Method 1 (primary, left-accented) — email reset: calls `forgotPassword`.
// Method 2 — device verify: calls `recoverByDevice(username, deviceId, newEmail)`.
// Method 3 — contact developer: navigates to the existing FeedbackPage.
// An InfoBanner at the top prompts the user to pick a method.

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/auth/validators.dart';
import 'package:chaldea/app/modules/home/subpage/feedback_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController _emailController;
  bool _emailTouched = false;

  late final TextEditingController _usernameController;
  late final TextEditingController _deviceIdController;
  late final TextEditingController _newEmailController;
  bool _devTouched = false;

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
    super.dispose();
  }

  bool get _isEmailResetAvailable => _emailController.text.isNotEmpty && validateEmail(_emailController.text) == null;

  bool get _isDeviceVerifyAvailable {
    return _usernameController.text.isNotEmpty &&
        _deviceIdController.text.isNotEmpty &&
        validateEmail(_newEmailController.text) == null &&
        _newEmailController.text.isNotEmpty;
  }

  Future<void> _sendResetEmail() async {
    if (!_isEmailResetAvailable) {
      setState(() => _emailTouched = true);
      return;
    }
    final ok = await showEasyLoading(() => ChaldeaServerApi.forgotPassword(email: _emailController.text));
    if (ok == true) {
      EasyLoading.showSuccess(S.current.success);
    }
    db.notifySettings();
  }

  Future<void> _submitDeviceVerify() async {
    if (!_isDeviceVerifyAvailable) {
      setState(() => _devTouched = true);
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
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      appBar: ModernAppBar(title: S.current.auth_forgot_password_title),
      children: [
        ModernInfoBanner(variant: ModernInfoBannerVariant.info, text: S.current.auth_forgot_password_hint),
        const SizedBox(height: 16),
        _buildEmailResetCard(),
        const SizedBox(height: 16),
        _buildDeviceVerifyCard(),
        const SizedBox(height: 16),
        _buildContactDeveloperCard(),
      ],
    );
  }

  Widget _buildEmailResetCard() {
    return _MethodCard(
      primary: true,
      icon: Icons.email_outlined,
      title: S.current.auth_method_email_reset_title,
      desc: S.current.auth_method_email_reset_desc,
      children: [
        ModernInput(
          placeholder: S.current.email,
          controller: _emailController,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailTouched ? validateEmail(_emailController.text) : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        ModernPrimaryButton(
          label: S.current.auth_send_reset_email,
          onPressed: _isEmailResetAvailable ? _sendResetEmail : null,
        ),
      ],
    );
  }

  Widget _buildDeviceVerifyCard() {
    return _MethodCard(
      icon: Icons.smartphone_outlined,
      title: S.current.auth_method_device_verify_title,
      desc: S.current.auth_method_device_verify_desc,
      children: [
        ModernInput(
          placeholder: S.current.login_username,
          icon: Icons.person_outline,
          controller: _usernameController,
          autocorrect: false,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        ModernInput(
          placeholder: S.current.auth_device_id,
          icon: Icons.devices_outlined,
          controller: _deviceIdController,
          autocorrect: false,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        ModernInput(
          placeholder: S.current.auth_new_email,
          icon: Icons.email_outlined,
          controller: _newEmailController,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          errorText: _devTouched && _newEmailController.text.isNotEmpty
              ? validateEmail(_newEmailController.text)
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        ModernPrimaryButton(
          label: S.current.auth_submit_verification,
          onPressed: _isDeviceVerifyAvailable ? _submitDeviceVerify : null,
        ),
      ],
    );
  }

  Widget _buildContactDeveloperCard() {
    return _MethodCard(
      icon: Icons.support_agent_outlined,
      title: S.current.auth_method_contact_developer_title,
      desc: S.current.auth_method_contact_developer_desc,
      children: [
        ModernSecondaryButton(
          label: S.current.auth_contact_developer_btn,
          onPressed: () => router.push(child: FeedbackPage()),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: primary ? cs.primary : cs.outlineVariant, width: primary ? 4 : 1),
          top: BorderSide(color: cs.outlineVariant, width: 1),
          right: BorderSide(color: cs.outlineVariant, width: 1),
          bottom: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        boxShadow: [BoxShadow(color: cs.shadow.withAlpha(10), offset: const Offset(0, 1), blurRadius: 2)],
      ),
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
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
