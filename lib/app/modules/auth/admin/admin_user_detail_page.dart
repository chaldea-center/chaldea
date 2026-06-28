// AdminUserDetailPage: read-only user detail + 2 admin actions.
// Sections: ModernProfileCard (admin sees full email, no masking) + 基本信息
// (info-rows: name/id/email/role+badge/createdAt/isOnline) + 统计
// (info-rows: backupsCount/teamsCount/sessions list/logins list — last two
// read-only lists) + 管理操作 with exactly 2 ActionRows: 重置密码
// (confirm dialog → adminRecoverUser(password:)) and 发送恢复邮件
// (confirm → adminRecoverUser(email:)). No other action-rows per design D6.

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class AdminUserDetailPage extends StatefulWidget {
  final int userId;
  const AdminUserDetailPage({super.key, required this.userId});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  AdminUserDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ChaldeaServerApi.adminGetUserDetail(widget.userId);
      _detail = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final confirmed = await SimpleConfirmDialog(
      title: Text(S.current.auth_admin_reset_password_confirm),
      content: Text(S.current.auth_admin_reset_password_prompt),
      confirmText: S.current.confirm,
    ).showDialog(context);
    if (confirmed != true) return;
    final resp = await showEasyLoading(
      () => ChaldeaServerApi.adminRecoverUser(userId: widget.userId, password: 'temporary'),
    );
    if (resp != null) {
      EasyLoading.showSuccess(resp.messageZh.isNotEmpty ? resp.messageZh : resp.message);
    }
    db.notifySettings();
  }

  Future<void> _sendRecoveryEmail() async {
    final email = _detail?.user.email;
    if (email == null || email.isEmpty) {
      EasyLoading.showError(S.current.auth_admin_no_email);
      return;
    }
    final confirmed = await SimpleConfirmDialog(
      title: Text(S.current.auth_admin_send_recovery_confirm),
      content: Text('${S.current.auth_admin_send_recovery}: $email'),
      confirmText: S.current.confirm,
    ).showDialog(context);
    if (confirmed != true) return;
    final resp = await showEasyLoading(() => ChaldeaServerApi.adminRecoverUser(userId: widget.userId, email: email));
    if (resp != null) {
      EasyLoading.showSuccess(resp.messageZh.isNotEmpty ? resp.messageZh : resp.message);
    }
    db.notifySettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ModernScaffold(
        appBar: ModernAppBar(title: S.current.auth_admin_user_detail_title),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _detail == null) {
      return ModernScaffold(
        appBar: ModernAppBar(title: S.current.auth_admin_user_detail_title),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: Text(S.current.auth_admin_load_more)),
            ],
          ),
        ),
      );
    }
    final d = _detail!;
    final user = d.user;
    return ModernScaffold(
      appBar: ModernAppBar(title: S.current.auth_admin_user_detail_title),
      children: [
        ModernProfileCard(title: user.name, subtitle: '${S.current.auth_user_id}: ${user.id}'),
        _buildBasicInfo(d, user),
        _buildStatistics(d),
        _buildAdminActions(),
      ],
    );
  }

  Widget _buildBasicInfo(AdminUserDetail d, ChaldeaUser user) {
    final created = user.createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(user.createdAt! * 1000).toDateString()
        : '-';
    return ModernSectionCard(
      title: S.current.auth_admin_basic_info,
      children: [
        ModernInfoRow(icon: Icons.person_outline, label: S.current.login_username, value: user.name),
        ModernInfoRow(icon: Icons.tag, label: S.current.auth_user_id, value: user.id.toString(), valueMono: true),
        ModernInfoRow(
          icon: Icons.email_outlined,
          label: S.current.auth_email_field,
          value: (user.email == null || user.email!.isEmpty) ? S.current.auth_admin_no_email : user.email!,
        ),
        ModernInfoRow(
          icon: Icons.shield_outlined,
          label: S.current.auth_role,
          valueWidget: user.isAdmin ? ModernBadge(label: S.current.auth_role_admin) : null,
        ),
        ModernInfoRow(icon: Icons.calendar_today_outlined, label: S.current.auth_admin_created_at, value: created),
        ModernInfoRow(
          icon: Icons.circle,
          label: S.current.auth_admin_online_status,
          value: user.role == ChaldeaUserRole.admin ? S.current.auth_admin_online : S.current.auth_admin_offline,
        ),
      ],
    );
  }

  Widget _buildStatistics(AdminUserDetail d) {
    return ModernSectionCard(
      title: S.current.auth_admin_statistics,
      children: [
        ModernInfoRow(
          icon: Icons.cloud_upload_outlined,
          label: S.current.auth_admin_backups_count,
          value: d.backupsCount.toString(),
          valueMono: true,
        ),
        ModernInfoRow(
          icon: Icons.groups_outlined,
          label: S.current.auth_admin_teams_count,
          value: d.teamsCount.toString(),
          valueMono: true,
        ),
        ModernInfoRow(
          icon: Icons.devices_outlined,
          label: S.current.auth_admin_sessions,
          value: '${d.sessions.length}',
          valueMono: true,
        ),
        ModernInfoRow(
          icon: Icons.history_outlined,
          label: S.current.auth_admin_recent_logins,
          value: '${d.logins.length}',
          valueMono: true,
        ),
      ],
    );
  }

  Widget _buildAdminActions() {
    return ModernSectionCard(
      title: S.current.auth_admin_actions,
      children: [
        ModernActionRow(icon: Icons.lock_reset_outlined, label: S.current.auth_admin_reset_password, onTap: _resetPassword),
        ModernActionRow(icon: Icons.email_outlined, label: S.current.auth_admin_send_recovery, onTap: _sendRecoveryEmail),
      ],
    );
  }
}
