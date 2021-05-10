# ROADMAP

## New feature
- [ ] Servant
  - [ ] battle model/avatar
  - [ ] HP/ATK curve
  - [x] crafts and cmd codes that have appeared in
- [x] Master Mission: 
  - [x] support **and** / **or** inside one mission
  - [x] related quests, sorted by mission target counts
- [x] Experience cards and qp cost when leveling up
- [x] Patch dataset.json online
- [ ] ~~damage/NP calculation - GIVE UP~~

## Enhancement
- [ ] add version for userdata, convert if necessary
- [ ] custom SharedPreferences with prefix
- [x] move `Servant.unavailable` to dataset.json
- [x] NP Lv.5 for low rarity and event servants
- [ ] ocr for skills

## Performance
- [ ] update itemStat in Isolate
- [x] save userdata periodically, rather manually call it

## Bug fix - long term
- [ ] `SplitRoute` currently all detail routes is transparent even not in split mode
- [ ] audio format not fully supported
  | Format | Android | iOS/macOS | Windows |
  |:------:|:-------:|:---------:|:-------:|
  |  mp3   |    ✔    |     ✔     |    ✔    |
  |  wav   |    ✔    |     ❌    |    ✔    |
  |  ogg   |    ✔    |     ❌    |    ❌    |
  |  ogx   |    ✔    |     ❌    |    ❌    |
- [ ] iOS only, move among a list of FocusNode may fail when outside viewport, won't auto scroll
- [ ] catch close action and save userdata for desktop
  - [x] windows, but not always success
  - [ ] macOS
- [ ] RenderEditable bug: https://github.com/flutter/flutter/issues/80226

## Docs
- [ ] Tutorials
- [ ] English/Japanese Translation - **Help Wanted**
- [ ] English/Japanese Game Data
  - [x] Servant
  - [x] CE/Command Code
  - [x] Mystic Code
  - [x] Event
  - [ ] Summon - show banner image instead
  - [x] Quest

## UI
毫无艺术细胞，有生之年
- [x] Dark mode
- [ ] Animation
    - [x] transition animation of `SplitRoute`
      - [ ] custom transition
    - [x] support swipe to back
