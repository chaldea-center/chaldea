import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/saint_quartz/common.dart' show SaintLocalized;
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';

class LoginResultPage extends StatefulWidget {
  final FakerRuntime runtime;
  const LoginResultPage({super.key, required this.runtime});

  @override
  State<LoginResultPage> createState() => _LoginResultPageState();
}

class _LoginResultPageState extends State<LoginResultPage> {
  late final runtime = widget.runtime;
  late final loginResultData = widget.runtime.agent.data.loginResultData;

  Map<String, List<int>> itemNames = {};

  @override
  void initState() {
    super.initState();

    for (final item in db.gameData.items.values) {
      if (const [
        ItemType.chargeStone,
        ItemType.aniplexPlusChargeStone,
        ItemType.netmarbleChargeStone,
      ].contains(item.type)) {
        continue;
      }
      itemNames.putIfAbsent(item.name, () => []).add(item.id);
    }
    for (final svt in db.gameData.entities.values) {
      if (svt.classId == SvtClass.ALL.value) {
        itemNames.putIfAbsent(svt.name, () => []).add(svt.id);
      }
    }
    itemNames.removeWhere((k, v) => v.length != 1);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      for (final bonus in loginResultData.campaignBonus) buildCampaignBonusData(bonus),
      for (final bonus in loginResultData.totalLoginBonus) buildLoginBonusData(bonus, SaintLocalized.accLogin),
      for (final bonus in loginResultData.seqLoginBonus) buildLoginBonusData(bonus, SaintLocalized.continuousLogin),
      // for (final bonus in loginResultData.campaignDirectBonus) buildDirectBonusData(bonus),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Login Bonus'), actions: [runtime.buildMenuButton(context)]),
      body: ListView.separated(
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (_, _) => const Divider(),
        itemCount: children.length,
      ),
    );
  }
  // List<LoginBonusData> totalLoginBonus;
  // List<LoginBonusData> seqLoginBonus;
  // List<CampaignBonusData> campaignBonus;
  // List<Map<String, dynamic>> campaignDirectBonus;

  Widget buildCampaignBonusData(CampaignBonusData bonus) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          title: Text(bonus.name),
          subtitle: Text.rich(
            TextSpan(
              children: divideList([
                if (bonus.detail.isNotEmpty) TextSpan(text: bonus.detail),
                if (bonus.addDetail.isNotEmpty) TextSpan(text: bonus.addDetail),
                _buildKeyAndItems(bonus),
              ], const TextSpan(text: '\n')),
            ),
          ),
        ),
        _buildButtons(bonus),
      ],
    );
  }

  Widget buildLoginBonusData(LoginBonusData bonus, String prefix) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          title: Text.rich(TextSpan(text: '$prefix ', children: [_buildKeyAndItems(bonus)])),
          subtitle: bonus.message.isEmpty ? null : Text(bonus.message),
        ),
        _buildButtons(bonus),
      ],
    );
  }

  Widget buildDirectBonusData(Map bonus) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          subtitle: Text(bonus.toString()),
          onTap: () {
            router.pushPage(JsonViewerPage(bonus, defaultOpen: true));
          },
        ),
      ],
    );
  }

  InlineSpan _buildKeyAndItems(LoginBonusBase bonus) {
    return TextSpan(
      text: '${bonus.key} ',
      children: bonus.items.map((item) {
        final itemId = itemNames[item.name]?.single;
        return TextSpan(
          children: [
            itemId == null
                ? TextSpan(text: item.name)
                : CenterWidgetSpan(
                    child: Item.iconBuilder(context: context, item: null, itemId: itemId, width: 24),
                  ),
            TextSpan(text: '×${item.num} '),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildButtons(LoginBonusBase bonus) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        TextButton(
          onPressed: () {
            router.pushPage(JsonViewerPage(bonus.srcData, defaultOpen: true));
          },
          child: Text('JSON'),
        ),
        for (final (:bannerUrl, :urlLink) in bonus.getBanners(runtime.region))
          TextButton(
            onPressed: () {
              if (bannerUrl == null) {
                if (urlLink != null) {
                  jumpToExternalLinkAlert(url: urlLink);
                }
                return;
              }
              router.showDialog(
                builder: (context) => SimpleConfirmDialog(
                  title: Text(S.current.open),
                  scrollable: true,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      db.getIconImage(bannerUrl, placeholder: (context) => const CircularProgressIndicator()),
                      if (urlLink != null) Text.rich(SharedBuilder.textButtonSpan(context: context, text: urlLink)),
                    ],
                  ),
                  showOk: false,
                  actions: [
                    TextButton(
                      onPressed: () => jumpToExternalLinkAlert(url: bannerUrl),
                      child: Text('image'),
                    ),
                    if (urlLink != null)
                      TextButton(
                        onPressed: () => jumpToExternalLinkAlert(url: urlLink),
                        child: Text('link'),
                      ),
                  ],
                ),
              );
            },
            child: Text('banner'),
          ),
      ],
    );
  }
}
