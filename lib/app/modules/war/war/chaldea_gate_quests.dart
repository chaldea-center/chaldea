import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/query.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/filter_group.dart';

class ChaldeaGateQuestListPage extends StatefulWidget {
  const ChaldeaGateQuestListPage({super.key});

  @override
  State<ChaldeaGateQuestListPage> createState() => _ChaldeaGateQuestListPageState();
}

class _ChaldeaGateQuestListPageState extends State<ChaldeaGateQuestListPage>
    with RegionBasedState<NiceWar, ChaldeaGateQuestListPage> {
  late final searchEditingController = TextEditingController();
  Query query = Query();

  _SortType _sortType = _SortType.openedAt;
  int tz = 9;

  @override
  void initState() {
    super.initState();
    doFetchData();
  }

  @override
  Future<NiceWar?> fetchData(Region? r) async {
    r ??= Region.jp;
    if (r == Region.jp) {
      final war = db.gameData.wars[WarId.chaldeaGate];
      if (war != null && war.quests.length > 500) {
        return war;
      }
    }
    return AtlasApi.war(WarId.chaldeaGate, region: r);
  }

  @override
  Widget build(BuildContext context) {
    region ??= Region.jp;
    tz = region!.timezone;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.chaldea_gate),
        actions: [dropdownRegion()],
        bottom: SearchBar2(
          controller: searchEditingController,
          onChanged: (s) {
            EasyDebounce.debounce('search_onchanged', const Duration(milliseconds: 300), () {
              if (mounted) setState(() {});
            });
          },
          onSubmitted: (s) {
            FocusScope.of(context).unfocus();
          },
          // searchOptionsBuilder: options?.builder,
        ),
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, NiceWar war) {
    final quests = war.quests;

    final keyword = searchEditingController.text.trim();
    query.parse(keyword);
    if (keyword.isNotEmpty) {
      quests.retainWhere((quest) => query.match(SearchUtil.getAllKeys(quest.lName)));
    }

    final groups = _GroupData.getValidGroups(tz);

    int Function(Quest q) qt;
    if (_sortType == _SortType.openedAt) {
      quests.sort2((e) => e.openedAt);
      qt = (q) => q.openedAt;
    } else if (_sortType == _SortType.closedAt) {
      quests.sort2((e) => e.closedAt);
      qt = (q) => q.closedAt;
    } else {
      qt = (q) => q.openedAt;
    }
    for (final quest in quests) {
      final group = groups.firstWhereOrNull((e) => e.startTime <= qt(quest) && e.endTime > qt(quest));
      group?.quests.add(quest);
    }
    groups.removeWhere((e) => e.quests.isEmpty);
    groups.sort2((e) => -e.startTime);
    List<Widget> children = [];
    for (final group in groups) {
      children.add(buildGroup(group));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (context, index) => kDefaultDivider,
          ),
        ),
        kDefaultDivider,
        SafeArea(
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              const Text("Group by "),
              FilterGroup<_SortType>(
                combined: true,
                options: _SortType.values,
                values: FilterRadioData.nonnull(_sortType),
                optionBuilder: (v) => Text(v == _SortType.openedAt ? S.current.time_start : S.current.time_close),
                onFilterChanged: (v, _) {
                  setState(() {
                    _sortType = v.radioValue!;
                  });
                },
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildGroup(_GroupData group) {
    return SimpleAccordion(
      headerBuilder: (context, expanded) {
        return ListTile(
          dense: true,
          title: Text(group.months == 1
              ? "${group.startYear}/${group.startMonth}"
              : "${group.startYear}/${group.startMonth} ~ ${group.endYear}/${group.endMonth}"),
          subtitle: Text('${group.quests.length} ${S.current.quest}'),
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          selected: expanded,
        );
      },
      contentBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final quest in group.quests)
              ListTile(
                dense: true,
                title: Text(quest.lName.l),
                subtitle: Text(
                    [quest.openedAt.sec2date().toDateString(), quest.closedAt.sec2date().toDateString()].join(" ~ ")),
                trailing: Text(
                  ['Lv.${quest.recommendLv}', if (quest.consumeType.useAp) "AP ${quest.consume}"].join("\n"),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => quest.routeTo(region: region),
              ),
          ],
        );
      },
    );
  }
}

class _GroupData {
  final int startYear;
  final int startMonth;
  late final int startTime;
  final int endYear;
  final int endMonth;
  late final int endTime;
  final List<Quest> quests = [];

  _GroupData(this.startYear, this.startMonth, this.endYear, this.endMonth, int tz) {
    startTime = DateTime.utc(startYear, startMonth, 1, -tz).timestamp;
    endTime = DateTime.utc(endYear, endMonth, 1, -tz).timestamp;
  }

  int get months {
    return (endYear * 12 + endMonth - 1) - (startYear * 12 + startMonth - 1);
  }

  static List<_GroupData> getValidGroups(int tz) {
    const dm = 1;

    final endTime = DateTime.now().add(const Duration(days: 100));
    final endYear = endTime.year, endMonth = endTime.month;
    int year = 2015, month = 7;

    List<_GroupData> groups = [
      _GroupData(1900, 1, year, month, tz),
    ];
    while (year * 12 + month < endYear * 12 + endMonth) {
      var (int y2, int m2) = normMonth(year, month + dm);
      groups.add(_GroupData(year, month, y2, m2, tz));
      year = y2;
      month = m2;
    }
    groups.add(_GroupData(year, month, 2999, 12, tz));
    return groups;
  }
}

enum _SortType {
  openedAt,
  closedAt,
}

(int year, int month) normMonth(int y, int m) {
  int m2 = (m - 1) % 12 + 1;
  int y2 = y + (m - m2) ~/ 12;
  return (y2, m2);
}
