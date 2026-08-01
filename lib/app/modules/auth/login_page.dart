import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/auth/forgot_password_page.dart';
import 'package:chaldea/app/modules/auth/profile_page.dart';
import 'package:chaldea/app/modules/auth/register_page.dart';
import 'package:chaldea/app/modules/auth/validators.dart';
import 'package:chaldea/app/modules/auth/widgets/brand_area.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _pwdController;
  bool _obscurePwd = true;
  // bool _nameTouched = false;
  // bool _pwdTouched = false;

  final secrets = db.settings.secrets;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: secrets.user.name);
    _pwdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  bool get _isLoginAvailable => isLoginAvailable(_nameController.text, _pwdController.text);

  Future<void> _doLogin() async {
    final name = _nameController.text;
    final pwd = _pwdController.text;
    if (!isLoginAvailable(name, pwd)) {
      setState(() {
        // _nameTouched = true;
        // _pwdTouched = true;
      });
      return;
    }
    final user = await showEasyLoading(() => ChaldeaServerApi.login(username: name, password: pwd));
    if (user != null) {
      secrets.user.updateFromLoginResponse(user);
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      Navigator.of(context).pop();
      router.push(child: const ProfilePage());
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.auth_login_title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            const SizedBox(height: 8),
            const BrandArea(),
            const SizedBox(height: 32),
            FormInput(
              label: S.current.auth_username_or_email,
              prefixIcon: Icons.person_outline,
              hint: S.current.auth_username_or_email,
              controller: _nameController,
              autocorrect: false,
              validator: validateLoginIdentifier,
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
              validator: (v) => validatePassword(v),
              errorDisplayMode: ErrorDisplayMode.onBlur,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
                tooltip: _obscurePwd ? S.current.show : S.current.hide,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: S.current.auth_login_title, onPressed: _isLoginAvailable ? _doLogin : null),
            const SizedBox(height: 16),
            if (secrets.user.accessToken?.isNotEmpty != true && secrets.user.secret?.isNotEmpty == true) ...[
              PrimaryButton(label: S.current.auth_migrate_account, onPressed: _migrateAccount),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => router.push(child: const ForgotPasswordPage()),
                  child: Text(S.current.auth_forgot_password_link),
                ),
                TextButton(
                  onPressed: () => router.push(child: const RegisterPage()),
                  child: Text(S.current.auth_register_account),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _migrateAccount() async {
    final user = secrets.user;
    final accessToken = user.accessToken ?? "", secret = user.secret ?? "";
    if (accessToken.isNotEmpty || secret.isEmpty) return;
    final confirm = await SimpleConfirmDialog(
      title: Text(S.current.auth_migrate_account),
      content: Text([user.name, 'ID: ${user.id}', 'secret: ${"*" * 6}'].join('\n')),
    ).showDialog(context);
    if (confirm != true) return;

    final user2 = await showEasyLoading(() => ChaldeaServerApi.migrateToken(secret: secret));
    if (user2 == null) {
      if (mounted) {
        SimpleConfirmDialog(title: Text(S.current.error), showCancel: false).showDialog(context);
      }
      return;
    }
    secrets.user.updateFromLoginResponse(user2);
    setState(() {});
    if (mounted) {
      Navigator.pop(context);
      router.showDialog(builder: (context) => SimpleConfirmDialog(title: Text(S.current.success), showCancel: false));
    }
    db.notifyAppUpdate();
  }
}
