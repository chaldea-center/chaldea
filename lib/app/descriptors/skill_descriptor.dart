import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../generated/l10n.dart';
import '../modules/skill/skill_detail.dart';
import '../modules/skill/td_detail.dart';
import 'func/func.dart';

class SkillDescriptor extends StatelessWidget with FuncsDescriptor, _SkillDescriptorMixin {
  final BaseSkill skill;
  final int? level; // 1-10
  final bool showPlayer;
  final bool showEnemy;
  final bool showNone;
  final bool hideDetail;
  final bool showBuffDetail;
  final bool jumpToDetail;
  final bool showExtraPassiveCond;
  final bool showEvent;
  final Region? region;
  final List<OverwriteSkillData> overwrites;
  final Servant? overwriteServant;

  const SkillDescriptor({
    super.key,
    required this.skill,
    this.level,
    this.showPlayer = true,
    this.showEnemy = false,
    this.showNone = false,
    this.hideDetail = false,
    this.showBuffDetail = false,
    this.jumpToDetail = true,
    this.showExtraPassiveCond = true,
    this.showEvent = true,
    this.region,
    this.overwrites = const [],
    this.overwriteServant,
  });

  const SkillDescriptor.only({
    super.key,
    required this.skill,
    required bool isPlayer,
    this.level,
    this.showNone = false,
    this.hideDetail = false,
    this.showBuffDetail = false,
    this.jumpToDetail = true,
    this.showExtraPassiveCond = true,
    this.showEvent = true,
    this.region,
    this.overwrites = const [],
    this.overwriteServant,
  }) : showPlayer = isPlayer,
       showEnemy = !isPlayer;

  static Widget fromId({required int id, required WidgetDataBuilder<BaseSkill> builder, Region? region}) {
    return FutureBuilder2(
      id: '$id$region',
      loader: () async {
        region ??= Region.jp;
        BaseSkill? skill;
        if (region == Region.jp) skill = db.gameData.baseSkills[id];
        return skill ?? await AtlasApi.skill(id, region: region!);
      },
      builder: (context, skill) {
        if (skill == null) return Text('${S.current.skill} $id');
        return builder(context, skill);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cds = skill.coolDown.toSet().toList()..sort2((e) => -e);

    final header = _buildHeader(context, cds);
    const divider = Divider(indent: 16, endIndent: 16, height: 2, thickness: 1);
    final detailText = skill.lDetail ?? '???';

    final loops = LoopTargets()..addSkill(skill.id);
    final costumeReleaseWidget = getEquipCostumeConditions(context, skill.skillSvts);

    Widget child = TileGroup(
      children: [
        ?costumeReleaseWidget,
        header,
        if (overwrites.isNotEmpty)
          _AscensionOverwriteSection(
            key: ValueKey('skill-overwrites-${skill.id}'),
            previewName: Transl.skillNames(overwrites.first.skillName).l,
            indent: 16,
            children: [
              for (final entry in overwrites)
                _buildOverwriteEntry(
                  context,
                  _overwriteCondition(overwriteServant, entry.ascensions, entry.costumes),
                  _buildHeader(context, cds, overwriteName: entry.skillName),
                ),
            ],
          ),
        if (!hideDetail) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
            child: Text(detailText, style: Theme.of(context).textTheme.bodySmall),
          ),
          divider,
        ],
        ...describeFunctions(
          funcs: skill.functions,
          script: skill.script,
          owner: skill,
          level: level,
          showPlayer: showPlayer,
          showEnemy: showEnemy,
          showNone: showNone,
          showBuffDetail: showBuffDetail,
          showEvent: showEvent,
          loops: loops,
          region: region,
        ),
      ],
    );

    return InheritSelectionArea(child: child);
  }

  Widget _buildHeader(BuildContext context, List<int> cds, {String? overwriteName}) {
    final isOverwrite = overwriteName != null;
    final name = isOverwrite ? Transl.skillNames(overwriteName).l : skill.lName.l;
    return CustomTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
      leading: db.getIconImage(skill.icon ?? Atlas.common.unknownSkillIcon, width: 33, aspectRatio: 1),
      title: Text.rich(
        TextSpan(
          text: name,
          children: [
            if (!isOverwrite && skill.skillAdd.isNotEmpty)
              CenterWidgetSpan(
                child: InkWell(
                  onTap: () => showDialog(context: context, useRootNavigator: false, builder: _skillAddDialog),
                  child: Icon(Icons.info_outline, size: 16, color: Theme.of(context).hintColor),
                ),
              ),
            if (!isOverwrite && skill is NiceSkill && (skill as NiceSkill).extraPassive.isNotEmpty)
              CenterWidgetSpan(
                child: InkWell(
                  onTap: () => showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => _extraPassiveDialog(context, skill as NiceSkill),
                  ),
                  child: Icon(Icons.info_outline, size: 16, color: Theme.of(context).hintColor),
                ),
              ),
          ],
        ),
      ),
      subtitle: isOverwrite
          ? (skill.ruby.isEmpty ? null : Text(skill.ruby))
          : Transl.isJP || hideDetail || (skill.lName.l == skill.name && skill.lName.m?.ofRegion() == null)
          ? null
          : Text(skill.name),
      trailing: cds.isEmpty || (cds.length == 1 && cds.single <= 0)
          ? null
          : cds.length == 1
          ? Text('   CD: ${cds.single}')
          : Text.rich(
              TextSpan(
                text: '   CD: ',
                children: divideList([
                  for (final cd in cds)
                    TextSpan(
                      text: cd.toString(),
                      style: skill.coolDown.getOrNull((level ?? 0) - 1) == cd
                          ? TextStyle(color: AppTheme.ofExtra(context).accent)
                          : null,
                    ),
                ], const TextSpan(text: '→')),
              ),
            ),
      onTap: !isOverwrite && jumpToDetail
          ? () => skill.routeTo(
              region: region,
              child: SkillDetailPage(
                skill: skill,
                region: region,
                initView: FuncApplyTarget.fromBool(showPlayer: showPlayer, showEnemy: showEnemy),
              ),
            )
          : null,
    );
  }

  Widget _skillAddDialog(BuildContext context) {
    List<Widget> children = [];
    for (final skillAdd in skill.skillAdd) {
      children.add(
        ListTile(
          title: Text(Transl.skillNames(skillAdd.name).l),
          subtitle: Transl.isJP ? Text(skillAdd.ruby) : Text('${skillAdd.ruby}\n${skillAdd.name}'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      );
      for (final release in skillAdd.releaseConditions) {
        children.add(
          CondTargetValueDescriptor(
            condType: release.condType,
            target: release.condId,
            value: release.condNum,
            textScaleFactor: 0.8,
            leading: const TextSpan(text: ' ꔷ '),
          ),
        );
      }
    }

    return SimpleConfirmDialog(
      // title: Text(skill.lName.l),
      content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: children),
      showCancel: false,
      scrollable: true,
    );
  }

  Widget _extraPassiveDialog(BuildContext context, NiceSkill skill) {
    List<Widget> children = [];
    skill.extraPassive.sort((a, b) => a.num == b.num ? a.priority - b.priority : a.num - b.num);
    final style = Theme.of(context).textTheme.bodySmall;
    for (int index = 0; index < skill.extraPassive.length; index++) {
      final cond = skill.extraPassive[index];
      List<Widget> condDetails = [Text('num ${cond.num} priority ${cond.priority}', style: style)];
      if (cond.condQuestId != 0) {
        condDetails.add(
          CondTargetValueDescriptor(
            condType: CondType.questClearPhase,
            target: cond.condQuestId,
            value: cond.condQuestPhase,
            leading: const TextSpan(text: ' ꔷ '),
            style: style,
          ),
        );
      }
      if (cond.condLv != 0) {
        condDetails.add(Text(' ꔷ Servant Level ${cond.condLv}', style: style));
      }
      if (cond.condLimitCount != 0) {
        condDetails.add(Text(' ꔷ ${S.current.ascension} ${cond.condLimitCount}', style: style));
      }
      if (cond.condFriendshipRank != 0) {
        condDetails.add(Text(' ꔷ ${S.current.bond} Lv.${cond.condFriendshipRank}', style: style));
      }
      if (cond.script != null) print(cond.script?.condIndividuality);
      if (cond.script?.condIndividuality?.isNotEmpty == true) {
        condDetails.add(
          Text.rich(
            TextSpan(
              text: ' ꔷ ${S.current.trait}: ',
              children: SharedBuilder.traitSpans(context: context, traits: cond.script?.condIndividuality ?? []),
            ),
            style: style,
          ),
        );
      }

      final eventIds = cond.getValidEventIds();
      for (final eventId in eventIds) {
        final event = db.gameData.events[eventId];
        condDetails.add(
          Text.rich(
            TextSpan(
              text: ' ꔷ ${S.current.event} ',
              children: [
                SharedBuilder.textButtonSpan(
                  context: context,
                  text: event?.lName.l ?? eventId.toString(),
                  onTap: () => router.push(url: Routes.eventI(eventId)),
                ),
              ],
            ),
            style: style,
          ),
        );
      }
      if (eventIds.isEmpty && cond.isLimited) {
        condDetails.add(
          Text(
            ' ꔷ ${[cond.startedAt, cond.endedAt].map((e) => e.sec2date().toDateString()).join(' ~ ')}',
            style: style,
          ),
        );
      }
      for (final release in cond.releaseConditions) {
        condDetails.add(
          CondTargetValueDescriptor.commonRelease(
            commonRelease: release,
            leading: const TextSpan(text: ' ꔷ '),
            style: style,
          ),
        );
      }
      condDetails.add(const SizedBox(height: 4));
      children.add(
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: condDetails),
      );
    }

    return SimpleConfirmDialog(
      title: Text(skill.lName.l),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(children),
      ),
      showCancel: false,
      scrollable: true,
    );
  }
}

class OverwriteSkillData {
  final String skillName;
  final List<int> ascensions = [];
  final List<int> costumes = [];

  OverwriteSkillData(this.skillName);

  static List<OverwriteSkillData> fromAscensionAdd(AscensionAdd data, int skillId) {
    final results = <OverwriteSkillData>[];

    void add(int key, List<OverwriteValue> names, bool isCostume) {
      final name = names.firstWhereOrNull((e) => e.id == skillId)?.value;
      if (name == null || name.isEmpty) return;
      OverwriteSkillData? result = results.firstWhereOrNull((e) => e.skillName == name);
      if (result == null) {
        result = OverwriteSkillData(name);
        results.add(result);
      }
      (isCostume ? result.costumes : result.ascensions).add(key);
    }

    for (final key in data.overwriteSkillName.ascension.keys.toList()..sort()) {
      add(key, data.overwriteSkillName.ascension[key]!, false);
    }
    for (final key in data.overwriteSkillName.costume.keys.toList()..sort()) {
      add(key, data.overwriteSkillName.costume[key]!, true);
    }
    return results;
  }
}

class OverwriteTDData {
  final String? tdName;
  final String? tdRuby;
  final String? tdFileName;
  final String? tdRank;
  final String? tdTypeText;

  final List<int> ascensions = [];
  final List<int> costumes = [];

  OverwriteTDData({
    required this.tdName,
    required this.tdRuby,
    required this.tdFileName,
    required this.tdRank,
    required this.tdTypeText,
  });

  static List<OverwriteTDData> fromAscensionAdd(AscensionAdd data) {
    final results = <OverwriteTDData>[];

    void add(int key, bool isCostume) {
      String? get(AscensionAddEntry<String> entry) => isCostume ? entry.costume[key] : entry.ascension[key];
      final value = OverwriteTDData(
        tdName: get(data.overWriteTDName),
        tdRuby: get(data.overWriteTDRuby),
        tdFileName: get(data.overWriteTDFileName),
        tdRank: get(data.overWriteTDRank),
        tdTypeText: get(data.overWriteTDTypeText),
      );
      final result = results.firstWhereOrNull((e) => e._sameValues(value)) ?? value;
      if (identical(result, value)) results.add(value);
      (isCostume ? result.costumes : result.ascensions).add(key);
    }

    final ascensions = <int>{
      ...data.overWriteTDName.ascension.keys,
      ...data.overWriteTDRuby.ascension.keys,
      ...data.overWriteTDFileName.ascension.keys,
      ...data.overWriteTDRank.ascension.keys,
      ...data.overWriteTDTypeText.ascension.keys,
    }.toList()..sort();
    final costumes = <int>{
      ...data.overWriteTDName.costume.keys,
      ...data.overWriteTDRuby.costume.keys,
      ...data.overWriteTDFileName.costume.keys,
      ...data.overWriteTDRank.costume.keys,
      ...data.overWriteTDTypeText.costume.keys,
    }.toList()..sort();
    for (final key in ascensions) {
      add(key, false);
    }
    for (final key in costumes) {
      add(key, true);
    }
    return results;
  }

  bool _sameValues(OverwriteTDData other) =>
      tdName == other.tdName &&
      tdRuby == other.tdRuby &&
      tdFileName == other.tdFileName &&
      tdRank == other.tdRank &&
      tdTypeText == other.tdTypeText;
}

String _overwriteCondition(Servant? servant, List<int> ascensions, List<int> costumes) {
  return [
    if (ascensions.isNotEmpty) '${S.current.ascension_short} ${ascensions.join('&')}',
    if (costumes.isNotEmpty)
      '${S.current.costume} ${costumes.map((id) => servant?.costume[id]?.lName.l ?? id.toString()).join(' & ')}',
  ].join(' · ');
}

Widget _buildOverwriteEntry(BuildContext context, String condition, Widget header, {String? fileName}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
        child: Text(condition, style: Theme.of(context).textTheme.labelSmall),
      ),
      header,
      // if (fileName != null)
      //   Padding(
      //     padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      //     child: Text('${S.current.filename}: $fileName', style: Theme.of(context).textTheme.bodySmall),
      //   ),
    ],
  );
}

class _AscensionOverwriteSection extends StatefulWidget {
  final String previewName;
  final double indent;
  final List<Widget> children;

  const _AscensionOverwriteSection({
    super.key,
    required this.previewName,
    required this.indent,
    required this.children,
  });

  @override
  State<_AscensionOverwriteSection> createState() => _AscensionOverwriteSectionState();
}

class _AscensionOverwriteSectionState extends State<_AscensionOverwriteSection> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(widget.indent, 4, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${S.current.ascension_info_changes}: ${widget.previewName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18),
              ],
            ),
          ),
        ),
        if (expanded)
          ...divideTiles(
            widget.children,
            divider: const Divider(indent: 16, endIndent: 16, height: 4),
            top: true,
            bottom: true,
          ),
      ],
    );
  }
}

class TdDescriptor extends StatelessWidget with FuncsDescriptor, _SkillDescriptorMixin {
  final BaseTd td;
  final int? level;
  final int? oc;
  final bool showPlayer;
  final bool showEnemy;
  final bool showNone;
  final List<OverwriteTDData> overwrites;
  final Servant? overwriteServant;
  final bool jumpToDetail;
  final Region? region;
  final bool isBaseTd;

  const TdDescriptor({
    super.key,
    required this.td,
    this.level,
    this.oc,
    this.showPlayer = true,
    this.showEnemy = false,
    this.showNone = false,
    this.overwrites = const [],
    this.overwriteServant,
    this.jumpToDetail = true,
    this.region,
    this.isBaseTd = false,
  });

  const TdDescriptor.only({
    super.key,
    required this.td,
    required bool isPlayer,
    this.level,
    this.oc,
    this.showNone = false,
    this.overwrites = const [],
    this.overwriteServant,
    this.jumpToDetail = true,
    this.region,
    this.isBaseTd = false,
  }) : showPlayer = isPlayer,
       showEnemy = !isPlayer;

  @override
  Widget build(BuildContext context) {
    final ref = RefMemo();
    if (isBaseTd) {
      ref.add('base');
    }
    if (td.getIndividuality().every((e) => e != Trait.cardNP.value)) {
      ref.add('cardNP');
    }
    final baseTrait = CardType.getBaseTrait(td.svt.card);
    if (baseTrait != null && td.getIndividuality().every((e) => e != baseTrait.value)) {
      ref.add('cardTrait');
    }
    const divider = Divider(indent: 16, endIndent: 16, height: 2, thickness: 1);
    final header = _buildHeader(context);
    final detailText = td.lDetail ?? '???';

    final costumeReleaseWidget = getEquipCostumeConditions(context, td.npSvts);

    Widget child = TileGroup(
      children: [
        ?costumeReleaseWidget,
        header,
        if (overwrites.isNotEmpty)
          _AscensionOverwriteSection(
            key: ValueKey('td-overwrites-${td.id}'),
            previewName: _overwritePreview(overwrites.first),
            indent: 16,
            children: [
              for (final entry in overwrites)
                _buildOverwriteEntry(
                  context,
                  _overwriteCondition(overwriteServant, entry.ascensions, entry.costumes),
                  _buildHeader(context, overwrite: entry),
                  fileName: entry.tdFileName,
                ),
            ],
          ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
          child: Text(detailText, style: Theme.of(context).textTheme.bodySmall),
        ),
        divider,
        ...describeFunctions(
          funcs: td.functions,
          script: td.script,
          owner: td,
          level: level,
          oc: oc,
          showPlayer: showPlayer,
          showEnemy: showEnemy,
          showNone: showNone,
          loops: LoopTargets()..addSkill(td.id),
          region: region,
        ),
        CustomTable(
          children: [
            CustomTableRow.fromTexts(
              texts: const ['Buster', 'Arts', 'Quick', 'Extra', 'NP', 'Def'],
              defaults: TableCellData(isHeader: true, maxLines: 1),
            ),
            CustomTableRow.fromTexts(
              texts: [
                td.npGain.buster,
                td.npGain.arts,
                td.npGain.quick,
                td.npGain.extra,
                td.npGain.np,
                td.npGain.defence,
              ].map((e) => '${e.first / 100}%').toList(),
            ),
            CustomTableRow(
              children: [
                TableCellData(
                  child: Text.rich(
                    TextSpan(
                      text: 'Hits',
                      children: [if (isBaseTd) SpecialTextSpan.superscript('[${ref.add("base")}]')],
                    ),
                  ),
                  isHeader: true,
                ),
                TableCellData(
                  text: td.svt.damage.isEmpty
                      ? '   -  '
                      : '   ${td.svt.damage.length} Hits '
                            '(${td.svt.damage.join(', ')})  ',
                  flex: 5,
                  alignment: Alignment.centerLeft,
                  style: TextStyle(
                    fontStyle: isBaseTd ? FontStyle.italic : null,
                    decoration: td.damageType == TdEffectFlag.support ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (ref._tags.isNotEmpty)
          SFooter(
            [
              if (ref.contain('base')) '[${ref.add("base")}] ${S.current.td_base_hits_hint}',
              if (ref.contain("cardNP"))
                '[${ref.add("cardNP")}] ${S.current.td_cardnp_hint(Transl.traitName(Trait.cardNP.value))}',
              if (ref.contain("cardTrait"))
                '[${ref.add("cardTrait")}] ${S.current.td_cardcolor_hint(CardType.getName(td.svt.card).toTitle(), Transl.traitName(baseTrait!.value))}',
            ].join('\n'),
          ),
      ],
    );
    return InheritSelectionArea(child: child);
  }

  Widget _buildHeader(BuildContext context, {OverwriteTDData? overwrite}) {
    final tdType = Transl.tdTypes(overwrite?.tdTypeText ?? td.type);
    final tdRank = overwrite?.tdRank ?? td.rank;
    final tdName = Transl.tdNames(overwrite?.tdName ?? td.name);
    final tdRuby = Transl.tdRuby(overwrite?.tdRuby ?? td.ruby);
    return CustomTile(
      leading: Column(
        children: <Widget>[
          CommandCardWidget(card: td.svt.card, width: 90),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110 * 0.9),
            child: Text('${tdType.l} $tdRank', style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
          ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tdRuby.l,
            textScaler: const TextScaler.linear(0.95),
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          Text(tdName.l, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (!Transl.isJP) ...[
            Text(
              tdRuby.jp,
              textScaler: const TextScaler.linear(0.95),
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            Text(tdName.jp, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ],
      ),
      onTap: overwrite == null && jumpToDetail
          ? () => td.routeTo(
              region: region,
              child: TdDetailPage(
                td: td,
                region: region,
                initView: FuncApplyTarget.fromBool(showPlayer: showPlayer, showEnemy: showEnemy),
              ),
            )
          : null,
    );
  }

  String _overwritePreview(OverwriteTDData entry) {
    if (entry.tdName != null && entry.tdName != td.name) return Transl.tdNames(entry.tdName!).l;
    if (entry.tdRuby != null && entry.tdRuby != td.ruby) return Transl.tdRuby(entry.tdRuby!).l;
    if (entry.tdRank != null && entry.tdRank != td.rank) return 'Rank ${entry.tdRank}';
    if (entry.tdTypeText != null && entry.tdTypeText != td.type) return Transl.tdTypes(entry.tdTypeText!).l;
    return entry.tdFileName ?? td.lName.l;
  }
}

mixin _SkillDescriptorMixin {
  Widget? getEquipCostumeConditions(BuildContext context, List<SkillSvtBase> skillSvts) {
    List<InlineSpan> spans = [];

    for (final skillSvt in skillSvts) {
      final releaseConditions = skillSvt.releaseConditions
          .where((e) => e.condType == CondType.equipWithTargetCostume && e.condTargetId == skillSvt.svtId)
          .toList();
      if (releaseConditions.isEmpty) continue;

      for (final release in releaseConditions) {
        final svtId = release.condTargetId;
        final svt = db.gameData.servantsById[svtId] ?? db.gameData.entities[svtId];
        final limitCount = release.condNum;
        NiceCostume? costume;
        if (limitCount > 0 && svt is Servant) {
          costume = svt.getCostume(limitCount);
        }
        if (costume != null) {
          spans.addAll([
            CenterWidgetSpan(child: db.getIconImage(costume.borderedIcon, onTap: costume.routeTo, width: 36)),
            SharedBuilder.textButtonSpan(context: context, text: costume.lName.l, onTap: costume.routeTo),
            const TextSpan(text: '  '),
          ]);
        } else if (svt != null) {
          String? overrideIcon;
          if (svt is Servant) {
            overrideIcon = svt.ascendIcon(limitCount);
          }
          spans.addAll([
            CenterWidgetSpan(
              child: svt.iconBuilder(context: context, width: 36, overrideIcon: overrideIcon),
            ),
            TextSpan(text: ' ${S.current.ascension_stage_short} $limitCount  '),
          ]);
        } else {
          spans.addAll([
            SharedBuilder.textButtonSpan(
              context: context,
              text: svtId.toString(),
              onTap: () {
                router.push(url: Routes.servantI(svtId));
              },
            ),
            TextSpan(text: ' ${S.current.ascension_stage_short} $limitCount  '),
          ]);
        }
      }
    }
    if (spans.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}

class RefMemo {
  bool alphabetic;
  RefMemo([this.alphabetic = false]);
  final List<String> _tags = [];

  bool contain(String key) => _tags.contains(key);

  String add(String key) {
    int index = _tags.indexOf(key);
    if (index < 0) {
      _tags.add(key);
      index = _tags.length - 1;
    }
    if (alphabetic) {
      return index2alpha(index);
    } else {
      return index.toString();
    }
  }

  static String index2alpha(int index) {
    const ab = 'abcdefghijklmnopqrstuvwxyz';
    String s = '';
    do {
      s = ab[index % ab.length] + s;
      index ~/= ab.length;
    } while (index > 0);
    return s;
  }
}
