import 'dart:math' show max;

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart' show Maths;
import 'package:chaldea/utils/extension.dart' show range;
import 'ce_pool.dart';

/// Extra playable servant ids that are not in the normal collection numbering.
const List<int> kExtraPlayableSvtIds = [505700];

/// A member (concrete servant) of a servant equivalence class.
class BondSvtMember {
  final Servant svt;

  /// limitCounts (ascensions/costumes) whose (cost, traits, effects) are identical
  /// in this class. Empty means all limitCounts behave the same.
  final List<int> limitCounts;

  /// Traits shared by all limitCounts in this member (identical by slice grouping).
  /// Used by the solver to evaluate trait-targeted effects from fixed sources.
  final List<int> traits;

  const BondSvtMember({required this.svt, required this.limitCounts, required this.traits});
}

/// Servant equivalence class: all members are interchangeable in the solver.
///
/// The class key is the projection of a servant's (ascension-slice) data onto
/// solver-relevant dimensions — the "effective individuality" is expressed as
/// per-CE-class effect vectors instead of raw trait sets.
class BondSvtClass {
  final int cost;

  /// own event passive bond rate/value (self-scope effects, slice-matched)
  final int ownEventRate;
  final int ownEventValue;

  /// campaign bond rate from enabled campaigns
  final int campaignRate;

  /// rare: flat team-wide (ptFull) event passive rate of this servant
  final int flatTeamEventRate;

  /// rare: flat team-wide (ptFull) event passive value of this servant
  final int flatTeamEventValue;

  /// Per owned CE class index: self effect rate sum (0 if the CE has no active
  /// self effect on this class). Length = owned CE class count.
  final List<int> ceSelfRate;

  /// Per owned CE class index: self effect value sum.
  final List<int> ceSelfValue;

  /// Per owned CE class index: whether the CE's team-scope effects activate when
  /// a member of this class WEARS it (wearer-side conditions met).
  final List<bool> ceTeamActive;

  /// Per owned CE class index: sum of team-effect rates whose TARGET conditions
  /// match this class (i.e. what this class receives when ANY slot wears that CE).
  final List<int> ceTeamTargetRate;

  final List<BondSvtMember> members;

  const BondSvtClass({
    required this.cost,
    required this.ownEventRate,
    required this.ownEventValue,
    required this.campaignRate,
    required this.flatTeamEventRate,
    required this.flatTeamEventValue,
    required this.ceSelfRate,
    required this.ceSelfValue,
    required this.ceTeamActive,
    required this.ceTeamTargetRate,
    required this.members,
  });

  int get memberCount => members.length;

  /// capacity = number of DISTINCT member servants. Several ascension slices
  /// of the same servant can merge into one class (identical solver
  /// projection); they still represent a single fieldable servant.
  int get capacity => members.map((e) => e.svt.id).toSet().length;

  Set<int> get memberSvtIds => members.map((e) => e.svt.id).toSet();
}

/// Builds servant candidate classes with exclusion filters applied.
class SvtBondPool {
  final List<BondSvtClass> classes = [];

  /// names of dropped/rare features that were approximated (for warnings)
  final List<String> warnings = [];

  SvtBondPool._();

  static const int _kBondEventSkillSkipId = 970663; // 夢火の導き (Bond 15)

  /// Solver-approximation warnings (deduped): rare effect kinds that the
  /// receiver-side class vectors cannot express exactly.
  static const String kWarnTargetedTeamEvent =
      'targeted team bond effect from a servant event passive is ignored (rare)';
  static const String kWarnWearerCondTeamCe =
      'team bond CE effect whose activation depends on the wearer is ignored (rare)';

  void _warn(String message) {
    if (!warnings.contains(message)) warnings.add(message);
  }

  static SvtBondPool build({
    required QuestPhase? quest,
    required CeBondPool cePool,
    required Region region,
    required bool favoriteOnly,
    required bool excludeUnreleased,
    required int maxBond,
    required Set<int> excludedSvts,
    required List<(Event, EventCampaign)> enabledCampaigns,
    required bool enableEvent,
  }) {
    final pool = SvtBondPool._();
    final eventId = quest?.logicEventId ?? 0;
    final questIndivs = quest?.questIndividuality ?? const <int>[];
    final hasQuest = quest != null;
    final ceClassCount = cePool.ownedClasses.length;

    for (final svt in db.gameData.servantsById.values) {
      if (svt.collectionNo <= 0 || !svt.isUserSvt) continue;
      if (excludedSvts.contains(svt.id)) continue;
      final status = svt.status;
      if (favoriteOnly && !status.favorite) continue;
      if (maxBond > 0 && status.bond >= maxBond) continue;
      if (excludeUnreleased && region != Region.jp) {
        // JP is the data source of truth — everything is released there
        // (mirrors CeBondPool._isCeReleased's JP short-circuit).
        final released = db.gameData.mappingData.entityRelease.ofRegion(region);
        if (released?.contains(svt.id) == false) continue;
      }

      // campaign rate (eventAddRate per formation_bond calcResults)
      int campaignRate = 0;
      for (final (_, campaign) in enabledCampaigns) {
        if (!campaign.targetIds.contains(svt.id)) continue;
        switch (campaign.calcType) {
          case EventCombineCalc.addition:
            campaignRate += max(0, campaign.value);
            break;
          case EventCombineCalc.multiplication:
            campaignRate += max(0, campaign.value - 1000);
            break;
          default:
            break;
        }
      }

      // resolve event extraPassive skills: highest priority per extraPassive.num group,
      // filtered by quest window / eventId (mirrors calcResults)
      final resolvedEventSkills = enableEvent && quest != null ? resolveEventSkills(svt, quest) : const <NiceSkill>[];

      // ascension slices: (limitCount group) -> (cost, traits)
      final slices = ascensionSlices(svt, eventId);
      if (slices.isEmpty) continue;

      for (final slice in slices) {
        final cls = pool._evaluateSlice(
          svt,
          slice,
          resolvedEventSkills,
          campaignRate,
          eventId,
          questIndivs,
          hasQuest,
          cePool,
          ceClassCount,
        );
        pool._addClass(cls);
      }
    }
    return pool;
  }

  /// Groups limitCounts by identical (cost, traits) — the solver-relevant projection.
  static List<({int cost, List<int> traits, List<int> limitCounts})> ascensionSlices(Servant svt, int eventId) {
    final allLimitCounts = <int>{...range(5), ...svt.costume.keys, ...svt.ascensionAdd.individuality2.all.keys};
    final grouped = <String, ({int cost, List<int> traits, List<int> limitCounts})>{};
    for (final limitCount in allLimitCounts) {
      // copy: never mutate the game data lists (getAscended returns stored lists)
      List<int> indivs = List<int>.of(svt.getAscended(limitCount, (v) => v.individuality2) ?? svt.traits);
      for (final add in svt.traitAdd) {
        if (add.eventId != 0 && eventId != add.eventId) continue;
        if (add.limitCount != -1) {
          if (svt.battleCharaToLimitCount(limitCount) != add.limitCount) continue;
        }
        indivs.addAll(add.trait);
      }
      final cost = svt.getAscended(limitCount, (attr) => attr.overwriteCost) ?? svt.cost;
      final traits = indivs.toSet().toList()..sort();
      final key = '$cost|${traits.join(',')}';
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = (cost: cost, traits: traits, limitCounts: [limitCount]);
      } else {
        existing.limitCounts.add(limitCount);
      }
    }
    return grouped.values.toList();
  }

  /// Resolves the event extraPassive skills active for [svt] on [quest]:
  /// highest-priority skill per `extraPassive.num` group, filtered by quest
  /// window/eventId (mirrors `FormationBondTab.calcResults`).
  static List<NiceSkill> resolveEventSkills(Servant svt, QuestPhase quest) {
    final groupedEventSkills = <int, Map<int, NiceSkill>>{};
    for (final skill in svt.extraPassive) {
      if (skill.id == _kBondEventSkillSkipId) continue; // 夢火の導き Bond 15
      final eventPassives = skill.extraPassive.where((eventPassive) {
        if (eventPassive.startedAt > quest.closedAt || eventPassive.endedAt < quest.openedAt) return false;
        final eventIds = eventPassive.getValidEventIds();
        if (eventIds.isNotEmpty && !eventIds.contains(quest.logicEventId ?? 0)) return false;
        return true;
      }).toList();
      if (eventPassives.isEmpty) continue;
      for (final eventPassive in eventPassives) {
        groupedEventSkills.putIfAbsent(eventPassive.num, () => {})[eventPassive.priority] = skill;
      }
    }
    return [for (final skills in groupedEventSkills.values) skills[Maths.max<int>(skills.keys)]!];
  }

  BondSvtClass _evaluateSlice(
    Servant svt,
    ({int cost, List<int> traits, List<int> limitCounts}) slice,
    List<NiceSkill> resolvedEventSkills,
    int campaignRate,
    int eventId,
    List<int> questIndivs,
    bool hasQuest,
    CeBondPool cePool,
    int ceClassCount,
  ) {
    final traits = slice.traits;

    // event effects: self-scope -> own rate/value; team-scope -> flat team rate.
    // Mash's main-story team-wide bond passives are intentionally ignored.
    final eventEffects = CeBondPool.extractBondEffects(
      resolvedEventSkills,
      eventId: eventId,
      questIndivs: questIndivs,
      hasQuest: hasQuest,
    );
    int ownEventRate = 0, ownEventValue = 0, flatTeamEventRate = 0, flatTeamEventValue = 0;
    for (final effect in eventEffects) {
      if (!effect.wearerMatches(traits)) continue;
      switch (effect.scope) {
        case BondEffectScope.self:
          if (effect.targetMatches(traits)) {
            ownEventRate += effect.rate;
            ownEventValue += effect.value;
          }
          break;
        case BondEffectScope.team:
          if (svt.collectionNo == 1) break; // Mash main-story team passives ignored
          if (effect.isFlat) {
            flatTeamEventRate += effect.rate;
            flatTeamEventValue += effect.value;
          } else {
            // Rare: targeted team effect from an event passive. Its receipt depends
            // on every receiver's traits, which the flat scalar cannot express.
            _warn(kWarnTargetedTeamEvent);
          }
          break;
      }
    }

    // CE class vectors
    final ceSelfRate = List<int>.filled(ceClassCount, 0);
    final ceSelfValue = List<int>.filled(ceClassCount, 0);
    final ceTeamActive = List<bool>.filled(ceClassCount, false);
    final ceTeamTargetRate = List<int>.filled(ceClassCount, 0);
    for (final (index, ceClass) in cePool.ownedClasses.indexed) {
      var selfRate = 0, selfValue = 0, teamTargetRate = 0;
      var teamActive = false;
      for (final effect in ceClass.effects) {
        switch (effect.scope) {
          case BondEffectScope.self:
            if (effect.wearerMatches(traits) && effect.targetMatches(traits)) {
              selfRate += effect.rate;
              selfValue += effect.value;
            }
            break;
          case BondEffectScope.team:
            if (effect.wearerMatches(traits)) {
              teamActive = true;
            }
            if (effect.wearerActIndiv.isEmpty && effect.wearerRequiredIndiv == 0) {
              // receiver-side receipt: no wearer dependency — activation is guaranteed
              if (effect.targetMatches(traits)) {
                teamTargetRate += effect.rate;
              }
            } else {
              // Wearer-conditional team effect: activation depends on the wearer's
              // traits (another class), which this receiver-side vector cannot
              // express — dropped in v1.
              _warn(kWarnWearerCondTeamCe);
            }
            break;
        }
      }
      ceSelfRate[index] = selfRate;
      ceSelfValue[index] = selfValue;
      ceTeamActive[index] = teamActive;
      ceTeamTargetRate[index] = teamTargetRate;
    }

    return BondSvtClass(
      cost: slice.cost,
      ownEventRate: ownEventRate,
      ownEventValue: ownEventValue,
      campaignRate: campaignRate,
      flatTeamEventRate: flatTeamEventRate,
      flatTeamEventValue: flatTeamEventValue,
      ceSelfRate: ceSelfRate,
      ceSelfValue: ceSelfValue,
      ceTeamActive: ceTeamActive,
      ceTeamTargetRate: ceTeamTargetRate,
      members: [BondSvtMember(svt: svt, limitCounts: List.of(slice.limitCounts), traits: traits)],
    );
  }

  static String _classKey(BondSvtClass cls, int ceClassCount) {
    final cePart = [
      for (final i in range(ceClassCount))
        '${cls.ceSelfRate[i]}|${cls.ceSelfValue[i]}|${cls.ceTeamActive[i] ? 1 : 0}|${cls.ceTeamTargetRate[i]}',
    ].join(',');
    return '${cls.cost}|${cls.ownEventRate}|${cls.ownEventValue}|${cls.campaignRate}'
        '|${cls.flatTeamEventRate}|${cls.flatTeamEventValue}|$cePart';
  }

  void _addClass(BondSvtClass cls) {
    final key = _classKey(cls, cls.ceSelfRate.length);
    for (final existing in classes) {
      if (_classKey(existing, existing.ceSelfRate.length) == key) {
        existing.members.addAll(cls.members);
        return;
      }
    }
    classes.add(cls);
  }
}
