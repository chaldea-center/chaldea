// ChangeUsernamePage: form to update the user's display name.
// On success: secrets.user is updated (preserving accessToken) and the
// page pops; ProfilePage refreshes via its _pushAndRefresh await.
// The top of the page uses ValueHeader (large icon + label + current
// value) instead of the old InfoBanner to fill the empty space meaningfully.

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/modules/auth/validators.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({super.key});

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  late final TextEditingController _nameController;
  bool _touched = false;
  final secrets = db.settings.secrets;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _currentName => secrets.user?.name ?? '';

  String? get _errorText {
    final newName = _nameController.text;
    if (!_touched || newName.isEmpty) return null;
    return validateNewName(newName, oldName: _currentName);
  }

  bool get _isAvailable {
    final newName = _nameController.text;
    return newName.isNotEmpty && validateNewName(newName, oldName: _currentName) == null;
  }

  Future<void> _submit() async {
    final newName = _nameController.text;
    if (!_isAvailable) {
      setState(() => _touched = true);
      return;
    }
    final user = await showEasyLoading(() => ChaldeaServerApi.updateMe(name: newName));
    if (user != null) {
      final previous = secrets.user;
      if (previous != null && (user.accessToken == null || user.accessToken!.isEmpty)) {
        user.accessToken = previous.accessToken;
      }
      secrets.user = user;
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.auth_change_username_title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            ValueHeader(
              icon: Icons.person_outline,
              label: S.current.auth_current_username,
              value: _currentName.isEmpty ? '-' : _currentName,
            ),
            const SizedBox(height: 24),
            FormInput(
              label: S.current.auth_new_username,
              prefixIcon: Icons.person_outline,
              hint: S.current.auth_new_username,
              controller: _nameController,
              autocorrect: false,
              helperText: S.current.auth_username_helper,
              errorText: _errorText,
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
