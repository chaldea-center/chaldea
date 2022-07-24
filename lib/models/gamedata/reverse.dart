import '../db.dart';
import 'gamedata.dart';

class ReverseGameData {
  const ReverseGameData._();

  static Iterable<GameCardMixin> skill2All(int skillId) sync* {
    yield* skill2Svt(skillId);
    yield* skill2CE(skillId);
    yield* skill2CC(skillId);
    yield* skill2MC(skillId);
  }

  static Iterable<Servant> skill2Svt(
    int skillId, {
    bool active = true,
    bool passive = true,
    bool append = true,
    bool extraPassive = true,
  }) sync* {
    for (final svt in db.gameData.servants.values) {
      if ((active && svt.skills.any((e) => e.id == skillId)) ||
          (passive && svt.classPassive.any((e) => e.id == skillId)) ||
          (append && svt.appendPassive.any((e) => e.skill.id == skillId)) ||
          (extraPassive && svt.extraPassive.any((e) => e.id == skillId))) {
        yield svt;
      }
    }
  }

  static Iterable<CraftEssence> skill2CE(int skillId) sync* {
    for (final ce in db.gameData.craftEssences.values) {
      if (ce.skills.any((e) => e.id == skillId)) {
        yield ce;
      }
    }
  }

  static Iterable<CommandCode> skill2CC(int skillId) sync* {
    for (final cc in db.gameData.commandCodes.values) {
      if (cc.skills.any((e) => e.id == skillId)) {
        yield cc;
      }
    }
  }

  static Iterable<MysticCode> skill2MC(int skillId) sync* {
    for (final mc in db.gameData.mysticCodes.values) {
      if (mc.skills.any((e) => e.id == skillId)) {
        yield mc;
      }
    }
  }

  static Iterable<Servant> td2Svt(int tdId) sync* {
    for (final svt in db.gameData.servants.values) {
      if (svt.noblePhantasms.any((e) => e.id == tdId)) {
        yield svt;
      }
    }
  }
}
