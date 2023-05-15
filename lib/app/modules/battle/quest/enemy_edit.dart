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

class QuestEnemyEditPage extends StatefulWidget {
  final bool simple;
  final QuestEnemy enemy;
  const QuestEnemyEditPage({super.key, required this.enemy, this.simple = false});

  @override
  State<QuestEnemyEditPage> createState() => _QuestEnemyEditPageState();
}

class _QuestEnemyEditPageState extends State<QuestEnemyEditPage> {
  late final enemy = widget.enemy;

  late Servant? niceSvt = db.gameData.servantsById[enemy.svt.id];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('[${S.current.edit}] ${S.current.enemy}'),
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
        subtitle: Text(Transl.svtClassId(enemy.svt.classId).l),
        trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        onTap: enemy.routeTo,
      ),
      DividerWithTitle(
        title: S.current.select,
        height: 16,
      ),
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
              router.pushPage(EnemyListPage(onSelected: _onSelectEnemy));
            },
            child: Text(S.current.enemy),
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
          enemy.traits.removeWhere((e) => ConstData.classInfo.values.any((cls) => cls.individuality == e.id));
          final traitId = ConstData.classInfo[v]?.individuality;
          if (traitId != null && traitId > 0) {
            enemy.traits.add(NiceTrait(id: traitId));
          }
        },
      ),
      enumTile<Attribute>(
        title: Text(S.current.filter_attribute),
        value: enemy.svt.attribute,
        values: Attribute.values,
        itemBuilder: (v) => Text(Transl.svtAttribute(v).l, textScaleFactor: 0.9),
        onChanged: (v) {
          enemy.svt.attribute = v;
          enemy.traits.removeWhere((e) => Attribute.values.any((attr) => attr.trait?.id == e.id));
          final trait = v.trait;
          if (trait != null) enemy.traits.add(NiceTrait(id: trait.id));
        },
      ),
      ListTile(
        dense: true,
        title: Text(S.current.trait),
        subtitle: enemy.traits.isEmpty
            ? const Text('NONE')
            : SharedBuilder.traitList(context: context, traits: enemy.traits..sort2((e) => e.id)),
      ),
    ];

    if (niceSvt != null) {
      final limits = {
        ...niceSvt!.ascensionAdd.individuality.all.keys,
        if (niceSvt!.isUserSvt) ...[0, 1, 2, 3, 4]
      }.toList();
      if (limits.isEmpty) limits.add(0);
      limits.sort();
      final dftValue = limits.first;
      if (enemy.limit != null && !limits.contains(enemy.limit!.limitCount)) {
        enemy.limit!.limitCount = dftValue;
      }
      children.add(enumTile<int>(
        title: Text(S.current.ascension),
        value: enemy.limit?.limitCount ?? dftValue,
        values: limits,
        itemBuilder: (v) {
          if (v < 10) return Text(v.toString());
          return Text(v.toString());
        },
        onChanged: (v) {
          enemy.limit ??= EnemyLimit();
          enemy.limit!.limitCount = v;
          if (niceSvt != null && niceSvt!.id == enemy.svt.id && niceSvt!.collectionNo > 0) {
            final face = niceSvt!.ascendIcon(v, false);
            if (face != null) {
              // ignore: invalid_use_of_protected_member
              enemy.svt.face = face;
            }
          }
        },
      ));
    } else {
      children.add(ListTile(
        dense: true,
        title: Text(S.current.ascension),
        trailing: Text((enemy.limit?.limitCount ?? 0).toString()),
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
          enemy.serverMod
            ..tdRate = v
            ..tdAttackRate = v;
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
    ]);

    children.add(const SafeArea(child: SizedBox(height: 36)));
    return ListView(children: children);
  }

  void _onSelectSvt(Servant svt) {
    niceSvt = svt;
    enemy.svt = BasicServant.fromNice(svt);
    enemy.name = svt.name;
    // enemy.serverMod
    final td = svt.noblePhantasms.lastWhereOrNull((e) => e.num == 1);
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
    if (mounted) setState(() {});
  }

  void _onSelectEnemy(BasicServant svt) async {
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
              ..limit = qe.limit == null ? null : EnemyLimit.fromJson(qe.limit!.toJson());
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
    if (mounted) setState(() {});
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
