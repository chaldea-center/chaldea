import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/inherit_selection_area.dart';
import 'mc_prob_edit.dart';

class MCSummonCreatePage extends StatefulWidget {
  final List<MstGacha> gachas;
  const MCSummonCreatePage({super.key, required this.gachas});

  @override
  State<MCSummonCreatePage> createState() => _MCSummonCreatePageState();
}

class _MCSummonCreatePageState extends State<MCSummonCreatePage> {
  List<_GachaState> gachas = [];
  bool get anyNoResult => gachas.any((e) => e.result?.groups.isNotEmpty != true);

  // -2=gacha page, -1=simulator page, 0/1/2/3=data{X+1}
  final curTab = FilterRadioData<int>.nonnull(-2);
  late final _jpNameController = TextEditingController();
  late final _cnNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    gachas = widget.gachas.map((e) => _GachaState(e)).toList();
    gachas.sort2((e) => e.gacha.openedAt);
    parse();
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("新建Mooncell卡池"),
        ),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final (index, gacha) in gachas.enumerate)
          ListTile(
            dense: true,
            minLeadingWidth: 24,
            horizontalTitleGap: 8,
            contentPadding: EdgeInsets.zero,
            leading: gacha.result == null
                ? const Icon(Icons.error, color: Colors.red, size: 18)
                : const Icon(Icons.check_circle, color: Colors.green, size: 18),
            title: Text('${index + 1} - ${gacha.gacha.name}'),
            onTap: () {
              router.pushPage(MCGachaProbEditPage(gacha: gacha.gacha));
            },
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          ),
        Center(
          child: ElevatedButton(
            onPressed: parse,
            child: const Text('解析所有卡池'),
          ),
        ),
        const Divider(height: 16),
        const SizedBox(height: 16),
        TextFormField(
          controller: _jpNameController,
          decoration: const InputDecoration(
            labelText: '日文卡池名(不能出现英文斜杠/)',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cnNameController,
          decoration: const InputDecoration(
            labelText: '中文卡池名(不能出现英文斜杠/)',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: FilterGroup<int>(
            combined: true,
            options: [-2, -1, ...List.generate(gachas.length, (index) => index)],
            values: curTab,
            optionBuilder: (v) {
              if (v == -2) return const Text('卡池');
              if (v == -1) return const Text('模拟器');
              return Text('data${v + 1}');
            },
            onFilterChanged: (_, __) {
              setState(() {});
            },
          ),
        ),
        curTab.radioValue == -2
            ? summonTab
            : curTab.radioValue == -1
                ? simulatorTab
                : dataTab(curTab.radioValue!)
      ],
    );
  }

  String fmtJpDate(int t) {
    final utc = DateTime.fromMillisecondsSinceEpoch(t * 1000, isUtc: true);
    final jst = utc.add(const Duration(hours: 9)); // JST=UTC+9
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${jst.year}-${pad(jst.month)}-${pad(jst.day)} ${pad(jst.hour)}:${jst.minute}';
  }

  Widget _buildWikitext(String? wikitext, String? page, {String? warning}) {
    page = page?.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            FilledButton(
              onPressed:
                  wikitext == null || wikitext.trim().isEmpty ? null : () => copyToClipboard(wikitext, toast: true),
              child: Text(S.current.copy),
            ),
            FilledButton.tonal(
              onPressed: page == null || page.isEmpty
                  ? null
                  : () {
                      launch(Uri.parse('https://fgo.wiki/w/$page?action=edit').toString(), external: true);
                    },
              child: const Text('创建页面'),
            ),
          ],
        ),
        if (warning != null)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                warning,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(wikitext ?? "解析失败"),
          ),
        ),
      ],
    );
  }

  Widget get summonTab {
    final openAt = Maths.min(gachas.map((e) => e.gacha.openedAt), 0);
    final closeAt = Maths.min(gachas.map((e) => e.gacha.closedAt), 0);
    List<int> puSvts = [], puCEs = [];
    for (final gacha in gachas) {
      final result = gacha.result;
      if (result == null) continue;
      for (final group in result.groups) {
        if (group.display) {
          if (group.isSvt) {
            puSvts.addAll(group.ids);
          } else {
            puCEs.addAll(group.ids);
          }
        }
      }
    }
    puSvts = puSvts.toSet().toList();
    puCEs = puCEs.toSet().toList();
    puSvts.sort((a, b) => SvtFilterData.compare(
          db.gameData.servantsNoDup[a],
          db.gameData.servantsNoDup[b],
          keys: [SvtCompare.rarity, SvtCompare.no],
          reversed: [true, false],
        ));
    puCEs.sort((a, b) => CraftFilterData.compare(
          db.gameData.craftEssences[a],
          db.gameData.craftEssences[b],
          keys: [CraftCompare.rarity, CraftCompare.no],
          reversed: [true, false],
        ));

    String svtNames = puSvts.map((e) => db.gameData.servantsNoDup[e]?.extra.mcLink ?? "未知从者$e").join(',');
    String ceNames = puCEs.map((e) => db.gameData.craftEssences[e]?.extra.mcLink ?? "未知礼装$e").join(',');
    if (anyNoResult) {
      const hint = '<!-- 部分卡池解析失败 -->';
      svtNames += hint;
      ceNames += hint;
    }

    final wikitext = """{{卡池信息
|卡池名cn=
|卡池名缩短cn=
|卡池开始时间cn=
|卡池结束时间cn=
|卡池图文件名cn=
|卡池时间预估cn=
|卡池官网链接cn=
|卡池名jp=${_jpNameController.text}
|卡池名ha=${_cnNameController.text}
|卡池名缩短jp=
|卡池开始时间jp=${fmtJpDate(openAt)}
|卡池结束时间jp=${fmtJpDate(closeAt)}
|卡池图文件名jp=${_cnNameController.text} jp.png
|卡池官网链接jp=<!-- 手动填写公告地址和上传标题图 -->
|关联活动1=
|关联卡池1=
|推荐召唤从者=$svtNames
|推荐召唤礼装=$ceNames
|其他信息=
}}
""";
    return _buildWikitext(wikitext, _cnNameController.text);
  }

  Widget get simulatorTab {
    final buffer = StringBuffer();
    buffer.writeln("""{{抽卡模拟器
|卡池图片={{#show:{{Decode|{{BASEPAGENAME}}}}|?SummonImage|link=none}}
|类型=20220101""");
    if (gachas.any((e) => e.gacha.isLuckyBag)) {
      buffer.writeln('|福袋=ssr <!--若包含四星保底则为ssrsr-->');
    }

    List<Set<int>> svtIdsGroups = [];
    for (final gacha in gachas) {
      final groups = gacha.result?.groups ?? [];
      if (groups.isEmpty) continue;
      final ids = groups.where((e) => e.isSvt && e.display).expand((e) => e.ids).toList();
      if (ids.isNotEmpty) {
        svtIdsGroups.add(ids.toSet());
      }
    }
    final Set<int> allSvtIds = {for (final x in svtIdsGroups) ...x};
    final Set<int> sameSvtIds = allSvtIds.where((e) => svtIdsGroups.every((g) => g.contains(e))).toSet();
    for (final (index, gacha) in gachas.indexed) {
      final idx = index + 1;
      final groups = gacha.result?.groups.where((e) => e.isSvt && e.display).toList() ?? [];
      final groupIds = groups.expand((e) => e.ids).toList();
      final diffIds = groupIds.where((e) => !sameSvtIds.contains(e));
      if (diffIds.isEmpty) {
        if (gachas.length == 1) {
          buffer.writeln("|子名称$idx=默认");
        } else {
          buffer.writeln("|子名称$idx=默认$idx<!-- 未知 -->");
        }
      } else {
        final name = diffIds.map((e) => db.gameData.servantsNoDup[e]?.extra.mcLink ?? "从者$e").join('+');
        buffer.writeln('|子名称$idx=$name');
      }
      buffer.writeln('|数据$idx={{PAGENAME}}/data$idx');
    }
    buffer.writeln('}}');
    if (gachas.any((e) => e.gacha.isLuckyBag)) {
      // buffer.writeln('|类型=20220101');
    }

    final wikitext = buffer.toString();
    String page = _cnNameController.text.trim();
    return _buildWikitext(wikitext, page.isEmpty ? null : '$page/模拟器');
  }

  Widget dataTab(int index) {
    final gacha = gachas[index];
    final result = gacha.result;
    final table = result?.toOutput();
    String page = _cnNameController.text.trim();
    if (page.isNotEmpty) {
      page = '$page/模拟器/data${index + 1}';
    }
    String? warning;
    if (result != null) {
      warning = '检查概率: ${result.guessTotalProb()}% (${result.getTotalProb()}%)';
    }

    return _buildWikitext(table, page, warning: warning);
  }

  Future<void> parse() async {
    try {
      for (final gacha in gachas) {
        if (gacha.url == null) continue;
        final text = await showEasyLoading(() => CachedApi.cacheManager.getText(gacha.url!));
        if (text == null) continue;
        gacha.result = GachaParser().parse(text, gacha.gacha);
      }
      EasyLoading.showSuccess('Done');
    } catch (e, s) {
      logger.e('parse gachas failed', e, s);
      EasyLoading.showError(e.toString());
    }
    if (mounted) setState(() {});
  }
}

class _GachaState {
  final MstGacha gacha;
  final String? url;
  GachaParseResult? result;
  _GachaState(this.gacha) : url = gacha.getHtmlUrl(Region.jp);
}
