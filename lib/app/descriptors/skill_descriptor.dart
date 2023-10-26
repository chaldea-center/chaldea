import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../generated/l10n.dart';
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
  })  : showPlayer = isPlayer,
        showEnemy = !isPlayer;

  static Widget fromId({
    required int id,
    required WidgetDataBuilder<BaseSkill> builder,
    Region? region,
  }) {
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
    int cd0 = 0, cd1 = 0;
    if (skill.coolDown.isNotEmpty) {
      cd0 = skill.coolDown.first;
      cd1 = skill.coolDown.last;
    }

    final header = CustomTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
      leading: db.getIconImage(skill.icon ?? Atlas.common.unknownSkillIcon, width: 33, aspectRatio: 1),
      title: Text.rich(TextSpan(text: skill.lName.l, children: [
        if (skill.skillAdd.isNotEmpty)
          CenterWidgetSpan(
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                useRootNavigator: false,
                builder: _skillAddDialog,
              ),
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        if (skill is NiceSkill && (skill as NiceSkill).extraPassive.isNotEmpty)
          CenterWidgetSpan(
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => _extraPassiveDialog(context, skill as NiceSkill),
              ),
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
      ])),
      subtitle: Transl.isJP || hideDetail || (skill.lName.l == skill.name && skill.lName.m?.ofRegion() == null)
          ? null
          : Text(skill.name),
      trailing: cd0 <= 0 && cd1 <= 0
          ? null
          : cd0 == cd1
              ? Text('   CD: $cd0')
              : Text('   CD: $cd0→$cd1'),
      onTap: jumpToDetail ? () => skill.routeTo(region: region) : null,
    );
    const divider = Divider(indent: 16, endIndent: 16, height: 2, thickness: 1);
    final detailText = skill.lDetail ?? '???';

    final loops = LoopTargets()..addSkill(skill.id);
    final costumeReleaseWidget = getEquipCostumeConditions(context, skill.skillSvts);

    Widget child = TileGroup(
      children: [
        if (costumeReleaseWidget != null) costumeReleaseWidget,
        header,
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

  Widget _skillAddDialog(BuildContext context) {
    List<Widget> children = [];
    for (final skillAdd in skill.skillAdd) {
      children.add(ListTile(
        title: Text(Transl.skillNames(skillAdd.name).l),
        subtitle: Transl.isJP ? Text(skillAdd.ruby) : Text('${skillAdd.ruby}\n${skillAdd.name}'),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ));
      for (final release in skillAdd.releaseConditions) {
        children.add(CondTargetValueDescriptor(
          condType: release.condType,
          target: release.condId,
          value: release.condNum,
          textScaleFactor: 0.8,
          leading: const TextSpan(text: ' ꔷ '),
        ));
      }
    }

    return SimpleCancelOkDialog(
      // title: Text(skill.lName.l),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
      hideCancel: true,
      scrollable: true,
    );
  }

  Widget _extraPassiveDialog(BuildContext context, NiceSkill skill) {
    List<Widget> children = [];
    skill.extraPassive.sort((a, b) => a.num == b.num ? a.priority - b.priority : a.num - b.num);
    final style = Theme.of(context).textTheme.bodySmall;
    for (int index = 0; index < skill.extraPassive.length; index++) {
      final cond = skill.extraPassive[index];
      List<Widget> condDetails = [];
      if (cond.condQuestId != 0) {
        condDetails.add(CondTargetValueDescriptor(
          condType: CondType.questClearPhase,
          target: cond.condQuestId,
          value: cond.condQuestPhase,
          leading: const TextSpan(text: ' ꔷ '),
          style: style,
        ));
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
      if (cond.eventId != 0) {
        final event = db.gameData.events[cond.eventId];
        condDetails.add(Text(' ꔷ ${S.current.event} ${event?.lName.l ?? cond.eventId}', style: style));
      }
      children.add(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: condDetails,
      ));
    }

    return SimpleCancelOkDialog(
      title: Text(skill.lName.l),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(children),
      ),
      hideCancel: true,
      scrollable: true,
    );
  }
}

class OverrideTDData {
  final String? tdName;
  final String? tdRuby;
  final String? tdFileName;
  final String? tdRank;
  final String? tdTypeText;

  final List<int> keys;

  OverrideTDData({
    required this.tdName,
    required this.tdRuby,
    required this.tdFileName,
    required this.tdRank,
    required this.tdTypeText,
  }) : keys = [];

  static List<OverrideTDData> fromAscensionAdd(AscensionAdd data) {
    List<OverrideTDData> tds = [];
    for (final key in data.overWriteTDName.all.keys) {
      final v = OverrideTDData(
        tdName: data.overWriteTDName.all[key],
        tdRuby: data.overWriteTDRuby.all[key],
        tdFileName: data.overWriteTDFileName.all[key],
        tdRank: data.overWriteTDRank.all[key],
        tdTypeText: data.overWriteTDTypeText.all[key],
      );
      v.keys.add(key);
      final td = tds.firstWhereOrNull((e) => e._hashCode == v._hashCode);
      if (td == null) {
        tds.add(v);
      } else {
        td.keys.add(key);
      }
    }
    return tds;
  }

  int get _hashCode => Object.hash(tdName, tdRuby, tdFileName, tdRank, tdTypeText);
}

class TdDescriptor extends StatelessWidget with FuncsDescriptor, _SkillDescriptorMixin {
  final BaseTd td;
  final int? level;
  final int? oc;
  final bool showPlayer;
  final bool showEnemy;
  final bool showNone;
  final OverrideTDData? overrideData;
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
    this.overrideData,
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
    this.overrideData,
    this.jumpToDetail = true,
    this.region,
    this.isBaseTd = false,
  })  : showPlayer = isPlayer,
        showEnemy = !isPlayer;
  final cardMap = const <CardType, Trait>{
    CardType.quick: Trait.cardQuick,
    CardType.arts: Trait.cardArts,
    CardType.buster: Trait.cardBuster,
    CardType.weak: Trait.cardWeak,
    CardType.strength: Trait.cardStrong,
  };
  @override
  Widget build(BuildContext context) {
    final ref = RefMemo();
    if (isBaseTd) {
      ref.add('base');
    }
    if (td.individuality.every((e) => e.name != Trait.cardNP)) {
      ref.add('cardNP');
    }
    if (cardMap.containsKey(td.svt.card) && td.individuality.every((e) => e.name != cardMap[td.svt.card])) {
      ref.add('cardQAB');
    }
    final tdType = Transl.tdTypes(overrideData?.tdTypeText ?? td.type);
    final tdRank = overrideData?.tdRank ?? td.rank;
    final tdName = Transl.tdNames(overrideData?.tdName ?? td.name);
    final tdRuby = Transl.tdRuby(overrideData?.tdRuby ?? td.ruby);
    const divider = Divider(indent: 16, endIndent: 16, height: 2, thickness: 1);
    final header = CustomTile(
      leading: Column(
        children: <Widget>[
          CommandCardWidget(card: td.svt.card, width: 90),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110 * 0.9),
            child: Text(
              '${tdType.l} $tdRank',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tdRuby.l,
            textScaleFactor: 0.95,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Text(tdName.l, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (!Transl.isJP) ...[
            Text(
              tdRuby.jp,
              textScaleFactor: 0.95,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            Text(tdName.jp, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]
        ],
      ),
      onTap: jumpToDetail ? () => td.routeTo(region: region) : null,
    );
    final detailText = td.lDetail ?? '???';

    final costumeReleaseWidget = getEquipCostumeConditions(context, td.npSvts);

    Widget child = TileGroup(
      children: [
        if (costumeReleaseWidget != null) costumeReleaseWidget,
        header,
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
        CustomTable(children: [
          CustomTableRow.fromTexts(
              texts: const ['Buster', 'Arts', 'Quick', 'Extra', 'NP', 'Def'],
              defaults: TableCellData(isHeader: true, maxLines: 1)),
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
          CustomTableRow(children: [
            TableCellData(
              child: Text.rich(TextSpan(
                  text: 'Hits', children: [if (isBaseTd) SpecialTextSpan.superscript('[${ref.add("base")}]')])),
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
            )
          ]),
        ]),
        if (ref._tags.isNotEmpty)
          SFooter([
            if (ref.contain('base')) '[${ref.add("base")}] ${S.current.td_base_hits_hint}',
            if (ref.contain("cardNP"))
              '[${ref.add("cardNP")}] ${S.current.td_cardnp_hint(Transl.trait(Trait.cardNP.id).l)}',
            if (ref.contain("cardQAB"))
              '[${ref.add("cardQAB")}] ${S.current.td_cardcolor_hint(td.svt.card.name.toTitle(), Transl.trait(cardMap[td.svt.card]!.id).l)}',
          ].join('\n')),
      ],
    );
    return InheritSelectionArea(child: child);
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
              child: svt.iconBuilder(
                context: context,
                width: 36,
                overrideIcon: overrideIcon,
              ),
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
