import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'battle_simulation.dart';

void replaySimulation({required BattleShareData detail, int? replayTeamId}) async {
  final questInfo = detail.quest;
  if (questInfo == null) {
    return EasyLoading.showError('invalid quest info');
  }
  EasyLoading.show();
  final questPhase = await AtlasApi.questPhase(
    questInfo.id,
    questInfo.phase,
    hash: questInfo.enemyHash,
    region: Region.jp,
  );
  EasyLoading.dismiss();

  if (questPhase == null) {
    EasyLoading.showError('${S.current.not_found}: quest ${questInfo.toUrl()}');
    return;
  }
  if (detail.actions.isEmpty) {
    EasyLoading.showError('No replay action found');
    return;
  }

  final questCopy = QuestPhase.fromJson(questPhase.toJson());

  final options = BattleOptions();
  options.fromShareData(detail.options);
  final formation = detail.formation;
  for (int index = 0; index < max(6, formation.svts.length); index++) {
    options.formation.svts[index] = await PlayerSvtData.fromStoredData(formation.svts.getOrNull(index));
  }

  options.formation.mysticCodeData.loadStoredData(formation.mysticCode);

  if (options.disableEvent) {
    questCopy.warId = 0;
    questCopy.removeEventQuestIndividuality();
  }
  if (questCopy.isLaplaceNeedAi) {
    // should always turn on
    options.simulateAi = true;
  }

  router.push(
    url: Routes.laplaceBattle,
    child: BattleSimulationPage(
      questPhase: questCopy,
      region: Region.jp,
      options: options,
      replayActions: detail,
      replayTeamId: replayTeamId,
    ),
  );
}
