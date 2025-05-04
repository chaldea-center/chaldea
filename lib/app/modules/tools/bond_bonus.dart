import 'package:chaldea/app/battle/utils/battle_utils.dart' show BattleUtils;
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_page_base.dart';
import '../servant/filter.dart';

typedef _GroupItem = ({int rateCount, List<int> ceIds, List<({Servant svt, List<int> limitCounts})> svts});

class BondBonusPage extends StatefulWidget {
  const BondBonusPage({super.key});

  @override
  State<BondBonusPage> createState() => _BondBonusPageState();
}

/// functvals: traits
/// DataVals: [RateCount], [AddCount] (ignore)
class _BondBonusPageState extends State<BondBonusPage> {
  Map<int, ({CraftEssence ce, List<List<NiceTrait>> traits, int rateCount})> allCeData = {};
  Map<int, Map<int, List<int>>> allCeMatchSvtData = {}; //<ceId, <svtId, [limitCount]>>

  final svtFilterData = SvtFilterData(
    sortKeys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
    sortReversed: [true, false, true],
  );
  int? selectedCeId;

  @override
  void initState() {
    super.initState();
    // ce data
    for (final ce in db.gameData.craftEssencesById.values) {
      if (ce.collectionNo <= 0 || ce.isRegionSpecific) continue;
      final skills = ce.getActivatedSkills(true)[1] ?? <NiceSkill>[];
      if (skills.isEmpty) continue;
      if (skills.length > 1) {
        print('CE ${ce.collectionNo} has ${skills.length} bond bonus skills, skip');
        continue;
      }
      final skill = skills.single;
      final funcs = [
        for (final func in skill.functions)
          if (func.funcType == FuncType.servantFriendshipUp &&
              (func.svals.firstOrNull?.EventId ?? 0) == 0 &&
              (func.functvals.isNotEmpty || func.overWriteTvalsList.isNotEmpty))
            func,
      ];
      if (funcs.isEmpty) continue;
      if (funcs.length > 1) {
        print('CE ${ce.collectionNo} skill ${skill.id} ${funcs.length} bond bonus functions, skip');
        continue;
      }
      final func = funcs.single;
      final rateCount = func.svals.firstOrNull?.RateCount ?? 0;
      if (rateCount <= 0) continue;
      // 英霊逢魔: 1973-1979
      if (ce.collectionNo >= 1974 && ce.collectionNo <= 1979) continue;
      allCeData[ce.id] = (
        ce: ce,
        traits: func.overWriteTvalsList.isEmpty ? func.functvals.map((e) => [e]).toList() : func.overWriteTvalsList,
        rateCount: rateCount,
      );
    }

    sortDict(allCeData, inPlace: true, compare: (a, b) => a.value.ce.collectionNo.compareTo(b.value.ce.collectionNo));

    // ce mapping svt
    for (final (:ce, :traits, rateCount: _) in allCeData.values) {
      for (final svt in db.gameData.servantsById.values) {
        if (svt.collectionNo <= 0) continue;
        final limitCounts = getMatchedLimitCounts(svt, traits);
        if (limitCounts.isEmpty) continue;
        allCeMatchSvtData.putIfAbsent(ce.id, () => {})[svt.id] = limitCounts;
      }
    }
  }

  List<int> getMatchedLimitCounts(Servant svt, List<List<NiceTrait>> bonusTraitsList) {
    final baseTraits = svt.traits;
    List<int> matchedLimitCounts = [];
    final allLimitCounts = _getSvtAllLimits(svt);
    for (final limitCount in allLimitCounts) {
      List<NiceTrait> resultTraits = svt.ascensionAdd.individuality.all[limitCount] ?? [];
      if (resultTraits.isEmpty) resultTraits = baseTraits;
      resultTraits = List.of(resultTraits);
      final limitCount2 = limitCount < 100 ? limitCount : svt.costume[limitCount]?.id ?? limitCount;
      for (final traitAdd in svt.traitAdd) {
        if (traitAdd.eventId != 0 ||
            traitAdd.condType != CondType.none ||
            (traitAdd.endedAt > 0 && traitAdd.endedAt < kNeverClosedTimestamp)) {
          continue;
        }
        if (traitAdd.limitCount == -1 || traitAdd.limitCount == limitCount2 || traitAdd.limitCount == limitCount) {
          resultTraits.addAll(traitAdd.trait);
        }
      }

      bool matched = false;
      for (final andTraits in bonusTraitsList) {
        if (andTraits.isEmpty) continue;
        if (andTraits.every((e) => resultTraits.contains(e))) {
          matched = true;
          break;
        }
      }
      if (matched) {
        matchedLimitCounts.add(limitCount);
      }
    }

    return matchedLimitCounts;
  }

  List<_GroupItem> getGroupData() {
    final List<int> mustHaveCeIds = [if (selectedCeId != null) selectedCeId!];
    final List<int> freeCeIds = allCeData.keys.toSet().difference(mustHaveCeIds.toSet()).toList();
    final int n = freeCeIds.length;
    List<_GroupItem> resultData = [];
    for (int mask = 0; mask < (1 << n); mask++) {
      final List<int> usedCeIds = List.of(mustHaveCeIds);
      usedCeIds.sort(); // for key sort
      for (int i = 0; i < n; i++) {
        if ((mask & (1 << i)) != 0) {
          usedCeIds.add(freeCeIds[i]);
        }
      }
      if (usedCeIds.isEmpty) continue;

      final List<Set<int>> svtIdList = usedCeIds.map((ceId) => allCeMatchSvtData[ceId]!.keys.toSet()).toList();
      final sameSvtIds = _intersectionSetList(svtIdList);
      if (sameSvtIds.isEmpty) continue;

      List<({Servant svt, List<int> limitCounts})> svts = [];
      for (final svtId in sameSvtIds) {
        final svt = db.gameData.servantsById[svtId]!;
        if (!ServantFilterPage.filter(svtFilterData, svt)) continue;
        final sameLimitCounts = _intersectionSetList(
          usedCeIds.map((ceId) => allCeMatchSvtData[ceId]![svtId]?.toSet() ?? <int>{}).toList(),
        );
        if (sameLimitCounts.isNotEmpty) {
          svts.add((svt: svt, limitCounts: sameLimitCounts.toList()));
        }
      }
      if (svts.isEmpty) continue;
      svts.sort(
        (a, b) =>
            SvtFilterData.compare(a.svt, b.svt, keys: svtFilterData.sortKeys, reversed: svtFilterData.sortReversed),
      );
      final rateCount = Maths.sum(usedCeIds.map((e) => allCeData[e]!.rateCount));
      resultData.add((ceIds: usedCeIds, rateCount: rateCount, svts: svts));
    }
    resultData.sortByList((e) => [-e.rateCount, e.ceIds.length, ...e.ceIds]);

    return resultData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.craft_essence} - ${S.current.bond}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed:
                () => FilterPage.show(
                  context: context,
                  builder:
                      (context) => ServantFilterPage(
                        filterData: svtFilterData,
                        onChanged: (_) {
                          if (mounted) setState(() {});
                        },
                        planMode: false,
                      ),
                ),
          ),
        ],
      ),
      body: Column(children: [Expanded(child: mainBody), kDefaultDivider, buttonBar]),
    );
  }

  Widget get mainBody {
    final groups = getGroupData();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final (:ceIds, :rateCount, :svts) = groups[index];
        List<Widget> children = [];
        children.add(
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(minWidth: 40),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: EdgeInsetsDirectional.only(end: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                ),
                child: Text(rateCount.format(percent: true, base: 10)),
              ),
              ...ceIds
                  .map((ceId) {
                    final (:ce, :traits, :rateCount) = allCeData[ceId]!;
                    return <Widget>[
                      ce.iconBuilder(context: context, width: 24),
                      InkWell(
                        onTap: ce.routeTo,
                        child: Text('${_describeTraits(traits)}  ', style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ];
                  })
                  .expand((e) => e),
            ],
          ),
        );

        children.add(
          Wrap(
            children:
                svts.map((x) {
                  final (:svt, :limitCounts) = x;
                  final allLimitCounts = _getSvtAllLimits(svt);
                  final conditional = limitCounts.length != allLimitCounts.length;
                  Widget child = Container(
                    decoration: BoxDecoration(
                      color: conditional ? Theme.of(context).colorScheme.errorContainer.withAlpha(191) : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(1),
                    margin: const EdgeInsets.all(1),
                    child: svt.iconBuilder(
                      context: context,
                      // width: 32,
                      text: [
                        if (conditional) '${limitCounts.length}/${allLimitCounts.length}',
                        svt.status.favorite ? 'Lv${svt.status.bond}' : '',
                      ].join('\n'),
                      option: ImageWithTextOption(fontSize: 12),
                      width: 48,
                    ),
                  );
                  if (conditional) {
                    String msg = limitCounts
                        .map((limitCount) {
                          String name;
                          if (limitCount < 10) {
                            int stage = BattleUtils.limitCountToStage(limitCount);
                            name =
                                '${S.current.ascension_short} $limitCount (${S.current.ascension_stage_short} $stage)';
                          } else {
                            final costume = svt.costume[limitCount];
                            name = costume?.lName.l ?? '${S.current.costume} $limitCount';
                          }
                          return '- $name';
                        })
                        .join('\n');
                    msg = '${svt.lName.l}\n$msg';
                    child = Tooltip(message: msg, child: child);
                  }
                  return child;
                }).toList(),
          ),
        );
        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }

  Widget get buttonBar {
    final ces = allCeData.values.toList();
    ces.sortByList((e) => [-e.rateCount, -e.ce.collectionNo]);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButton<int?>(
          value: selectedCeId,
          // hint: Text(S.current.craft_essence),
          items: [
            DropdownMenuItem(child: Text(S.current.craft_essence)),
            for (final ce in ces)
              DropdownMenuItem(
                value: ce.ce.id,
                child: Text.rich(
                  TextSpan(
                    children: [
                      CenterWidgetSpan(child: ce.ce.iconBuilder(context: context, width: 32)),
                      TextSpan(
                        text: ' ${_describeTraits(ce.traits)}',
                        children: [TextSpan(text: ' +${ce.rateCount.format(percent: true, base: 10)}')],
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          onChanged: (v) {
            setState(() {
              selectedCeId = v;
            });
          },
        ),
      ),
    );
  }

  String _describeTraits(List<List<NiceTrait>> traitsList) {
    return traitsList.map((ee) => ee.map((e) => Transl.trait(e.signedId).l).join('&')).join('/');
  }

  Set<int> _getSvtAllLimits(Servant svt) {
    return {...range(5), ...svt.costume.keys, ...svt.ascensionAdd.individuality.all.keys};
  }
}

Set<T> _intersectionSetList<T>(List<Set<T>> array) {
  if (array.isEmpty) return {};
  Set<T> result = array.first.toSet();
  for (final s in array.skip(1)) {
    result = result.intersection(s);
  }
  return result;
}
