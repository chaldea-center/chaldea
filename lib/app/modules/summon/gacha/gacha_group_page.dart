import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/mc/converter.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../summon_detail_page.dart';
import 'gacha_parser.dart';

class GachaGroupPage extends StatefulWidget {
  final List<NiceGacha> gachas;
  final String? nameJp;
  final String? nameZh;
  const GachaGroupPage({super.key, required this.gachas, this.nameZh, this.nameJp});

  @override
  State<GachaGroupPage> createState() => _GachaGroupPageState();
}

class _GachaGroupPageState extends State<GachaGroupPage> {
  late List<GachaProbData> gachas = widget.gachas.map((e) => GachaProbData(e, '', [])).toList();
  List<JpGachaNotice> notices = [];
  JpGachaNotice? _selectedNotice;

  bool get anyNoResult => gachas.any((e) => e.isInvalid);

  // -2=gacha page, -1=simulator page, 0/1/2/3=data{X+1}
  final curTab = FilterRadioData<int>.nonnull(-2);
  late final _jpNameController = TextEditingController(text: widget.nameJp);
  late final _cnNameController = TextEditingController(text: widget.nameZh);
  bool _isLuckyBagWithSR = false;

  String get bannerFnBase => _cnNameController.text.trim().replaceAll(RegExp(r'[:\/ ]'), '_');

  @override
  void initState() {
    super.initState();
    parseProbs();
    parseNotices();
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(S.current.raw_gacha_group)),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return ListView(
      children: [
        for (final (index, gacha) in gachas.indexed)
          ListTile(
            dense: true,
            minLeadingWidth: 24,
            horizontalTitleGap: 8,
            leading: gacha.isInvalid
                ? const Icon(Icons.error, color: Colors.red, size: 18)
                : const Icon(Icons.check_circle, color: Colors.green, size: 18),
            title: Text('${index + 1} - ${gacha.gacha.name.setMaxLines(1)}'),
            onTap: () {
              gacha.gacha.routeTo(region: Region.jp);
            },
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          ),
        const SizedBox(height: 8),
        Wrap(
          alignment: .center,
          spacing: 8,
          children: [
            FilledButton(onPressed: () => parseProbs(refresh: true), child: Text(S.current.refresh)),
            FilledButton.tonal(
              onPressed: () {
                if (gachas.isEmpty) return;
                final summon = toLimitedSummon();
                router.pushPage(SummonDetailPage(summon: summon));
              },
              child: Text(S.current.simulator),
            ),
          ],
        ),
        const Divider(height: 16),
        ListTile(
          dense: true,
          title: Text(S.current.region_notice(Region.jp.localName)),
          trailing: TextButton.icon(
            onPressed: _selectedNotice?.link == null
                ? null
                : () {
                    launch(_selectedNotice!.link!);
                  },
            icon: const Icon(Icons.open_in_new),
            label: Text(S.current.open_in_browser),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<JpGachaNotice>(
            value: _selectedNotice,
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  notices.isEmpty
                      ? "${S.current.region_notice(Region.jp.localName)} ${S.current.downloading}..."
                      : (Language.isZH ? "<选择一个公告(若在列表中)>" : "Choose a notice if in list"),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              for (final notice in notices)
                DropdownMenuItem(
                  value: notice,
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 12),
                      children: [
                        TextSpan(
                          text: '[${notice.lastUpdate} ${S.current.update}]',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextSpan(text: notice.title ?? notice.fullTitle),
                      ],
                    ),
                  ),
                ),
            ],
            onChanged: (v) {
              setState(() {
                _selectedNotice = v;
                if (v != null && v.title != null) {
                  _jpNameController.text = v.title!;
                }
              });
            },
          ),
        ),
        if (_selectedNotice?.topBanner != null)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: CachedImage(
              imageUrl: _selectedNotice!.topBanner,
              aspectRatio: 8 / 3,
              showSaveOnLongPress: true,
              onTap: () {
                launch(_selectedNotice!.topBanner!, external: true);
              },
            ),
          ),
        const Divider(height: 32),
        Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SimpleAccordion(
            headerBuilder: (context, _) => ListTile(title: Text(S.current.create_mooncell_summon)),
            contentBuilder: (context) {
              final children = [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _selectedNotice?.topBanner == null
                          ? null
                          : () {
                              launch(_selectedNotice!.topBanner!, external: true);
                            },
                      child: const Text('下载标题图'),
                    ),
                    TextButton(
                      onPressed: () {
                        final cnName = bannerFnBase;
                        if (cnName.isEmpty) {
                          EasyLoading.showInfo('请先填写中文卡池名');
                          return;
                        }
                        final fn = '${cnName}_jp.png';
                        launch("https://fgo.wiki/index.php?title=特殊:上传文件&wpDestFile=$fn");
                      },
                      child: const Text('上传标题图'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _jpNameController,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: '日文卡池名',
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
                    isDense: true,
                    labelText: '中文卡池名',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                if (gachas.any((e) => e.gacha.isLuckyBag))
                  SwitchListTile(
                    dense: true,
                    title: const Text("福袋是否必定保底一四星从者"),
                    contentPadding: EdgeInsets.zero,
                    value: _isLuckyBagWithSR,
                    onChanged: (v) {
                      setState(() {
                        _isLuckyBagWithSR = v;
                      });
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
                    onFilterChanged: (_, _) {
                      setState(() {});
                    },
                  ),
                ),
                curTab.radioValue == -2
                    ? summonTab
                    : curTab.radioValue == -1
                    ? simulatorTab
                    : dataTab(curTab.radioValue!),
              ];
              return Padding(
                padding: .symmetric(horizontal: 8),
                child: Column(mainAxisSize: .min, children: children),
              );
            },
          ),
        ),
      ],
    );
  }

  String fmtJpDate(int t) {
    final utc = DateTime.fromMillisecondsSinceEpoch(t * 1000, isUtc: true);
    final jst = utc.add(const Duration(hours: 9)); // JST=UTC+9
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${jst.year}-${pad(jst.month)}-${pad(jst.day)} ${pad(jst.hour)}:${pad(jst.minute)}';
  }

  Widget _buildWikitext(String? wikitext, String? page, {String? warning, Color? warningColor}) {
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
              onPressed: wikitext == null || wikitext.trim().isEmpty
                  ? null
                  : () => copyToClipboard(wikitext, toast: true),
              child: Text(S.current.copy),
            ),
            FilledButton.tonal(
              onPressed: page == null || page.isEmpty
                  ? null
                  : () {
                      if (wikitext != null && wikitext.isNotEmpty) {
                        copyToClipboard(wikitext, toast: true);
                      }
                      launch(Uri.parse('https://fgo.wiki/w/$page?action=edit').toString(), external: true);
                    },
              child: const Text('创建页面'),
            ),
          ],
        ),
        if (warning != null)
          Card(
            color: warningColor,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(warning, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
            ),
          ),
        InheritSelectionArea(
          child: Card(
            child: Padding(padding: const EdgeInsets.all(8), child: Text(wikitext ?? "解析失败")),
          ),
        ),
      ],
    );
  }

  Widget get summonTab {
    final openAt = Maths.min(gachas.map((e) => e.gacha.openedAt), 0);
    final closeAt = Maths.max(gachas.map((e) => e.gacha.closedAt), 0);
    List<int> puSvts = [], puCEs = [];
    for (final gacha in gachas) {
      if (gacha.isInvalid) continue;
      for (final group in gacha.groups) {
        if (group.pickup) {
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
    puSvts.sort((a, b) => SvtFilterData.compare(db.gameData.servantsNoDup[a], db.gameData.servantsNoDup[b]));
    puCEs.sort((a, b) => CraftFilterData.compare(db.gameData.craftEssences[a], db.gameData.craftEssences[b]));

    String svtNames = puSvts.map((e) => db.gameData.servantsNoDup[e]?.extra.mcLink ?? "从者$e").join(',');
    String ceNames = puCEs.map((e) => db.gameData.craftEssences[e]?.extra.mcLink ?? "礼装$e").join(',');
    if (anyNoResult) {
      const hint = '<!-- 部分卡池解析失败 -->';
      svtNames += hint;
      ceNames += hint;
    }

    String cnName = _cnNameController.text.trim();
    String bannerFilename = bannerFnBase;
    bannerFilename = bannerFilename.isEmpty ? "<!-- 上传标题图 -->" : '${bannerFilename}_jp.png';
    String? jpLink = _selectedNotice?.link ?? "<!-- 填写公告地址 -->";
    """
{{卡池信息
|类型=福袋
|名称cn=
|标题图文件名cn=
|开始时间cn=
|结束时间cn=
|公告编号cn=
|公告链接cn=
|名称ha=2025年新年福袋召唤(男女区别×三骑士·四骑士·EXTRA区别×宝具类型·效果区别)
|名称jp=2025年お正月福袋召喚(男女別×三騎士･四騎士･EXTRA別×宝具タイプ･効果別)
|标题图文件名jp=2025年新年福袋召唤(男女区别×三骑士·四骑士·EXTRA区别×宝具类型·效果区别)_jp.png
|开始时间jp=2025-01-01 00:00
|结束时间jp=2025-01-15 12:59
|公告链接jp=https://news.fate-go.jp/2025/luckybag2025/
|公告翻译=
|主关联页=2025年新年活动
|关联页面=
|推荐召唤从者=
|推荐召唤礼装=
|友情召唤从者=
|圣杯=
|圣杯转结晶=
|传承结晶=
|稀有棱镜=
|★4芙芙=
|其他信息=
}}
==福袋召唤具体情况==
""";
    final isLuckyBag = gachas.any((e) => e.gacha.isLuckyBag);
    final buffer = StringBuffer();
    buffer.writeln("""{{卡池信息
|类型=${isLuckyBag ? "福袋" : "限定"}
|名称cn=
|标题图文件名cn=
|开始时间cn=
|结束时间cn=
|公告编号cn=
|公告链接cn=
|名称ha=$cnName
|名称jp=${_jpNameController.text}
|标题图文件名jp=$bannerFilename
|开始时间jp=${fmtJpDate(openAt)}
|结束时间jp=${fmtJpDate(closeAt)}
|公告链接jp=$jpLink
|公告翻译=
|主关联页=2025年新年活动
|关联页面=
|推荐召唤从者=$svtNames
|推荐召唤礼装=$ceNames
|友情召唤从者=
|圣杯=
|圣杯转结晶=
|传承结晶=
|稀有棱镜=
|★4芙芙=
|其他信息=
}}
""");

    // 卡池情况
    buffer.writeln('\n==推荐召唤具体情况==');
    for (final gacha in gachas.map((e) => e.gacha)) {
      if (gacha.storyAdjusts.isEmpty) continue;
      final questId = gacha.storyAdjusts.firstWhereOrNull((e) => e.condType == CondType.questClear)?.targetId;
      final quest = db.gameData.quests[questId];
      String chapter;
      if (questId != null && quest != null && quest.war?.lastQuestId == questId) {
        chapter = quest.war?.extra.mcLink?.replaceAll('_', ' ') ?? quest.war!.lLongName.l;
        chapter = '[[$chapter]]';
      } else if (questId != null) {
        chapter = "${quest?.war?.lLongName.l ?? ''} ${quest?.lName.l ?? questId}".trim();
      } else {
        chapter = "未知进度";
      }

      buffer.writeln("{{cbox2|lv=4|icon=exclamation|title=召唤「xxxx(查看公告并补充)」需要通关「$chapter」}}");
      break;
    }

    String _getJpTime(int timestamp) {
      return McConverter().getJpTime(timestamp);
      // final date = McConverter().getDate(timestamp, 9);
      // // 9月13日(周三) 18:00～<br/>9月20日(周三) 17:59
      // const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      // return '${date.month.padTwoDigit}月${date.day.padTwoDigit}日(${weekdays[date.weekday]}) ${date.hour.padTwoDigit}:${date.minute.padTwoDigit}';
    }

    String fmtProb(String? indivProb, List<int>? ids) {
      if (indivProb == null || ids == null || ids.isEmpty) return '';
      String prob = RegExp(r'^\d+\.\d00%$').hasMatch(indivProb)
          ? '${indivProb.substring(0, indivProb.length - 3)}%'
          : indivProb;
      if (ids.length == 1) return prob;
      return '各$prob';
    }

    List<String> dates = [], svtProbs = [], ceProbs = [], svtIds = [], ceIds = [];
    for (final gacha in gachas) {
      final date = '${_getJpTime(gacha.gacha.openedAt)},${_getJpTime(gacha.gacha.closedAt)}';
      String svtProb = [5, 4, 3]
          .map((rarity) {
            final group = gacha.groups.firstWhereOrNull((e) => e.isSvt && e.pickup && e.rarity == rarity);
            return fmtProb(group?.indivProb, group?.ids);
          })
          .where((e) => e.isNotEmpty)
          .join(',');
      String ceProb = [5, 4, 3]
          .map((rarity) {
            final group = gacha.groups.firstWhereOrNull((e) => !e.isSvt && e.pickup && e.rarity == rarity);
            return fmtProb(group?.indivProb, group?.ids);
          })
          .where((e) => e.isNotEmpty)
          .join(',');
      String svtId = gacha.groups
          .where((e) => e.isSvt && e.pickup)
          .expand((e) => e.ids)
          .map((e) => e.toString().padLeft(3, '0'))
          .join(',');
      String ceId = gacha.groups
          .where((e) => !e.isSvt && e.pickup)
          .expand((e) => e.ids)
          .map((e) => e.toString().padLeft(3, '0'))
          .join(',');
      dates.add(date);
      svtProbs.add(svtProb);
      ceProbs.add(ceProb);
      svtIds.add(svtId);
      ceIds.add(ceId);
    }

    String _mergeRows(List<String> rows, [bool fallback = true]) {
      if (fallback && rows.length > 1 && rows.toSet().length == 1) {
        rows = [rows.first];
      }
      if (rows.toSet().length == 1 && rows.first.isEmpty) {
        return '';
      }
      return rows.map((e) => '*$e').join('\n');
    }

    buffer.writeln("{{推荐召唤情况\n|召唤时段=");
    if (dates.length > 1) buffer.writeln(_mergeRows(dates));
    buffer.writeln('|从者概率=');
    buffer.writeln(_mergeRows(svtProbs));
    buffer.writeln('|礼装概率=');
    buffer.writeln(_mergeRows(ceProbs));
    buffer.writeln('|从者序号=');
    buffer.writeln(_mergeRows(svtIds, false));
    buffer.writeln('|礼装序号=');
    buffer.writeln(_mergeRows(ceIds, false));

    buffer.writeln("""|召唤时段cn=

|从者概率cn=

|礼装概率cn=

|从者序号cn=

|礼装序号cn=

}}""");

    return _buildWikitext(buffer.toString(), _cnNameController.text);
    // return _buildWikitext('模版过时了', _cnNameController.text);
  }

  Widget get simulatorTab {
    final buffer = StringBuffer();
    buffer.writeln("""{{抽卡模拟器
|卡池图片={{#show:{{Decode|{{BASEPAGENAME}}}}|?SummonImage|link=none}}
|类型=20220101""");
    if (gachas.any((e) => e.gacha.isLuckyBag)) {
      buffer.write('|福袋=');
      buffer.writeln(_isLuckyBagWithSR ? 'ssrsr' : 'ssr');
    }

    List<Set<int>> svtIdsGroups = [];
    for (final gacha in gachas) {
      final groups = gacha.groups;
      if (groups.isEmpty) continue;
      final ids = groups.where((e) => e.isSvt && e.pickup).expand((e) => e.ids).toList();
      if (ids.isNotEmpty) {
        svtIdsGroups.add(ids.toSet());
      }
    }
    final Set<int> allSvtIds = {for (final x in svtIdsGroups) ...x};
    final Set<int> sameSvtIds = allSvtIds.where((e) => svtIdsGroups.every((g) => g.contains(e))).toSet();
    for (final (index, gacha) in gachas.indexed) {
      final idx = index + 1;
      final groups = gacha.groups.where((e) => e.isSvt && e.pickup).toList();
      final groupIds = groups.expand((e) => e.ids).toList();
      final diffIds = groupIds.where((e) => !sameSvtIds.contains(e));
      if (diffIds.isEmpty) {
        if (gachas.length == 1) {
          buffer.writeln("|子名称$idx=默认");
        } else {
          buffer.writeln("|子名称$idx=第$idx组<!-- ${gacha.gacha.name.setMaxLines(1)} -->");
        }
      } else {
        final name = diffIds.map((e) => db.gameData.servantsNoDup[e]?.extra.mcLink ?? "从者$e").join('+');
        buffer.writeln('|子名称$idx=$name');
      }
      buffer.writeln('|数据$idx={{PAGENAME}}/data$idx');
    }
    buffer.writeln('}}');

    final wikitext = buffer.toString();
    String page = _cnNameController.text.trim();
    return _buildWikitext(wikitext, page.isEmpty ? null : '$page/模拟器');
  }

  Widget dataTab(int index) {
    final gacha = gachas[index];
    final table = gacha.toOutput();
    String page = _cnNameController.text.trim();
    if (page.isNotEmpty) {
      page = '$page/模拟器/data${index + 1}';
    }
    String? warning;
    Color? warningColor = Theme.of(context).colorScheme.error;
    if (gacha.isInvalid) {
      warning = '该卡池解析失败';
    } else {
      if ((100 - gacha.guessTotalProb()).abs() < 0.05 && (100 - gacha.getTotalProb()).abs() < 0.06) {
        warningColor = Theme.of(context).colorScheme.primary;
      }
      warning =
          '检查概率: ${gacha.guessTotalProb().toStringAsPrecision(5)}% (${gacha.getTotalProb().toStringAsPrecision(5)}%)';
    }

    return _buildWikitext(table, page, warning: warning, warningColor: warningColor);
  }

  Future<void> parseProbs({bool refresh = false}) async {
    try {
      gachas = await showEasyLoading(() => JpGachaParser().parseMultiple(widget.gachas, refresh: refresh));
      final errorCount = gachas.where((e) => e.isInvalid).length;
      if (errorCount > 0) {
        EasyLoading.showSuccess('$errorCount个卡池解析失败');
      } else {
        EasyLoading.showSuccess('Done');
      }
    } catch (e, s) {
      logger.e('parse gachas failed', e, s);
      EasyLoading.showError(e.toString());
    }
    if (mounted) setState(() {});
  }

  Future<void> parseNotices() async {
    notices = await JpGachaParser().parseNotices();
    _selectedNotice = null;
    if (mounted) {
      setState(() {});
    }
  }

  LimitedSummon toLimitedSummon() {
    final name = _findCleanCommonPrefix(gachas.map((e) => e.gacha.name).toList());
    return LimitedSummon(
      isFromWiki: false,
      id: '',
      name: name,
      type: gachas.firstOrNull?.gacha.isLuckyBag == true ? .gssr : .limited,
      startTime: MappingBase(jp: Maths.min(gachas.map((e) => e.gacha.openedAt))),
      endTime: MappingBase(jp: Maths.min(gachas.map((e) => e.gacha.closedAt))),
      officialBanner: MappingBase(jp: AssetURL.i.summonBanner(gachas.first.gacha.imageId)),
      subSummons: gachas.map((gacha) {
        String title = gacha.gacha.name.substring(name.length).trim();
        if (title.isEmpty) title = gacha.gacha.name;
        const puText = 'ピックアップ召喚';
        if (title.endsWith(puText)) {
          title = title.substring(0, title.length - puText.length);
        }
        return gacha.toSubSummon()..title = title;
      }).toList(),
    );
  }

  String _findCleanCommonPrefix(List<String> strings) {
    if (strings.isEmpty) return '';

    String _findLongestCommonPrefix() {
      if (strings.isEmpty) return '';
      String first = strings[0];
      for (int i = 0; i < first.length; i++) {
        String currentChar = first[i];
        for (int j = 1; j < strings.length; j++) {
          if (i >= strings[j].length || strings[j][i] != currentChar) {
            return first.substring(0, i);
          }
        }
      }
      return first;
    }

    String commonPrefix = _findLongestCommonPrefix();
    if (commonPrefix.isEmpty) return '';

    const trailingChars = {' ', '　', '(', '（', '【', '[', '「', '『', '｢'};
    int end = commonPrefix.length - 1;
    while (end >= 0 && trailingChars.contains(commonPrefix[end])) {
      end--;
    }
    if (end < 0) return '';
    return commonPrefix.substring(0, end + 1);
  }
}
