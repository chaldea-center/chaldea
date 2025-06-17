import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/quest/breakdown/stage.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'enemy_edit.dart';
import 'trait_edit.dart';

class QuestEditPage extends StatefulWidget {
  final QuestPhase? quest;
  final Function(QuestPhase quest) onComplete;
  const QuestEditPage({super.key, required this.quest, required this.onComplete});

  @override
  State<QuestEditPage> createState() => _QuestEditPageState();
}

class _QuestEditPageState extends State<QuestEditPage> {
  late QuestPhase quest;

  @override
  void initState() {
    super.initState();
    quest = widget.quest == null ? getBlankQuest() : QuestPhase.fromJson(widget.quest!.toJson());
    quest.id = -quest.id.abs();
  }

  QuestPhase getBlankQuest() {
    final id = -(DateTime.now().timestamp % 10000000);
    return QuestPhase(
      id: id,
      name: "${S.current.general_custom} $id",
      phase: 1,
      phases: [1],
      stages: [Stage(wave: 1, enemies: [])],
    );
  }

  void onConfirm() {
    if (quest.stages.isEmpty) {
      EasyLoading.showError(S.current.empty_hint);
      return;
    }
    for (final stage in quest.stages) {
      final enemies = stage.enemies.where((e) => e.deck == DeckType.enemy).toList();
      final onFieldEnemies = enemies.where((e) => e.deckId <= (stage.enemyFieldPosCountReal)).toList();
      if (onFieldEnemies.isEmpty) {
        EasyLoading.showError(
          '${S.current.quest_wave} ${stage.wave}: ${S.current.empty_hint} (Pos 1-${stage.enemyFieldPosCountReal})',
        );
        return;
      }
    }
    Navigator.pop(context);
    widget.onComplete(quest);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(quest.name),
          leading: BackButton(
            onPressed: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => SimpleConfirmDialog(
                  title: Text(S.current.save),
                  confirmText: "YES",
                  onTapOk: onConfirm,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("NO"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(child: body),
            kDefaultDivider,
            SafeArea(child: buttonBar),
          ],
        ),
      ),
    );
  }

  Widget get buttonBar {
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: () {
            quest = getBlankQuest();
            setState(() {});
          },
          icon: const Icon(Icons.replay),
          label: Text(S.current.clear),
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
        ),
        FilledButton.icon(onPressed: onConfirm, icon: const Icon(Icons.check), label: Text(S.current.confirm)),
      ],
    );
  }

  Widget get body {
    final warIds = <int>{
      0,
      quest.warId,
      ...db.gameData.wars.values.where((e) => e.quests.isNotEmpty).map((e) => e.id),
    }.toList();
    warIds.sort2((e) {
      if (e == 0) return double.infinity;
      final event = db.gameData.wars[e]?.eventReal;
      if (event == null) return e;
      return event.startedAt;
    }, reversed: true);
    List<Widget> children = [
      ListTile(leading: const Text("ID"), trailing: Text(quest.id.toString())),
      ListTile(
        title: Text(S.current.name),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150, minWidth: 100),
          child: Text.rich(
            SharedBuilder.textButtonSpan(
              context: context,
              text: quest.name.isEmpty ? '???' : quest.name,
              onTap: () {
                InputCancelOkDialog(
                  initValue: quest.name,
                  title: S.current.name,
                  onSubmit: (s) {
                    s = s.trim();
                    if (s.isEmpty) return;
                    quest.name = s;
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              },
            ),
            textScaler: const TextScaler.linear(0.9),
            textAlign: TextAlign.end,
          ),
        ),
      ),
      ListTile(
        title: Text(S.current.war),
        subtitle: Text(S.current.event),
        trailing: DropdownButton<int>(
          value: quest.warId,
          isDense: true,
          underline: const SizedBox.shrink(),
          alignment: AlignmentDirectional.centerEnd,
          items: [
            for (final warId in warIds)
              DropdownMenuItem(
                value: warId,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    warId == 0 ? '0-none' : "$warId-${db.gameData.wars[warId]?.lName.l}",
                    textScaler: const TextScaler.linear(0.8),
                    maxLines: 1,
                  ),
                ),
              ),
          ],
          onChanged: (v) {
            setState(() {
              quest.warId = v ?? 0;
              quest.individuality.removeWhere((e) => e.isEventField);
              quest.phaseIndividuality?.removeWhere((e) => e.isEventField);
              if (quest.warId < 1000) return; // main story only have bond related bonus?

              final addFieldTraits = <NiceTrait>[];
              for (final entry in db.gameData.mappingData.fieldTrait.entries) {
                if (entry.value.warIds.contains(quest.warId)) {
                  addFieldTraits.add(NiceTrait(id: entry.key));
                }
              }
              quest.individuality = {...quest.individuality, ...addFieldTraits}.toList();
              if (quest.phaseIndividuality != null) {
                quest.phaseIndividuality = {...quest.phaseIndividuality!, ...addFieldTraits}.toList();
              }
            });
          },
        ),
      ),
      ListTile(
        title: Text(S.current.quest_fields),
        subtitle: Text.rich(
          TextSpan(
            children: SharedBuilder.traitSpans(context: context, traits: quest.questIndividuality),
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            router.pushPage(
              TraitEditPage(
                traits: quest.questIndividuality,
                onChanged: (traits) {
                  quest.individuality = traits.toList();
                  quest.phaseIndividuality = null;
                  if (mounted) setState(() {});
                },
              ),
            );
          },
          icon: const Icon(Icons.edit),
          tooltip: S.current.edit,
        ),
      ),
      SFooter(S.current.quest_edit_hint),
    ];
    for (int index = 0; index < quest.stages.length; index++) {
      children.addAll(buildStage(index, quest.stages[index]));
    }
    children.addAll([
      const Divider(height: 16),
      Center(
        child: FilledButton.icon(
          onPressed: () {
            setState(() {
              quest.stages.add(
                Stage(
                  wave: quest.stages.length,
                  enemyFieldPosCount: quest.stages.lastOrNull?.enemyFieldPosCount,
                  enemies: [],
                ),
              );
            });
          },
          icon: const Icon(Icons.add),
          label: Text('${S.current.add}(${S.current.quest_wave} ${quest.stages.length + 1})'),
        ),
      ),
    ]);
    children.add(const SizedBox(height: 16));
    return ListView(children: children);
  }

  List<Widget> buildStage(int index, Stage stage) {
    stage.wave = index + 1;
    List<Widget> children = [
      DividerWithTitle(title: '${S.current.quest_wave} ${stage.wave}', indent: 16),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                quest.stages.remove(stage);
              });
            },
            child: Text(S.current.remove, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          Text('${S.current.max_enemy_on_stage}:'),
          DropdownButton<int>(
            value: stage.enemyFieldPosCountReal,
            items: [
              for (final count in {3, 6, stage.enemyFieldPosCountReal})
                DropdownMenuItem(value: count, child: Text(count.toString())),
            ],
            onChanged: (v) {
              setState(() {
                stage.enemyFieldPosCount = v;
              });
            },
          ),
        ],
      ),
    ];
    final onFieldCount = stage.enemyFieldPosCountReal;
    final enemies = {
      for (final enemy in stage.enemies)
        if (enemy.deck == DeckType.enemy) enemy.deckId: enemy,
    };
    final maxDeckId = Maths.max([(onFieldCount / 3).ceil() * 3, ...enemies.keys]) + 1;
    List<Widget> enemyDeck = [];
    for (int index = 0; index < maxDeckId; index++) {
      final deckId = index + 1;
      final enemy = enemies[deckId];
      enemyDeck.add(buildEnemy(stage, deckId, enemy));
    }
    const int colPerRow = 3;
    final rowCount = (enemyDeck.length / colPerRow).ceil();
    final onFieldRowCount = (onFieldCount / colPerRow).ceil();
    for (int row = 0; row < rowCount; row++) {
      if (row == onFieldRowCount) {
        children.add(const CustomPaint(painter: DashedLinePainter(indent: 16), size: Size(double.infinity, 16)));
      }
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              for (int col = 0; col < colPerRow; col++)
                Expanded(child: enemyDeck.getOrNull(row * colPerRow + col) ?? const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return children;
  }

  Widget buildEnemy(Stage stage, int deckId, QuestEnemy? enemy) {
    return Card(
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('$deckId - ${enemy?.lName.l ?? "none"}', maxLines: 1, overflow: TextOverflow.ellipsis),
            if (enemy != null)
              InkWell(
                onTap: () async {
                  await router.pushPage(
                    QuestEnemyEditPage(
                      enemy: enemy,
                      onPaste: (enemy2) {
                        enemy2 = QuestEnemy.fromJson(enemy2.toJson());
                        enemy2
                          ..deck = DeckType.enemy
                          ..deckId = deckId
                          ..npcId = enemy.npcId
                          ..enemyScript.shift = null;
                        final index = stage.enemies.indexOf(enemy);
                        if (index < 0) return enemy;
                        stage.enemies[index] = enemy2;
                        EasyLoading.showSuccess(S.current.success);
                        return enemy2;
                      },
                      onClear: () {
                        stage.enemies.remove(enemy);
                      },
                    ),
                  );
                  if (mounted) setState(() {});
                },
                child: AbsorbPointer(child: QuestEnemyWidget(enemy: enemy, showTrueName: true, region: null)),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: IconButton(
                  onPressed: () {
                    final blankEnemy = QuestEnemy.blankEnemy();
                    blankEnemy
                      ..deckId = deckId
                      ..npcId = Maths.max(stage.enemies.map((e) => e.npcId), 700000) + 1
                      ..hp = 10000;
                    stage.enemies.add(blankEnemy);
                    stage.enemies.sort2((e) => e.deck.index * 10000 + e.deckId);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: '${S.current.add} (${S.current.enemy})',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
