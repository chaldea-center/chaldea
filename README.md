<p align="center"><img alt="Chaldea logo" src="https://raw.githubusercontent.com/chaldea-center/chaldea/master/res/img/launcher_icon/app_icon_rounded.png" width="128"></p>

# [Chaldea](https://github.com/chaldea-center/chaldea)

[![platforms](https://img.shields.io/badge/platform-web_|_android_|_ios_|_windows_|_macos_|_linux-blue)](https://github.com/chaldea-center/chaldea/releases)
[![release](https://img.shields.io/github/v/release/chaldea-center/chaldea?sort=semver)](https://github.com/chaldea-center/chaldea/releases)
[![license AGPL-3.0](https://img.shields.io/github/license/chaldea-center/chaldea.svg?style=flat)](https://github.com/chaldea-center/chaldea/blob/main/LICENSE)
[![stars](https://img.shields.io/github/stars/chaldea-center/chaldea?style=social)](https://github.com/chaldea-center/chaldea/stargazers)

Chaldea is a cross-platform tool for [Fate/Grand Order](https://www.fate-go.jp), composed of `Chaldeas` and `Laplace`. `Chaldeas` is a planner to help masters planning materials, servants, events. While `Laplace` is a novel battle simulator to help building your team.

For more details or usage, please check our document: [English](https://docs.chaldea.center)
| [中文](https://docs.chaldea.center/zh/)

## Features

### Chaldeas

- support all platforms: Android, iOS, Windows, macOS, Linux and Web.
- profiles of **Servants**, **Craft Essences**, **Command Codes**, **Mystic Codes**, **Events**,
  **Items** and **Summons**
- item/material planning
  - servants' ascension, skill, dress, append skill, palingenesis, fou-kun and bond(Chaldea lantern)
  - limit events, main records, exchange tickets and campaigns
  - owned items
  - Saint Quartz planning
- free quest solver
  - calculate the best solution of least AP or battle times according to item demands
  - compare free quest efficiency by giving item weight
  - master mission/weekly mission/event mission solver, customization is supported
- summon/gacha simulator
- import user data
  - all needed account data from captured https traffic when login to CN/TW/JP/NA server
  - import item/active skill/append skill data from game screenshots (realized on server side)
  - from [https://fgosim.github.io/Material](https://fgosim.github.io/Material)

### Laplace

- battle simulation on any quest (ally only yet)
- up-to-date quest data for new JP events - powered by AADB/Rayshift
- controllable random number for damage and NP calculation
- support custom skill to simulate some enemy/field AI effects

## Supported Platforms

| Platform | Minimum Version                  |
| -------- | -------------------------------- |
| Android  | Android 6.0 (API level 23)       |
| iOS      | iOS 11.0                         |
| Windows  | Windows 8 (64-bit), x86-64 based |
| macOS    | macOS 10.14                      |
| Linux    | Debian 10 & above                |
| Web      | Any modern browser               |

More about [Supported Platforms](https://docs.flutter.dev/development/tools/sdk/release-notes/supported-platforms)

## Installation

### Google Play

[<img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width="137.5px"/>](https://play.google.com/store/apps/details?id=cc.narumi.chaldea)
[<img alt='Get it on F-droid' src='https://fdroid.gitlab.io/artwork/badge/get-it-on.png' width="137.5px"/>](https://f-droid.org/packages/cc.narumi.chaldea.fdroid/)

> MUST Uninstall v1.x then install v2.x

### App Store

[<img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-US?size=250x83&amp;releaseDate=1610841600&h=cb0adac232fdd6b88894f78b2f349b6e" alt="Download on the App Store" width="120px">](https://apps.apple.com/us/app/chaldea/id1548713491?itsct=apps_box&itscg=30200)

### Installer

For Android, Windows and Linux, you can download binary assets in releases page on [Github](https://github.com/chaldea-center/chaldea/releases)
or our [document](https://docs.chaldea.center/guide/releases) site.

### Web

- [https://chaldea.center](https://chaldea.center)
- [https://cn.chaldea.center](https://cn.chaldea.center) for China Mainland(中国大陆)

## Donation

If you would like to support or donate for this project, please move
to [Donation Page](https://docs.chaldea.center/guide/donation.html).

## Feedback and Contribution

If you have any bug report, feature request, question or want to contribute to this project, feel free to

- File an [issue](https://github.com/chaldea-center/chaldea/issues/new/choose)
- Pull request or join the collaboration
- Discord: [https://discord.gg/5M6w5faqjP](https://discord.gg/5M6w5faqjP)
- Email: [chaldea@narumi.cc](mailto:chaldea@narumi.cc)

## Acknowledgements

This project is built with [Flutter](https://flutter.dev). For help getting started with Flutter, view the online [documentation](https://docs.flutter.dev/).

Thanks all contributors and translators help developing the app!

- [CONTRIBUTORS](./CONTRIBUTORS)

Chaldea is greatly inspired by

- iOS app [Guda](https://bbs.nga.cn/read.php?tid=12082000)
- WeChat mini program [FGO material programe](https://github.com/lacus87/fgo)

And the dataset is powered by

- [TYPE-MOON/FGO PROJECT](https://www.fate-go.jp/)
- ~~DELiGHTWORKS~~ [Lasengle Inc](https://www.lasengle.co.jp/)
- [Atlas Academy](https://atlasacademy.io/)
- The Chinese wiki - [Mooncell](https://fgo.wiki)
- The English wiki - [Fandom - Fate/Grand Order Wiki](https://fategrandorder.fandom.com/wiki/)
- [FGO 効率劇場](https://sites.google.com/view/fgo-domus-aurea)

Laplace is built with inspiration of

- [FGO Teamup](https://www.fgo-teamup.com)
- [FGO Simulator](https://github.com/SharpnelXu/FGOSimulator)

Thanks for all above communities and contributors.
