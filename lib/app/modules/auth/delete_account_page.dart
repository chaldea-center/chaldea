// DeleteAccountPage: destructive action with explicit confirmation.
// Layout: danger banner (icon + title + warning) + consequences card
// (4 list items with X icons) + password input + destructive button +
// cancel link. On success: clear user, pop to root, push LoginPage.

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/auth/login_page.dart';
import 'package:chaldea/app/modules/auth/validators.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  late final TextEditingController _pwdController;
  bool _obscurePwd = true;
  bool _touched = false;
  final secrets = db.settings.secrets;

  @override
  void initState() {
    super.initState();
    _pwdController = TextEditingController();
  }

  @override
  void dispose() {
    _pwdController.dispose();
    super.dispose();
  }

  bool get _isAvailable => _pwdController.text.isNotEmpty && validatePassword(_pwdController.text) == null;

  Future<void> _delete() async {
    if (!_isAvailable) {
      setState(() => _touched = true);
      return;
    }
    final confirmed = await SimpleConfirmDialog(
      title: Text(S.current.auth_delete_account_confirm),
      content: Text(S.current.auth_delete_account_warning),
      confirmText: S.current.delete,
    ).showDialog(context);
    if (confirmed != true) return;
    final ok = await showEasyLoading(() => ChaldeaServerApi.deleteMe(password: _pwdController.text));
    if (ok == true) {
      secrets.user = null;
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      router.popAll();
      router.push(child: const LoginPage());
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ModernScaffold(
      appBar: ModernAppBar(title: S.current.auth_delete_account_title),
      children: [
        _buildDangerHeader(cs),
        const SizedBox(height: 16),
        _buildConsequencesCard(cs),
        const SizedBox(height: 16),
        ModernInput(
          label: S.current.auth_confirm_password_prompt,
          icon: Icons.lock_outline,
          placeholder: S.current.auth_confirm_password_prompt,
          controller: _pwdController,
          obscure: _obscurePwd,
          autocorrect: false,
          errorText: _touched ? validatePassword(_pwdController.text) : null,
          onToggleVisibility: () => setState(() => _obscurePwd = !_obscurePwd),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        ModernPrimaryButton(
          label: S.current.auth_delete_account_confirm,
          danger: true,
          onPressed: _isAvailable ? _delete : null,
        ),
        const SizedBox(height: 8),
        ModernTextButton(label: S.current.auth_cancel_back, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _buildDangerHeader(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cs.error.withAlpha(25), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded, size: 36, color: cs.error),
          const SizedBox(height: 8),
          Text(
            S.current.auth_delete_account_title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.error, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            S.current.auth_delete_account_warning,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildConsequencesCard(ColorScheme cs) {
    final items = [
      S.current.auth_delete_account_consequence_1,
      S.current.auth_delete_account_consequence_2,
      S.current.auth_delete_account_consequence_3,
      S.current.auth_delete_account_consequence_4,
    ];
    return ModernSectionCard(
      divided: false,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map(
                (text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.close, size: 18, color: cs.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          text,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
