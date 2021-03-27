# ROADMAP

## New feature
- Servant
  - [ ] battle model/avatar
  - [ ] HP/ATK curve
- [ ] Master Mission: 
  - [ ] support **and** / **or** inside one mission
  - [ ] related quests, sorted by mission target counts
- [ ] Experience cards and qp cost when leveling up
- [ ] Patch dataset.json online
- [ ] ~~damage/NP calculation - GIVE UP~~

## Enhancement
- [ ] add version for userdata, convert if necessary
- [ ] custom SharedPreferences with prefix


## Performance
- [ ] update itemStat in Isolate
- [ ] save userdata periodically, rather manually call it

## Bug fix - long term
- [ ] `SplitRoute` currently all detail routes is transparent even not in split mode
- [ ] `audioplayers` not support `wav` file on iOS and macOS
- [ ]  iOS only, move among a list of FocusNode may fail when outside viewport, won't auto scroll
- [ ]  move `Servant.unavailable` to dataset.json

## Docs
- [ ] Tutorials
- [ ] English/Japanese Translation - **Help Wanted**
- [ ] English/Japanese Game Data - possible?

## UI
毫无艺术细胞，有生之年
- [ ] Dark mode
- [ ] Animation
    - [ ] transition animation of `SplitRoute`
    - [ ] support swipe to back
