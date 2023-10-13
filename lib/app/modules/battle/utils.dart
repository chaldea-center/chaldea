import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'battle_simulation.dart';

void replaySimulation({
  required BattleShareData detail,
  // only use quest info to compatible old version
  BattleQuestInfo? questInfo,
}) async {
  questInfo = detail.quest ?? questInfo;
  if (questInfo == null) {
    return EasyLoading.showError('invalid quest info');
  }
  EasyLoading.show();
  final questPhase = await AtlasApi.questPhase(
    questInfo.id,
    questInfo.phase,
    hash: questInfo.hash,
    region: Region.jp,
  );
  EasyLoading.dismiss();

  if (questPhase == null) {
    EasyLoading.showError('${S.current.not_found}: quest ${questInfo.toUrl()}');
    return;
  }
  if (detail.actions == null || detail.actions!.actions.isEmpty) {
    EasyLoading.showError('No replay action found');
    return;
  }

  final questCopy = QuestPhase.fromJson(questPhase.toJson());

  final options = BattleOptions();
  options.fromShareData(detail.option);
  final formation = detail.team;
  for (int index = 0; index < 3; index++) {
    options.team.onFieldSvtDataList[index] = await PlayerSvtData.fromStoredData(formation.onFieldSvts.getOrNull(index));
    options.team.backupSvtDataList[index] = await PlayerSvtData.fromStoredData(formation.backupSvts.getOrNull(index));
  }

  options.team.mysticCodeData.loadStoredData(formation.mysticCode);

  if (options.disableEvent) {
    questCopy.warId = 0;
    questCopy.individuality.removeWhere((e) => e.isEventField);
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
      replayActions: detail.actions,
    ),
  );
}
