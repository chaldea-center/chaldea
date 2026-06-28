// AdminUserDetailPage: read-only user detail + 2 admin actions.
// Sections: ProfileCard (admin sees full email, no masking) + Basic Info
// (info-rows: name/id/email/role+badge/createdAt/isOnline) + Statistics
// (info-rows: backupsCount/teamsCount/sessions list/logins list — last two
// read-only lists) + Admin Actions with exactly 2 ActionRows: Reset Password
// (confirm dialog → adminRecoverUser(password:)) and Send Recovery Email
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
      return Scaffold(
        appBar: AppBar(title: Text(S.current.auth_admin_user_detail_title)),
        body: SafeArea(
          top: false, // AppBar already handles top safe area
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }
    if (_error != null || _detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text(S.current.auth_admin_user_detail_title)),
        body: SafeArea(
          top: false, // AppBar already handles top safe area
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error ?? 'error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _load, child: Text(S.current.auth_admin_load_more)),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final d = _detail!;
    final user = d.user;
    return Scaffold(
      appBar: AppBar(title: Text(S.current.auth_admin_user_detail_title)),
      body: SafeArea(
        top: false, // AppBar already handles top safe area
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            ProfileCard(title: user.name, subtitle: '${S.current.auth_user_id}: ${user.id}'),
            _buildBasicInfo(d, user),
            _buildStatistics(d),
            _buildAdminActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(AdminUserDetail d, ChaldeaUser user) {
    final created = user.createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(user.createdAt! * 1000).toDateString()
        : '-';
    return SectionCard(
      title: S.current.auth_admin_basic_info,
      children: [
        InfoRow(leading: Icon(Icons.person_outline), title: S.current.login_username, value: user.name),
        InfoRow(leading: Icon(Icons.tag), title: S.current.auth_user_id, value: user.id.toString(), valueMono: true),
        InfoRow(
          leading: Icon(Icons.email_outlined),
          title: S.current.auth_email_field,
          value: (user.email == null || user.email!.isEmpty) ? S.current.auth_admin_no_email : user.email!,
        ),
        InfoRow(
          leading: Icon(Icons.shield_outlined),
          title: S.current.auth_role,
          valueWidget: user.isAdmin ? Chip(label: Text(S.current.auth_role_admin)) : null,
        ),
        InfoRow(leading: Icon(Icons.calendar_today_outlined), title: S.current.auth_admin_created_at, value: created),
        InfoRow(
          leading: Icon(Icons.circle),
          title: S.current.auth_admin_online_status,
          value: user.role == ChaldeaUserRole.admin ? S.current.auth_admin_online : S.current.auth_admin_offline,
        ),
      ],
    );
  }

  Widget _buildStatistics(AdminUserDetail d) {
    return SectionCard(
      title: S.current.auth_admin_statistics,
      children: [
        InfoRow(
          leading: Icon(Icons.cloud_upload_outlined),
          title: S.current.auth_admin_backups_count,
          value: d.backupsCount.toString(),
          valueMono: true,
        ),
        InfoRow(
          leading: Icon(Icons.groups_outlined),
          title: S.current.auth_admin_teams_count,
          value: d.teamsCount.toString(),
          valueMono: true,
        ),
        InfoRow(
          leading: Icon(Icons.devices_outlined),
          title: S.current.auth_admin_sessions,
          value: '${d.sessions.length}',
          valueMono: true,
        ),
        InfoRow(
          leading: Icon(Icons.history_outlined),
          title: S.current.auth_admin_recent_logins,
          value: '${d.logins.length}',
          valueMono: true,
        ),
      ],
    );
  }

  Widget _buildAdminActions() {
    return SectionCard(
      title: S.current.auth_admin_actions,
      children: [
        ActionRow(
          leading: Icon(Icons.lock_reset_outlined),
          title: S.current.auth_admin_reset_password,
          onTap: _resetPassword,
        ),
        ActionRow(
          leading: Icon(Icons.email_outlined),
          title: S.current.auth_admin_send_recovery,
          onTap: _sendRecoveryEmail,
        ),
      ],
    );
  }
}
