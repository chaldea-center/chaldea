import 'dart:convert';
import 'dart:io';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/saint_quartz/common.dart' show SaintLocalized;
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
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
  late final loginResultData = runtime.agentData.loginResultData;
  final typeFilter = FilterGroupData<_LoginResultDataType>();

  Map<String, List<int>> itemNames = {}; // jp name -> item cache

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
      if (typeFilter.matchOne(_LoginResultDataType.campaign))
        for (final bonus in loginResultData.campaignBonus) buildCampaignBonusData(bonus),
      if (typeFilter.matchOne(_LoginResultDataType.totalLogin))
        for (final bonus in loginResultData.totalLoginBonus) buildLoginBonusData(bonus, SaintLocalized.accLogin),
      if (typeFilter.matchOne(_LoginResultDataType.seqLogin))
        for (final bonus in loginResultData.seqLoginBonus) buildLoginBonusData(bonus, SaintLocalized.continuousLogin),
      // for (final bonus in loginResultData.campaignDirectBonus) buildDirectBonusData(bonus),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Bonus'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                loginResultData.clear();
              });
            },
            icon: Icon(Icons.clear_all),
            tooltip: S.current.clear,
          ),
          IconButton(
            onPressed: () {
              InputCancelOkDialog.number(
                title: 'Load Local History',
                initValue: 5,
                validate: (v) => v > 0,
                onSubmit: (maxLoadCount) async {
                  showEasyLoading(() => _loadLocalHistory(maxLoadCount));
                },
              ).showDialog(context);
            },
            icon: Icon(Icons.history),
            tooltip: S.current.history,
          ),
          runtime.buildMenuButton(context),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilterGroup(
              options: _LoginResultDataType.values,
              values: typeFilter,
              combined: true,
              optionBuilder: (v) => Text(v.name),
              onFilterChanged: (optionData, lastChanged) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) => children[index],
              separatorBuilder: (_, _) => const Divider(),
              itemCount: children.length,
            ),
          ),
        ],
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
        for (final (:bannerUrl, urlLink: _) in bonus.getBanners(runtime.region))
          CachedImage(
            imageUrl: bannerUrl,
            viewFullOnTap: true,
            showSaveOnLongPress: true,
            placeholder: (context, url) => const CircularProgressIndicator(),
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
      text: '${bonus.createdAt.sec2date().toCustomString(year: false, second: false)}  ${bonus.key}  ',
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

  Future<void> _loadLocalHistory(int maxLoadCount) async {
    final folder = Directory(runtime.agent.network.fakerDir);
    final files = [
      for (final file in folder.listSync().whereType<File>())
        if (file.path.endsWith('.json') && file.path.contains('login')) file,
    ];
    files.sort((a, b) => b.path.compareTo(a.path));
    int loaded = 0;
    for (final fp in files) {
      if (loaded >= maxLoadCount) break;
      try {
        final resp = FateTopLogin.fromJson(jsonDecode(await fp.readAsString()));
        final updated = runtime.agentData.updateLoginResult(resp);
        if (updated != null) {
          loaded += 1;
          if (mounted) setState(() {});
        }
      } catch (e, s) {
        logger.e('read login result failed', e, s);
      }
    }
    if (mounted) setState(() {});
  }
}

enum _LoginResultDataType {
  campaign,
  seqLogin,
  totalLogin,
  // campaignDirect
}
