# TODO

There are plenty of work need to do.

## Battles

### Ally Function Logic:

- [ ] After 7th anni, donotAct will not stop first card from contributing to FirstCardType
- [ ] Unify buff execution, eliminate unnecessary calls to buff.shouldApply and switch to buff.shouldActivate to check
  for buff useRate
- [ ] Move all checkTrait logic into battle and remove individual checkTrait methods in models
- [ ] There is a bug that will reset accumulation damage when deathEffect is triggered
  not verified for gutsEffect
- [ ] Damage should remove buff with buffScript field damageRelease: 1
- [ ] FuncType damageNpCounter
- [ ] FuncType damageNpRate Target == 0 is target, verify if Target ==1 is activator?
- [ ] FuncType gainHpPer figure out if Percentage heal benefits from healGrant buff
- [ ] FuncType gainHp/NpFromTargets & moveState can probably be implemented in the dependedFunc with an additional
  receiver argument to receive what's lost from absorbTargets
- [ ] FuncType transformServant may need a local copy of Hyde data, and figure out how to disable Hyde's NP
- [ ] DataVals AddLinkageTargetIndividualty & BehaveAsFamilyBuff & UnSubStateWhileLinkedToOthers
- [ ] DataVals CounterId CounterLv CounterOc SkillReaction UseTreasureDevice
- [ ] DataVals TriggeredFuncPosition ignored, only checking previous function success for now
- [ ] Group npDamageIndividualSum & buff ParamAddCount's counting logic together?
- [ ] BuffType doNotGainNp & upGiveNp
- [ ] BuffType doNotRecovery interacts with maxHp?
- [ ] BuffType doNotActCommandType
- [ ] BuffType doNotSelectCommandCard
- [ ] BuffType tdTypeChange: if there are multiple instances of this buff, the last one dominates
- [ ] BuffType overwriteClassRelation, atkSide first or defSide first? When two overwriteForce type interact, is it
  based on buff order? E.g. Kama skill3 & Reinis NP vs alterego attacker, is the final relation 500 or 1000 or depends
  on which buff comes last?
- [ ] BuffType preventDeathByDamage works if Van Gogh has burn?
- [ ] BuffType reflectionFunction
- [ ] BuffType skillRankUp has a maxRate of 0, so it's probably not a ValuedBuff? Currently only counting by buffTrait
- [ ] INDIVIDUALITIE seen on fields, buffTraits, servantId, are other traits included as well?
- [ ] update INDIVIDUALITIE to only check its state in certain situations, perhaps in checkBuffStatus()?
- [ ] includeIgnoredTrait only adds NP card traits for now
- [ ] more sample on convertBuff's scripts
- [ ] prepare a dummy BattleServantData as Master
- [ ] Figure out how to write reasonable test cases for UI required effects like randomEffect & changeTdType

#### Unknowns:

- [ ] DataVals ProgressSelfTurn
- [ ] DataVals CheckDuplicate
- [ ] BuffType upNpturnval not sure what this is

### NPC Simulation

- [ ] Account for NP disabled NPCs (they don't gain any NP)

### Enemy Simulation

- [ ] build enemy active skills & cards & NP
- [ ] TargetType ptSelfAnotherRandom for svt 251 skill 3
- [ ] TargetType enemyOneNoTargetNoAction for svt 311 skill 3
- [ ] FuncType transformServant on enemies
- [X] Check Atlas for enemy trigger functions

## Misc

- [ ] Integrate Sentry
- [ ] Adding crash log review
- [ ] command card: add svt assets
- [ ] userdata: make all constructor params nullable, catch error when converting token
- [ ] remember svt tabs
- [ ] logger.level
- [ ] l10n: related_card->related_card_on_stage
- [ ] android: external SD card
- [ ] filter_group_data: default value
- [ ] svt icon: custom image
- [ ] plan_tab: append/active/all
- [ ] cards: weak/strength
- [ ] huntingId=any
- [ ] func/buff/skill/td: factory fromJson(json,{cached=true})
- [ ] routeTo: add this as argument
- [ ] generate skill/np in one image
- [ ] trait: dynamic tabs(fixed some tabs), items
- [ ] list view: pull to show outdated
- [ ] class icon+name
- [ ] breaking change: FixedDrop
- [ ] filter_group: add onReset
- [ ] separate cn proxy
- [ ] free quest drop table
- [ ] parser: check summon prob correct
- [ ] summon: add wiki prob edit util
- [ ] add daily quests' enemy traits for missions
- [ ] improve audio player
- [ ] enhanced spoiler

## Servant

- [x] Duplicated servant support
- [ ] Plan:
    - [ ] support TextField input
- [x] skill/np/quest/voice/profile condition

## Adding more pages

- [x] Summon list and detail page
    - [ ] summon plan: ?
- [x] Saint Quartz estimate
    - [ ] poor performance
- [ ] Events
    - [ ] War Map
- [ ] Buff/Function reversing
- [ ] Support Party generation

## Server side

- [x] item/skill recognition
- [x] account system: server or cloudflare?
    - [ ] ~~auto-backup user data~~: must manually backup
- [ ] recognizer: invalid image error

## Translation

Hey! These files need to be translated:

- [https://github.com/chaldea-center/chaldea-data/tree/main/mappings](https://github.com/chaldea-center/chaldea-data/tree/main/mappings)
- [https://github.com/chaldea-center/chaldea/tree/main/lib/l10n](https://github.com/chaldea-center/chaldea/tree/main/lib/l10n)
