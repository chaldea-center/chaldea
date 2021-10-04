## 1.6.1

- Linux support
- support https data for CN/TW/JP/EN
- macOS: require at least 10.12.2
- bug fix

## 1.6.0

- use new build number strategy
- fix free calc objective values reset unexpectedly

## 1.5.9

- fix free calculator
- fix type cast errors

## 1.5.8

- fix null-safety breaking ~~change~~ bug

## 1.5.7

- buff/effect filter
- support new(after 6th) and legacy drop rate data
- show growth curve of servant/ce on tapping ATK/HP
- add main quests and free quests for events
- summon algorithm changed: statistic r5 prob 1.44%->1.24%->1.04%

## 1.5.6

- add append skill in plan list page
- add account in homepage
- fix bugs

## 1.5.5

- add Saint Quartz planning
- support Append skill recognition
- add enemy page, show quest's enemy icon

## 1.5.4

- fix main record planning
- [BREAK CHANGE] windows: migrate user data folder to app folder
- add lucky bag expectation
- improve summon page and filter

## 1.5.3

- fix exchange ticket planning
- basic support of servant coin

## 1.5.2

- add ★3 fou-kun planning
- add Chaldea flame/lantern planning(bond)
- add servant equipped cmd code planning
- add item demands/consumed overview in Statistics
- sort by bond or item efficiency in free quest calculator
- fix popup menu not show dialog/new route
- more profile support for Altoria Caster
- settings: add servant tabs sorting
- settings: add servant priority tagging

## 1.5.1

- Import servant/item data from http://fgosimulator.webcrow.jp/Material/
- fix append skill data not saved
- re-enable autorotate on mobile

## 1.5.0

- [FEATURE] Append Skill planning support
- support grail planning to max Lv.120
- improve and support search feature in more pages

## 1.4.9

- add servant sprites tab
- add Campaign events
- display setting: remember or reset favorite and filter settings
- string search and filters works together
- fix startup crash

## 1.4.8

- fix unavailable characters related bug
- show CN/JP servant info(e.g. skills) when EN version is not available

## 1.4.7

- allow long press to save illustrations and voice files
- enable scale/pan gestures in full-screen image viewer
- add search CV/illustrator/costume list page
- compress screenshots before uploading to avoid 413 error
- fix some null safety bugs, scrollbar bugs
- enable markdown support for help messages

## 1.4.6

- NEW: add ★️4 fou-kun planning
- TabBarView for skill/item recognizer
- add debug tab for skill recognizer
- refresh carousel slides after settings changed
- limit carousel height
- bug fix

## 1.4.5

- [FEATURE] recognize skill screenshots
- standalone costume list
- support deleting chaldea user
- remove orientation setting on iPad
- add next/previous buttons in item list page

## 1.4.4

- add servant bond detail and sorting in import https body page
- support import https body from clipboard
- fix wrong conversion of costume id to servant plan value
- use a RichText as ErrorWidget to avoid extra bugs
- add share app

## 1.4.3

- fix HiveBox closed when app inactive(on mobile)

## 1.4.2

- consistent null-safety with mcparser
- fix patching data
- add welfare servant in limit event page
- add foukun(rarity 4) as regular item
- improve render behaviour of PieChart
- improve localizations

## 1.4.1

- [FEATURE] Dark Mode
- add NA/TW server tracking
- add English text of servant voice
- servant filter: NP-Charge

## 1.4.0

- [BREAKING CHANGE] Exchange ticket now use monthJp as index, days per month depends on GameServer
- English localization almost supported(data from fandom)
  - servant, craft essence, command code, event, mystic code, quest
  - not support: summon
- fix scrollbar issue
- servant statistics: fix empty PieChartData

## 1.3.12

- fix android app auto-update
- fix windows userdata link
- add bug page

## 1.3.11

- NEW: servant statistics, craft favorites, CV and illustrator list
- log to file
- l10n
- fix patch fails

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
- downgrade `flutter_audio_desktop 0.1.0` to version `0.0.8`, which will cause stuck in Windows
  with `file_picker_cross` together

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
- support `Tab` to move to next focusNode

## 1.1.0

- support Windows

## 1.0.0

- first publish for Android
