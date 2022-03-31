# TODO

There are plenty of work need to do.

## Misc

- [ ] Search should be re-designed and improved
- [ ] pass locale to `Text` for Region-based gamedata text.
      which translation found, then pass that locale
- [ ] only save game data file(split into multiple files) when loaded successfully
- [ ] add release progress for different regions: Servant/CE/CC
- [ ] Integrate Sentry
- [ ] Adding crash log review
- [x] Add build time/commit hash to AppInfo
- [ ] add legacy data of `ConstData.userLevel`
- [x] GameData split wiki_data into files
- [ ] use github issue forms for issue templates

## Quest Related

- [x] add `runs/samples` hint for drop data, both domus-aurea and rayshift
- [ ] add AP rate and drop rate toggle for both
- [x] only show last phase for free quest
- [x] QuestEnemy detail page
- [ ] add AI link

## Servant

- [ ] Duplicated servant support
- [ ] Servant-Info tab: np rate: add all if servant has changed np rate
- [ ] Voices: from regions and wikis
- [ ] Lores: from regions and wikis
- [ ] Plan:
  - [ ] support TextField input

## Adding more pages

- [x] CV/illustrator: list page 
  - [ ] and detail page
- [x] Costume list and detail page
- [x] Summon list and detail page
  - [ ] summon plan: ?
- [x] EXP demand calculation
- [ ] Enemy(BaseServant) list and detail page
- [x] Saint Quartz estimate
- [ ] Events
  - [ ] Shop
  - [ ] Lottery
  - [ ] Point
  - [ ] Tower
  - [ ] TreasureBox
  - [ ] Mission
  - [ ] War Map
- [ ] Mission Solver
  - [x] choose free quests from event wars or main story
  - [ ] link from Event/Mission part
  - [ ] hint for invalid mission
- [x] Statistics
- [ ] Buff/Function reversing
- [ ] Support Party generation

## Func&Buff

- [ ] add field/trait info
- [ ] add translation for funcs without popuptext

## Server side

- [ ] item/skill recognition
- [x] account system: server or cloudflare?
  - [ ] ~~auto-backup user data~~: must manually backup

## Battles

???

## Translation

Hey! These files need to be translated:

- [https://github.com/chaldea-center/chaldea-data/tree/main/mappings](https://github.com/chaldea-center/chaldea-data/tree/main/mappings)
- [https://github.com/chaldea-center/chaldea/tree/main/lib/l10n](https://github.com/chaldea-center/chaldea/tree/main/lib/l10n)
