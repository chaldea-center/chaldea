import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';

class TransformSvtProfileTabber extends StatelessWidget {
  final Servant svt;
  final Widget Function(BuildContext context, Servant svt, SvtOverwriteViewData? overwriteData) builder;
  const TransformSvtProfileTabber({super.key, required this.svt, required this.builder});

  @override
  Widget build(BuildContext context) {
    if (svt.type == SvtType.heroine) {
      final costumeVariants = <SvtOverwriteViewData>[
        getOverwriteData([12, 13, 18], false),
        getOverwriteData([17], false),
        // getOverwriteData([18], true),
        getOverwriteData([19], true),
      ];
      final normalData = SvtOverwriteViewData(svt)
        ..name = svt.lName.l
        ..icon = svt.borderedIcon
        ..activeSkills = {for (final (k, v) in svt.groupedActiveSkills.items) k: List.of(v)}
        ..tds = {for (final (k, v) in svt.groupedNoblePhantasms.items) k: List.of(v)};
      for (final variant in costumeVariants) {
        for (final (skillNum, skills) in variant.activeSkills.items) {
          normalData.activeSkills[skillNum]?.removeWhere((e) => skills.contains(e));
        }
        normalData.activeSkills.removeWhere((k, v) => v.isEmpty);

        for (final (tdNum, tds) in variant.tds.items) {
          normalData.tds[tdNum]?.removeWhere((e) => tds.contains(e));
        }
        normalData.tds.removeWhere((k, v) => v.isEmpty);
      }

      costumeVariants.insert(0, normalData);

      return _buildTabber(context, [for (final v in costumeVariants) (svt: svt, overwriteData: v)]);
    } else {
      final List<Servant> transformVariants = [svt];
      for (final skill in [...svt.skills, ...svt.noblePhantasms]) {
        for (final func in skill.filteredFunction(showPlayer: true, showEnemy: true, includeTrigger: true)) {
          if (func is! NiceFunction) continue;
          if (func.funcType == FuncType.transformServant) {
            final transformSvt = db.gameData.servantsById[func.svals.firstOrNull?.Value];
            if (transformSvt != null && transformVariants.every((e) => e.id != transformSvt.id)) {
              transformVariants.add(transformSvt);
            }
          }
        }
      }
      return _buildTabber(context, transformVariants.map((e) => (svt: e, overwriteData: null)).toList());
    }
  }

  SvtOverwriteViewData getOverwriteData(List<int> costumeIds, bool isStory) {
    final data = SvtOverwriteViewData(svt);
    final firstCostume = svt.costume.values.firstWhereOrNull((e) => e.id == costumeIds.first);
    data.name = firstCostume?.lName.l.setMaxLines(1) ?? "${S.current.costume} ${costumeIds.join('/')}";
    if (isStory) {
      data.name = '${data.name}(Story)';
    }
    data.icon = firstCostume?.borderedIcon;

    final activeSkills = svt.skills
        .where(
          (skill) => skill.skillSvts
              .expand((skillSvt) => skillSvt.releaseConditions)
              .any((cond) => cond.condType == CondType.equipWithTargetCostume && costumeIds.contains(cond.condNum)),
        )
        .toList();
    for (final skill in activeSkills) {
      data.activeSkills.putIfAbsent(skill.svt.num, () => []).add(skill);
    }

    Set<int> classPassives = {};
    for (final costumeId in costumeIds) {
      classPassives.addAll(svt.ascensionAdd.overwriteClassPassive.costume[costumeId] ?? []);
    }
    if (classPassives.isNotEmpty) {
      data.classPassives = [
        for (final skillId in classPassives)
          if (db.gameData.baseSkills.containsKey(skillId)) db.gameData.baseSkills[skillId]!.toNice(),
      ];
    }

    final tds = svt.noblePhantasms
        .where(
          (td) => td.npSvts
              .expand((npSvt) => npSvt.releaseConditions)
              .any((cond) => cond.condType == CondType.equipWithTargetCostume && costumeIds.contains(cond.condNum)),
        )
        .toSet();
    for (final td in tds.toSet()) {
      final tdTypeChangeIds = td.script?.tdTypeChangeIDs ?? [];
      tds.addAll(svt.noblePhantasms.where((e) => tdTypeChangeIds.contains(e.id)));
    }
    for (final td in tds) {
      data.tds.putIfAbsent(td.svt.num, () => []).add(td);
    }

    return data;
  }

  Widget _buildTabber(
    BuildContext context,
    List<({Servant svt, SvtOverwriteViewData? overwriteData})> transformVariants,
  ) {
    if (transformVariants.length == 1) {
      return builder(context, transformVariants.single.svt, transformVariants.single.overwriteData);
    }

    return DefaultTabController(
      length: transformVariants.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    tabs: [for (final e in transformVariants) buildHeader(context, e.svt, e.overwriteData)],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(children: [for (final e in transformVariants) builder(context, e.svt, e.overwriteData)]),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget buildHeader(BuildContext context, Servant svt, SvtOverwriteViewData? overwriteData) {
    String name = overwriteData?.name ?? (svt == this.svt ? svt.lName.l : '${svt.lName.l}(${svt.id})');
    return Tab(
      child: Text.rich(
        TextSpan(
          children: [
            CenterWidgetSpan(
              child: overwriteData?.icon != null
                  ? db.getIconImage(overwriteData?.icon, width: 24)
                  : svt.iconBuilder(context: context, width: 24),
            ),
            TextSpan(text: ' $name'),
          ],
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class SvtOverwriteViewData {
  Servant svt;
  String? name;
  String? icon;
  Map<int, List<NiceSkill>> activeSkills = {};
  List<NiceSkill> classPassives = [];
  Map<int, List<NiceTd>> tds = {};
  SvtOverwriteViewData(this.svt);
}
