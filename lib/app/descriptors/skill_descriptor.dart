import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../generated/l10n.dart';
import 'func/func.dart';

class SkillDescriptor extends StatelessWidget with FuncsDescriptor {
  final BaseSkill skill;
  final int? level; // 1-10
  final bool showPlayer;
  final bool showEnemy;
  final bool showNone;
  final bool hideDetail;
  final bool showBuffDetail;
  final bool jumpToDetail;
  final bool showExtraPassiveCond;

  const SkillDescriptor({
    Key? key,
    required this.skill,
    this.level,
    this.showPlayer = true,
    this.showEnemy = false,
    this.showNone = false,
    this.hideDetail = false,
    this.showBuffDetail = false,
    this.jumpToDetail = true,
    this.showExtraPassiveCond = true,
  }) : super(key: key);

  const SkillDescriptor.only({
    Key? key,
    required this.skill,
    required bool isPlayer,
    this.level,
    this.showNone = false,
    this.hideDetail = false,
    this.showBuffDetail = false,
    this.jumpToDetail = true,
    this.showExtraPassiveCond = true,
  })  : showPlayer = isPlayer,
        showEnemy = !isPlayer,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    int cd0 = 0, cd1 = 0;
    if (skill.coolDown.isNotEmpty) {
      cd0 = skill.coolDown.first;
      cd1 = skill.coolDown.last;
    }

    final header = CustomTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
      leading: db.getIconImage(skill.icon, width: 33, aspectRatio: 1),
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
                builder: (context) =>
                    _extraPassiveDialog(context, skill as NiceSkill),
              ),
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
      ])),
      subtitle: Transl.isJP ||
              hideDetail ||
              (skill.lName.l == skill.name && skill.lName.m?.ofRegion() == null)
          ? null
          : Text(skill.name),
      trailing: cd0 <= 0 && cd1 <= 0
          ? null
          : cd0 == cd1
              ? Text('   CD: $cd0')
              : Text('   CD: $cd0→$cd1'),
      onTap: jumpToDetail ? skill.routeTo : null,
    );
    const divider = Divider(indent: 16, endIndent: 16, height: 2, thickness: 1);
    return TileGroup(
      children: [
        header,
        if (!hideDetail) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
            child: Text(skill.lDetail ?? '???',
                style: Theme.of(context).textTheme.caption),
          ),
          divider,
        ],
        ...describeFunctions(
          funcs: skill.functions,
          level: level,
          showPlayer: showPlayer,
          showEnemy: showEnemy,
          showNone: showNone,
          showBuffDetail: showBuffDetail,
        )
      ],
    );
  }

  Widget _skillAddDialog(BuildContext context) {
    List<Widget> children = [];
    for (final skillAdd in skill.skillAdd) {
      children.add(ListTile(
        title: Text(Transl.skillNames(skillAdd.name).l),
        subtitle: Transl.isJP
            ? Text(skillAdd.ruby)
            : Text('${skillAdd.ruby}\n${skillAdd.name}'),
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
    skill.extraPassive.sort(
        (a, b) => a.num == b.num ? a.priority - b.priority : a.num - b.num);
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
        condDetails.add(Text(' ꔷ ${S.current.ascension} ${cond.condLimitCount}',
            style: style));
      }
      if (cond.condFriendshipRank != 0) {
        condDetails.add(Text(' ꔷ ${S.current.bond} Lv.${cond.condLimitCount}',
            style: style));
      }
      if (cond.eventId != 0) {
        final event = db.gameData.events[cond.eventId];
        condDetails.add(Text(
            ' ꔷ ${S.current.event_title} ${event?.lName.l ?? cond.eventId}',
            style: style));
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

  int get _hashCode =>
      Object.hash(tdName, tdRuby, tdFileName, tdRank, tdTypeText);
}

class TdDescriptor extends StatelessWidget with FuncsDescriptor {
  final BaseTd td;
  final int? level;
  final bool showPlayer;
  final bool showEnemy;
  final bool showNone;
  final OverrideTDData? overrideData;
  final bool jumpToDetail;

  const TdDescriptor({
    Key? key,
    required this.td,
    this.level,
    this.showPlayer = true,
    this.showEnemy = false,
    this.showNone = false,
    this.overrideData,
    this.jumpToDetail = true,
  }) : super(key: key);

  const TdDescriptor.only({
    Key? key,
    required this.td,
    required bool isPlayer,
    this.level,
    this.showNone = false,
    this.overrideData,
    this.jumpToDetail = true,
  })  : showPlayer = isPlayer,
        showEnemy = !isPlayer,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final tdType = Transl.tdTypes(overrideData?.tdTypeText ?? td.type);
    final tdRank = overrideData?.tdRank ?? td.rank;
    final tdName = Transl.tdNames(overrideData?.tdName ?? td.name);
    final tdRuby = Transl.tdRuby(overrideData?.tdRuby ?? td.ruby);
    const divider = Divider(indent: 16, endIndent: 16, height: 2, thickness: 1);
    final header = CustomTile(
      leading: Column(
        children: <Widget>[
          CommandCardWidget(card: td.card, width: 90),
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
          AutoSizeText(
            tdRuby.l,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.caption?.color),
            maxLines: 1,
          ),
          AutoSizeText(
            tdName.l,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
          ),
          if (!Transl.isJP) ...[
            AutoSizeText(
              tdRuby.jp,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.caption?.color),
              maxLines: 1,
            ),
            AutoSizeText(
              tdName.jp,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
            ),
          ]
        ],
      ),
      onTap: jumpToDetail ? td.routeTo : null,
    );
    return TileGroup(
      children: [
        header,
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
          child: Text(td.lDetail ?? '???',
              style: Theme.of(context).textTheme.caption),
        ),
        divider,
        ...describeFunctions(
          funcs: td.functions,
          level: level,
          showPlayer: showPlayer,
          showEnemy: showEnemy,
          showNone: showNone,
        ),
        CustomTable(children: [
          CustomTableRow(children: [
            TableCellData(text: 'Hits', isHeader: true),
            TableCellData(
              text: td.npDistribution.isEmpty
                  ? '   -'
                  : '   ${td.npDistribution.length} Hits '
                      '(${td.npDistribution.join(', ')})',
              flex: 5,
              alignment: Alignment.centerLeft,
            )
          ]),
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
        ]),
      ],
    );
  }
}
