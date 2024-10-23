# Changelog

## 2.5.16

- Fix order between removing entities & turn end effects

## 2.5.15

- Fix command codes procing as passive skills
- Support KazuraDrop
  - BattleClass overwrite
  - Gain NP couting targets

## 2.5.14

Lasengle shi ne!

- Add new bond coins
- Servant class passives now ignores debuff immune when adding debuffs
- Support new Summer BB related functions

## 2.5.13

- batch setting append skills
- add campaign login bonus for SQ plan
- fix append 5 not work for transform skill
- support summer XX NP

## 2.5.12

- Fix skill option bug: Kulkulcan etc
- Fix Space Ereshkigal's master affection to master skill

## 2.5.11

- Support planning 5 appends
- Laplace
  - Support Append Skill 5 shorten skill after use
  - Fixed a bug where reduced damage (for overkill bug counting) is not reset after NP
  - Support Summer Eresh
    - New NP Dmg type based on battle points
    - Support battle points system
    - Support activate skill when being targeted
    - Support activate skill before NP/Skill
    - Support activate skill after select cards

## 2.5.10

- Support Destiny Order Summon
- Count quest phase present
- Trait - quest reverse lookup
- Improve Material 3 theme
- Improve rare/additional enemy hints
- Trait list: support multiple traits mode
- NP DMG Ranking: fixed part of servants' skill order
- Support Hibiki & Chikagi different sub attribute
- Support event sweets trade
- Fix some bugs

## 2.5.9

- Aoko Aozaki
  - Fix incorrect checks on magic bullet buffs
  - Support Protagonist Correction
- Sizuki Soujyuro
  - Support Avoid Lethal Attack Damage (Skill 1)
  - Support Np Multiply (Skill 2)
  - Support Pierce Damage Cut (NP)
- Alice Kuonji
  - Support overwrite attribute
  - Support guts on instant death
  - Support DoT Value Up/Down
  - Fix her passive can't reach 0
- General
  - Skills & NPs that transform servants now reapply passives & adjust atk & maxHp (except Jekyll, it's literally hardcoded in the game as a constant)
  - Fix certain command codes & attack trigger functions not working due to Aoko's AoE card update causing lots of type changes
  - Add support to linked buffs & behave as family buffs (Summer Chloe Skill 1). These buffs will share use count & will get removed at the same time
  - Fix toleranceSubstate sometimes activate when shouldn't

## 2.5.8

- Add more April Fool Assets
- Fix incorrect class advantages against special enemy classes
- Improve team check before uploading
- Fix Gilgamesh S1 trait check
- Fix Github backup failed on web

## 2.5.7

- Add related gacha to mc summons
- Fix Bakin's skill3 trigger effect
- Upgrade framework version

## 2.5.6

- Add more campaign events
- Add limited master missions rewards in item's event tab
- Display setting: add option to disable edge-swipe pop gesture
- Laplace
  - Support manually removing buff by long press
  - 【Challenge Quest Related】Support breakGaugeUp
  - 【Challenge Quest Related】Support gutsHp
  - 【Challenge Quest Related】Max HP related buffs will no longer cause targets which hp are below 0 to gain hp (mainly affects gauge break)
  - 【Challenge Quest Related】Enemy Melusine can now use her skill 3 to correctly transform
  - 【Challenge Quest Related】Enemy skills can now be acted multiple times each turn
  - Support Aŋra Mainiiu NP
  - Guts will now clear accumulation damage (overkill bug related)
  - Fix a bug that will cause servants to always gain max HP when affected by percentMaxHp related buffs

## 2.5.5

Happy New Year ヾ(^▽^ヾ)

- Improve Mooncell converters
- Laplace
  - support shiftGuts
  - fix preventDeathByDamage

## 2.5.4

- Export quest data and gacha data to Mooncell wiki format
- Check svt release time before uploading team
- Allow uploading critical team
- Add event servant filter when build formation

## 2.5.3

- NP Damage Ranking supports: class score, custom enemy passives/buffs, event/field traits
- Fix window cannot be closed on desktop
- Fix event item planner
- Add tool to export Mooncell Gacha Prob Table

## 2.5.2

- Saving full battle to local teams, a replacement of uploading to shared team for personal usage
- Don't count costume and append skill unlock materials for dup svt
- Support reading iOS device info for account file login
- Improve summon pickup info
- Disallow random ActSet effect for team upload (e.g. Summer Da Vinci's NP)
- Fix incorrect cc and card strength after card type change

## 2.5.1

- Improvements and bug fix
- Support deep link on mobile
- Fix sniffed data import may failed
- Add favorite team list (not up voted)

## 2.5.0

- Server Migration
  - previous app versions will be refused to upload user data, upload team etc.
- Add war board treasures
- Fix event quest solver bug when any quest is disabled
- Laplace: Support Ptolemaios transform servant

## 2.4.19

- Fix event quest solver error
- Add event related limited mission
- Sniffing: count total Bond/skill Lv/svt lv for class board mission

## 2.4.18

- Chaldeas
  - Add timer: countdown for event, gacha, mission and Da Vinci shop
  - Add free SR/SSR exchange targets filter in servant list
  - Shop item solver supports different bonus for one quest
  - Master Mission: option to exclude random enemy quests in Ordeal Call
- Laplace
  - Tsunguska raid battles must turn on AI simulation for team upload
  - Support enemy appearance rate up effect (but disable now)
  - Fix 32-bit float bug when calculating damage and refund

## 2.4.17

- Fix crash on iOS 16 or lower

## 2.4.16

- Chaldeas
  - Mission solver:
    - support blacklist
    - support adding NotBasedOnServant trait for Traum enemies (trait removed in JP)
  - Add S.P. DMG summary page for svt and enemy
  - Add lv/oc selector and enemy/player view in skill&td detail page
  - Show event related campaigns
- Laplace
  - Support favorite teams
  - Support manual skill target selection (click one ally target twice to turn on, radio button becomes red)
  - Fix Chloe NP S.E. not take effect
  - Fix Tell skill & NP S.E. & Summer Baobhan skill 1 vs unreleasable buff

## 2.4.15

- Disable KR carousel
- Shared team filter supports blocking MLB CE
- Support skipping current turn

## 2.4.14

- Fix Chloe didn't move to last
- Mash doesn't consume grail from Lv 80 to 90

## 2.4.13

- Fix CommandCode trigger buff processed as passive
- Add CN gacha info before 2019
- CN exchange tickets skip 3 months

## 2.4.12

- Fix Kingprotea skill 3 NP Damage Up
- Fix Command Seal
- Fix Serva Fes 2023 event point buff
- Fix some field buff condition check
- Simple AI simulation(alpha testing!) for Tunguska raid

## 2.4.11

- Support Summer Barghest NP Change buff
- Fix entry function should only trigger once (Summer Chloe bond CE)
- Fix team upload ineligibility check

## 2.4.10

- Chaldeas
  - Master mission solver supports Advanced Quests
  - Illustration of Summer Castoria's bond CE has female and male two versions
  - Add raw gacha list viewer
- Laplace
  - Fix CE pin to top not work in Laplace
  - Fix condition check for Andersen skill 3 upgrade and Cnoc na Riabh skill 3
  - Fix summer 2023 point buff
  - Fix move to last member should check actor can act (Summer Chloe S2)
  - ~~Fix entry function should activate multiple times if count >0~~ bug
  - Fix servant event trait should check limit count (Murasama event bonus in summer 2023)

## 2.4.9

Bug Everywhere!

- Bazett's counter NP trial (manually select after enemy action enabled)
- Fix trigger logic of on-attack buffs: SaberAlter/Bakin/KoyanDark/Hokusai/Bhima/etc
- Fix Sleep buff release on Gong/Arash NP
- Fix condition check on "if prev/some func succeeds"
- Fix story support servant not set the correct passive skills
- Fix reorder bug in local teams page

## 2.4.8

Happy 8th Anniversary, FGO!

- Laplace
  - Support Rain Witch's new skill effects
  - Local teams are saved in userdata now (support backup)
  - Fix battle replay error if contains Order Change
  - Convert class board data to custom skill when edit servant

## 2.4.7

Happy 8th Anniversary, FGO!

- Chaldeas
  - Sniffing: add present box and Gacha statistics when importing login data
  - Show related event quests in event page(hunting/trial/advanced quests)
- Laplace
  - Records panel can be shown in two columns to avoid image too long
  - Fix master skill not working correctly because actor may not be reset

## 2.4.6

- Chaldeas
  - Add disable split view option and max window width setting(web)
  - Add basic AI description page
- Laplace
  - Fix Damage Cut
  - Fix activator not reset after custom skill
  - Show Fou on svt avatar if not equal to 1000
  - Fix Master Skill Effect Up skill from Tezcatlipoca

## 2.4.5

- Chaldeas
  - Add event heel portrait
  - UI improvements
- Laplace
  - Fix Hokusai (Foreigner) skill 3 triggers before NP
  - Fix users able to interact with UI during calculations
  - Support functionWaveStart buffs
  - Support rarity check for skills

## 2.4.4

- Chaldeas
  - Rewrite class score planning
  - UI improvements
- Laplace
  - Support customize/edit quest data
  - Basic support for enemy simulation
  - Fix HP Fou input conversion
  - Support set skill/NP upgrades according to quest's JP event time

## 2.4.3

- Fix class board planning and support import it from login data
- Add batch set for class board plans
- Improve class board map

## 2.4.2

- Chaldeas
  - Added Class Score and planning
  - Chaldea Gates event quest listing
  - Servant plan show only current bond
  - When importing sniffing/login data, properly mark withdrawn event servants
- Laplace
  - Team Setup
    - (New Feature) Added team sharing.
    - Fixed team costs not up-to-date in setup page
    - Added an option to export / import quest data in JSON format
    - Any team change needs to be manually saved
    - (PC) In the setup page, hover on servant / CE icon to show remove/change buttons
  - Servant / CE select
    - Pinged servants / CEs now shown in a separated row
    - Long press icon to view details
    - Added a new row for rarity & NP type / color filters
  - Edit Servant Option
    - Improved UI
    - Able to manually input values for sliders in settings
    - CE minimal level is applied if set to max limit break
    - Added an option to export/import skill data in JSON format
    - Added common debuffs to custom skill constructor
  - Battle Simulation
    - Added options in custom skills for (delayed) instant death
    - Added an option to reset mystic code skill CD
    - Fixed trait related buffs to correctly ignore self / opponent traits to avoid infinite loop
    - Fixed target selection interaction with stages that disables enemy positions
    - Certain mandatory selection actions can now be canceled (e.g. replace member)
    - Added support for functions that affect random party members
  - NP Damage
    - Fixed mystic code skills not used
    - Fixed supports not having upgraded skills
    - Default Kukulkan's skill activation selection to consume critical stars

## 2.4.1

- Chaldeas
  - Add current bond level for servant
  - Add bulletin board speaker
  - Fix Plan page favorite button not work
- Laplace
  - Support team url share and import
  - Show team and quest in recorder
  - Fix skill cd is not defined for custom skill
  - Fix enemyImmediateAppear should not work on player team
- NP damage ranking
  - always use ascension 4 even if using player data
  - Fix rank last svt is hidden

## 2.4.0

- 2000 commits reached!
- Temporally disable system tray on Linux
- Laplace
  - Add NP Damage Ranking
  - Show supporter's Noble Phantasm in recorder
  - Show team total COST
  - Bug Fix
    - Musashi(Saber)'s upgraded NP always apply super effective damage
    - CE passive skills should be activated after all servants' passives

## 2.3.7

- Laplace
  - Show supporter NP in records
  - Show total cost
  - Add NP damage ranking

## 2.3.6

- Laplace
  - Handle enemy HP bars that are for display only
  - Handle additional skills in skill activation
  - Automatically select NP card if asked to charge NP to 100%
  - Ping bond CE for selected servant
  - Show buff activator if buff needs activator on field
  - Support the following functions:
    - shiftServant/callServant/changeServant
    - updateEntryPosition
    - extendSkill
    - shorten/extend Buff Turn/Count
    - lossHpPer/lossHpPerSafe
  - Bug fix:
    - Proper buff turn duration counting to fix endOfTurn buffs may end too early
    - gainNpIndividualSum now properly counts traits from specified targets

## 2.3.5

- Add Event free calculator for event items (via event shop page)
- Replenish missing enemy class type in event mission target tab
- Add event command assist (Lilim Harlot)
- Laplace
  - Support auto add "Seven Knights Servant" trait for enemies if Draco in team
  - Support add enemy entity to player team (e.g. enemy & boss)
  - Support enemyImmediateAppear quests
  - Support buff hpReduceToRegain
  - bug fix

## 2.3.4

- Fix new Beast class
- Optimize Digging event UI

## 2.3.3

- Laplace
  - Save teams
  - Support custom skill: svt extra passive + activate custom skill during battle
  - Support event point buff (Grail Live & Oniland)
  - Support disable event effect: event field trait

## 2.3.2

- Free quest solver supports item drop rate (bonus CE from Advanced Quests)
- Add BGM to MyRoom
- Fix app bugs
  - Simplified Chinese characters rendered with Traditional/Japanese font
  - Failed to download data in some browsers
- Laplace
  - Ping event CEs to top
  - Custom default servant lvs
  - Show Instant Death in battle records
  - Fix Archetype:Earth field check
  - Fix Lady Avalon skill 3 downNpturnval

## 2.3.1

- Add more readable battle records
- Drag svt/ce when building team
- Ping preferred svt/ce to top when building team
- Add command spell effects
- Fix several battle simulator bugs

## 2.3.0

- Welcome "Laplace"! The new Battle Simulator
- Add material efficiency of event free quests
- Show quest's all possible enemy decks
- Add Beat's footprint into planner
- Custom face for chara figure
- Fix bugs: import wrong file with same filename, EXP cards calc, etc.

## 2.2.6

- Fix auth file auto login
- Add bili video player

## 2.2.5

- Add wars to home page
- Import command code from http sniffing
- Improve skill and enemy descriptor
- Add trait in filters
- Add route history
- Support system tray for desktop
- Tool - combine images

## 2.2.4

- Add free quest drop item table
- Add servant class info page
- Add event ongoing indicator and filter
- Add event skills in svt skill tab
- Add in-app screenshot (debug mode)
- Add event trait
- Export bond detail to csv (https sniffing)
- Split shops by pay item

## 2.2.3

- Fix auth file decode for auto login
- Fix image didn't shown
- Add skill CD filter for NP charge list

## 2.2.2

- Add new import method for JP/NA: auto login
- Add war assets listing
- Add APK download page
- Support updating data on startup
- Support playing video except linux
- Support sort by AP campaign time in RankUp&Interlude timeline
- Revert engine to avoid crash on iOS

## 2.2.1

- New: Da Vinci shop
- Event plan: customize getable items
- Fix and improve master mission/custom mission
- Fix missing linux plugin which crash free quest or mission solver

## 2.2.0

- custom mission: support multiple conditions
- add event reward scenes, event voices, random missions
- add CE status/limit count/lv tracking
- np charge list: add CE
- svt icon: use planned ascension value
- bgm unlock materials
- exchange ticket: show left days of current month
- switch regions in skill/np/func/buff pages

## 2.1.2

- script/story reader
- new event content: fortification, recollection quests, campaigns
- bgm page
- gacha probability calculation
- set bond bonus for quest efficiency
- sortable item list

## 2.1.1

- bug fix

## 2.1.0

- NP Charge list
- exchange ticket: >3 items
- event shop: plan each purchase quantity
- support dup svts from sniffing
- event list: show empty event
- add war map
- add event recipe

## 2.0.11

- free quest solver: add AP Cost 1/2 option
- wide screen: adjust split screen ratio
- merge illustrations into one image

## 2.0.10

- support duplicated servant planning
- exchange ticket can be 30x4 per month
- add event cooltime and bulletinboard

## 2.0.9

- add events-chaldea gate tab
- bug fix

## 2.0.8

- 🎉 FGO 7th/6th/5th Anniversary 🎉
- add next level exp in exp calc
- add quest/skill conditions
- add cv/illustrator detail page
- add character list(non-servant chara)
- add skill/td/func/buff/trait listing
- show quest support servant
- interlude&rankup timeline
- add event search and filter
- pull to refresh svt/ce/cc list
- improve effect filter

## 2.0.7

- fix GSSR lessThan calculation
- search keyword for func/buff descriptor
- add more filter options for effect search
- github backup: custom commit message

## 2.0.6

- fix incorrect path on Android

## 2.0.5

- fix offline startup
- fix svt coin stat, but all owned coin counts cleared
- support backup to Github repo
- support different exchange ticket info for each region
- settings: custom shown servant plan detail
- add wiki translation for servant profile
- add append skill stuff to button bar of plan related page
- re-add fou3 planning
- support excluding event shop items
- show more items
- support servant AprilFools' icon
- upload userdata warning before closing desktop app
- plan list: add option - only unlocked append
- add network settings(force online mode)
- add event digging
- add effect search for all svt/ce/cc

## 2.0.2

- add Fate/Freedom Order

## 2.0.1

- improve memory usage
- add MC april fool illustration and sprite models
- added to F-Droid
- minor fixes

## 2.0.0

- The new age for v2.x
- support all 5 official regions: JP/CN/TW/NA/KR

## 1.7.0

- last build for v1.x

## 1.6.7

- fix planner give wrong solution if containing ignored items
- improve web support
- set custom name for each Plan
- add target selection in skill effect filter
- fix append skill level in import https response

## 1.6.6

- Korean support for UI text

## 1.6.5

- partially support Korean
- enable 120Hz ProMotion by cycling power saving mode

## 1.6.4

- improve performance when loading and updating game data
- master mission: support search, sort traits by alphabetical
- SQ plan: add missing monthly tickets from mana prism store

## 1.6.3

- fix Android 12 compatibility
- revert incompatible flutter version

## 1.6.2

- support Bond and EXP as item in free quest calculator
- support caching icons in Settings-Gamedata
- archive limit event items by parts
- add enemy alignment and trait filter, fix enemy search
- add consumed tab in item detail
- disable NA news on Windows because of bug
- update some translations

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
- support `Tab` to move to next focusNode

## 1.1.0

- support Windows

## 1.0.0

- first publish for Android
