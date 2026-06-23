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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.ad)),
      body: ListView(
        children: [
          // 广告总开关
          TileGroup(
            header: S.current.ad,
            footer: "Turn off to disable all ad features. The ad SDK will not be initialized when disabled.",
            children: [
              _buildStateTile(
                title: "Ads",
                remoteState: remoteAd.enabled,
                localState: setting.enabled,
                onLocalChanged: (state) {
                  setState(() => setting.enabled = state);
                },
              ),
            ],
          ),
          // 广告类型开关
          TileGroup(
            header: "Ad Types",
            footer: "Will try not to affect normal use as much as possible",
            children: [
              _buildStateTile(
                title: "Banner AD",
                subtitle: 'e.g. ${S.current.carousel}',
                remoteState: remoteAd.bannerEnabled,
                localState: setting.banner,
                onLocalChanged: (state) {
                  setState(() => setting.banner = state);
                },
              ),
              _buildStateTile(
                title: "App Open",
                subtitle: "Min interval: ${remoteAd.appOpenMinInterval ~/ 3600}h",
                remoteState: remoteAd.appOpenEnabled,
                localState: setting.appOpen,
                onLocalChanged: (state) {
                  setState(() => setting.appOpen = state);
                },
              ),
              _buildStateTile(
                title: "Interstitial AD",
                subtitle: "Interstitial ads between content",
                remoteState: remoteAd.interstitialEnabled,
                localState: setting.interstitial,
                onLocalChanged: (state) {
                  setState(() => setting.interstitial = state);
                },
              ),
            ],
          ),
          // 个性化广告
          TileGroup(
            header: "Personalization",
            footer: remoteAd.forceNonPersonalized
                ? "Server has forced non-personalized ads for compliance."
                : "When disabled, only non-personalized (contextual) ads will be shown. "
                      "Your advertising identifier will not be used for ad targeting.",
            children: [
              SwitchListTile.adaptive(
                value: AppAds.shouldPersonalizeAds,
                title: const Text("Personalized Ads"),
                subtitle: Text(
                  remoteAd.forceNonPersonalized ? "Forced off by server" : "Allow ads based on your interests",
                ),
                onChanged: remoteAd.forceNonPersonalized
                    ? null
                    : (v) {
                        setState(() {
                          setting.personalizedAds = v;
                        });
                        AppAds.onPersonalizedAdsChanged(v);
                      },
              ),
            ],
          ),
          // 隐私与权限
          TileGroup(
            header: "Privacy & Permissions",
            footer: "If there is any inappropriate ad, please send feedback with info like screenshot/country/time.",
            children: [
              if (AppAds.instance.supported && PlatformU.isIOS)
                ListTile(
                  title: const Text("Ad Tracking (iOS)"),
                  subtitle: Text(_attStatusText),
                  trailing: _attAuthorized == null
                      ? FilledButton(onPressed: _requestAtt, child: const Text("Authorize"))
                      : null,
                ),
              ListTile(
                title: const Text("Privacy Policy"),
                subtitle: const Text("View ad-related privacy information"),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () => _showPrivacyInfo(context),
              ),
              ListTile(
                title: Text(S.current.about_feedback),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () => router.pushPage(FeedbackPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建广告状态选择Tile
  /// 支持三态切换：defaults / on / off
  /// 远程配置的 forcedOn/off 会在subtitle中提示
  Widget _buildStateTile({
    required String title,
    String? subtitle,
    required AdFeatureState remoteState,
    required AdFeatureState localState,
    required ValueChanged<AdFeatureState> onLocalChanged,
  }) {
    // 远程强制状态时，本地设置不可更改
    final isRemoteForced = remoteState.isForced || remoteState == AdFeatureState.off;

    // 计算最终生效状态
    final effectiveEnabled = AdFeatureDecision.shouldEnable(remoteState, localState);

    // 构建subtitle
    String stateHint;
    if (remoteState.isForced) {
      stateHint = "Server: forced on";
    } else if (remoteState == AdFeatureState.off) {
      stateHint = "Server: disabled";
    } else if (localState.isDefault) {
      stateHint = "Default";
    } else if (localState == AdFeatureState.on) {
      stateHint = "User: enabled";
    } else {
      stateHint = "User: disabled";
    }

    return SwitchListTile.adaptive(
      value: effectiveEnabled,
      title: Text(title),
      subtitle: Text(subtitle != null ? '$subtitle · $stateHint' : stateHint),
      onChanged: isRemoteForced
          ? null
          : (v) {
              onLocalChanged(v ? AdFeatureState.on : AdFeatureState.off);
            },
    );
  }

  bool? get _attAuthorized => setting.attAuthorized;

  String get _attStatusText {
    if (_attAuthorized == null) {
      return "Not yet requested";
    } else if (_attAuthorized == true) {
      return "Authorized";
    } else {
      return "Denied - Only non-personalized ads will be shown";
    }
  }

  Future<void> _requestAtt() async {
    final result = await AppAds.requestAttPermission();
    if (mounted) setState(() {});
    if (!mounted) return;
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tracking authorized")));
    } else if (result == false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Denied - Only non-personalized ads will be shown")));
    }
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ad SDK Information", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("SDK: GroMore Ad SDK (by ByteDance)"),
              Text("Provider: Beijing Juliang Engine Network Technology Co., Ltd."),
              SizedBox(height: 12),
              Text("Data Collected", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("• Device info: brand, model, OS version"),
              Text("• Device identifier: OAID/IDFA/GAID"),
              Text("• Network info: type, carrier"),
              Text("• App info: package name, version"),
              SizedBox(height: 12),
              Text("Purpose", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("• Ad delivery and targeting"),
              Text("• Ad effectiveness measurement"),
              Text("• Fraud prevention"),
              SizedBox(height: 12),
              Text("Your Rights", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("• Opt out of personalized ads"),
              Text("• Disable all ads in settings"),
              Text("• Revoke tracking permission in system settings"),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(S.current.ok))],
      ),
    );
  }
}
