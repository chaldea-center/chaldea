// ChangeEmailPage: 2-step email-binding flow.
// Step 1: enter new email → call `changeEmail` to send verification code.
// Step 2: enter code → call `verifyEmail` to confirm. On success, manually
// patch `secrets.user.email` (verifyEmail returns bool, not a fresh user)
// then pop; ProfilePage refreshes via its _pushAndRefresh await.
// The top uses ValueHeader (large icon + label + current email).

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/modules/auth/validators.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  int _step = 1;
  String _code = '';
  late final TextEditingController _emailController;
  final secrets = db.settings.secrets;

  // Resend cooldown: counts down from 60 after sending code.
  int _resendCountdown = 0;
  bool _resendTimerActive = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String get _currentEmail => secrets.user.email ?? '';

  bool get _isStep1Available {
    final email = _emailController.text;
    return email.isNotEmpty && validateEmail(email) == null && email != _currentEmail;
  }

  bool get _isStep2Available => _code.length == 6;

  Future<void> _sendCode() async {
    if (!_isStep1Available || _resendTimerActive) {
      setState(() {});
      return;
    }
    final ok = await showEasyLoading(() => ChaldeaServerApi.changeEmail(newEmail: _emailController.text));
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
    if (!_isStep2Available) return;
    final ok = await showEasyLoading(() => ChaldeaServerApi.verifyEmail(newEmail: _emailController.text, code: _code));
    if (ok == true) {
      // verifyEmail returns bool, not a fresh user — manually update info with new email
      final currentInfo = secrets.user.info;
      if (currentInfo != null) {
        secrets.user.updateFromUserInfo(
          UserInfo(
            id: currentInfo.id,
            name: currentInfo.name,
            email: _emailController.text,
            role: currentInfo.role,
            createdAt: currentInfo.createdAt,
          ),
        );
      }
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.auth_change_email_title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            ValueHeader(
              icon: Icons.email_outlined,
              label: S.current.auth_current_email,
              value: _currentEmail.isEmpty ? '-' : _currentEmail,
            ),
            const SizedBox(height: 16),
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
        label: S.current.auth_new_email,
        prefixIcon: Icons.email_outlined,
        hint: 'example@email.com',
        controller: _emailController,
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
        errorDisplayMode: ErrorDisplayMode.onBlur,
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
      PrimaryButton(label: S.current.auth_confirm_change, onPressed: _isStep2Available ? _verify : null),
      const SizedBox(height: 8),
      TextButton(
        onPressed: _isStep1Available && !_resendTimerActive ? _sendCode : null,
        child: Text(
          _resendTimerActive ? '${S.current.auth_resend_code} (${_resendCountdown}s)' : S.current.auth_resend_code,
        ),
      ),
    ];
  }
}
