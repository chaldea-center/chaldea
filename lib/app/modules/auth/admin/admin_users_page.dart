// AdminUsersPage: admin-only paginated list of users with search.
// Pulls `adminSearchUsers(search:, limit: 20, offset: N)` and renders each
// row as an AdminUserListTile (avatar + name + id + masked email + role
// badge + online dot + createdAt). Tap → push AdminUserDetailPage(userId).
// "Load more" affordance at list end when `hasNextPage` is true.
// Uses Scaffold(body:) because the page has a sticky search bar + a
// scrollable list (Expanded) — not a simple flat ListView.

import 'package:flutter/material.dart';

import 'package:chaldea/app/api/chaldea_server.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/auth/admin/admin_user_detail_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/modern.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AdminUserListItem> _users = [];
  int _offset = 0;
  int? _total;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  String _activeSearch = '';

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _users.clear();
        _offset = 0;
        _hasMore = true;
        _activeSearch = _searchController.text.trim();
      }
    });
    try {
      final result = _activeSearch.isEmpty
          ? null
          : await ChaldeaServerApi.adminSearchUsers(search: _activeSearch, limit: 20, offset: _offset);
      if (result != null) {
        _users.addAll(result.data);
        _offset = result.offset + result.data.length;
        _total = result.total;
        _hasMore = result.hasNextPage;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onSearch() async {
    await _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.auth_admin_users_title)),
      body: SafeArea(
        top: false, // AppBar already handles top safe area
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormInput(
                      hint: S.current.auth_search_users,
                      prefixIcon: Icons.search,
                      controller: _searchController,
                      autocorrect: false,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PrimaryButton(label: S.current.auth_search_users, onPressed: _loading ? null : _onSearch),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
            TextButton(onPressed: () => _load(reset: true), child: Text(S.current.auth_admin_load_more)),
          ],
        ),
      );
    }
    if (_loading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_users.isEmpty) {
      return Center(child: Text(S.current.auth_admin_no_email, style: Theme.of(context).textTheme.bodyMedium));
    }
    return ListView(
      controller: _scrollController,
      children: [
        SectionCard(divided: true, children: _users.map(_buildTile).toList()),
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: TextButton(
                onPressed: _loading ? null : () => _load(),
                child: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(S.current.auth_admin_load_more),
              ),
            ),
          ),
        if (_total != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: Text(
                '${_users.length} / $_total',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTile(AdminUserListItem user) {
    final cs = Theme.of(context).colorScheme;
    final emailText = (user.email == null || user.email!.isEmpty)
        ? S.current.auth_admin_no_email
        : _maskEmail(user.email!);
    final created = DateTime.fromMillisecondsSinceEpoch(user.createdAt * 1000);
    return InkWell(
      onTap: () => router.push(child: AdminUserDetailPage(userId: user.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary.withAlpha(30)),
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user.isOnline ? Colors.green : cs.outline,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (user.role == ChaldeaUserRole.admin) Chip(label: Text(S.current.auth_role_admin)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${user.id} · $emailText',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${S.current.auth_admin_created_at}: ${created.toDateString()}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant.withAlpha(180), fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return email;
    final local = email.substring(0, at);
    final domain = email.substring(at);
    final first = local.isNotEmpty ? local[0] : '';
    return '$first***$domain';
  }
}
