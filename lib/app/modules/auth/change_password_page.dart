// ChangePasswordPage: change the user's password.
// Per design.md D-change-password: the API returns a fresh accessToken, so
// the session stays valid (NO auto-logout). The design's footer hint
// "After password change, you will be automatically logged out" is intentionally omitted.

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/modules/auth/validators.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late final TextEditingController _currentController;
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  final secrets = db.settings.secrets;

  @override
  void initState() {
    super.initState();
    _currentController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isAvailable {
    final cur = _currentController.text;
    final newPwd = _newController.text;
    final confirm = _confirmController.text;
    return cur.isNotEmpty &&
        validatePassword(cur) == null &&
        newPwd.isNotEmpty &&
        confirm == newPwd &&
        validateNewPassword(newPwd, oldPwd: cur) == null;
  }

  Future<void> _submit() async {
    if (!_isAvailable) {
      setState(() {});
      return;
    }
    final user = await showEasyLoading(
      () => ChaldeaServerApi.changePassword(currentPassword: _currentController.text, newPassword: _newController.text),
    );
    if (user != null) {
      secrets.user.updateFromLoginResponse(user);
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.auth_change_password_title)),
      body: SafeArea(
        top: false, // AppBar already handles top safe area
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            InfoBanner(variant: InfoBannerVariant.warning, text: S.current.auth_change_password_warning),
            const SizedBox(height: 16),
            FormInput(
              label: S.current.auth_current_password,
              prefixIcon: Icons.lock_outline,
              hint: S.current.auth_current_password,
              controller: _currentController,
              obscure: _obscureCurrent,
              autocorrect: false,
              validator: validatePassword,
              errorDisplayMode: ErrorDisplayMode.onBlur,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                tooltip: _obscureCurrent ? 'Show' : 'Hide',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            FormInput(
              label: S.current.login_password,
              prefixIcon: Icons.lock_outline,
              hint: S.current.login_password,
              controller: _newController,
              obscure: _obscureNew,
              autocorrect: false,
              validator: (v) => validateNewPassword(v, oldPwd: _currentController.text),
              errorDisplayMode: ErrorDisplayMode.onBlur,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                tooltip: _obscureNew ? 'Show' : 'Hide',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            FormInput(
              label: S.current.login_confirm_password,
              prefixIcon: Icons.lock_outline,
              hint: S.current.login_confirm_password,
              controller: _confirmController,
              obscure: _obscureConfirm,
              autocorrect: false,
              validator: (v) {
                if (v.isEmpty) return null;
                if (v != _newController.text) return S.current.login_password_error_confirm_mismatch;
                return null;
              },
              errorDisplayMode: ErrorDisplayMode.onBlur,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                tooltip: _obscureConfirm ? 'Show' : 'Hide',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: S.current.auth_confirm_change, onPressed: _isAvailable ? _submit : null),
          ],
        ),
      ),
    );
  }
}
