# TODO

## Battles

### High Priority

- [x] battle delegate
- [ ] menu skills
  - [ ] Skip turn! support 0 card
- [x] active/passiveList make private, filter out actor died buffs, INDIV
- [ ] gainNp/gainHp/gainHpPer related funcs: check DataVals.Unaffected

### Recorder

- [ ] BattleServantActionHistory.TYPE: HPLOSS,INSTANT_DEATH,REDUCE_HP,DAMAGE_REFLECTION,DAMAGE_VALUE

### Ally Function Logic:

- [ ] Unify buff execution, eliminate unnecessary calls to buff.shouldApply and switch to buff.shouldActivate to check
      for buff useRate
- [ ] BuffScript should only be checked when buffType matches
- [ ] FuncType damageNpCounter
- [ ] FuncType damageNpRare Target == 0 is target, verify if Target ==1 is activator?
- [ ] FuncType gainHpPer figure out if Percentage heal benefits from healGrant buff
- [ ] FuncType gainHp/NpFromTargets & moveState can probably be implemented in the dependedFunc with an additional
      receiver argument to receive what's lost from absorbTargets
- [ ] DataVals AddLinkageTargetIndividualty & BehaveAsFamilyBuff & UnSubStateWhileLinkedToOthers
- [ ] DataVals CounterId CounterLv CounterOc SkillReaction UseTreasureDevice
- [x] DataVals TriggeredFuncPosition ignored, only checking previous function success for now
- [ ] Group npDamageIndividualSum & buff ParamAddCount's counting logic together?
- [ ] BuffType doNotGainNp & upGiveNp & DataVals Unaffected
- [ ] BuffType doNotRecovery interacts with maxHp? Treating as no interaction for now & DataVals Unaffected
- [ ] BuffType doNotActCommandType
- [ ] BuffType doNotSelectCommandCard
- [x] BuffType overwriteClassRelation, atkSide first or defSide first? When two overwriteForce type interact, is it
      based on buff order? E.g. Kama skill3 & Reinis NP vs alterego attacker, is the final relation 500 or 1000 or depends
      on which buff comes last?
  - Def side takes priority.
  - For the same servant, first applied overwrite buff takes priority.
  - In conclusion, first applied defender side buff takes priority. Therefore, evaluation order goes from attacker to
    defender, from most recent buff to lease recent buff.
- [ ] BuffType preventDeathByDamage works if Van Gogh has both curse and burn?
- [ ] BuffType reflectionFunction
- [ ] BuffType skillRankUp has a maxRate of 0, so it's probably not a ValuedBuff? Currently only counting by buffTrait
- [x] INDIVIDUALITIE seen on fields, buffTraits, servantId, are other traits included as well?
- [ ] IncludeIgnoreIndividuality only adds NP card traits for now
- [ ] more sample on convertBuff's scripts
  - [ ] BuffConvert is converting a buff list to another buff list, (or trait list to another buff list, not used yet)
- [ ] prepare a dummy BattleServantData as Master
- [ ] Figure out how to write reasonable test cases for UI required effects like randomEffect & changeTdType
- [ ] funcSuccess for some wired function types
- [ ] Enemy shift target may not exist
- [ ] shiftGuts(Ratio)

#### Unknowns:

- [ ] DataVals ProgressSelfTurn
- [ ] DataVals CheckDuplicate

### Team setup

- [x] svt/enemy: edit indivs, ~~skills, tds~~

### Common Simulation

- [ ] manually remove/add buff
- [x] manually apply skill(custom activator/target)
- [ ] Transform: what if skill/td has upgrades or disabled?
  - Currently matching id for upgrades.
- [x] add ce event skill on/off
- [x] Custom skill! (passive or active)
- [ ] Player side `allyTargetIndex` could be null or -1, let user to choose manually
- [x] SkillRankUp: get skill from api if not in db, make init async

### NPC Simulation

- [ ] Account for NP disabled NPCs (they don't gain any NP)

### Enemy Simulation

- [x] build enemy active skills & cards & NP
- [ ] TargetType ptSelfAnotherRandom for svt 251 skill 3
- [x] TargetType enemyOneNoTargetNoAction for svt 311 skill 3
- [ ] FuncType transformServant on enemies

## Misc

- [ ] onWindowClose no effect on Windows
- [ ] Extra Mission descriptor
- [ ] Integrate Sentry
- [ ] command card: add svt assets
- [ ] userdata: make all constructor params nullable, catch error when converting token
- [ ] remember svt tabs
- [ ] logger.level
- [ ] filter_group_data: default value
- [ ] plan_tab: append/active/all
- [ ] routeTo: add this as argument
- [ ] generate skill/np in one image
- [ ] trait: dynamic tabs(fixed some tabs), items
- [ ] class icon+name
- [ ] filter_group: add onReset
- [ ] separate cn proxy
- [ ] parser: check summon prob correct
- [ ] summon: add wiki prob edit util
- [ ] add daily quests' enemy traits for missions
- [ ] improve audio player
- [ ] home buttons: update, upload, download
- [ ] ce: chara on illust + related chara
- [ ] shop: another pay type (api)

## Servant

- [ ] Plan:
  - [ ] support TextField input

## Adding more pages

- [x] Summon list and detail page
  - [ ] summon plan: ?
- [ ] Buff/Function reversing with remote data
- [ ] Support Party generation

## Translation

Hey! These files need to be translated:

- [https://github.com/chaldea-center/chaldea-data/tree/main/mappings](https://github.com/chaldea-center/chaldea-data/tree/main/mappings)
- [https://github.com/chaldea-center/chaldea/tree/main/lib/l10n](https://github.com/chaldea-center/chaldea/tree/main/lib/l10n)
