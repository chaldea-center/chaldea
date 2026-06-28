// LoginPage: entry auth page reusing the shared modern widget library.
// Design deviation: keeps a back button (native AppBar auto-shows it when
// the route can pop) because in Chaldea auth pages are pushed from settings
// rather than being app entry points. Drops the design's "或" divider per
// design.md D2.

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
  bool _nameTouched = false;
  bool _pwdTouched = false;

  final secrets = db.settings.secrets;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: secrets.user?.name ?? '');
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
        _nameTouched = true;
        _pwdTouched = true;
      });
      return;
    }
    final user = await showEasyLoading(() => ChaldeaServerApi.login(username: name, password: pwd));
    if (user != null) {
      secrets.user = user;
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
              errorText: _nameTouched ? validateUsername(_nameController.text) : null,
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
              errorText: _pwdTouched ? validatePassword(_pwdController.text) : null,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
                tooltip: _obscurePwd ? 'Show' : 'Hide',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: S.current.auth_login_title, onPressed: _isLoginAvailable ? _doLogin : null),
            const SizedBox(height: 16),
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
}
