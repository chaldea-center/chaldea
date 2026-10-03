import 'package:chaldea/models/gamedata/individuality.dart' show Individuality;
import 'package:chaldea/models/models.dart';

import '../bond_rules.dart';

/// Target scope of a bond effect extracted from a `servantFriendshipUp` function.
enum BondEffectScope { self, team }

/// One bond effect, including conditions on its wearer and recipient.
class CeBondEffect {
  final BondEffectScope scope;
  final int rate;
  final int value;

  /// `skill.actIndividuality`, checked against the wearer.
  final List<int> wearerActIndiv;

  /// `vals.Individuality`, checked against the wearer; zero means none.
  final int wearerRequiredIndiv;

  /// `overWriteTvalsList`: any group may match, with every trait in that group.
  final List<List<int>> targetOrAll;

  /// `functvals`, checked against the recipient when [targetOrAll] is empty.
  final List<int> targetPartial;

  const CeBondEffect({
    required this.scope,
    required this.rate,
    required this.value,
    this.wearerActIndiv = const [],
    this.wearerRequiredIndiv = 0,
    this.targetOrAll = const [],
    this.targetPartial = const [],
  });

  bool get isFlat => wearerActIndiv.isEmpty && wearerRequiredIndiv == 0 && targetOrAll.isEmpty && targetPartial.isEmpty;

  bool get hasCondition => !isFlat;

  bool get hasTargetCondition => targetOrAll.isNotEmpty || targetPartial.isNotEmpty;

  bool wearerMatches(List<int> traits) {
    if (wearerActIndiv.isNotEmpty &&
        !Individuality.checkSignedIndivPartialMatch(self: traits, signedTarget: wearerActIndiv)) {
      return false;
    }
    if (wearerRequiredIndiv != 0 &&
        !Individuality.checkSignedIndivPartialMatch(self: traits, signedTarget: [wearerRequiredIndiv])) {
      return false;
    }
    return true;
  }

  bool targetMatches(List<int> traits) {
    if (targetOrAll.isNotEmpty) {
      return targetOrAll.any((and) => Individuality.checkSignedIndivAllMatch(self: traits, signedTarget: and));
    }
    if (targetPartial.isNotEmpty) {
      return Individuality.checkSignedIndivPartialMatch(self: traits, signedTarget: targetPartial);
    }
    return true;
  }

  /// A virtual support servant has no traits, so only unconditional effects apply.
  bool get matchesNoTraitPlaceholder => isFlat;
}

/// Extracts the same bond effects used by the solver for one CE variant.
List<CeBondEffect> extractCeBondEffects(CraftEssence ce, bool limitBreak, QuestPhase quest, {required bool support}) {
  final effects = <CeBondEffect>[];
  final eventTraits = quest.questIndividuality;
  final eventId = quest.logicEventId ?? 0;
  final skills = ce.getActivatedSkills(limitBreak).values.expand((entries) => entries);
  for (final skill in skills) {
    for (final func in skill.functions) {
      if (func.funcType != FuncType.servantFriendshipUp) continue;
      if (func.funcquestTvals.isNotEmpty &&
          !Individuality.checkSignedIndivPartialMatch(self: eventTraits, signedTarget: func.funcquestTvals)) {
        continue;
      }
      final vals = support ? (func.followerVals?.firstOrNull ?? func.svals.firstOrNull) : func.svals.firstOrNull;
      if (vals == null || (support && vals.ApplySupportSvt == 0)) continue;
      if (vals.EventId != null && vals.EventId != 0 && vals.EventId != eventId) continue;
      final rate = vals.RateCount ?? 0;
      final value = vals.AddCount ?? 0;
      if (rate == 0 && value == 0) continue;
      final scope = switch (func.funcTargetType) {
        FuncTargetType.self when ce.id == kHeroicSpiritPortraitDariusCeId => BondEffectScope.team,
        FuncTargetType.self => BondEffectScope.self,
        FuncTargetType.ptFull => BondEffectScope.team,
        _ => null,
      };
      if (scope == null) continue;
      final targetOrAll = func.getOverwriteTvalsList();
      effects.add(
        CeBondEffect(
          scope: scope,
          rate: rate,
          value: value,
          wearerActIndiv: skill.actIndividuality,
          wearerRequiredIndiv: vals.Individuality ?? 0,
          targetOrAll: targetOrAll,
          targetPartial: targetOrAll.isEmpty ? func.functvals : const [],
        ),
      );
    }
  }
  return effects;
}

/// Selects the highest-priority active skill in each event passive group.
List<NiceSkill> resolveBondEventSkills(Servant svt, QuestPhase quest) {
  final grouped = <int, Map<int, NiceSkill>>{};
  for (final skill in svt.extraPassive) {
    if (skill.id == 970663) continue; // Bond 15 passive is handled separately.
    for (final passive in skill.extraPassive) {
      if (passive.startedAt > quest.closedAt || passive.endedAt < quest.openedAt) continue;
      final eventIds = passive.getValidEventIds();
      if (eventIds.isNotEmpty && !eventIds.contains(quest.logicEventId ?? 0)) continue;
      grouped.putIfAbsent(passive.num, () => {})[passive.priority] = skill;
    }
  }
  return [for (final priorities in grouped.values) priorities[priorities.keys.reduce((a, b) => a > b ? a : b)]!];
}
