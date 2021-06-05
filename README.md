<p align="center"><img alt="Chaldea logo" src="https://raw.githubusercontent.com/chaldea-center/chaldea/master/res/img/launcher_icon/app_icon_rounded.png" width="128"></p>

# Chaldea

[![platforms](https://img.shields.io/badge/platform-android_|_ios_|_windows_|_macos-blue)](https://github.com/chaldea-center/chaldea/releases)
[![release](https://img.shields.io/github/v/release/chaldea-center/chaldea?sort=semver)](https://github.com/chaldea-center/chaldea/releases)
![license GPL-3.0](https://img.shields.io/github/license/chaldea-center/chaldea.svg?style=flat)
[![stars](https://img.shields.io/github/stars/chaldea-center/chaldea?style=social)](https://github.com/chaldea-center/chaldea/stargazers)

Chaldea is a cross-platform tool for [Fate/Grand Order](https://www.fate-go.jp) to help masters planning their trip of taking back the future. 

Chaldea is inspired from the iOS app [Guda](https://apps.apple.com/sg/app/guda/id1229055088) and WeChat mini program [FGO material programe](https://github.com/lacus87/fgo). 
And dataset resources are mostly based on the Chinese FGO wiki [Mooncell](https://fgo.wiki) and English wiki [Fandom](https://fategrandorder.fandom.com/wiki/).

## Features

- support almost all platform: Android, iOS, Windows and macOS
- profiles of **Servants**, **Craft Essences**, **Command Codes**, **Mystic Codes**, **Events**, **Items** and **Summons**
- item/material planning
  - servants' ascension, skill, dress and palingenesis
  - limit events, main records and exchange tickets
  - owned items
- free quest solution
  - calculate the best solution of least AP or battle times according to item demands
  - compare free quest efficiency by define items' weight
  - master mission/weekly mission solver, customization is supported
- summon/gacha simulator
- import user data
    - import item and servant data from captured https traffic when login to CN server(Bilibili)
    - import item data from game screenshots (realized on server side)
    - from `Guda` exported data


## Support Platforms

Platform  | Minimum Version
----------|--------------------------------------
Android   | Android 6.0 (API level 23)
iOS       | iOS 10.0
Windows   | Windows 7 SP1 (64-bit), x86-64 based
macOS     | macOS 10.11
Linux     | Not implemented
Web       | Not supported      


## Install

### Google Play
[<img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width="137.5px"/>](https://play.google.com/store/apps/details?id=cc.narumi.chaldea)

### App Store
[<img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-US?size=250x83&amp;releaseDate=1610841600&h=cb0adac232fdd6b88894f78b2f349b6e" alt="Download on the App Store" width="120px">](https://apps.apple.com/us/app/chaldea/id1548713491?itsct=apps_box&itscg=30200)

If possible, join the iOS beta program in [TestFlight](https://testflight.apple.com/join/HSyZttrr).

### Installer
You can download installer package in [release](https://github.com/chaldea-center/chaldea/releases) page for Android, Windows and macOS.

## Dataset
The game dataset which should be place at `res/data/dataset.zip` is maintained in another repository [chaldea-dataset](https://github.com/chaldea-center/chaldea-dataset). 

You can download the latest dataset from the release page then import it in app, or just check update inside app's setting page.

Note that the dataset version defines the minimal compatible app version.
E.g. 20210502-1.4.0 means that the dataset is created at 2021/05/02 and requires Chaldea app version >= 1.4.0


## Troubleshooting

**VCRUNTIME140_1.dll was not found on Windows**

You may need to install [Microsoft Visual C++ redistributable package](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads) to enable VC++ runtime support.

## Feedback and contribution
If you have any bug report, feature request, question or want to contribute to this project, feel free to
- open an [issue](https://github.com/chaldea-center/chaldea/issues/new/choose)
- pull request or join the collaboration
- Email: chaldea@narumi.cc
- [![Twitter](https://img.shields.io/twitter/url?label=Twitter&style=social&url=https%3A%2F%2Ftwitter.com%2Fnarumi147)](https://twitter.com/narumi147)