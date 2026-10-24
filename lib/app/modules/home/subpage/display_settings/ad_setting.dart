import 'package:flutter/foundation.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/ads/ads.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/material.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../feedback_page.dart';

class AdSettingPage extends StatefulWidget {
  const AdSettingPage({super.key});

  @override
  State<AdSettingPage> createState() => _AdSettingPageState();
}

class _AdSettingPageState extends State<AdSettingPage> {
  AdSetting get setting => db.settings.display.ad;
  AdConfig get remoteAd => db.settings.remoteConfig.ad;

  static bool _locked(AdFeatureState remote) => remote.isForced || remote == AdFeatureState.off;

  Widget _switchTile({
    required String title,
    required AdFeatureState remote,
    required AdFeatureState local,
    required ValueChanged<AdFeatureState> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: AdFeatureDecision.shouldEnable(remote, local, fallback: false),
      title: Text(title),
      onChanged: (v) => setState(() => onChanged(v ? AdFeatureState.on : AdFeatureState.off)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterLocked = _locked(remoteAd.enabled);
    final typeTiles = <Widget>[
      if (!_locked(remoteAd.bannerEnabled))
        _switchTile(
          title: S.current.ad_type_banner,
          remote: remoteAd.bannerEnabled,
          local: setting.banner,
          onChanged: (v) => setting.banner = v,
        ),
      if (!_locked(remoteAd.appOpenEnabled))
        _switchTile(
          title: S.current.ad_type_app_open,
          remote: remoteAd.appOpenEnabled,
          local: setting.appOpen,
          onChanged: (v) => setting.appOpen = v,
        ),
      if (!_locked(remoteAd.interstitialEnabled))
        _switchTile(
          title: S.current.ad_type_interstitial,
          remote: remoteAd.interstitialEnabled,
          local: setting.interstitial,
          onChanged: (v) => setting.interstitial = v,
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(S.current.ad)),
      body: ListView(
        children: [
          if (!masterLocked)
            TileGroup(
              header: S.current.ad,
              children: [
                _switchTile(
                  title: S.current.ad,
                  remote: remoteAd.enabled,
                  local: setting.enabled,
                  onChanged: (v) => setting.enabled = v,
                ),
              ],
            ),
          if (typeTiles.isNotEmpty) TileGroup(header: S.current.ad_types, children: typeTiles),
          TileGroup(
            header: S.current.privacy_and_feedback,
            children: [
              if (PlatformU.isIOS && AppAds.instance.supported) _buildAttTile(),
              ListTile(
                title: Text(S.current.report_inappropriate_ad),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () => router.pushPage(FeedbackPage()),
              ),
            ],
          ),
          if (kDebugMode) _buildDebugGroup(),
        ],
      ),
    );
  }

  Widget _buildAttTile() {
    final authorized = setting.attAuthorized;
    return ListTile(
      title: Text(S.current.ios_att_title),
      subtitle: Text(switch (authorized) {
        null => S.current.ios_att_not_requested,
        true => S.current.ios_att_authorized,
        false => S.current.ios_att_denied,
      }),
      trailing: authorized == null
          ? FilledButton(onPressed: _requestAtt, child: Text(S.current.ios_att_request))
          : null,
    );
  }

  Future<void> _requestAtt() async {
    final result = await AppAds.requestAttPermission();
    if (!mounted) return;
    setState(() {});
    final message = switch (result) {
      true => S.current.ios_att_authorized,
      false => S.current.ios_att_denied,
      null => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildDebugGroup() {
    final rows = remoteAd.toJson().entries.map((e) => '${e.key}=${e.value}');
    return TileGroup(
      header: 'Debug: remoteConfig.ad',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(rows.join('\n'), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
        ),
      ],
    );
  }
}
