import 'dart:math';

import 'package:flutter/gestures.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/buff/buff_list.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/ai/ai_table.dart';
import 'vals.dart';

mixin FuncsDescriptor {
  List<Widget> describeFunctions({
    required List<NiceFunction> funcs,
    required SkillScript? script,
    required bool showPlayer,
    required bool showEnemy,
    bool showNone = false,
    int? level,
    int? oc,
    EdgeInsetsGeometry? padding,
    bool showBuffDetail = false,
    SkillOrTd? owner,
    bool showEvent = true,
    bool showActIndiv = true,
    LoopTargets? loops,
    Region? region,
  }) => describe(
    funcs: funcs,
    script: script,
    showPlayer: showPlayer,
    showEnemy: showEnemy,
    showNone: showNone,
    level: level,
    oc: oc,
    padding: padding,
    showBuffDetail: showBuffDetail,
    owner: owner,
    showEvent: showEvent,
    showActIndiv: showActIndiv,
    loops: loops,
    region: region,
  );

  static List<Widget> describe({
    required List<NiceFunction> funcs,
    required SkillScript? script,
    required bool showPlayer,
    required bool showEnemy,
    bool showNone = false,
    int? level,
    int? oc,
    EdgeInsetsGeometry? padding,
    bool showBuffDetail = false,
    SkillOrTd? owner,
    bool showEvent = true,
    bool showActIndiv = true,
    LoopTargets? loops,
    Region? region,
  }) {
    final funcs2 = funcs.where((func) {
      if (!showNone && func.funcType == FuncType.none) return false;
      if (func.funcTargetTeam == FuncApplyTarget.all) {
        return true;
      }
      if (func.isPlayerOnlyFunc) return showPlayer;
      if (func.isEnemyOnlyFunc) return showEnemy;
      return true;
    }).toList();
    List<Widget> children = [];
    final actIndiv = (showActIndiv && owner is BaseSkill) ? owner.actIndividuality : <int>[];
    if (script?.isNotEmpty == true || actIndiv.isNotEmpty) {
      children.add(SkillScriptDescriptor(script: script, actIndividuality: actIndiv, region: region));
    }

    for (int index = 0; index < funcs2.length; index++) {
      final func = funcs2[index];
      if (func.svals.isNotEmpty && func.svals[0].TriggeredFuncPosition != null) {
        final val = func.svals[0];
        final int? pos =
            val.TriggeredFuncPositionSameTarget ?? val.TriggeredFuncPositionAll ?? val.TriggeredFuncPosition;
        if (pos != null && pos != 0) {
          final pos2 = pos.abs();
          if (pos2 >= 1 && pos2 <= funcs.length) {
            final preFunc = funcs.getOrNull(pos2 - 1);
            if (preFunc == null) continue;
            final newPos = funcs2.indexOf(preFunc) + 1;
            func.svals[0].set('TriggeredFuncPositionDisp', newPos >= 1 && newPos != pos2 ? newPos * pos.sign : null);
          }
        }
      }
      children.add(
        FuncDescriptor(
          func: func,
          lastFuncTarget: index == 0 ? null : funcs2[index - 1].funcTargetType,
          level: level,
          oc: oc,
          padding: padding,
          showPlayer: showPlayer,
          showEnemy: showEnemy,
          showBuffDetail: showBuffDetail,
          owner: owner,
          showEvent: showEvent,
          loops: loops,
          region: region,
        ),
      );
    }
    final additionalSkillId =
        script?.additionalSkillId?.getOrNull(level ?? 0) ?? script?.additionalSkillId?.firstOrNull;
    final additionalSkillLv =
        script?.additionalSkillLv?.getOrNull(level ?? 0) ?? script?.additionalSkillLv?.firstOrNull;

    if (additionalSkillId != null && additionalSkillId != 0) {
      children.add(
        Builder(
          builder: (context) => Container(
            margin: const EdgeInsetsDirectional.only(start: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).hintColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: _LazyTrigger(
              trigger: BuffValueTriggerType(
                buffType: BuffType.none,
                skill: additionalSkillId,
                level: additionalSkillLv,
              ),
              buff: null,
              func: null,
              isNp: false,
              useRate: null,
              showPlayer: showPlayer,
              showEnemy: showEnemy,
              loops: loops ?? LoopTargets(),
              region: region,
            ),
          ),
        ),
      );
    }

    return children;
  }
}

class _DescriptorWrapper extends StatelessWidget {
  final Widget title;
  final Widget? trailing;
  final List<Widget> lvCells;
  final List<Widget> ocCells;
  final List<Widget> supportCells;
  final int? lv;
  final int? oc;

  const _DescriptorWrapper({
    required this.title,
    required this.trailing,
    this.lvCells = const [],
    this.ocCells = const [],
    this.supportCells = const [],
    this.lv,
    this.oc,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutTryBuilder(
      builder: (context, constraints) {
        double maxWidth = 80;
        int perLine = 5;
        if (constraints.maxWidth.isFinite) {
          maxWidth = max(maxWidth, constraints.maxWidth / 3);
          maxWidth = min(maxWidth, constraints.maxWidth / 2.5);
          if (constraints.maxWidth > 600 && [lvCells, ocCells, supportCells].any((e) => e.length > 5)) {
            perLine = 10;
          }
        }

        List<Widget> children = [];
        if (trailing == null) {
          children.add(title);
        } else {
          children.add(
            Row(
              children: [
                Expanded(flex: perLine - 1, child: title),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth, minWidth: min(20, maxWidth)),
                  child: trailing,
                ),
              ],
            ),
          );
        }
        final cellsList = [lvCells, ocCells, supportCells];
        for (int cellIndex = 0; cellIndex < cellsList.length; cellIndex++) {
          final _cells = cellsList[cellIndex];
          if (_cells.isEmpty) continue;
          List<Widget> rows = [];
          int _perLine = perLine;
          if (_cells.length == 1) _perLine = 1;
          int rowCount = (_cells.length / _perLine).ceil();
          for (int i = 0; i < rowCount; i++) {
            List<Widget> cols = [];
            for (int j = i * _perLine; j < (i + 1) * _perLine; j++) {
              Widget cell = _cells.getOrNull(j) ?? const SizedBox();
              cell = Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: cell);
              if ((cellIndex == 0 && lv != null && lv! - 1 == j) || (cellIndex == 1 && oc != null && oc! - 1 == j)) {
                cell = DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: cellIndex == 1 ? Colors.amber.withAlpha(180) : AppTheme(context).tertiary.withAlpha(180),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: cell,
                );
              }
              cols.add(cell);
            }
            rows.add(Row(children: cols.map((e) => Expanded(child: e)).toList()));
          }
          children.addAll(rows);
        }
        if (children.length == 1) return children.first;
        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }
}

class SkillScriptDescriptor extends StatelessWidget {
  final SkillScript? script;
  final List<int> actIndividuality;
  final Region? region;

  const SkillScriptDescriptor({
    super.key,
    required this.script,
    this.actIndividuality = const [],
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (actIndividuality.isNotEmpty) {
      final isSvt = actIndividuality.any((indiv) => db.gameData.servantsById.containsKey(indiv.abs()));
      children.add(
        _pad(
          _DescriptorWrapper(
            title: Text.rich(
              TextSpan(
                children: [
                  ...SharedBuilder.replaceSpan(
                    Transl.misc2('SkillScript', isSvt ? 'actIndividuality' : 'actIndividuality2'),
                    '{0}',
                    divideList(
                      actIndividuality.map((indiv) {
                        final svt = db.gameData.servantsById[indiv.abs()];
                        String name = Transl.traitName(indiv, addSvtId: false);
                        if (svt != null) {
                          name += '(${Transl.svtClassId(svt.classId).l})';
                        }
                        return SharedBuilder.textButtonSpan(
                          context: context,
                          text: name,
                          onTap: svt?.routeTo ?? () => router.push(url: Routes.traitI(indiv)),
                        );
                      }).toList(),
                      const TextSpan(text: '/'),
                    ),
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: null,
          ),
        ),
      );
    }
    if (script?.NP_HIGHER?.isNotEmpty == true) {
      children.add(_keyLv(context, 'NP_HIGHER', script!.NP_HIGHER!, (v) => '$v%'));
    }
    if (script?.NP_LOWER?.isNotEmpty == true) {
      children.add(_keyLv(context, 'NP_LOWER', script!.NP_LOWER!, (v) => '$v%'));
    }
    if (script?.STAR_HIGHER?.isNotEmpty == true) {
      children.add(_keyLv(context, 'STAR_HIGHER', script!.STAR_HIGHER!, (v) => '$v'));
    }
    if (script?.STAR_LOWER?.isNotEmpty == true) {
      children.add(_keyLv(context, 'STAR_LOWER', script!.STAR_LOWER!, (v) => '$v'));
    }
    if (script?.HP_VAL_HIGHER?.isNotEmpty == true) {
      children.add(_keyLv(context, 'HP_VAL_HIGHER', script!.HP_VAL_HIGHER!, (v) => '$v'));
    }
    if (script?.HP_VAL_LOWER?.isNotEmpty == true) {
      children.add(_keyLv(context, 'HP_VAL_LOWER', script!.HP_VAL_LOWER!, (v) => '$v'));
    }
    if (script?.HP_PER_HIGHER?.isNotEmpty == true) {
      children.add(
        _keyLv(
          context,
          'HP_PER_HIGHER',
          script!.HP_PER_HIGHER!,
          (v) => v.format(compact: false, percent: true, base: 10),
        ),
      );
    }
    if (script?.HP_PER_LOWER?.isNotEmpty == true) {
      children.add(
        _keyLv(
          context,
          'HP_PER_LOWER',
          script!.HP_PER_LOWER!,
          (v) => v.format(compact: false, percent: true, base: 10),
        ),
      );
    }
    if (script?.actRarity?.isNotEmpty == true) {
      children.add(
        _keyLv(context, 'actRarity', script!.actRarity!, (v) {
          if (v.length <= 1) return v.join();
          for (int index = 1; index < v.length; index++) {
            if (v[index] != v.first + index) {
              return v.join("&");
            }
          }
          return "${v.first}-${v.last}";
        }),
      );
    }
    if (script?.battleStartRemainingTurn?.isNotEmpty == true) {
      children.add(
        _keyLv(
          context,
          'battleStartRemainingTurn',
          script!.battleStartRemainingTurn!,
          (v) => Transl.special.funcValTurns(v),
        ),
      );
    }

    if (script?.additionalSkillId?.isNotEmpty == true) {
      final ids = script!.additionalSkillId!;
      final lvs = script?.additionalSkillLv ?? <int>[];
      List<InlineSpan> titleSpans = [
        TextSpan(text: Transl.misc2('SkillScript', 'additionalSkillId')),
        const TextSpan(text: ": "),
      ];
      Widget? trailing;
      List<Widget> cells = [];

      if (lvs.toSet().length == 1) {
        trailing = Text('Lv.${lvs.first}', style: const TextStyle(fontSize: 13));
      }
      if (ids.toSet().length == 1) {
        titleSpans.add(
          SharedBuilder.textButtonSpan(
            context: context,
            text: ids.first.toString(),
            onTap: () {
              router.push(url: Routes.skillI(ids.first));
            },
          ),
        );
        if (lvs.toSet().length > 1) {
          cells = lvs.map((e) => Text('Lv.$e', style: const TextStyle(fontSize: 13))).toList();
        }
      } else {
        cells = List.generate(ids.length, (index) {
          final id = ids[index];
          final lv = lvs.getOrNull(index);
          return Text.rich(
            TextSpan(
              children: [
                SharedBuilder.textButtonSpan(
                  context: context,
                  text: id.toString(),
                  onTap: () {
                    router.push(url: Routes.skillI(id));
                  },
                ),
                if (lv != null) TextSpan(text: '\n(Lv.$lv)'),
              ],
            ),
            textAlign: TextAlign.center,
          );
        });
      }
      children.add(
        _pad(
          _DescriptorWrapper(
            title: Text.rich(TextSpan(children: titleSpans), style: Theme.of(context).textTheme.bodySmall),
            trailing: trailing,
            lvCells: cells,
          ),
        ),
      );
    }
    if (script?.tdTypeChangeIDs?.isNotEmpty == true) {
      children.add(
        _pad(
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: Transl.misc2('SkillScript', 'tdTypeChangeIDs')),
                const TextSpan(text: ': '),
                ...divideList(
                  List.generate(script!.tdTypeChangeIDs!.length, (index) {
                    final tdId = script!.tdTypeChangeIDs![index];
                    return SharedBuilder.textButtonSpan(
                      context: context,
                      text: '$tdId',
                      onTap: () {
                        router.push(url: Routes.tdI(tdId));
                      },
                    );
                  }),
                  const TextSpan(text: ' / '),
                ),
              ],
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    if (script?.tdChangeByBattlePoint?.isNotEmpty == true) {
      children.add(
        _pad(
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: Transl.misc2('SkillScript', 'tdChangeByBattlePoint')),
                const TextSpan(text: ': '),
                ...divideList(
                  List.generate(script!.tdChangeByBattlePoint!.length, (index) {
                    final tdChange = script!.tdChangeByBattlePoint![index];
                    return TextSpan(
                      children: [
                        TextSpan(text: '(Lv≥${tdChange.phase}) '),
                        SharedBuilder.textButtonSpan(
                          context: context,
                          text: '${tdChange.noblePhantasmId}',
                          onTap: () {
                            router.push(url: Routes.tdI(tdChange.noblePhantasmId));
                          },
                        ),
                      ],
                    );
                  }),
                  const TextSpan(text: ' / '),
                ),
              ],
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    if (script?.SelectAddInfo?.isNotEmpty == true) {
      final infos = script!.SelectAddInfo!;
      final info = infos.first;
      final transl = Transl.miscScope('SelectAddInfo');
      children.add(
        _pad(
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '* ${transl('Optional').l}: ${transl(info.title).l}'),
                for (final (index, btn) in info.btn.indexed) btn.buildSpan(index),
              ].divided((_) => const TextSpan(text: '\n')),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            textScaler: const TextScaler.linear(0.9),
          ),
        ),
      );
    }
    if (script?.condBranchSkillInfo?.isNotEmpty == true) {
      final branches = script?.condBranchSkillInfo ?? [];
      final transl = Transl.miscScope('condBranchSkillInfo');
      for (final (index, branch) in branches.indexed) {
        String title = transl("Branch").l.replaceFirst('{0}', '${index + 1}');
        title = '[$title] ';
        if (Transl.md.skillNames.containsKey(branch.detailText)) {
          title += Transl.skillNames(branch.detailText).l;
        } else {
          title += transl(branch.detailText).l;
        }
        InlineSpan condSpan = switch (branch.condType) {
          BattleBranchSkillCondBranchType.none => TextSpan(text: branch.condType.name),
          BattleBranchSkillCondBranchType.isSelfTarget => TextSpan(
            text: transl("${branch.condType.name}.${branch.condValue.firstOrNull ?? 0}").l,
          ),
          BattleBranchSkillCondBranchType.individuality => TextSpan(
            text: '${transl(branch.condType.name).l}: ',
            children: SharedBuilder.traitSpans(context: context, traits: branch.condValue),
          ),
        };
        children.add(
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  leading: FutureBuilder2<int, String?>(
                    id: branch.iconBuffId,
                    loader: () async {
                      return branch.icon ?? (await AtlasApi.buff(branch.iconBuffId, region: region ?? Region.jp))?.icon;
                    },
                    builder: (context, icon) {
                      return db.getIconImage(icon, width: 24, height: 24);
                    },
                  ),
                  title: Text(title),
                  subtitle: Text.rich(
                    TextSpan(
                      text: '【',
                      children: [
                        condSpan,
                        const TextSpan(text: '】'),
                      ],
                    ),
                  ),
                ),
                FutureBuilder2<int, BaseSkill?>(
                  id: branch.skillId,
                  loader: () => AtlasApi.baseSkill(branch.skillId, region: region ?? Region.jp),
                  builder: (context, skill) {
                    if (skill == null) {
                      return Text(branch.skillId.toString(), style: const TextStyle(fontStyle: FontStyle.italic));
                    }
                    return SkillDescriptor(skill: skill, region: region);
                  },
                ),
              ],
            ),
          ),
        );
      }
    }
    if (children.isEmpty) return const SizedBox();
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Theme.of(context).hoverColor),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _keyLv<T>(BuildContext context, String key, List<T> vals, String Function(T v) builder) {
    String title = Transl.misc2('SkillScript', key);
    if (vals.toSet().length == 1) {
      title = title.replaceAll('{0}', builder(vals.first));
    }
    return _richLv(context, TextSpan(text: title), vals, builder);
  }

  Widget _richLv<T>(BuildContext context, TextSpan title, List<T> vals, String Function(T v) builder) {
    Widget? trailing;
    List<Widget> cells = [];
    if (vals.toSet().length == 1) {
      trailing = Text(builder(vals.first), style: const TextStyle(fontSize: 13));
    } else {
      for (final v in vals) {
        cells.add(Text(builder(v), style: const TextStyle(fontSize: 13)));
      }
    }

    return _pad(
      _DescriptorWrapper(
        title: Text.rich(title, style: Theme.of(context).textTheme.bodySmall),
        trailing: trailing,
        lvCells: cells,
      ),
    );
  }

  Widget _pad(Widget child) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: child);
  }
}

class FuncDescriptor extends StatelessWidget {
  final NiceFunction func;
  final FuncTargetType? lastFuncTarget;
  final int? level; // 1-10
  final int? oc;
  final EdgeInsetsGeometry? padding;
  final bool showPlayer;
  final bool showEnemy;
  final bool showBuffDetail;
  final SkillOrTd? owner;
  final bool showEvent;
  final LoopTargets? loops;
  final Region? region;

  const FuncDescriptor({
    super.key,
    required this.func,
    this.lastFuncTarget,
    this.level,
    this.oc,
    this.padding,
    this.showPlayer = true,
    this.showEnemy = false,
    this.showBuffDetail = false,
    this.owner,
    this.showEvent = true,
    this.loops,
    this.region,
  });

  static StringBuffer buildBasicFuncText(
    final NiceFunction func, {
    final bool showBuffDetail = false,
    final Region? region = Region.jp,
  }) {
    StringBuffer funcText = StringBuffer();
    Buff? buff = func.buff;
    final vals = func.svals.firstOrNull;

    if ((func.funcType == FuncType.addState ||
            func.funcType == FuncType.addStateShort ||
            func.funcType == FuncType.addFieldChangeToField) &&
        buff != null) {
      if (showBuffDetail) {
        funcText.write(Transl.buffDetail(buff.detail).l);
      } else {
        if (buff.id == 30042 || buff.id == 30043) {
          // 令呪励起, ActMasterGenderType
          funcText.write(Transl.buffNames('攻撃力アップ').l);
        } else if ([
          BuffType.addIndividuality,
          BuffType.subIndividuality,
          BuffType.fieldIndividuality,
          BuffType.subFieldIndividuality,
          BuffType.toFieldChangeField,
          BuffType.toFieldSubIndividualityField,
          BuffType.overwriteBattleclass,
          BuffType.overwriteSubattribute,
        ].contains(buff.type)) {
          funcText.write(Transl.buffNames(buff.type.name).l);
        } else if (buff.type == BuffType.upDamage &&
            func.funcGroup.any((e) => e.eventId != 0) & buff.ckOpIndv.isEmpty &&
            buff.ckSelfIndv.isEmpty &&
            func.functvals.isEmpty) {
          funcText.write(Transl.buffNames("威力アップ").l);
        } else if (buff.name.isEmpty) {
          funcText.write(Transl.buffType(buff.type).l);
        } else {
          funcText.write(Transl.buffNames(buff.name).l);
          if (region == Region.jp &&
              !Transl.md.buffNames.containsKey(buff.name) &&
              !kBuffValueTriggerTypes.containsKey(buff.type)) {
            funcText.write(' (${Transl.buffType(buff.type).l})');
          }
        }
      }
    } else if (const [
      FuncType.gainNpIndividualSum,
      FuncType.gainNpBuffIndividualSum,
      FuncType.gainNpTargetSum,
      FuncType.gainNpCriticalstarSum,
    ].contains(func.funcType)) {
      funcText.write(Transl.funcPopuptextBase(func.funcType.name).l);
    } else if (const [FuncType.enemyEncountRateUp, FuncType.enemyEncountCopyRateUp].contains(func.funcType)) {
      funcText.write(Transl.funcPopuptextBase(func.funcType.name).l);
    } else if (func.funcType == FuncType.updateEntryPositions) {
      funcText.write(Transl.enums(func.funcType, (enums) => enums.funcType).l);
      funcText.write(': ');
      if (vals?.OnPositions?.isNotEmpty == true) {
        funcText.write('${S.current.enable} ${vals?.OnPositions} ');
      }
      if (vals?.OffPositions?.isNotEmpty == true) {
        funcText.write('${S.current.disable} ${vals?.OffPositions}');
      }
    } else {
      funcText.write(Transl.funcPopuptext(func).l);
      String text = NiceFunction.normFuncPopupText(func.funcPopupText);
      if (region == Region.jp && !Transl.md.funcPopuptext.containsKey(text) && text.isNotEmpty) {
        funcText.write(' (${Transl.funcType(func.funcType).l})');
      }
    }

    // FuncType.breakGaugeUp
    if (vals?.ChangeMaxBreakGauge == 1) {
      funcText.write('(.ChangeMaxBreakGauge)');
    }

    if ([FuncType.gainHpFromTargets, FuncType.absorbNpturn, FuncType.gainNpFromTargets].contains(func.funcType)) {
      funcText.write(Transl.special.funcAbsorbFrom);
    }

    final staticVal = func.getStaticVal();

    int turn = staticVal.Turn ?? -1, count = staticVal.Count ?? -1;
    if (turn > 0 || count > 0) {
      funcText.write(' (');
      funcText.write(
        [
          if (count > 0) Transl.special.funcValCountTimes(count),
          if (turn > 0) Transl.special.funcValTurns(turn),
        ].join(M.of(jp: '·', cn: '·', tw: '·', na: ', ', kr: ', ')),
      );
      funcText.write(')');
    }
    return funcText;
  }

  @override
  Widget build(BuildContext context) {
    StringBuffer funcText = buildBasicFuncText(func, showBuffDetail: showBuffDetail, region: region);

    Buff? buff = func.buff;
    final mutatingLvVals = func.getMutatingVals(null, levelOnly: true);
    final mutatingOCVals = func.getMutatingVals(null, ocOnly: true);
    final staticVal = func.getStaticVal();

    Widget trailing;
    List<Widget> lvCells = [];
    List<Widget> ocCells = [];
    List<Widget> supportCells = [];
    trailing = ValDsc(
      func: func,
      vals: staticVal,
      originVals: func.svals.getOrNull(0),
      ignoreRate: true,
      ignoreCount: true,
    );

    Widget _listVal(DataVals mVals, DataVals? oVals, int? index, {bool support = false}) {
      Widget cell = ValDsc(
        func: func,
        vals: mVals,
        originVals: oVals,
        ignoreRate: false,
        color: index == 5 || index == 9 ? AppTheme(context).tertiary : null,
        inList: true,
        supportOnly: support,
      );
      return cell;
    }

    if (mutatingLvVals.isNotEmpty) {
      funcText.write('<Lv>');
      lvCells.addAll(
        List.generate(
          mutatingLvVals.length,
          (index) => _listVal(mutatingLvVals[index], func.svals.getOrNull(index), index),
        ),
      );
    }
    if (mutatingOCVals.isNotEmpty) {
      funcText.write('<OC>');
      ocCells.addAll(
        List.generate(
          mutatingOCVals.length,
          (index) => _listVal(mutatingOCVals[index], func.ocVals(0).getOrNull(index), index),
        ),
      );
    }
    if (func.followerVals?.isNotEmpty == true) {
      // doesn't split static or mutating vals, it is rarely used.
      supportCells.addAll(
        List.generate(
          func.followerVals!.length,
          (index) => _listVal(func.followerVals![index], null, index, support: true),
        ),
      );
    }

    DataVals? vals = func.svals.getOrNull(0);

    List<InlineSpan> spans = [];
    Widget? icon;
    String? _iconUrl = func.funcPopupIcon ?? buff?.icon;
    if (_iconUrl != null) {
      icon = db.getIconImage(_iconUrl, width: 18);
      if (vals?.SetPassiveFrame == 1 || vals?.ProcPassive == 1) {
        icon = DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).hintColor),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(padding: const EdgeInsets.all(1), child: icon),
        );
      }
      if (vals?.ShowState == -1 || vals?.ShowState == -2) {
        icon = Opacity(opacity: 0.6, child: icon);
      }
    } else if (func.funcType == FuncType.eventFortificationPointUp) {
      int? indiv = func.svals.getOrNull(0)?.Individuality;
      EventWorkType? workType;
      if (indiv != null) workType = EventWorkType.values.getOrNull(indiv - 1);
      String indivName;
      indivName = workType != null ? Transl.enums(workType, (enums) => enums.eventWorkType).l : '$indiv';
      if (indiv != null) {
        spans.add(CenterWidgetSpan(child: db.getIconImage(EventWorkType.getIcon(indiv), width: 20, aspectRatio: 1)));
      }
      spans.add(TextSpan(text: '〔$indivName〕'));
    } else if ([
      FuncType.eventDropUp,
      FuncType.eventDropRateUp,
      FuncType.eventPointUp,
      FuncType.eventPointRateUp,
    ].contains(func.funcType)) {
      int? indiv = func.svals.getOrNull(0)?.Individuality;
      final items = db.gameData.items.values.where((item) => item.individuality.contains(indiv)).toList();
      if (items.isEmpty) {
        spans.add(TextSpan(text: '$indiv  '));
      }
      for (final item in items) {
        spans.add(
          TextSpan(
            children: [
              CenterWidgetSpan(
                child: Item.iconBuilder(context: context, item: item, width: 20),
              ),
              TextSpan(text: ' ${item.lName.l}  '),
            ],
            recognizer: TapGestureRecognizer()..onTap = item.routeTo,
          ),
        );
      }
    }
    if (icon != null) {
      spans.insert(
        0,
        CenterWidgetSpan(
          child: Padding(padding: const EdgeInsetsDirectional.only(end: 4), child: icon),
        ),
      );
    }

    final posVal =
        vals?.TriggeredFuncPositionSameTarget ?? vals?.TriggeredFuncPositionAll ?? vals?.TriggeredFuncPosition;
    if (vals != null && posVal != null && posVal != 0) {
      final dispPos = vals.TriggeredFuncPositionDisp ?? posVal;
      String hint;
      if (vals.TriggeredFuncPositionSameTarget != null) {
        hint = Transl.misc2('Function', 'TriggeredFuncPositionSameTarget');
      } else if (vals.TriggeredFuncPositionAll != null) {
        hint = Transl.misc2('Function', 'TriggeredFuncPositionAll');
      } else {
        hint = Transl.misc2('Function', 'TriggeredFuncPosition');
      }
      hint = hint.replaceAll('{1}', posVal > 0 ? Transl.special.succeed : Transl.special.fail);

      spans.insertAll(0, [
        const TextSpan(text: '('),
        ...SharedBuilder.replaceSpan(hint, '{0}', [TextSpan(text: dispPos.abs().toString())]),
        const TextSpan(text: ')'),
      ]);
    } else if (vals?.Rate != null && vals!.Rate! < 0) {
      final hint = Transl.misc2('Function', 'ifPrevFuncSucceed');
      spans.insert(0, TextSpan(text: '($hint)'));
    }

    if (vals?.ActSelectIndex != null) {
      String hint = Transl.misc2('Function', 'ActSelectIndex');
      hint = hint.replaceAll('{0}', (vals!.ActSelectIndex! + 1).toString());
      spans.insert(0, TextSpan(text: '($hint)'));
    }

    void _addFuncTarget() {
      if ([
        FuncType.eventDropUp,
        FuncType.eventDropRateUp,
        FuncType.eventPointUp,
        FuncType.eventPointRateUp,
        FuncType.eventFortificationPointUp,
        FuncType.enemyEncountRateUp,
        FuncType.enemyEncountCopyRateUp,
      ].contains(func.funcType)) {
        return;
      }
      // if (showPlayer && showEnemy) return;
      final actMasterGenderType = vals?.ActMasterGenderType;
      if (actMasterGenderType != null) {
        spans.add(TextSpan(text: '[${actMasterGenderType == 2 ? S.current.guda_female : S.current.guda_male}]'));
      }
      if (lastFuncTarget == func.funcTargetType) return;
      spans.add(TextSpan(text: '[${Transl.funcTargetType(func.funcTargetType).l}] '));
    }

    _addFuncTarget();

    void _addFuncText() {
      final text = funcText.toString();
      final style = func.isEnemyOnlyFunc ? const TextStyle(fontStyle: FontStyle.italic) : null;

      InlineSpan _replaceTrait(int trait, {int? guessTrait}) {
        return TextSpan(
          children: SharedBuilder.replaceSpan(text, '{0}', [
            SharedBuilder.traitSpan(
              context: context,
              trait: trait,
              style: guessTrait == null ? null : const TextStyle(decoration: TextDecoration.lineThrough),
            ),
            if (guessTrait != null) ...[
              const TextSpan(text: '('),
              SharedBuilder.traitSpan(context: context, trait: guessTrait),
              const TextSpan(text: '?)'),
            ],
          ]),
          style: style,
        );
      }

      InlineSpan _replaceTraits(List<int> traits, {bool useAndJoin = false}) {
        return TextSpan(
          children: SharedBuilder.replaceSpan(
            text,
            '{0}',
            SharedBuilder.traitSpans(context: context, traits: traits, useAndJoin: useAndJoin),
          ),
          style: style,
        );
      }

      switch (func.funcType) {
        case FuncType.damageNpIndividual:
        case FuncType.damageNpStateIndividualFix:
          int? indiv = vals?.Target;
          if (indiv != null) {
            spans.add(_replaceTrait(indiv));
            return;
          }
          break;
        case FuncType.damageNpAndOrCheckIndividuality:
          final andOrCheckIndivs = vals?.AndOrCheckIndividualityList;
          List<int> andCheckIndivs = vals?.AndCheckIndividualityList ?? [];
          if (andOrCheckIndivs != null && andOrCheckIndivs.isNotEmpty) {
            spans.add(
              TextSpan(
                children: SharedBuilder.replaceSpan(
                  text,
                  '{0}',
                  divideList([
                    for (final traits in andOrCheckIndivs)
                      TextSpan(
                        children: SharedBuilder.traitSpans(context: context, traits: traits, useAndJoin: true),
                      ),
                  ], const TextSpan(text: '  /  ')),
                ),
                style: style,
              ),
            );
          } else if (andCheckIndivs.isNotEmpty) {
            spans.add(_replaceTraits(andCheckIndivs, useAndJoin: true));
            return;
          }
          break;
        case FuncType.damageNpIndividualSum:
          if ((vals?.TargetList?.length ?? 0) > 0) {
            spans.addAll(
              SharedBuilder.replaceSpanMaps(text, {
                "{0}": (_) => [
                  TextSpan(
                    children: SharedBuilder.traitSpans(
                      context: context,
                      traits: [for (int indiv in vals?.TargetList ?? []) indiv],
                    ),
                    style: style,
                  ),
                ],
                "{1}": (_) => [TextSpan(text: vals?.Target == 0 ? Transl.special.self : Transl.special.opposite)],
              }),
            );
            return;
          }
          break;
        case FuncType.gainNpIndividualSum:
        case FuncType.gainNpBuffIndividualSum:
        case FuncType.gainNpTargetSum:
          spans.addAll(
            SharedBuilder.replaceSpanMaps(text, {
              "{0}": (_) {
                final target = func.funcType == FuncType.gainNpBuffIndividualSum ? 0 : vals?.Value2 ?? 0;
                String targetText = 'TargetType<$target>';
                if (target == GainNpIndividualSumTarget.target.value) {
                  targetText = Transl.special.target;
                } else if (target == GainNpIndividualSumTarget.player.value) {
                  targetText = Transl.funcTargetType(FuncTargetType.ptAll).l;
                } else if (target == GainNpIndividualSumTarget.enemy.value) {
                  targetText = Transl.funcTargetType(FuncTargetType.enemyAll).l;
                } else if (target == GainNpIndividualSumTarget.all.value) {
                  targetText = M.of(jp: '敵味方全体', cn: '敌我双方全体', tw: '敵我雙方全體', na: 'All allies and enemies');
                } else if (target == GainNpIndividualSumTarget.otherAll.value) {
                  targetText = Transl.funcTargetType(FuncTargetType.fieldOther).l;
                }
                return [TextSpan(text: targetText)];
              },
              "{1}": (_) => SharedBuilder.traitSpans(context: context, traits: func.traitVals),
            }),
          );
          return;
        case FuncType.enemyEncountRateUp:
        case FuncType.enemyEncountCopyRateUp:
          int? indiv = vals?.Individuality;
          if (indiv != null) {
            spans.add(_replaceTrait(indiv));
            return;
          }
          break;
        default:
          break;
      }
      if (buff != null) {
        switch (buff.type) {
          case BuffType.addIndividuality:
          case BuffType.subIndividuality:
          case BuffType.fieldIndividuality:
            int? indiv = vals?.Value;
            if (indiv != null) {
              int? guessTrait;
              if (indiv == 0 || indiv == 9999) {
                bool _isGuessTrait(int v) =>
                    (v >= 2000 && v < 3000) || (v >= 3050 && v < 4000) || (v >= 6000 && v < 7000);
                final guessTraits = buff.vals.where((e) => _isGuessTrait(e)).toList();
                if (guessTraits.length == 1) guessTrait = guessTraits.first;
                for (final v in vals?.getAddIndividuality() ?? <int>[]) {
                  if (guessTrait == null && _isGuessTrait(v)) {
                    guessTrait = v;
                    break;
                  }
                }
                // directly show guessTrait for known ones
                if (guessTrait != null && (const [5359, 5546, 5512, 5586, 5561].contains(buff.id))) {
                  indiv = guessTrait;
                  guessTrait = null;
                }
              }
              spans.add(_replaceTrait(indiv, guessTrait: guessTrait));
              return;
            }
            break;
          case BuffType.subFieldIndividuality:
          case BuffType.toFieldSubIndividualityField: // need verify
            List<int>? indivs = vals?.TargetList;
            if (indivs != null && indivs.isNotEmpty) {
              spans.add(
                TextSpan(
                  children: SharedBuilder.replaceSpan(
                    text,
                    '{0}',
                    divideList([
                      for (final indiv in indivs) SharedBuilder.traitSpan(context: context, trait: indiv),
                    ], const TextSpan(text: ' / ')),
                  ),
                  style: style,
                ),
              );
              return;
            }
            break;
          case BuffType.toFieldChangeField:
            List<int>? indivs = vals?.FieldIndividuality;
            if (indivs != null) {
              spans.add(_replaceTraits(indivs));
              return;
            }
            break;
          case BuffType.overwriteBattleclass:
            final clsId = vals?.Value;
            if (clsId != null) {
              spans.add(
                TextSpan(
                  children: SharedBuilder.replaceSpan(text, '{0}', [
                    TextSpan(text: Transl.miscFunction('TargetEnemyClass')),
                  ]),
                  style: style,
                ),
              );
              return;
            }
            break;
          case BuffType.overwriteSubattribute:
            final attri = vals?.Value;
            if (attri != null) {
              final svtAttri = ServantSubAttribute.values.firstWhereOrNull((e) => e.value == attri);
              final attriName = svtAttri == null ? attri.toString() : Transl.svtSubAttribute(svtAttri).l;
              spans.add(
                TextSpan(
                  children: SharedBuilder.replaceSpan(text, '{0}', [TextSpan(text: attriName)]),
                  style: style,
                ),
              );
              return;
            }
            break;
          default:
            break;
        }
      }
      spans.add(TextSpan(text: text, style: style));
    }

    _addFuncText();

    BgmEntity? _changeBgm;
    if (func.funcType == FuncType.changeBgm) {
      _changeBgm = db.gameData.bgms[vals?.Value];
    } else if (buff != null && buff.type == BuffType.changeBgm) {
      _changeBgm = db.gameData.bgms[vals?.BgmId];
    }
    if (_changeBgm != null) {
      spans.add(
        SharedBuilder.textButtonSpan(context: context, text: '  ${_changeBgm.tooltip}', onTap: _changeBgm.routeTo),
      );
    }

    if (func.funcType == FuncType.transformServant) {
      final transformId = vals?.Value, transformLimit = vals?.SetLimitCount;
      if (transformId != null) {
        final transformSvt = db.gameData.servantsById[transformId] ?? db.gameData.entities[transformId];
        if (transformSvt != null) {
          spans.add(
            CenterWidgetSpan(
              child: transformSvt.iconBuilder(
                context: context,
                width: 20,
                overrideIcon: transformLimit != null && transformSvt is Servant
                    ? transformSvt.ascendIcon(transformLimit)
                    : null,
              ),
            ),
          );
        }
        spans.add(
          SharedBuilder.textButtonSpan(
            context: context,
            text: transformLimit == null
                ? ' $transformId '
                : ' $transformId[${S.current.ascension_short}$transformLimit] ',
            onTap: () {
              router.push(url: Routes.servantI(transformId));
            },
          ),
        );
      }
    } else if (const [
      FuncType.shortenSkill,
      FuncType.extendSkill,
      FuncType.shortenUserEquipSkill,
      FuncType.extendUserEquipSkill,
    ].contains(func.funcType)) {
      final targetNum = vals?.Value2 ?? 0;
      if (targetNum > 0) {
        spans.insert(0, TextSpan(text: '(${S.current.skill} $targetNum)'));
      }
    } else if (func.funcType == FuncType.displayBattleMessage ||
        func.funcType == FuncType.setDisplayDirectBattleMessageInFsm) {
      final msgId = vals?.Value ?? 0;
      spans.add(
        SharedBuilder.textButtonSpan(
          context: context,
          text: ' $msgId',
          onTap: () {
            if (msgId == 0) return;
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) => BattleMessageDialog(msgId: msgId, region: region),
            );
          },
        ),
      );
    }

    if (buff?.type == BuffType.donotSkillSelect && vals?.Value != null) {
      final targetNum = vals?.Value ?? 0;
      if (targetNum > 0) {
        spans.insert(0, TextSpan(text: '(${S.current.skill} $targetNum)'));
      }
    }

    if (vals?.AddLinkageTargetIndividualty != null && vals?.BehaveAsFamilyBuff == 1) {
      final color = Theme.of(context).textTheme.bodySmall?.color;
      spans.add(const TextSpan(text: '('));
      spans.add(CenterWidgetSpan(child: FaIcon(FontAwesomeIcons.link, size: 12, color: color)));
      if (vals?.UnSubStateWhileLinkedToOthers == 1) {
        spans.add(CenterWidgetSpan(child: FaIcon(FontAwesomeIcons.linkSlash, size: 12, color: color)));
      }
      spans.add(TextSpan(text: '${vals?.AddLinkageTargetIndividualty}'));
      spans.add(const TextSpan(text: ')'));
    }
    //

    List<List<InlineSpan>> _condSpans = [];

    int? paramAddMaxCount = vals?.ParamAddMaxCount;
    int? paramAddValue = vals?.ParamAdd ?? vals?.ParamAddValue;
    int? paramAddMaxValue = vals?.ParamMax ?? vals?.ParamAddMaxValue;
    if (paramAddValue != null && paramAddMaxValue != null && paramAddMaxValue % paramAddValue == 0) {
      paramAddMaxCount ??= paramAddMaxValue ~/ paramAddValue;
    }
    if (paramAddMaxCount != null) {
      _condSpans.add(
        SharedBuilder.replaceSpan(Transl.miscFunction('ParamAddMaxCount'), '{0}', [
          TextSpan(text: '$paramAddMaxCount'),
        ]),
      );
    }

    // ParamAddIndiv
    void _addParamAddIndiv(String targetText, {List<int>? traitIds, List<List<int>>? andCheckTraitIds}) {
      final targetType = vals?.ParamAddIndividualityTargetType;
      if (targetType != null) {
        final funcTargetType = FuncTargetType.values.firstWhereOrNull((e) => e.value == targetType);
        targetText = funcTargetType == null ? 'TargetType$targetType' : Transl.funcTargetType(funcTargetType).l;
      }

      // Noah's skill3 crit buff
      if (func.funcId == 201 &&
          andCheckTraitIds != null &&
          andCheckTraitIds.expand((e) => e).map((e) => e.abs()).toSet().equalTo({2005, 2632, 2821, 10000})) {
        andCheckTraitIds = null;
        traitIds = [2005, 2632, 2821, -10000];
      }

      if (traitIds != null && traitIds.isNotEmpty) {
        _condSpans.add(
          SharedBuilder.replaceSpan(
            Transl.special.funcTraitPerBuff(target: targetText),
            '{0}',
            SharedBuilder.traitSpans(context: context, traits: traitIds),
          ),
        );
      } else if (andCheckTraitIds != null && andCheckTraitIds.isNotEmpty) {
        _condSpans.add(
          SharedBuilder.replaceSpan(
            Transl.special.funcTraitPerBuff(target: targetText),
            '{0}',
            SharedBuilder.traitsListSpans(context: context, traitsList: andCheckTraitIds),
          ),
        );
      }
    }

    _addParamAddIndiv(Transl.special.self, traitIds: vals?.ParamAddSelfIndividuality);
    _addParamAddIndiv(Transl.special.opposite, traitIds: vals?.ParamAddOpIndividuality);
    _addParamAddIndiv(Transl.special.field, traitIds: vals?.ParamAddFieldIndividuality);
    _addParamAddIndiv(Transl.special.self, andCheckTraitIds: vals?.ParamAddSelfIndividualityAndCheck);
    _addParamAddIndiv(Transl.special.opposite, andCheckTraitIds: vals?.ParamAddOpIndividualityAndCheck);
    _addParamAddIndiv(Transl.special.field, andCheckTraitIds: vals?.ParamAddFieldIndividualityAndCheck);

    // CondParamAdd
    final condParamType = vals?.CondParamRangeType ?? vals?.CondParamAddType ?? 0;
    List<int>? condParamTargetId = vals?.CondParamRangeTargetId ?? vals?.CondParamAddTargetId ?? [];
    num? condParamMaxCount = vals?.CondParamRangeMaxCount;
    if (vals?.CondParamAddMaxValue != null && vals?.CondParamAddValue != null) {
      condParamMaxCount ??= vals!.CondParamAddMaxValue! / vals.CondParamAddValue!;
    }
    if (condParamType != 0) {
      final targetText = TextSpan(
        children: divideList([
          for (final clsId in condParamTargetId)
            SharedBuilder.textButtonSpan(
              context: context,
              text: Transl.svtClassId(clsId).l,
              onTap: () => Routes.svtClassI(clsId),
            ),
        ], const TextSpan(text: ' / ')),
      );
      final functionScope = Transl.md.misc['Function'];
      String translKey = 'CondParamType$condParamType';
      if (functionScope != null &&
          !functionScope.containsKey(translKey) &&
          functionScope.containsKey('CondParamType0')) {
        translKey = 'CondParamType0';
      }
      _condSpans.add(
        SharedBuilder.replaceSpanMaps(Transl.miscFunction(translKey), {
          '{target}': (_) => [targetText],
          '{maxCount}': (_) => [TextSpan(text: condParamMaxCount?.format())],
          '{type}': (_) => [TextSpan(text: '$condParamType')],
        }),
      );
    }

    void _addTraits(String? prefix, List<int> traits, {bool useAnd = false}) {
      if ([BuffType.upCommandall, BuffType.downCommandall].contains(buff?.type)) {
        traits = traits
            .where(
              (e) => ![
                Trait.cardQuick.value,
                Trait.cardArts.value,
                Trait.cardBuster.value,
                Trait.cardExtra.value,
              ].contains(e),
            )
            .toList();
      }
      if (traits.isEmpty) return;
      _condSpans.add([
        if (prefix != null) TextSpan(text: prefix),
        ...SharedBuilder.traitSpans(context: context, traits: traits, useAndJoin: useAnd),
        const TextSpan(text: ' '), // not let recognizer extends its width
      ]);
    }

    if (func.traitVals.isNotEmpty) {
      if (func.funcType == FuncType.subState) {
        _addTraits(Transl.special.funcTraitRemoval, func.traitVals);
      } else if (func.funcType == FuncType.eventDropUp) {
        _addTraits(Transl.special.buffCheckSelf, func.traitVals);
      }
    }
    if (func.funcType != FuncType.subState) {
      final overwriteTvals = func.getOverwriteTvalsList();
      if (overwriteTvals.isNotEmpty) {
        _condSpans.add([
          TextSpan(text: Transl.special.funcTargetVals),
          ...divideList([
            for (final traits in overwriteTvals)
              TextSpan(
                children: SharedBuilder.traitSpans(context: context, traits: traits, useAndJoin: true),
              ),
          ], const TextSpan(text: '  /  ')),
          const TextSpan(text: ' '), // not let recognizer extends its width
        ]);
      } else if (func.traitVals.join(',') != func.functvals.join(',')) {
        final targetTypeInt = vals?.FuncCheckTargetIndividualityTargetType;
        final targetType = FuncTargetType.values.firstWhereOrNull((e) => e.value == targetTypeInt);
        String text = Transl.special.funcTargetVals;
        if (targetType != null) {
          text = "(${Transl.funcTargetType(targetType).l})$text";
        }
        _addTraits(text, func.functvals);
      }
    }
    // if (func.funcType != FuncType.subState ||
    //     func.traitVals.map((e) => e.id).join(',') != func.functvals.map((e) => e.id).join(',')) {
    //   _addTraits(Transl.special.funcTargetVals, func.functvals);
    // }
    if ([
      FuncType.extendBuffcount,
      FuncType.extendBuffturn,
      FuncType.shortenBuffcount,
      FuncType.shortenBuffturn,
    ].contains(func.funcType)) {
      _addTraits(Transl.special.funcTargetVals, vals?.TargetList ?? []);
    }
    if (vals?.TargetFunctionIndividuality?.isNotEmpty == true) {
      _addTraits('(func)${Transl.special.funcTargetVals}', vals!.TargetFunctionIndividuality!);
    }
    if (vals?.TargetBuffIndividuality?.isNotEmpty == true) {
      _addTraits('(buff)${Transl.special.funcTargetVals}', vals!.TargetBuffIndividuality!);
    }
    if (vals?.ApplyBuffIndividuality?.isNotEmpty == true) {
      _condSpans.add([
        TextSpan(text: '(Buff)${Transl.special.funcTargetVals}'),
        ...SharedBuilder.traitsListSpans(context: context, traitsList: vals!.ApplyBuffIndividuality!),
        const TextSpan(text: ' '),
      ]);
    }

    if (buff != null) {
      _addTraits(Transl.special.buffCheckSelf, buff.ckSelfIndv, useAnd: buff.script.checkIndvTypeAnd == true);
      if (buff.type == BuffType.upToleranceSubstate &&
          buff.ckOpIndv.toSet().equalTo(Trait.upToleranceSubstateBuffTraits.map((e) => e.value).toSet())) {
        _condSpans.add([
          TextSpan(text: Transl.special.buffCheckOpposite),
          SharedBuilder.textButtonSpan(context: context, text: Transl.special.variousPositiveBuffs),
          const TextSpan(text: ' '),
        ]);
      } else {
        _addTraits(Transl.special.buffCheckOpposite, buff.ckOpIndv, useAnd: buff.script.checkIndvTypeAnd == true);
      }
      final script = buff.script;
      if (script.TargetIndiv != null) {
        _addTraits('Target Indiv: ', [script.TargetIndiv!]);
      }

      List<int> ownerIndivs = [];
      bool ownerIndivAnd = false;
      if (buff.script.INDIVIDUALITIE != null) {
        ownerIndivs.add(buff.script.INDIVIDUALITIE!);
      } else if (buff.script.INDIVIDUALITIE_AND != null) {
        ownerIndivs = buff.script.INDIVIDUALITIE_AND!;
        ownerIndivAnd = true;
      } else if (buff.script.INDIVIDUALITIE_OR != null) {
        ownerIndivs = buff.script.INDIVIDUALITIE_OR!;
      }
      if (ownerIndivs.isNotEmpty) {
        String? countCond;
        if (buff.script.INDIVIDUALITIE_COUNT_ABOVE != null) {
          countCond = '≥${buff.script.INDIVIDUALITIE_COUNT_ABOVE}';
        } else if (buff.script.INDIVIDUALITIE_COUNT_BELOW != null) {
          countCond = '≤${buff.script.INDIVIDUALITIE_COUNT_BELOW}';
        }
        if ((buff.type == BuffType.guts || buff.type == BuffType.gutsRatio) &&
            ownerIndivs.length == 1 &&
            ownerIndivs.first == -3086 &&
            countCond == null) {
          // don't show gutsBlock
        } else {
          final ownerIndivSpans = SharedBuilder.replaceSpan(Transl.special.buffOwnerIndiv, '{0}', [
            ...SharedBuilder.traitSpans(context: context, traits: ownerIndivs, useAndJoin: ownerIndivAnd),
            if (countCond != null) TextSpan(text: countCond),
          ]);
          final targetTypeId = buff.script.individualityCondTargetType;
          if (targetTypeId != null) {
            final targetType = BuffConditionTargetType.fromId(targetTypeId);
            ownerIndivSpans.insert(0, TextSpan(text: "(${targetType?.dispName ?? 'TargetType $targetTypeId'})"));
          }
          _condSpans.add(ownerIndivSpans);
        }
      }

      for (final (target, ckCountIndiv) in [
        (Transl.special.buffCheckSelf, buff.script.ckSelfCountIndividuality),
        (Transl.special.buffCheckOpposite, buff.script.ckOpCountIndividuality),
      ]) {
        if (ckCountIndiv == null || ckCountIndiv.isEmpty) continue;
        _condSpans.add([
          TextSpan(text: target),
          ...SharedBuilder.replaceSpan(Transl.special.buffOwnerIndiv, '{0}', [
            ...SharedBuilder.traitSpans(context: context, traits: ckCountIndiv, useAndJoin: false),
            if (buff.script.ckIndvCountBelow != null) TextSpan(text: '≤${buff.script.ckIndvCountBelow}'),
            if (buff.script.ckIndvCountAbove != null) TextSpan(text: '≥${buff.script.ckIndvCountAbove}'),
          ]),
        ]);
      }

      if (script.HP_HIGHER != null) {
        final v = script.HP_HIGHER!.format(percent: true, base: 10);
        _condSpans.add([TextSpan(text: 'HP≥$v')]);
      }
      if (script.HP_LOWER != null) {
        final v = script.HP_LOWER!.format(percent: true, base: 10);
        _condSpans.add([TextSpan(text: 'HP≤$v')]);
      }
      if (script.useFirstTimeInTurn == 1) {
        _condSpans.add([TextSpan(text: Transl.miscFunction('useFirstTimeInTurn'))]);
      }
      if (script.fromMasterEquip == 1) {
        _condSpans.add([TextSpan(text: Transl.miscFunction('fromMasterEquip'))]);
      }
      if (script.fromCommandSpell == 1) {
        _condSpans.add([TextSpan(text: Transl.miscFunction('fromCommandSpell'))]);
      }
      if (buff.type == BuffType.npattackPrevBuff) {
        _condSpans.add([TextSpan(text: '替换宝具效果中的第${(vals?.Value ?? 0) + 1}个效果(包含敌方效果)')]);
      }

      final condBuffValues = buff.script.condBuffValue ?? [];
      for (final condBuffValue in condBuffValues) {
        final buffType = BuffType.fromId(condBuffValue.buffType ?? -1);
        final buffIndivs = condBuffValue.buffIndividualitie ?? [];
        final targetType = condBuffValue.valueCondTargetTypeEnum;
        String? condValue = condBuffValue.condValue;
        if (condValue != null) {
          final percentBase = buffType?.percentBase;
          if (percentBase != null) {
            condValue = condValue.replaceAllMapped(RegExp(r'\d+'), (m) {
              return int.parse(m.group(0)!).format(percent: true, base: percentBase);
            });
          }
        }

        _condSpans.add([
          TextSpan(
            children: [
              if (targetType != null) TextSpan(text: '${targetType.dispName}: '),
              const TextSpan(text: '('),
              if (condBuffValue.buffType != null) ...[
                SharedBuilder.textButtonSpan(
                  context: context,
                  text: buffType == null ? 'BuffType ${condBuffValue.buffType}' : Transl.buffType(buffType).l,
                  onTap: () => router.push(
                    url: Routes.buffs,
                    child: BuffListPage(type: buff.type),
                    detail: false,
                  ),
                ),
              ],
              if (condBuffValue.buffType != null && buffIndivs.isNotEmpty) const TextSpan(text: ' & '),
              if (buffIndivs.isNotEmpty) ...[
                TextSpan(text: ' ${S.current.trait} '),
                ...SharedBuilder.traitSpans(
                  context: context,
                  traits: buffIndivs,
                  useAndJoin: condBuffValue.checkIndvTypeAnd,
                ),
              ],
              const TextSpan(text: ') '),
              TextSpan(text: condValue),
            ],
          ),
        ]);
      }
    }

    if (func.funcType == FuncType.lastUsePlayerSkillCopy) {
      final buffTypes = vals?.CopyTargetBuffType ?? [];
      final funcTypes = vals?.CopyTargetFunctionType ?? [];
      final ptOnly = vals?.CopyFunctionTargetPTOnly == 1;
      if (buffTypes.isNotEmpty) {
        _condSpans.add([
          TextSpan(text: Transl.misc2('Function', 'CopyTargetBuffType')),
          const TextSpan(text: ': '),
          TextSpan(text: buffTypes.toString()),
          const TextSpan(text: ' '),
        ]);
      }
      if (funcTypes.isNotEmpty) {
        _condSpans.add([
          TextSpan(text: Transl.misc2('Function', 'CopyTargetFunctionType')),
          const TextSpan(text: ': '),
          TextSpan(text: funcTypes.toString()),
          const TextSpan(text: ' '),
        ]);
      }
      if (ptOnly) {
        _condSpans.add([
          TextSpan(text: Transl.misc2('Function', 'CopyFunctionTargetPTOnly')),
          const TextSpan(text: ' '),
        ]);
      }
    }

    if (vals?.FriendShipAbove != null) {
      _condSpans.add([TextSpan(text: '${S.current.bond}≥${vals?.FriendShipAbove}')]);
    }
    if (vals?.StartingPosition?.isNotEmpty == true) {
      _condSpans.add([
        TextSpan(text: '${Transl.miscFunction('StartingPosition')}: ${vals!.StartingPosition!.join("/")}'),
      ]);
    }
    if (vals?.CheckOverChargeStageRange != null) {
      final ocRanges = DataVals.beautifyRangeTexts(
        vals!.CheckOverChargeStageRange!,
      ).map((e) => e.replaceAllMapped(RegExp(r'\d+'), (m) => (int.parse(m.group(0)!) + 1).toString())).toList();
      _condSpans.add([TextSpan(text: '${Transl.miscFunction('CheckOverChargeStageRange')}: ${ocRanges.join(" & ")}')]);
    }
    if (vals?.CheckBattlePointPhaseRange?.isNotEmpty == true) {
      final ranges = DataVals.beautifyRangeTexts(vals!.CheckBattlePointPhaseRange!.first.range);
      _condSpans.add([TextSpan(text: '${Transl.miscFunction('CheckBattlePointPhaseRange')}: ${ranges.join(" & ")}')]);
    }
    if (vals?.TriggeredFieldCountTarget != null) {
      final target = {
        0: FuncTargetType.ptAll,
        1: FuncTargetType.enemyAll,
        2: FuncTargetType.fieldAll, //
      }[vals?.TriggeredFieldCountTarget];
      final targetText = target == null
          ? 'Unknown Target ${vals?.TriggeredFieldCountTarget}'
          : Transl.funcTargetType(target).l;
      String range = vals?.TriggeredFieldCountRange ?? "";
      range = range
          .replaceAllMapped(RegExp(r'<(\d+)'), (m) => '≤${m.group(1)}')
          .replaceAllMapped(RegExp(r'>(\d+)'), (m) => '≥${m.group(1)}')
          .replaceAllMapped(RegExp(r'(\d+)<'), (m) => '≥${m.group(1)}');
      _condSpans.add([TextSpan(text: '$targetText '), TextSpan(text: 'Count $range')]);
    }

    if (func.funcquestTvals.isNotEmpty) {
      if (showEvent || func.funcquestTvals.any((e) => !db.gameData.mappingData.fieldTrait.containsKey(e.abs()))) {
        _condSpans.add(
          SharedBuilder.replaceSpan(
            Transl.special.funcTraitOnField,
            '{0}',
            SharedBuilder.traitSpans(
              context: context,
              traits: func.funcquestTvals,
              format: (v) => Transl.traitName(v, field: true),
            ),
          ),
        );
      }
    }
    if (vals?.EventId != null && vals?.EventId != 0 && showEvent) {
      final eventName =
          db.gameData.events[vals?.EventId]?.lShortName.l.replaceAll('\n', ' ') ?? 'Event ${vals?.EventId}';
      _condSpans.add(
        SharedBuilder.replaceSpan(Transl.special.funcEventOnly, '{0}', [
          TextSpan(
            text: eventName,
            style: TextStyle(color: AppTheme(context).tertiary),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                router.push(url: Routes.eventI(vals!.EventId!));
              },
          ),
        ]),
      );
    }

    for (int index = 0; index < _condSpans.length; index++) {
      spans.add(TextSpan(text: index == _condSpans.length - 1 ? '\n ┗ ' : '\n ┣ '));
      spans.addAll(_condSpans[index]);
    }

    Widget title = Text.rich(TextSpan(children: spans), style: Theme.of(context).textTheme.bodySmall);
    title = InkWell(
      onTap: () => func.routeTo(region: region),
      child: title,
    );
    Widget last = _DescriptorWrapper(
      title: title,
      trailing: trailing,
      lvCells: lvCells,
      ocCells: ocCells,
      supportCells: supportCells,
      lv: level,
      oc: oc,
    );

    final triggerSkills = _buildTrigger(context);
    final dependFunc = _buildDependFunc(context);
    if (triggerSkills.isNotEmpty || dependFunc != null) {
      last = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget?>[last, ...triggerSkills, dependFunc].whereType<Widget>().toList(),
      );
    }
    last = Padding(padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: last);
    return last;
  }

  List<Widget> _buildTrigger(BuildContext context) {
    DataVals? vals = func.svalsList.getOrNull((oc ?? 1) - 1)?.getOrNull((level ?? 1) - 1);
    final isFuncTrigger = kFuncValueTriggerTypes.containsKey(func.funcType);
    final triggers = kBuffValueTriggerTypes[func.buff?.type] ?? kFuncValueTriggerTypes[func.funcType];

    if (triggers == null || triggers.isEmpty) return [];
    List<Widget> children = [];
    for (final trigger in triggers) {
      final details = func.svals.map((e) => trigger(e)).toList();
      final ocDetails = func.ocVals(0).map((e) => trigger(e)).toList();
      func.svalsList.getOrNull((oc ?? 1) - 1)?.getOrNull((level ?? 1) - 1);
      final detail = vals != null ? trigger(vals) : details.getOrNull((level ?? -1) - 1) ?? details.firstOrNull;
      bool noLevel =
          details.isEmpty ||
          ((level == null || level == -1) && details.map((e) => e.level).toSet().length > 1) ||
          ((oc == null || oc == -1) && ocDetails.map((e) => e.level).toSet().length > 1);

      vals ??= func.svals.getOrNull((level ?? 1) - 1);
      vals ??= func.svals.getOrNull(0);
      if (detail == null || detail.skill == null) continue;

      if (noLevel) detail.level = null;

      final isNp = vals?.UseTreasureDevice == 1;
      Widget triggerChild;
      if (func.buff?.type == BuffType.counterFunction && vals?.UseAttack == 1) {
        final cardId = vals?.CounterId ?? 0;
        final textStyle = Theme.of(context).textTheme.bodySmall;
        String prefix = '[${Transl.buffType(func.buff!.type).l}] ${S.current.battle_command_card} ';
        triggerChild = _DescriptorWrapper(
          title: Text.rich(
            TextSpan(
              text: ' ',
              children: [
                CenterWidgetSpan(child: CommandCardWidget(card: cardId, width: 24)),
                TextSpan(text: ' $prefix ${CardType.getName(cardId).toTitle()}'),
              ],
            ),
            style: textStyle,
          ),
          trailing: null,
        );
      } else {
        triggerChild = _LazyTrigger(
          trigger: detail,
          buff: func.buff,
          func: isFuncTrigger ? func : null,
          isNp: isNp,
          useRate: vals?.UseRate,
          showPlayer: func.funcTargetType.isEnemy ? showEnemy : showPlayer,
          showEnemy: func.funcTargetType.isEnemy ? showPlayer : showEnemy,
          loops: LoopTargets.from(loops)..addFunc(func.funcId),
          region: region,
        );
      }
      children.add(
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).hintColor),
            borderRadius: BorderRadius.circular(6),
          ),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
          child: triggerChild,
        ),
      );
    }
    return children;
  }

  Widget? _buildDependFunc(BuildContext context) {
    final dependFuncId = func.svals.getOrNull(0)?.DependFuncId;
    if (dependFuncId == null) return null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor),
        borderRadius: BorderRadius.circular(6),
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
      child: _LazyFunc(
        dependFuncId: dependFuncId,
        trigger: func,
        level: level,
        loops: LoopTargets.from(loops)..addFunc(func.funcId),
        region: region,
      ),
    );
  }

  // ignore: unused_element
  Map<String, dynamic> _getFuncJson() {
    List<String> _traitList(List<int> traits) {
      return traits.map(Transl.traitName).toList();
    }

    final buff = func.buff;
    final script = buff?.script;
    return {
      "type": '${Transl.funcType(func.funcType).l}/${func.funcType.name}',
      "target": '${Transl.funcTargetType(func.funcTargetType).l}/${func.funcTargetType.name}',
      "team": func.funcTargetTeam.name,
      "popupText": func.lPopupText.l,
      if (func.functvals.isNotEmpty) "targetTraits": _traitList(func.functvals),
      if (func.funcquestTvals.isNotEmpty) "fieldTraits": _traitList(func.funcquestTvals),
      if (func.traitVals.isNotEmpty) "funcTargetTraits": _traitList(func.traitVals),
      if (buff != null) ...{
        "----buff----": "↓",
        "id": buff.id,
        "name": Transl.buffNames(buff.name).l,
        "buffType": '${Transl.buffType(buff.type).l}/${buff.type.name}',
        "detail": Transl.buffDetail(buff.detail).l,
        if (buff.ckSelfIndv.isNotEmpty) "ckSelfIndv": _traitList(buff.ckSelfIndv),
        if (buff.ckOpIndv.isNotEmpty) "ckOpIndv": _traitList(buff.ckOpIndv),
        "buffGroup": buff.buffGroup,
        if (buff.vals.isNotEmpty) "buffTraits": _traitList(buff.vals),
        "maxRate": buff.maxRate,
        if (script != null) ...{
          "----script----": "↓",
          "checkIndvType": ?script.checkIndvType,
          "CheckOpponentBuffTypes": ?script.CheckOpponentBuffTypes?.map(
            (e) => '${e.name}(${Transl.buffType(e).l})',
          ).toList(),
          if (script.relationId != null) "relationId": "!BuffRelationOverwrite!",
          "ReleaseText": ?script.ReleaseText,
          "DamageRelease": ?script.DamageRelease,
          if (script.INDIVIDUALITIE != null) "INDIVIDUALITIE": Transl.traitName(script.INDIVIDUALITIE!),
          if (script.UpBuffRateBuffIndiv != null) "UpBuffRateBuffIndiv": _traitList(script.UpBuffRateBuffIndiv!),
          "HP_LOWER": ?script.HP_LOWER,
        },
      },
    };
  }
}

class _LazyTrigger extends StatefulWidget {
  final BuffValueTriggerType trigger;
  final Buff? buff;
  final BaseFunction? func; // non-buff func, e.g. generateBattleSkillDrop
  final bool isNp;
  final int? useRate;
  final bool showPlayer;
  final bool showEnemy;
  final LoopTargets loops;
  final Region? region;

  const _LazyTrigger({
    required this.trigger,
    required this.buff,
    required this.func,
    required this.isNp,
    required this.useRate,
    required this.showPlayer,
    required this.showEnemy,
    required this.loops,
    required this.region,
  });

  @override
  State<_LazyTrigger> createState() => __LazyTriggerState();
}

class __LazyTriggerState extends State<_LazyTrigger> with FuncsDescriptor {
  SkillOrTd? skill;

  @override
  void initState() {
    super.initState();
    _fetchSkill();
  }

  @override
  void didUpdateWidget(covariant _LazyTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger.skill != oldWidget.trigger.skill) {
      _fetchSkill();
    }
  }

  void _fetchSkill() async {
    skill = null;
    if (widget.region == null || widget.region == Region.jp) {
      if (!widget.isNp) {
        skill = db.gameData.baseTds[widget.trigger.skill];
      } else {
        skill = db.gameData.baseSkills[widget.trigger.skill];
      }
    }
    if (skill != null) return;

    final skillId = widget.trigger.skill;
    if (skillId == null) {
      skill = null;
    } else if (widget.isNp) {
      skill = db.gameData.baseTds[skillId] ?? await AtlasApi.td(skillId, region: widget.region ?? Region.jp);
    } else {
      skill = db.gameData.baseSkills[skillId] ?? await AtlasApi.skill(skillId, region: widget.region ?? Region.jp);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String title = 'ID ${widget.trigger.skill}';
    if (skill != null) {
      title += ': ${skill!.lName.l}';
    }
    List<String> hints = [
      if (widget.buff != null)
        Transl.funcPopuptextBase(widget.buff!.type.name).l
      else if (widget.func != null)
        Transl.funcType(widget.func!.funcType).l,
      if (widget.useRate != null) Transl.special.funcValActChance(widget.useRate!.format(percent: true, base: 10)),
    ];
    final loops = LoopTargets.from(widget.loops)..addSkill(widget.trigger.skill);
    bool loop = widget.loops.skills.contains(skill?.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (skill != null) {
              skill?.routeTo(region: widget.region);
            } else if (widget.trigger.skill != null) {
              final id = widget.trigger.skill!;
              router.push(url: widget.isNp ? Routes.tdI(id) : Routes.skillI(id), region: widget.region);
            }
          },
          child: Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: '  $title ',
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
                if (hints.isNotEmpty) TextSpan(text: ' [${hints.join(", ")}]'),
              ],
              // recognizer: TapGestureRecognizer()..onTap = () => skill?.routeTo(),
            ),
          ),
        ),
        if (!loop)
          ...describeFunctions(
            funcs: skill?.functions ?? [],
            script: skill?.script,
            showPlayer: widget.showPlayer,
            showEnemy: widget.showEnemy,
            showActIndiv: false,
            level: widget.trigger.level,
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 2, 4),
            owner: skill,
            loops: loops,
            region: widget.region,
          ),
        if (loop)
          Center(
            child: Text.rich(
              TextSpan(
                text: '∞ ${widget.isNp ? S.current.noble_phantasm : S.current.skill} ',
                children: [
                  SharedBuilder.textButtonSpan(
                    context: context,
                    text: widget.trigger.skill.toString(),
                    onTap: () {
                      if (widget.trigger.skill != null) {
                        router.push(url: Routes.skillI(widget.trigger.skill!));
                      }
                    },
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _LazyFunc extends StatefulWidget {
  final int dependFuncId;
  final NiceFunction trigger;
  final int? level;
  final LoopTargets loops;
  final Region? region;

  const _LazyFunc({
    required this.dependFuncId,
    required this.trigger,
    required this.level,
    required this.loops,
    required this.region,
  });

  @override
  State<_LazyFunc> createState() => ___LazyFuncState();
}

class ___LazyFuncState extends State<_LazyFunc> with FuncsDescriptor {
  BaseFunction? func;

  @override
  void initState() {
    super.initState();
    _fetchFunc();
  }

  @override
  void didUpdateWidget(covariant _LazyFunc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dependFuncId != oldWidget.dependFuncId) {
      _fetchFunc();
    }
  }

  void _fetchFunc() async {
    func = null;
    if (widget.region == null || widget.region == Region.jp) {
      func = db.gameData.baseFunctions[widget.dependFuncId];
    }
    func ??= await AtlasApi.func(widget.dependFuncId, region: widget.region ?? Region.jp);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _func = func;
    final bool loop = widget.loops.funcs.contains(func?.funcId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!loop)
          if (_func != null)
            ...describeFunctions(
              funcs: [
                NiceFunction(
                  funcId: _func.funcId,
                  funcType: _func.funcType,
                  funcTargetType: _func.funcTargetType,
                  funcTargetTeam: _func.funcTargetTeam,
                  funcPopupText: _func.funcPopupText,
                  funcPopupIcon: _func.funcPopupIcon,
                  functvals: _func.functvals,
                  funcquestTvals: _func.funcquestTvals,
                  funcGroup: _func.funcGroup,
                  traitVals: _func.traitVals,
                  buffs: _func.buffs,
                  svals: _getDependVals(widget.trigger.svals),
                  svals2: _getDependVals(widget.trigger.svals2),
                  svals3: _getDependVals(widget.trigger.svals3),
                  svals4: _getDependVals(widget.trigger.svals4),
                  svals5: _getDependVals(widget.trigger.svals5),
                ),
              ],
              script: null,
              level: widget.level,
              showPlayer: true,
              showEnemy: true,
              padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 2, 4),
              loops: widget.loops.copy()..addFunc(widget.dependFuncId),
              region: widget.region,
            )
          else
            InkWell(
              onTap: () {
                if (_func != null) {
                  _func.routeTo(region: widget.region);
                } else {
                  router.push(url: Routes.funcI(widget.dependFuncId), region: widget.region);
                }
              },
              child: Text(
                '  Function ${widget.dependFuncId}  ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(decoration: TextDecoration.underline),
              ),
            ),
        if (loop)
          Center(
            child: Text.rich(
              TextSpan(
                text: '∞ Function ',
                children: [
                  SharedBuilder.textButtonSpan(
                    context: context,
                    text: widget.dependFuncId.toString(),
                    onTap: () {
                      router.push(url: Routes.funcI(widget.dependFuncId));
                    },
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  List<DataVals>? _getDependVals(List<DataVals>? svals) {
    if (svals == null) return null;
    final dependsvals = svals.map((e) => e.DependFuncVals).toList();
    if (dependsvals.any((e) => e == null)) return null;
    if (widget.trigger.funcType == FuncType.gainNpFromTargets || widget.trigger.funcType == FuncType.absorbNpturn) {
      return dependsvals.map((e) => DataVals(e!.toJson()..remove('Value2'))).toList();
    }
    return List.from(dependsvals);
  }
}

class LoopTargets {
  Set<int> skills = {}; //include tds
  Set<int> funcs = {};

  LoopTargets copy() {
    return LoopTargets()
      ..skills = skills.toSet()
      ..funcs = funcs.toSet();
  }

  static LoopTargets from(LoopTargets? other) {
    if (other == null) return LoopTargets();
    return other.copy();
  }

  void addSkill(int? id) {
    if (id != null) {
      skills.add(id);
    }
  }

  void addFunc(int? id) {
    if (id != null) {
      funcs.add(id);
    }
  }
}
