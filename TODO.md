# TODO

There are plenty of work need to do.

## Misc

- [ ] Search should be re-designed and improved
  - [ ] add search for event 
- [ ] pass locale to `Text` for Region-based gamedata text.
      which translation found, then pass that locale
- [x] only save game data file(split into multiple files) when loaded successfully
- [x] add release progress for different regions: Servant/CE/CC
- [ ] Integrate Sentry
- [ ] Adding crash log review
- [x] Add build time/commit hash to AppInfo
- [ ] add legacy data of `ConstData.userLevel`
- [x] GameData split wiki_data into files
- [x] use github issue forms for issue templates
- [ ] Clear Cache
- [x] userdata and gamedata, use getter+setter and update itemCenter 
- [ ] Auto update for android/windows/linux: pending tests

## Quest Related

- [x] add `runs/samples` hint for drop data, both domus-aurea and rayshift
- [x] add AP rate and drop rate toggle for both
- [x] only show last phase for free quest
- [x] QuestEnemy detail page
- [ ] add AI link

## Servant

- [ ] Duplicated servant support
- [x] Servant-Info tab: np rate: add all if servant has changed np rate
- [ ] Voices: 
  - [x] from AA
  - [ ] and wikis
- [ ] Lores: 
  - [x] from AA 
  - [ ] and wikis
- [ ] Plan:
  - [ ] support TextField input
- [x] skill RankUp(Kiara)
- [ ] skill/np/quest condition
- [ ] summon prob calc

## Adding more pages

- [x] CV/illustrator: list page 
  - [ ] and detail page
- [x] Costume list and detail page
- [x] Summon list and detail page
  - [ ] summon plan: ?
- [x] EXP demand calculation
- [x] Enemy(BaseServant) list and detail page
- [x] Saint Quartz estimate
  - [ ] poor performance
- [ ] Events
  - [x] Shop
    - [ ] shop planner?
  - [x] Lottery
  - [x] Point
  - [x] Tower
  - [x] TreasureBox
  - [x] Mission
  - [ ] War Map
- [ ] Mission Solver
  - [x] choose free quests from event wars or main story
  - [x] link from Event/Mission part
  - [ ] hint for invalid mission
- [x] Statistics
- [ ] Buff/Function reversing
- [ ] Support Party generation
- [ ] Fate/Freedom Order

## Func&Buff

- more dialog details


## Server side

- [x] item/skill recognition
- [x] account system: server or cloudflare?
  - [ ] ~~auto-backup user data~~: must manually backup

## Battles

???

## Translation

Hey! These files need to be translated:

- [https://github.com/chaldea-center/chaldea-data/tree/main/mappings](https://github.com/chaldea-center/chaldea-data/tree/main/mappings)
- [https://github.com/chaldea-center/chaldea/tree/main/lib/l10n](https://github.com/chaldea-center/chaldea/tree/main/lib/l10n)
