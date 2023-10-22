<p align="center"><img alt="Chaldea logo" src="https://raw.githubusercontent.com/chaldea-center/chaldea/master/res/img/launcher_icon/app_icon_rounded.png" width="128"></p>

# [Chaldea](https://github.com/chaldea-center/chaldea)

[![platforms](https://img.shields.io/badge/platform-web_|_android_|_ios_|_windows_|_macos_|_linux-blue)](https://github.com/chaldea-center/chaldea/releases)
[![release](https://img.shields.io/github/v/release/chaldea-center/chaldea?sort=semver)](https://github.com/chaldea-center/chaldea/releases)
[![license AGPL-3.0](https://img.shields.io/github/license/chaldea-center/chaldea.svg?style=flat)](https://github.com/chaldea-center/chaldea/blob/main/LICENSE)
[![stars](https://img.shields.io/github/stars/chaldea-center/chaldea?style=social)](https://github.com/chaldea-center/chaldea/stargazers)

Chaldea 是为手游[Fate/Grand Order](https://game.bilibili.com/fgo/)打造的多平台应用，其中包含了`Chaldeas`和`Laplace`两个部分。`Chaldeas`用于帮助御主规划材料、从者以及活动，`Laplace`是多功能战斗模拟器，用于帮助御主组建自己的队伍。

更多详细信息请参阅文档：[中文](https://docs.chaldea.center/zh/)|[English](https://docs.chaldea.center)

## 软件介绍

### Chaldeas

- 支持全平台，包括安卓、iOS、Windows、macOS、Linux 以及网页版。
- **从者**、**概念礼装**、**指令纹章**、**魔术礼装**、**活动**、**道具**以及**卡池**的各种资料
- 道具/材料规划
  - 从者的灵基、技能、灵衣、追加技能、圣杯以及芙芙
  - 限时活动、主线记录、兑换券以及特别纪念活动
  - 持有道具
  - 圣晶石/呼符规划
- 自由关卡计算器
  - 根据道具需求计算 AP 消耗/战斗次数最少的最优解
  - 通过加权比较不同自由关卡的效率
  - 御主任务/周常任务/活动任务/自定义任务计算器
- 卡池模拟器
- 导入用户数据
  - 在登录至简中服/繁中服/日服/美服时获取账户数据
  - 通过游戏内截图导入道具、主动技能、追加技能（在服务器端进行识别）
  - 从<https://fgosim.github.io/Material>导入数据

### Laplace

- 在所有关卡的战斗模拟
- 支持最新的日服活动关卡数据 - powered by AADB/Rayshift
- 可以控制随机数以计算伤害以及 NP 回收
- 支持自定义技能来模拟某些特殊的敌人/场地机制

## 支持平台

| 平台    | 最低版本需求                                       |
| ------- | -------------------------------------------------- |
| 安卓    | 安卓 6.0 (API level 23)                            |
| iOS     | iOS 12.0                                           |
| Windows | Windows 8 (64-bit), 64 位系统                      |
| macOS   | macOS 10.14                                        |
| Linux   | Debian 10 及以上                                   |
| Web     | 所有现代浏览器（Chrome、Firefox、Safari、Edge 等） |

更多信息请参阅[支持平台](https://docs.flutter.dev/reference/supported-platforms)

## 安装

### Google Play

[<img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width="137.5px"/>](https://play.google.com/store/apps/details?id=cc.narumi.chaldea)
[<img alt='Get it on F-droid' src='https://fdroid.gitlab.io/artwork/badge/get-it-on.png' width="137.5px"/>](https://f-droid.org/packages/cc.narumi.chaldea.fdroid/)

> 必须先卸载 1.x 版本才能安装 2.x 版本

### App Store

[<img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-US?size=250x83&amp;releaseDate=1610841600&h=cb0adac232fdd6b88894f78b2f349b6e" alt="Download on the App Store" width="120px">](https://apps.apple.com/us/app/chaldea/id1548713491?itsct=apps_box&itscg=30200)

### 直接下载

安卓、Windows 以及 Linux 用户可以直接从[Github](https://github.com/chaldea-center/chaldea/releases)或[官方网站](https://docs.chaldea.center/zh/guide/releases)下载安装包后解压即可直接使用。

### 网页版

- 中国大陆用户：[https://cn.chaldea.center](https://cn.chaldea.center)
- 海外用户：[https://chaldea.center](https://chaldea.center)

## 捐赠

如果你希望支持本项目或为本项目捐赠，请点击[支持与捐赠](https://docs.chaldea.center/zh/guide/donation.html)

## 反馈与建议

如果你发现了一个 bug，或是有想要添加的特性、对本软件有疑问，亦或是希望为本项目做出贡献，请随时通过以下方式联系我们：

- 在 Github 上提出一个[issue](https://github.com/chaldea-center/chaldea/issues/new/choose)
- Pull request 或者加入开发者组织
- Discord：[https://discord.gg/5M6w5faqjP](https://discord.gg/5M6w5faqjP)
- 电子邮箱：[chaldea@narumi.cc](mailto:chaldea@narumi.cc)

## 鸣谢

本项目使用[Flutter](https://flutter.dev)框架。如果希望学习如何使用 Flutter，可以参阅[文档](https://docs.flutter.dev/)。

感谢所有为软件做出贡献的开发者和翻译！

- [贡献者列表](./CONTRIBUTORS)

Chaldea 受到以下软件启发：

- iOS 软件[Guda](https://bbs.nga.cn/read.php?tid=12082000)
- 微信小程序[FGO 素材规划](https://github.com/lacus87/fgo)

Laplace 受到以下软件启发：

- [FGO Teamup](https://www.fgo-teamup.com)
- [FGO Simulator](https://github.com/SharpnelXu/FGOSimulator)

数据库由以下来源支持：

- [TYPE-MOON/FGO PROJECT](https://www.fate-go.jp/)
- ~~DELiGHTWORKS~~ [Lasengle Inc](https://www.lasengle.co.jp/)
- [Atlas Academy](https://atlasacademy.io/)
- 中文维基 - [Mooncell](https://fgo.wiki)
- 英文维基 - [Fandom - Fate/Grand Order Wiki](https://fategrandorder.fandom.com/wiki/)
- [FGO 効率劇場](https://sites.google.com/view/fgo-domus-aurea)

感谢上述的所有社区以及贡献者！
