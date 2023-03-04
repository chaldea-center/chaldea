import 'dart:math';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/video_player.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'quest_enemy.dart';

class QuestWave extends StatelessWidget {
  final Stage? stage;
  final List<QuestPhaseAiNpc> aiNpcs;
  final bool showTrueName;
  final Region? region;

  const QuestWave({
    super.key,
    required this.stage,
    this.aiNpcs = const [],
    this.showTrueName = false,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    final stageEnemies = stage?.enemies ?? [];
    final npcs = {
      for (final enemy in stageEnemies) enemy.npcId: enemy,
    };
    Set<int> _usedNpcIds = {};

    Widget _buildEnemyWithShift(QuestEnemy? enemy, {bool showDeck = false}) {
      if (enemy == null) return const SizedBox();
      List<Widget> parts = [];
      final dispBreakShift = enemy.enemyScript.dispBreakShift ?? -1;
      const lineThrough = TextStyle(decoration: TextDecoration.lineThrough);
      parts.add(QuestEnemyWidget(
        enemy: enemy,
        showTrueName: showTrueName,
        showDeck: showDeck,
        region: region,
        textStyle: dispBreakShift > 1 ? lineThrough : null,
      ));
      if (enemy.enemyScript.shift != null) {
        QuestEnemy prev = enemy;
        for (int index = 0; index < enemy.enemyScript.shift!.length; index++) {
          final shiftEnemy = npcs[enemy.enemyScript.shift![index]];
          if (shiftEnemy == null || shiftEnemy.deck != DeckType.shift) continue;
          parts.add(QuestEnemyWidget(
            enemy: shiftEnemy,
            showTrueName: showTrueName,
            showDeck: showDeck,
            showIcon: shiftEnemy.svt.icon != prev.svt.icon,
            textStyle: index + 2 < dispBreakShift ? lineThrough : null,
            region: region,
          ));
          prev = shiftEnemy;
        }
      }
      if (parts.length == 1) return parts.first;
      return Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: Theme.of(context).highlightColor,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: parts,
          ),
        ),
      );
    }

    List<Widget> _buildDeck(Iterable<QuestEnemy?> enemies, {bool showDeck = false, bool needSort = false}) {
      List<QuestEnemy?> _enemies;
      if (needSort) {
        _enemies = List.filled(
          enemies.fold(0, (p, e) => max(p, e?.deckId ?? 0)),
          null,
          growable: true,
        );
        for (final e in enemies) {
          if (e != null) {
            assert(_enemies[e.deckId - 1] == null);
            _enemies[e.deckId - 1] = e;
          }
        }
        // for (int i = 0; i < _enemies.length ~/ 3; i++) {
        //   if (_enemies.sublist(i * 3, i * 3 + 3).every((e) => e == null)) {
        //     _enemies.removeRange(i * 3, i * 3 + 3);
        //   }
        // }
      } else {
        _enemies = enemies.toList();
      }

      return [
        for (int i = 0; i < _enemies.length / 3; i++)
          Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              for (int j in [0, 1, 2])
                Expanded(
                  child: _buildEnemyWithShift(_enemies.getOrNull(i * 3 + j), showDeck: showDeck),
                ),
            ],
          ),
      ];
    }

    // building
    List<Widget> children = [];
    // enemy deck
    final _enemyDeck = stageEnemies.where((e) => e.deck == DeckType.enemy).toList();
    children.addAll(_buildDeck(_enemyDeck, needSort: true));
    for (final e in _enemyDeck) {
      _usedNpcIds.add(e.npcId);
      _usedNpcIds.addAll(e.enemyScript.shift ?? []);
    }
    // call deck
    final _callDeck = stageEnemies.where((e) => e.deck == DeckType.call).toList();
    if (_callDeck.isNotEmpty) {
      children.add(const Text('- Call Deck -', textAlign: TextAlign.center));
      children.addAll(_buildDeck(_callDeck, needSort: true));
    }
    _usedNpcIds.addAll(_callDeck.map((e) => e.npcId));
    // others
    final _unknownDeck = stageEnemies.where((e) => !_usedNpcIds.contains(e.npcId));
    if (_unknownDeck.isNotEmpty) {
      children.add(const Text('- Unknown Deck -', textAlign: TextAlign.center));
      children.addAll(_buildDeck(_unknownDeck, showDeck: true));
    }

    if (aiNpcs.isNotEmpty) {
      children.addAll(_buildAiNpc());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Iterable<Widget> _buildAiNpc() sync* {
    for (int i = 0; i < aiNpcs.length / 3; i++) {
      List<Widget> children = [];
      for (int j = 0; j < 3; j++) {
        final aiNpc = aiNpcs.getOrNull(i * 3 + j);
        if (aiNpc == null) {
          children.add(const SizedBox());
        } else {
          children.add(QuestPhaseAiNpcWidget(
            aiNpc: aiNpc,
            showTrueName: showTrueName,
            showDeck: false,
            region: region,
          ));
        }
      }
      yield Row(
        textDirection: TextDirection.rtl,
        children: [for (final c in children) Expanded(child: c)],
      );
    }
  }
}

class WaveInfoPage extends StatelessWidget {
  final Stage stage;
  const WaveInfoPage({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wave ${stage.wave}')),
      body: ListView(
        children: [
          if (stage.bgm != null && stage.bgm?.id != 0)
            ListTile(
              title: Text(S.current.bgm),
              trailing: Text(stage.bgm!.tooltip, textAlign: TextAlign.end),
              onTap: stage.bgm!.routeTo,
            ),
          if (stage.turn != null)
            ListTile(
              title: Text(S.current.turn_remain_limit),
              subtitle: Text({
                    StageLimitActType.win: S.current.turn_remain_limit_win,
                    StageLimitActType.lose: S.current.turn_remain_limit_lose,
                  }[stage.limitAct] ??
                  stage.limitAct?.toString() ??
                  "?"),
              trailing: Text(stage.turn.toString()),
            ),
          if (stage.enemyFieldPosCount != null)
            ListTile(
              title: Text(S.current.max_enemy_on_stage),
              trailing: Text(stage.enemyFieldPosCount.toString()),
            ),
          if (stage.enemyActCount != null)
            ListTile(
              title: Text(S.current.max_enemy_act_count),
              trailing: Text(stage.enemyActCount.toString()),
            ),
          if (stage.fieldAis.isNotEmpty)
            ListTile(
              title: Text(S.current.field_ai),
              trailing: Text.rich(
                TextSpan(
                  children: List.generate(stage.fieldAis.length, (index) {
                    final ai = stage.fieldAis[index];
                    int perLine = max(3, (stage.fieldAis.length / 2).ceil());
                    return TextSpan(children: [
                      SharedBuilder.textButtonSpan(
                        context: context,
                        text: ai.id.toString(),
                        onTap: () {
                          launch(Atlas.ai(ai.id, false));
                        },
                      ),
                      if (index < stage.fieldAis.length - 1) TextSpan(text: index == perLine - 1 ? '\n' : ', '),
                    ]);
                  }),
                ),
                textAlign: TextAlign.end,
              ),
            ),
          if (stage.waveStartMovies.isNotEmpty) ListTile(title: Text(S.current.stage_opening_movie)),
          for (final movie in stage.waveStartMovies) MyVideoPlayer.url(url: movie.waveStartMovie, autoPlay: false)
        ],
      ),
    );
  }
}

class QuestEnemyWidget extends StatelessWidget {
  final QuestEnemy enemy;
  final bool showTrueName;
  final bool showDeck;
  final TextStyle? textStyle;
  final Region? region;
  final bool showIcon;

  const QuestEnemyWidget({
    super.key,
    required this.enemy,
    this.showTrueName = false,
    this.showDeck = false,
    this.showIcon = true,
    this.textStyle,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    return EnemyThumbBase(
      icon: showIcon ? enemy.svt.icon : null,
      hidden: enemy.misc?.displayType == 2 && !showTrueName,
      name: showTrueName ? enemy.svt.lName.l : enemy.lShownName,
      className: enemy.svt.className,
      rarity: enemy.svt.rarity,
      hp: enemy.hp,
      deck: [if (showDeck) '[${enemy.deck.name}]', if (enemy.deck != DeckType.enemy) '*'].join(),
      textStyle: textStyle,
      onTap: () {
        router.push(child: QuestEnemyDetail(enemy: enemy, region: region));
      },
    );
  }
}

class QuestPhaseAiNpcWidget extends StatelessWidget {
  final QuestPhaseAiNpc aiNpc;
  final bool showTrueName;
  final bool showDeck;
  final Region? region;

  const QuestPhaseAiNpcWidget({
    super.key,
    required this.aiNpc,
    this.showTrueName = false,
    this.showDeck = false,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    final enemy = aiNpc.detail;
    return EnemyThumbBase(
      icon: enemy?.icon ?? aiNpc.npc.svt.icon,
      hidden: enemy?.misc?.displayType == 2 && !showTrueName,
      name: (showTrueName ? enemy?.svt.lName.l : enemy?.lShownName) ?? aiNpc.npc.svt.lName.l,
      className: enemy?.svt.className ?? aiNpc.npc.svt.className,
      rarity: enemy?.svt.rarity ?? aiNpc.npc.svt.rarity,
      hp: enemy?.atk ?? aiNpc.npc.hp,
      deck: [if (showDeck) '[${DeckType.aiNpc.name}]', '*'].join(),
      onTap: () {
        if (enemy != null) {
          router.push(
            child: QuestEnemyDetail(
              enemy: enemy,
              npcAis: aiNpc.aiIds,
              region: region,
              overrideTitle: 'NPC',
            ),
          );
        }
      },
    );
  }
}

class EnemyThumbBase extends StatelessWidget {
  final String? icon;
  final bool hidden;
  final String name;
  final SvtClass? className;
  final int? rarity;
  final int hp;
  final String? deck;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const EnemyThumbBase({
    super.key,
    this.icon,
    required this.hidden,
    required this.name,
    this.className,
    this.rarity,
    required this.hp,
    this.deck,
    this.textStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget? face;
    if (icon != null) {
      face = db.getIconImage(icon, width: 42, placeholder: (_) => const SizedBox());
    }

    if (hidden && face != null) {
      face = Stack(
        alignment: Alignment.center,
        children: [
          face,
          ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 4.5,
                sigmaY: 4.5,
              ),
              child: Container(
                width: 44,
                height: 44,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ],
      );
    }
    final clsHP = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (className != null) db.getIconImage(className?.icon(rarity ?? 5), width: 20),
        Flexible(
          child: AutoSizeText(
            '${className?.shortName ?? ""} $hp',
            maxFontSize: 12,
            // ensure HP is shown completely
            minFontSize: 1,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        )
      ],
    );
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (face != null) face,
          LayoutTryBuilder(builder: (context, constraints) {
            return AutoSizeText(
              [name, if (deck != null && deck!.isNotEmpty) deck].join(),
              textAlign: TextAlign.center,
              textScaleFactor: 0.8,
              maxFontSize: constraints.maxWidth < 120 ? 14 : 24,
              maxLines: constraints.maxWidth < 120 ? 2 : 1,
            );
          }),
          clsHP
        ],
      ),
    );
  }
}
