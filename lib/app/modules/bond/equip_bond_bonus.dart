import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart' show BattleUtils;
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_page_base.dart';
import '../servant/filter.dart';

typedef _GroupItem = ({int rateCount, List<int> ceIds, List<({Servant svt, List<int> limitCounts})> svts});

class EquipBondBonusTab extends StatefulWidget {
  final Servant? targetSvt;
  const EquipBondBonusTab({super.key, this.targetSvt});

  static Widget scaffold({Servant? targetSvt}) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.bond_bonus)),
      body: EquipBondBonusTab(targetSvt: targetSvt),
    );
  }

  @override
  State<EquipBondBonusTab> createState() => _EquipBondBonusTabState();
}

enum _FilterType {
  none,
  include,
  exclude,
  hide;

  Color? get color {
    return switch (this) {
      none => null,
      include => Colors.blue,
      exclude => Colors.red,
      hide => Colors.grey,
    };
  }

  String get shownName {
    if (Language.isZH) {
      return switch (this) {
        none => '默认',
        include => '包含',
        exclude => '排除',
        hide => '隐藏',
      };
    } else {
      return switch (this) {
        none => 'default',
        _ => name,
      };
    }
  }

  String get hint {
    if (Language.isZH) {
      return switch (this) {
        none => '默认',
        include => '必须享受到该礼装加成',
        exclude => '必须不能被该礼装的加成',
        hide => '不显示该礼装',
      };
    } else {
      return switch (this) {
        none => 'default',
        include => 'MUST have bonus from this CE',
        exclude => 'MUST NOT have bonus from this CE',
        hide => 'Hide the CE',
      };
    }
  }
}

/// functvals: traits
/// DataVals: [RateCount], [AddCount] (ignore)
class _EquipBondBonusTabState extends State<EquipBondBonusTab> {
  Map<int, ({CraftEssence ce, List<List<NiceTrait>> traits, int rateCount})> allCeData = {};
  Map<int, Map<int, List<int>>> allCeMatchSvtData = {}; //<ceId, <svtId, [limitCount]>>

  final svtFilterData = SvtFilterData(
    sortKeys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
    sortReversed: [true, false, true],
  );
  final ceFilterStates = <int, _FilterType>{};

  _FilterType getCeState(int ceId) => ceFilterStates[ceId] ??= _FilterType.none;

  @override
  void initState() {
    super.initState();
    // ce data
    for (final ce in db.gameData.craftEssencesById.values) {
      if (ce.collectionNo <= 0 || ce.isRegionSpecific) continue;
      if (ce.rarity < 5) continue;
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
      // 英霊逢魔: 1973-1979, FSN servant +10%
      if (ce.collectionNo >= 1973 && ce.collectionNo <= 1979) continue;
      allCeData[ce.id] = (
        ce: ce,
        traits: func.overWriteTvalsList.isEmpty ? func.functvals.map((e) => [e]).toList() : func.overWriteTvalsList,
        rateCount: rateCount,
      );
    }

    sortDict(allCeData, inPlace: true, compare: (a, b) => a.value.ce.collectionNo.compareTo(b.value.ce.collectionNo));

    // ce mapping svt
    final svts = widget.targetSvt != null
        ? [widget.targetSvt!]
        : db.gameData.servantsById.values.where((e) => e.collectionNo > 0);
    for (final (:ce, :traits, rateCount: _) in allCeData.values) {
      final svtLimitsData = allCeMatchSvtData[ce.id] ??= {};
      for (final svt in svts) {
        final limitCounts = getMatchedLimitCounts(svt, traits);
        if (limitCounts.isEmpty) continue;
        svtLimitsData[svt.id] = limitCounts;
      }
    }

    // hide unreleased ces
    for (final ceId in allCeData.keys) {
      if (!isCeReleased(ceId)) {
        ceFilterStates[ceId] = _FilterType.hide;
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

  bool isCeReleased(int ceId) {
    final region = db.curUser.region;
    if (region == Region.jp) return true;
    final releasedIds = db.gameData.mappingData.entityRelease.ofRegion(region);
    if (releasedIds != null && releasedIds.isNotEmpty) {
      return releasedIds.contains(ceId);
    }
    return true;
  }

  List<_GroupItem> getGroupData() {
    final List<int> allCeIds = allCeData.keys
        .where((e) => ![_FilterType.exclude, _FilterType.hide].contains(ceFilterStates[e]))
        .toList();
    final List<int> excludeCeIds = ceFilterStates.keys.where((e) => ceFilterStates[e] == _FilterType.exclude).toList();
    final List<int> mustHaveCeIds = ceFilterStates.keys.where((e) => ceFilterStates[e] == _FilterType.include).toList();
    final List<int> freeCeIds = allCeIds.where((e) => !mustHaveCeIds.contains(e) && !excludeCeIds.contains(e)).toList();
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
        final svt = widget.targetSvt?.id == svtId ? widget.targetSvt : db.gameData.servantsById[svtId];
        if (svt == null) continue;
        if (!ServantFilterPage.filter(svtFilterData, svt)) continue;
        final sameLimitCounts = _intersectionSetList(
          usedCeIds.map((ceId) => allCeMatchSvtData[ceId]![svtId]?.toSet() ?? <int>{}).toList(),
        );
        for (final ceId in excludeCeIds) {
          final excludeLimitCounts = allCeMatchSvtData[ceId]![svt.id] ?? [];
          sameLimitCounts.removeAll(excludeLimitCounts);
        }

        if (sameLimitCounts.isNotEmpty) {
          svts.add((svt: svt, limitCounts: sameLimitCounts.toList()));
        }
      }
      if (svts.isEmpty) continue;
      final rateCount = Maths.sum(usedCeIds.map((e) => allCeData[e]!.rateCount));
      resultData.add((ceIds: usedCeIds, rateCount: rateCount, svts: svts));
    }

    // show svts with no bonus for all ces
    if (ceFilterStates.values.every((e) => e == _FilterType.none) && widget.targetSvt == null) {
      final bonusSvtIds = <int>{for (final v in allCeMatchSvtData.values) ...v.keys};
      List<({Servant svt, List<int> limitCounts})> svts = [];
      for (final svt in db.gameData.servantsById.values) {
        if (!ServantFilterPage.filter(svtFilterData, svt)) continue;
        if (svt.collectionNo > 0 && !bonusSvtIds.contains(svt.id)) {
          svts.add((svt: svt, limitCounts: []));
        }
      }
      resultData.add((ceIds: [], rateCount: 0, svts: svts));
    }
    for (final record in resultData) {
      record.svts.sort(
        (a, b) =>
            SvtFilterData.compare(a.svt, b.svt, keys: svtFilterData.sortKeys, reversed: svtFilterData.sortReversed),
      );
    }
    resultData.sortByList((e) => [-e.rateCount, e.ceIds.length, -e.svts.length, ...e.ceIds]);

    return resultData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: mainBody),
        kDefaultDivider,
        buttonBar,
      ],
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
            children: svts.map((x) {
              final (:svt, :limitCounts) = x;
              final allLimitCounts = _getSvtAllLimits(svt);
              final conditional = limitCounts.length != allLimitCounts.length && limitCounts.isNotEmpty;
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
                        name = '${S.current.ascension_short} $limitCount (${S.current.ascension_stage_short} $stage)';
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
    final filterBtn = IconButton(
      icon: const Icon(Icons.filter_alt),
      tooltip: S.current.filter,
      onPressed: () => FilterPage.show(
        context: context,
        builder: (context) => ServantFilterPage(
          filterData: svtFilterData,
          onChanged: (_) {
            if (mounted) setState(() {});
          },
          planMode: false,
        ),
      ),
    );
    final List<Widget> ceBtns = ces.map((ce) {
      final curStatus = getCeState(ce.ce.id);
      return InkWell(
        onTap: () {
          router.showDialog(
            builder: (context) => SimpleDialog(
              title: Text.rich(
                TextSpan(
                  children: [
                    CenterWidgetSpan(
                      child: ce.ce.iconBuilder(context: context, width: 32, padding: EdgeInsets.all(2)),
                    ),
                    TextSpan(text: ce.ce.lName.l),
                  ],
                ),
              ),
              children: [
                SimpleDialogOption(
                  onPressed: ce.ce.routeTo,
                  child: Text.rich(
                    TextSpan(
                      text: '[+${ce.rateCount.format(percent: true, base: 10)}] ',
                      children: SharedBuilder.traitsListSpans(context: context, traitsList: ce.traits),
                    ),
                  ),
                ),
                kDefaultDivider,
                for (final type in _FilterType.values)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
                    title: Text(
                      curStatus == type ? '${type.shownName} (${S.current.current_})' : type.shownName,
                      style: TextStyle(color: type.color),
                    ),
                    subtitle: Text(type.hint),
                    onTap: () {
                      ceFilterStates[ce.ce.id] = type;
                      Navigator.pop(context);
                      if (mounted) setState(() {});
                    },
                  ),
              ],
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IgnorePointer(
              child: FilterOption(
                selected: curStatus != _FilterType.none,
                value: ce.ce.id,
                shrinkWrap: true,
                constraints: BoxConstraints(),
                selectedColor: curStatus.color,
                child: ce.ce.iconBuilder(context: context, jumpToDetail: false, width: 36, padding: EdgeInsets.all(3)),
              ),
            ),
            SizedBox(
              width: 36,
              height: 20,
              child: AutoSizeText(
                curStatus == _FilterType.none ? '-' : curStatus.shownName,
                maxLines: 1,
                minFontSize: 2,
                maxFontSize: 12,
                style: TextStyle(color: curStatus.color),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }).toList();
    return SafeArea(
      right: false,
      child: Padding(
        padding: EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 2,
          runSpacing: 1,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [filterBtn, ...ceBtns],
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
