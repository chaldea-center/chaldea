// ChangePasswordPage: change the user's password.
// Per design.md D-change-password: the API returns a fresh accessToken, so
// the session stays valid (NO auto-logout). The design's footer hint
// "密码修改成功后将自动退出登录" is intentionally omitted.

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
  bool _touched = false;
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

  String? get _currentError => _touched ? validatePassword(_currentController.text) : null;

  String? get _newError {
    if (!_touched) return null;
    return validateNewPassword(_newController.text, oldPwd: _currentController.text);
  }

  String? get _confirmError {
    if (!_touched) return null;
    final newPwd = _newController.text;
    final confirm = _confirmController.text;
    if (confirm.isEmpty) return null;
    if (confirm != newPwd) return S.current.login_password_error_same_as_old;
    return null;
  }

  bool get _isAvailable {
    final cur = _currentController.text;
    final newPwd = _newController.text;
    final confirm = _confirmController.text;
    return cur.isNotEmpty &&
        validatePassword(cur) == null &&
        validateNewPassword(newPwd, oldPwd: cur) == null &&
        confirm == newPwd;
  }

  Future<void> _submit() async {
    if (!_isAvailable) {
      setState(() => _touched = true);
      return;
    }
    final user = await showEasyLoading(
      () => ChaldeaServerApi.changePassword(currentPassword: _currentController.text, newPassword: _newController.text),
    );
    if (user != null) {
      secrets.user = user;
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      appBar: ModernAppBar(title: S.current.auth_change_password_title),
      children: [
        ModernInfoBanner(
          variant: ModernInfoBannerVariant.warning,
          text: S.current.auth_change_password_warning,
        ),
        const SizedBox(height: 16),
        ModernInput(
          label: S.current.auth_current_password,
          icon: Icons.lock_outline,
          placeholder: S.current.auth_current_password,
          controller: _currentController,
          obscure: _obscureCurrent,
          autocorrect: false,
          errorText: _currentError,
          onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        ModernInput(
          label: S.current.login_password,
          icon: Icons.lock_outline,
          placeholder: S.current.login_password,
          controller: _newController,
          obscure: _obscureNew,
          autocorrect: false,
          errorText: _newError,
          onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        ModernInput(
          label: S.current.login_confirm_password,
          icon: Icons.lock_outline,
          placeholder: S.current.login_confirm_password,
          controller: _confirmController,
          obscure: _obscureConfirm,
          autocorrect: false,
          errorText: _confirmError,
          onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        ModernPrimaryButton(label: S.current.auth_confirm_change, onPressed: _isAvailable ? _submit : null),
      ],
    );
  }
}
