## 1.3.10
- svt plan tab (actions in popup menu):
  - reset plan
  - switch slider/dropdown mode
- set initial frame center align and remember window position
  - only windows implemented

## 1.3.9
- rewrite `SplitRoute`, now support animation and swipe back gesture
- fix MediaQuery in root widget
- show curPlanNo on Switch Plan IconButton
- add license page

## 1.3.8
- support auto update for app and dataset
- add chaldea server as default download source 

## 1.3.7
- sync user data with server on multiple device
- fix FFO render speed issue
 
## 1.3.6
- Fate/Freedom Order
  - free assembly and random gacha

## 1.3.5
- bug fix
- auto backup userdata to /backup and external storage in Android if possible
- ignore errors in UserData.from and return null
- cannot download icon because of filename is treated as url
- fix Podfile and android storage permission

## 1.3.4
- master mission enhancement
- NEW: experience card cost calculation

## 1.3.3
- bug fix

## 1.3.2
- support duplicated servants
- CN server: import decrypted HTTPS response body to resolve data of servants and items

## 1.3.1
- decrease app size by removing most icons from assets, downloaded to icon folder when used

## 1.3.0
- [BREAKING CHANGE] null safety migration, upgrade to flutter 2
- downgrade `flutter_audio_desktop 0.1.0` to version `0.0.8`, which will cause stuck in Windows with `file_picker_cross` together

## 1.2.1
- [NEW FEATURE] add weekly mission(master mission) planning
- add event progress setting
  - used for events' outdated check
  - the progress setting of drop calculator and master mission is individual 
- remove gitee download source, now only support github releases
- fix text input bugs

## 1.2.0
- add summon/gacha module and summon simulator
- fix drop calculator textfield not updated issue

## 1.1.12
- fix item statistic not updated in some pages
- fix QP and grail statistics

## 1.1.11
- [NEW FEATURE] recognition of item screenshots
- add free quest query in drop calculator

## 1.1.10
- Happy Lunar New Year
- support servant priority
- drop calculator support blacklist

## 1.1.9
- feedback improvement

## 1.1.8
- add free quest efficiency comparison

## 1.1.7
- add mystic codes, servant voices and servant quests(interlude and rank up quests)
- support English and Japanese UI

## 1.1.6
- fix startup crash on iOS 12 or older caused by `flutter_qjs`

## 1.1.5
- support update dataset inside app

## 1.1.4
- support and upload iOS and Mac App Store
- fix grail/crystal not included in item statistics

## 1.1.3
- preparation for macOS version

## 1.1.2
- import servant and item data from Guda

## 1.1.1
- fix focus issue of mouse cursor
- support `Tab` to move next to focusNode

## 1.1.0
- support Windows

## 1.0.0
- first publish for Android
