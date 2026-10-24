import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/ads/ads.dart';
import 'package:chaldea/packages/analysis/analysis.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../auth/delete_account_page.dart';
import '../../common/web_page.dart';
import 'display_settings/ad_setting.dart';
import 'feedback_page.dart';

const kPrivacyContactEmail = kSupportTeamEmailAddress;

class PrivacyCenterPage extends StatefulWidget {
  const PrivacyCenterPage({super.key});

  @override
  State<PrivacyCenterPage> createState() => _PrivacyCenterPageState();
}

class _PrivacyCenterPageState extends State<PrivacyCenterPage> {
  PrivacySetting get privacy => db.settings.display.privacy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.privacy_center)),
      body: ListView(
        children: [
          TileGroup(
            header: S.current.privacy_policy,
            children: [
              ListTile(
                title: Text(S.current.privacy_policy),
                subtitle: Text('${S.current.privacy_policy_version}: v$kPrivacyPolicyVersion'),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () => openInAppWebView(context, ChaldeaUrl.doc('/privacy'), title: S.current.privacy_policy),
              ),
            ],
          ),
          TileGroup(
            header: S.current.privacy_data_switches,
            children: [
              if (!db.settings.remoteConfig.ad.forceNonPersonalized)
                SwitchListTile.adaptive(
                  value: AppAds.shouldPersonalizeAds,
                  title: Text(S.current.personalized_ads),
                  subtitle: Text(S.current.personalized_ads_desc),
                  onChanged: (v) {
                    setState(() => db.settings.display.ad.personalizedAds = v);
                    AppAds.onPersonalizedAdsChanged(v);
                  },
                ),
              ListTile(
                title: Text(S.current.ad),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () => router.push(child: const AdSettingPage()),
              ),
              SwitchListTile.adaptive(
                value: privacy.crashReportEnabled,
                title: Text(S.current.crash_report),
                subtitle: Text(S.current.crash_report_desc),
                onChanged: (v) => setState(() => privacy.crashReportEnabled = v),
              ),
              SwitchListTile.adaptive(
                value: privacy.analyticsEnabled,
                title: Text(S.current.product_analytics),
                subtitle: Text(S.current.product_analytics_desc),
                onChanged: _onAnalyticsChanged,
              ),
            ],
          ),
          TileGroup(
            header: S.current.privacy_your_rights,
            children: [
              if (kPrivacyConsentEnabled)
                !privacy.accepted
                    ? ListTile(
                        title: Text(S.current.consent_agree),
                        subtitle: Text(S.current.privacy_agree_desc),
                        onTap: _agreeNow,
                      )
                    : ListTile(
                        enabled: privacy.accepted,
                        title: Text(S.current.withdraw_consent),
                        subtitle: Text(S.current.withdraw_consent_desc),
                        onTap: _withdrawConsent,
                      ),
              ListTile(
                enabled: db.settings.secrets.isLoggedIn,
                title: Text(
                  S.current.auth_delete_account,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: db.settings.secrets.isLoggedIn ? null : Text(S.current.delete_account_login_required),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () => router.push(child: const DeleteAccountPage()),
              ),
              if (AppInfo.isDebugOn)
                ListTile(title: const Text('Reset Privacy & Ads'), onTap: () => resetPrivacyAndAdsForDebug(context)),
            ],
          ),
          TileGroup(
            header: S.current.privacy_contact,
            footer: S.current.privacy_contact_desc,
            children: [
              ListTile(
                title: Text(S.current.about_feedback),
                subtitle: Text(kPrivacyContactEmail),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () => router.pushPage(FeedbackPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onAnalyticsChanged(bool enabled) {
    setState(() => privacy.analyticsEnabled = enabled);
    if (!enabled) {
      AppAnalysis.instance.halt();
    } else if (privacy.consentSatisfied) {
      AppAnalysis.instance.initiate();
    }
  }

  void _agreeNow() {
    applyPrivacyConsent(true);
    AppAds.init();
    setState(() {});
  }

  Future<void> _withdrawConsent() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.withdraw_consent),
        content: Text(S.current.withdraw_consent_confirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(S.current.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(S.current.withdraw_consent)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    privacy.accepted = false;
    privacy.acceptedVersion = 0;
    AppAnalysis.instance.halt();
    setState(() {});
  }
}

Future<void> applyPrivacyConsent(bool agreed) async {
  final privacy = db.settings.display.privacy;
  privacy.consentAsked = true;
  if (agreed) {
    privacy.accepted = true;
    privacy.acceptedVersion = kPrivacyPolicyVersion;
    if (privacy.analyticsEnabled) AppAnalysis.instance.initiate();
  } else if (privacy.accepted) {
    privacy.accepted = false;
    privacy.acceptedVersion = 0;
    AppAnalysis.instance.halt();
  }
}

/// Debug-only: resets consent and ad prefs; restart to see the first-launch flow.
Future<void> resetPrivacyAndAdsForDebug(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset privacy & ads (debug)'),
      content: const Text('Clear consent and ad settings? The first-launch dialog will appear on the next app start.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(S.current.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(S.current.ok)),
      ],
    ),
  );
  if (ok != true) return;
  db.settings.display.privacy
    ..accepted = false
    ..acceptedVersion = 0
    ..consentAsked = false
    ..crashReportEnabled = true
    ..analyticsEnabled = true;
  db.settings.display.ad
    ..enabled = .defaults
    ..banner = .defaults
    ..appOpen = .defaults
    ..interstitial = .defaults
    ..personalizedAds = null
    ..attAuthorized = null
    ..lastAttRequestTime = 0
    ..lastAppOpen = 0;
  AppAnalysis.instance.halt();
  AppAds.resetInitState();
  await db.saveSettings();
  EasyLoading.showInfo('Privacy & ads reset. Restart the app to see the first-launch dialog.');
}

/// First-launch consent dialog: two explicit actions, not barrier-dismissible.
/// [isUpdate] switches to the re-consent copy (policy version changed).
class PrivacyConsentDialog extends StatelessWidget {
  final bool isUpdate;

  const PrivacyConsentDialog({super.key, required this.isUpdate});

  static Future<bool?> show(BuildContext context, {bool isUpdate = false}) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => PrivacyConsentDialog(isUpdate: isUpdate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isUpdate ? S.current.consent_update_title : S.current.consent_title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUpdate) Text(S.current.consent_update_body) else Text(S.current.consent_body_optional),
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () =>
                      openInAppWebView(context, ChaldeaUrl.doc('/privacy'), title: S.current.privacy_policy),
                  child: Text(S.current.consent_view_policy),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(S.current.consent_disagree)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(S.current.consent_agree)),
      ],
    );
  }
}
