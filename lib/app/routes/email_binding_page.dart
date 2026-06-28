import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';

/// Skippable email binding page.
///
/// Reuses the existing `/users/me/change-email` and `/users/me/verify-email`
/// endpoints. The user can navigate back at any time without completing the
/// binding — the server does not enforce email binding.
class EmailBindingPage extends StatefulWidget {
  const EmailBindingPage({super.key});

  @override
  State<EmailBindingPage> createState() => _EmailBindingPageState();
}

class _EmailBindingPageState extends State<EmailBindingPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String _l(final String zh, final String en) => Language.isZH ? zh : en;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      EasyLoading.showError(_l('请输入有效邮箱', 'Please enter a valid email'));
      return;
    }
    setState(() => _busy = true);
    try {
      final ok = await ChaldeaServerApi.changeEmail(newEmail: email);
      if (ok == true) {
        setState(() => _codeSent = true);
        EasyLoading.showSuccess(_l('验证码已发送', 'Verification code sent'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      EasyLoading.showError(_l('请输入验证码', 'Please enter the verification code'));
      return;
    }
    setState(() => _busy = true);
    try {
      final ok = await ChaldeaServerApi.verifyEmail(newEmail: email, code: code);
      if (ok == true) {
        // Update the local cached user so subsequent UI reflects the new email.
        final user = db.settings.secrets.user;
        if (user != null) {
          user.email = email;
          await db.saveSettings();
        }
        EasyLoading.showSuccess(_l('邮箱绑定成功', 'Email bound successfully'));
        if (mounted) Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_l('绑定邮箱', 'Bind Email'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _l('绑定邮箱后可通过邮箱找回密码，并接收重要通知。', 'Binding an email enables password recovery and important notifications.'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: _l('邮箱', 'Email'),
                border: const OutlineInputBorder(),
                enabled: !_codeSent,
              ),
            ),
            const SizedBox(height: 16),
            if (!_codeSent)
              FilledButton(onPressed: _busy ? null : _sendCode, child: Text(_l('发送验证码', 'Send Code')))
            else ...[
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _l('验证码', 'Verification Code'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () {
                            setState(() {
                              _codeSent = false;
                              _codeController.clear();
                            });
                          },
                    child: Text(_l('更换邮箱', 'Change Email')),
                  ),
                  FilledButton(onPressed: _busy ? null : _confirm, child: Text(_l('确认', 'Confirm'))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
