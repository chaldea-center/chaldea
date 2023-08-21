import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/enemy/enemy_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'trait_edit.dart';

class QuestEnemyEditPage extends StatefulWidget {
  final bool simple;
  final QuestEnemy enemy;
  final QuestEnemy Function(QuestEnemy enemy)? onReset;
  final QuestEnemy Function(QuestEnemy enemy)? onPaste;
  final VoidCallback? onClear;
  const QuestEnemyEditPage(
      {super.key, required this.enemy, this.simple = false, this.onReset, this.onPaste, this.onClear});

  @override
  State<QuestEnemyEditPage> createState() => _QuestEnemyEditPageState();
}

class _QuestEnemyEditPageState extends State<QuestEnemyEditPage> {
  late QuestEnemy enemy;
  Servant? niceSvt;

  QuestEnemy initEnemy(QuestEnemy e) {
    niceSvt = db.gameData.servantsById[e.svt.id];
    enemy = e;
    if (niceSvt == null && e.svt.id != QuestEnemy.blankEnemy().svt.id) {
      showEasyLoading(() => AtlasApi.svt(enemy.svt.id)).then((value) {
        if (value != null && enemy.svt.id == value.id) {
          niceSvt = value;
        }
        if (mounted) setState(() {});
      });
    }
    return e;
  }

  @override
  void initState() {
    super.initState();
    initEnemy(widget.enemy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('[${S.current.edit}] ${S.current.enemy}'),
        actions: [
          if (widget.onReset != null)
            IconButton(
              onPressed: () {
                setState(() {
                  initEnemy(widget.onReset!(enemy));
                });
              },
              icon: const Icon(Icons.restore),
              tooltip: S.current.reset,
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(S.current.copy),
                onTap: () {
                  setState(() {
                    db.runtimeData.clipBoard.questEnemy = enemy;
                  });
                  EasyLoading.showSuccess(S.current.copied);
                },
              ),
            ],
          )
        ],
      ),
      body: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    final classIds = {...ConstData.classInfo.keys, enemy.svt.classId}.toList();
    classIds.sort2((e) => ConstData.classInfo[e]?.priority ?? 0, reversed: true);
    List<Widget> children = [
      CustomTile(
        leading: db.getIconImage(enemy.icon ?? Atlas.common.unknownEnemyIcon, width: 64, aspectRatio: 1),
        title: Text(enemy.lShownName),
        subtitle:
            Text('No.${enemy.svt.shownId} $kStarChar2${enemy.svt.rarity} ${Transl.svtClassId(enemy.svt.classId).l}'),
        trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        onTap: enemy.routeTo,
      ),
      DividerWithTitle(title: S.current.select, height: 16),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          FilledButton(
            onPressed: () {
              router.pushPage(ServantListPage(onSelected: _onSelectSvt));
            },
            child: Text(S.current.servant),
          ),
          FilledButton(
            onPressed: () {
              router.pushPage(EnemyListPage(onSelected: _onSelectEntity));
            },
            child: Text(S.current.enemy),
          ),
          if (widget.onPaste != null)
            FilledButton(
              onPressed: db.runtimeData.clipBoard.questEnemy == null
                  ? null
                  : () {
                      final enemy2 = widget.onPaste!(db.runtimeData.clipBoard.questEnemy!);
                      enemy = initEnemy(enemy2);
                      setState(() {});
                    },
              child: Text(S.current.paste),
            ),
          if (widget.onClear != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onClear!();
              },
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
              child: Text(S.current.remove),
            ),
        ],
      ),
      const Divider(height: 16),
      enumTile<int>(
        title: Text(S.current.svt_class),
        value: enemy.svt.classId,
        values: classIds,
        itemBuilder: (v) => Text(Transl.svtClassId(v).l.substring2(0, 15), textScaleFactor: 0.8),
        onChanged: (v) {
          enemy.svt.classId = v;
          updateTrait(niceSvt, null);
        },
      ),
      enumTile<Attribute>(
        title: Text(S.current.filter_attribute),
        value: enemy.svt.attribute,
        values: Attribute.values,
        itemBuilder: (v) => Text(Transl.svtAttribute(v).l, textScaleFactor: 0.9),
        onChanged: (v) {
          enemy.svt.attribute = v;
          updateTrait(niceSvt, null);
        },
      ),
      ListTile(
        dense: true,
        title: Text(S.current.trait),
        subtitle: enemy.traits.isEmpty
            ? const Text('NONE')
            : SharedBuilder.traitList(context: context, traits: enemy.traits..sort2((e) => e.id)),
        trailing: IconButton(
          onPressed: () {
            router.pushPage(TraitEditPage(
              traits: enemy.traits,
              onChanged: (traits) {
                enemy.traits = traits.toList();
                if (mounted) setState(() {});
              },
            ));
          },
          icon: const Icon(Icons.edit),
          tooltip: S.current.edit,
        ),
      ),
    ];

    if (niceSvt != null) {
      final limits = {
        ...niceSvt!.ascensionAdd.lvMax.all.keys,
        if (niceSvt!.isUserSvt) ...[0, 1, 2, 3, 4]
      }.toList();
      if (limits.isEmpty) limits.add(0);
      limits.sort();
      final dftValue = limits.first;
      if (enemy.limit.dispLimitCount != 0 && enemy.limit.limitCount == 0) {
        enemy.limit.limitCount = enemy.limit.dispLimitCount;
      }

      if (!limits.contains(enemy.limit.limitCount)) {
        final costume =
            enemy.svt.costume.values.firstWhereOrNull((e) => e.id > 10 && e.id < 100 && e.id == enemy.limit.limitCount);
        enemy.limit.limitCount = costume?.battleCharaId ?? dftValue;
      }
      final costume = niceSvt?.profile.costume.values
          .firstWhereOrNull((e) => e.id == enemy.limit.limitCount || e.battleCharaId == enemy.limit.limitCount);
      children.add(enumTile<int>(
        title: Text(S.current.ascension),
        subtitle: costume == null ? null : Text(costume.lName.l),
        value: enemy.limit.limitCount,
        values: limits,
        itemBuilder: (v) {
          if (v < 10) return Text(v.toString());
          return Text(v.toString());
        },
        onChanged: (v) {
          enemy.limit.limitCount = v;
          if (niceSvt != null && niceSvt!.id == enemy.svt.id) {
            updateLimitCount(niceSvt!);
          }
        },
      ));
    } else {
      children.add(ListTile(
        dense: true,
        title: Text(S.current.ascension),
        trailing: Text((enemy.limit.limitCount).toString()),
      ));
    }

    children.add(const Divider(height: 16));
    children.addAll([
      intInputTile(
        title: 'HP',
        value: enemy.hp,
        base: 1,
        isPercent: false,
        onChanged: (v) {
          if (v >= 0) {
            enemy.hp = v;
          }
        },
      ),
      intInputTile(
        title: S.current.info_death_rate,
        value: enemy.deathRate,
        base: 10,
        isPercent: true,
        onChanged: (v) {
          enemy.deathRate = v;
        },
      ),
      intInputTile(
        title: S.current.defense_np_rate,
        value: enemy.serverMod.tdRate,
        base: 10,
        isPercent: true,
        onChanged: (v) {
          enemy.serverMod.tdRate = v;
        },
      ),
      intInputTile(
        title: S.current.attack_np_rate,
        value: enemy.serverMod.tdAttackRate,
        base: 10,
        isPercent: true,
        onChanged: (v) {
          enemy.serverMod.tdAttackRate = v;
        },
      ),
      intInputTile(
        title: S.current.crit_star_mod,
        value: enemy.serverMod.starRate,
        base: 10,
        isPercent: true,
        onChanged: (v) {
          enemy.serverMod.starRate = v;
        },
      ),
      if (enemy.noblePhantasm.noblePhantasm != null)
        enumTile<int>(
          title: Text(S.current.info_charge),
          value: enemy.chargeTurn,
          values: List.generate(max(10, enemy.chargeTurn) + 1, (index) => index),
          itemBuilder: (v) => Text(v.toString(), textScaleFactor: 0.8),
          onChanged: (v) {
            enemy.chargeTurn = v;
          },
        ),
    ]);

    children.add(const SafeArea(child: SizedBox(height: 36)));
    return ListView(children: children);
  }

  void _onSelectSvt(Servant svt) {
    // check type
    if (!svt.type.isServantType) {
      EasyLoading.showError(S.current.input_invalid_hint);
      return;
    }
    niceSvt = svt;
    enemy.svt = BasicServant.fromNice(svt);
    enemy.name = svt.name;
    // enemy.serverMod
    final td = svt.noblePhantasms.lastWhereOrNull((e) => e.svt.num == 1);
    final skill1 = svt.groupedActiveSkills[1]?.lastOrNull,
        skill2 = svt.groupedActiveSkills[2]?.lastOrNull,
        skill3 = svt.groupedActiveSkills[3]?.lastOrNull;
    enemy
      ..deathRate = svt.instantDeathChance
      ..traits = svt.traits.toList()
      ..skills = EnemySkill(
        skill1: skill1,
        skill2: skill2,
        skill3: skill3,
        skillId1: skill1?.id ?? 0,
        skillId2: skill2?.id ?? 0,
        skillId3: skill3?.id ?? 0,
        skillLv1: skill1?.maxLv ?? 0,
        skillLv2: skill2?.maxLv ?? 0,
        skillLv3: skill3?.maxLv ?? 0,
      )
      ..classPassive = EnemyPassive(classPassive: svt.classPassive.toList())
      ..noblePhantasm =
          EnemyTd(noblePhantasmId: td?.id ?? 0, noblePhantasm: td, noblePhantasmLv: 1, noblePhantasmLv1: 1)
      ..limit = EnemyLimit(limitCount: 0);
    if (svt.collectionNo > 0) {
      enemy.deathRate = 0;
    }

    updateLimitCount(svt);
    updateDefaultChargeTurn();
    if (mounted) setState(() {});
  }

  void _onSelectEntity(BasicServant svt) async {
    niceSvt = null;
    if (!const [SvtType.enemy, SvtType.enemyCollection, SvtType.normal].contains(enemy.svt.type)) {
      EasyLoading.showError(S.current.invalid_input);
      return;
    }
    enemy.svt = BasicServant.fromJson(svt.toJson());
    enemy.name = svt.name;
    bool found = false;
    if (svt.collectionNo == 0) {
      for (final quest in db.gameData.questPhases.values) {
        for (final qe in quest.allEnemies) {
          if (qe.svt.id == svt.id) {
            found = true;
            enemy
              ..deathRate = qe.deathRate
              ..chargeTurn = qe.chargeTurn
              ..traits = qe.traits.toList()
              ..skills = EnemySkill.fromJson(qe.skills.toJson())
              ..classPassive = EnemyPassive.fromJson(qe.classPassive.toJson())
              ..noblePhantasm = EnemyTd.fromJson(qe.noblePhantasm.toJson())
              ..limit = EnemyLimit.fromJson(qe.limit.toJson());
            break;
          }
        }
        if (found) break;
      }
    }
    if (!found) {
      EasyLoading.show();
      final niceSvt = await AtlasApi.svt(svt.id);
      EasyLoading.dismiss();
      if (niceSvt != null) {
        _onSelectSvt(niceSvt);
      }
    }
    updateDefaultChargeTurn();
    if (mounted) setState(() {});
  }

  void updateDefaultChargeTurn() {
    if (enemy.noblePhantasm.noblePhantasm == null) {
      enemy.chargeTurn = 0;
      return;
    }
    switch (enemy.svt.className) {
      case SvtClass.archer:
      case SvtClass.assassin:
      case SvtClass.alterEgo:
      case SvtClass.moonCancer:
        enemy.chargeTurn = 3;
        return;
      case SvtClass.saber:
      case SvtClass.lancer:
      case SvtClass.ruler:
      case SvtClass.pretender:
      case SvtClass.shielder:
        enemy.chargeTurn = 4;
        return;
      case SvtClass.rider:
      case SvtClass.berserker:
      case SvtClass.avenger:
      case SvtClass.foreigner:
      case SvtClass.beast:
        enemy.chargeTurn = 5;
        return;
      default:
        enemy.chargeTurn = 5;
        return;
    }
  }

  void updateLimitCount(Servant svt) {
    int limitCount = enemy.limit.limitCount;
    if (svt.extraAssets.faces.ascension?[limitCount] == null && svt.extraAssets.faces.costume?[limitCount] == null) {
      final costume = svt.profile.costume.values.firstWhereOrNull((e) => e.id > 10 && e.id < 100 && e.id == limitCount);
      limitCount = costume?.battleCharaId ?? 0;
    }
    enemy.limit.limitCount = limitCount;
    final face = niceSvt!.ascendIcon(limitCount, false);
    if (face != null) {
      // ignore: invalid_use_of_protected_member
      enemy.svt.face = face;
    }
    enemy.svt.rarity = svt.ascensionAdd.rarity.all[limitCount] ?? enemy.svt.rarity;
    updateTrait(svt, limitCount);
  }

  void updateTrait(Servant? svt, int? limitCount) {
    if (svt != null && limitCount != null) {
      final indivAdd = svt.ascensionAdd.individuality.all[limitCount];
      if (indivAdd != null && indivAdd.isNotEmpty) {
        enemy.traits = indivAdd.toList();
      } else {
        enemy.traits = svt.traits.toList();
      }
    }
    final removeTraits = <int?>{
      ...ConstData.classInfo.values.map((e) => e.individuality),
      ...Attribute.values.map((e) => e.trait?.id),
    };
    enemy.traits.removeWhere((e) => removeTraits.any((t) => t == e.id));
    final traitId = ConstData.classInfo[enemy.svt.classId]?.individuality;
    if (traitId != null && traitId > 0) {
      enemy.traits.add(NiceTrait(id: traitId));
    }

    final attriTrait = enemy.svt.attribute.trait;
    if (attriTrait != null) {
      enemy.traits.add(NiceTrait(id: attriTrait.id));
    }
  }

  Widget enumTile<T>({
    required Widget title,
    Widget? subtitle,
    required T value,
    required List<T> values,
    required Widget Function(T v) itemBuilder,
    required ValueChanged<T> onChanged,
  }) {
    return ListTile(
      dense: true,
      title: title,
      subtitle: subtitle,
      trailing: DropdownButton<T>(
        isDense: true,
        underline: const SizedBox.shrink(),
        value: value,
        alignment: AlignmentDirectional.centerEnd,
        items: [
          for (final v in values) DropdownMenuItem(value: v, child: itemBuilder(v)),
        ],
        onChanged: (v) {
          setState(() {
            if (v is T) onChanged(v);
          });
        },
      ),
    );
  }

  Widget intInputTile({
    required String title,
    Widget? subtitle,
    required int value,
    required final int base, // 10: 1000->100 or 100%
    required final bool isPercent,
    required ValueChanged<int> onChanged,
  }) {
    String format(int v) {
      if (base == 1 && !isPercent) return v.toString();
      return v.format(compact: false, base: base, percent: isPercent);
    }

    final dispValue = format(value);
    return ListTile(
      dense: true,
      title: Text(title),
      subtitle: subtitle,
      trailing: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              return InputCancelOkDialog(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                title: title,
                text: dispValue.trimChar('%'),
                validate: (s) => double.tryParse(s) != null,
                onSubmit: (s) {
                  final v = double.tryParse(s);
                  if (v == null) return;
                  onChanged((v * base).toInt());
                  if (mounted) setState(() {});
                },
              );
            },
          );
        },
        child: Text(format(value)),
      ),
    );
  }
}
