import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/userdata/local_settings.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/modern/modern.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../common/web_page.dart';

class PrivacyPermissionsPage extends StatefulWidget {
  const PrivacyPermissionsPage({super.key});

  @override
  State<PrivacyPermissionsPage> createState() => _PrivacyPermissionsPageState();
}

class _PrivacyPermissionsPageState extends State<PrivacyPermissionsPage> {
  late final Future<PrivacyPermissionCatalog> _catalog = _loadCatalog();
  PrivacyPermissionTarget? _previewTarget;

  String get _currentPlatform => PlatformU.isWeb ? 'web' : PlatformU.operatingSystem;

  bool _matchesCurrentDevice(PrivacyPermissionTarget target) =>
      target.platform == _currentPlatform && target.flavor == appFlavor;

  Future<PrivacyPermissionCatalog> _loadCatalog() async {
    final catalog = PrivacyPermissionCatalog.decode(await rootBundle.loadString(PrivacyPermissionCatalog.assetPath));
    if (kDebugMode) {
      // Debug packages preview release declarations without requiring a matching package identity.
      final matches = catalog.targets.where(_matchesCurrentDevice).toList();
      if (matches.length == 1) _previewTarget = matches.single;
    }
    return catalog;
  }

  PrivacyPermissionTarget? _currentTarget(PrivacyPermissionCatalog catalog) {
    return catalog.select(
      platform: _currentPlatform,
      flavor: PlatformU.isAndroid ? appFlavor : null,
      applicationId: AppInfo.packageName,
      versionName: AppInfo.versionString,
      buildNumber: AppInfo.buildNumber.toString(),
    );
  }

  Future<void> _openSettings() async {
    bool opened = false;
    try {
      opened = await permissions.openAppSettings();
    } catch (_) {
      // Some devices cannot resolve the application settings activity.
    }
    if (!opened && mounted) EasyLoading.showError(S.current.privacy_open_settings_failed);
  }

  String _title(PrivacyPermissionGroup group) => switch (group) {
    .network => S.current.privacy_permission_network,
    .files => S.current.privacy_permission_files,
    .photos => S.current.save_to_photos,
    .phone => S.current.privacy_permission_phone,
    .notifications => S.current.privacy_permission_notifications,
    .install => '${S.current.install} APK/XAPK',
    .advertising => S.current.privacy_permission_ad_identifiers,
    .other => S.current.privacy_permission_other,
  };

  String? _description(PrivacyPermissionGroup group) => switch (group) {
    .network => S.current.privacy_permission_network_desc,
    .files => S.current.privacy_permission_files_desc,
    .phone => S.current.privacy_permission_phone_desc,
    .notifications => S.current.privacy_permission_notifications_desc,
    .advertising => S.current.privacy_permission_ad_identifiers_desc,
    .other => S.current.privacy_permission_other_desc,
    .photos || .install => null,
  };

  Widget _buildDebugGroup(PrivacyPermissionCatalog catalog, PrivacyPermissionTarget? target) {
    final previewPlatform = _previewTarget?.platform ?? _currentPlatform;
    final platforms = catalog.targets.map((target) => target.platform).toSet();
    final flavors = <String?, PrivacyPermissionTarget>{};
    for (final target in catalog.targets.where((target) => target.platform == previewPlatform)) {
      flavors.putIfAbsent(target.flavor, () => target);
    }
    final hasFlavors = flavors.keys.any((flavor) => flavor?.isNotEmpty == true);
    // Both dropdowns carry an explicit "Current device" item so the selection is
    // never null and the card shows a real option instead of a placeholder hint.
    final selectedFlavor = _previewTarget == null ? null : flavors[_previewTarget!.flavor];
    return TileGroup(
      header: 'Debug preview',
      children: [
        ValueCardRow(
          cards: [
            ValueCard<({String? platform})>(
              label: 'platform',
              optionValue: (platform: _previewTarget?.platform),
              options: [(platform: null), for (final platform in platforms) (platform: platform)],
              optionLabel: (option) => option.platform == null
                  ? 'Current device'
                  : '${option.platform}${option.platform == _currentPlatform ? ' *' : ''}',
              onSelected: (option) => setState(() {
                final platform = option.platform;
                if (platform == null) {
                  _previewTarget = null;
                  return;
                }
                final targets = catalog.targets.where((target) => target.platform == platform).toList();
                _previewTarget = targets.firstWhereOrNull(_matchesCurrentDevice) ?? targets.first;
              }),
            ),
            ValueCard<({PrivacyPermissionTarget? target})>(
              label: 'flavor',
              value: hasFlavors ? null : '—',
              optionValue: (target: hasFlavors ? selectedFlavor : null),
              options: hasFlavors ? [(target: null), for (final target in flavors.values) (target: target)] : const [],
              optionLabel: (option) => option.target == null
                  ? 'Current device'
                  : '${option.target!.flavor ?? 'Default'}${_matchesCurrentDevice(option.target!) ? ' *' : ''}',
              onSelected: hasFlavors ? (option) => setState(() => _previewTarget = option.target) : null,
            ),
          ],
        ),
        if (target != null)
          InfoRow(
            title: 'status: ${target.status}',
            subtitle:
                'applicationId: ${target.applicationId ?? '—'}\n'
                'version: ${target.versionName ?? '—'}+${target.buildNumber ?? '—'}',
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.privacy_permissions)),
      body: FutureBuilder<PrivacyPermissionCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final catalog = snapshot.data;
          final preview = kDebugMode ? _previewTarget : null;
          final target = preview ?? (catalog == null ? null : _currentTarget(catalog));
          final groups = target?.groups ?? {};
          return SelectionArea(
            child: ListView(
              children: [
                if (kDebugMode && catalog != null) _buildDebugGroup(catalog, target),
                Padding(padding: const EdgeInsets.all(16), child: Text(S.current.privacy_permissions_intro)),
                if (target == null || target.status != 'inspected')
                  InfoRow(title: S.current.privacy_permissions_unverified),
                for (final group in PrivacyPermissionGroup.values)
                  if (groups[group]?.isNotEmpty == true)
                    TileGroup(
                      children: [
                        ExpansionTile(
                          key: ValueKey((target?.platform, target?.flavor, group)),
                          title: Text(_title(group)),
                          subtitle: _description(group) == null ? null : Text(_description(group)!),
                          children: [
                            for (final declaration in groups[group]!)
                              InfoRow(title: declaration.name, subtitle: declaration.details),
                          ],
                        ),
                      ],
                    ),
                TileGroup(
                  children: [
                    if (PlatformU.isMobile && (preview == null || _matchesCurrentDevice(preview)))
                      ActionRow(
                        leading: const Icon(Icons.settings_outlined),
                        title: S.current.open_settings,
                        onTap: _openSettings,
                      ),
                    ActionRow(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: S.current.privacy_policy,
                      onTap: () => openInAppWebView(
                        context,
                        Uri.parse(ChaldeaUrl.doc('/privacy')).replace(fragment: 'system-permissions').toString(),
                        title: S.current.privacy_policy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
