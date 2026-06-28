// ProfilePage: hub for the logged-in user.
// Layout: ModernProfileCard + 个人信息 SectionCard + 账号操作 SectionCard
// + (if accessToken empty) 迁移账号 ActionRow
// + (if isAdmin) 管理工具 SectionCard with 用户管理.
// Logout pops back to settings; sub-pages push and refresh on pop.

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/auth/admin/admin_users_page.dart';
import 'package:chaldea/app/modules/auth/change_email_page.dart';
import 'package:chaldea/app/modules/auth/change_password_page.dart';
import 'package:chaldea/app/modules/auth/change_username_page.dart';
import 'package:chaldea/app/modules/auth/delete_account_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final secrets = db.settings.secrets;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final user = await ChaldeaServerApi.updateMe();
    if (user != null && mounted) {
      secrets.user = user;
      setState(() {});
    }
    db.notifySettings();
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final at = email.indexOf('@');
    if (at <= 0) return email;
    final domain = email.substring(at);
    final local = email.substring(0, at);
    final first = local.isNotEmpty ? local[0] : '';
    return '$first***$domain';
  }

  Future<void> _logout() async {
    final confirmed = await SimpleConfirmDialog(
      title: Text(S.current.auth_logout),
      content: Text(S.current.auth_logout),
      confirmText: S.current.confirm,
    ).showDialog(context);
    if (confirmed != true) return;
    final ok = await showEasyLoading(() => ChaldeaServerApi.logout());
    if (ok == true) {
      secrets.user = null;
      EasyLoading.showSuccess(S.current.success);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
    db.notifySettings();
  }

  Future<void> _migrateAccount() async {
    final secret =
        await InputCancelOkDialog(title: S.current.auth_migrate_account, hintText: 'secret').showDialog(context)
            as String?;
    if (secret == null || secret.isEmpty) return;
    final user = await showEasyLoading(() => ChaldeaServerApi.migrateToken(secret: secret));
    if (user != null) {
      secrets.user = user;
      EasyLoading.showSuccess(S.current.auth_migration_success);
      setState(() {});
    } else {
      EasyLoading.showError(S.current.auth_migration_failed);
    }
    db.notifySettings();
  }

  Future<void> _pushAndRefresh(Widget child) async {
    await router.push(child: child);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = secrets.user;
    final name = user?.name ?? '';
    final uid = user?.id.toString() ?? '';
    final email = user?.email ?? '';
    final accessToken = user?.accessToken ?? '';
    final isAdmin = user?.isAdmin ?? false;

    return ModernScaffold(
      appBar: ModernAppBar(title: S.current.auth_profile_title),
      children: [
        ModernProfileCard(title: name, subtitle: '${S.current.auth_user_id}: $uid'),
        _buildPersonalInfoSection(name, uid, email, isAdmin),
        _buildAccountActionsSection(),
        if (accessToken.isEmpty) _buildMigrationSection(),
        if (isAdmin) _buildAdminSection(),
      ],
    );
  }

  Widget _buildPersonalInfoSection(String name, String uid, String email, bool isAdmin) {
    return ModernSectionCard(
      title: S.current.auth_personal_info,
      children: [
        ModernInfoRow(
          icon: Icons.person_outline,
          label: S.current.login_username,
          value: name,
          onTap: () => _pushAndRefresh(const ChangeUsernamePage()),
        ),
        ModernInfoRow(icon: Icons.tag, label: S.current.auth_user_id, value: uid, valueMono: true),
        ModernInfoRow(
          icon: Icons.email_outlined,
          label: S.current.auth_email_field,
          value: email.isEmpty ? S.current.auth_admin_no_email : _maskEmail(email),
          onTap: () => _pushAndRefresh(const ChangeEmailPage()),
        ),
        ModernInfoRow(
          icon: Icons.shield_outlined,
          label: S.current.auth_role,
          valueWidget: isAdmin ? ModernBadge(label: S.current.auth_role_admin) : null,
        ),
      ],
    );
  }

  Widget _buildAccountActionsSection() {
    return ModernSectionCard(
      title: S.current.auth_account_actions,
      children: [
        ModernActionRow(
          icon: Icons.lock_outline,
          label: S.current.auth_change_password,
          onTap: () => _pushAndRefresh(const ChangePasswordPage()),
        ),
        ModernActionRow(icon: Icons.logout, label: S.current.auth_logout, onTap: _logout),
        ModernActionRow(
          icon: Icons.delete_outline,
          label: S.current.auth_delete_account,
          variant: ModernActionRowVariant.error,
          onTap: () async {
            await router.push(child: const DeleteAccountPage());
            if (secrets.user == null && mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMigrationSection() {
    return ModernSectionCard(
      title: S.current.auth_migrate_account,
      divided: false,
      children: [
        ModernActionRow(icon: Icons.swap_horiz, label: S.current.auth_migrate_account, onTap: _migrateAccount),
      ],
    );
  }

  Widget _buildAdminSection() {
    return ModernSectionCard(
      title: S.current.auth_admin_tools,
      children: [
        ModernActionRow(
          icon: Icons.admin_panel_settings_outlined,
          label: S.current.auth_user_management,
          onTap: () => router.push(child: const AdminUsersPage()),
        ),
      ],
    );
  }
}
