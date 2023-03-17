# TODO

There are plenty of work need to do.

## Battles

### Ally Function Logic:
- [ ] Move all checkTrait logic into battle and remove individual checkTrait methods in models
- [ ] Account for OC buff
- [ ] There is a bug that will reset accumulation damage when deathEffect is triggered
not verified for gutsEffect
- [ ] FuncType damageNpCounter
- [ ] FuncType damageNpRate Target == 0 is target, verify if Target ==1 is activator?
- [ ] DataVals AddLinkageTargetIndividualty & BehaveAsFamilyBuff & UnSubStateWhileLinkedToOthers
- [ ] DataVals CounterId CounterLv CounterOc SkillReaction UseTreasureDevice
- [ ] DataVals TriggeredFuncPosition ignored, only checking previous function success for now
- [ ] Group npDamageIndividualSum & buff ParamAddCount's counting logic together?
#### Unknowns:
- [ ] DataVals ProgressSelfTurn
- [ ] DataVals CheckDuplicate
### NPC Simulation
- [ ] Account for NP disabled NPCs (they don't gain any NP)
### Enemy Simulation
- [ ] build enemy active skills & cards & NP
- [ ] TargetType ptSelfAnotherRandom for svt 251 skill 3


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
