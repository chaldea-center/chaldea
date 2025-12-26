import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../bond_detail_page.dart';
import '../quest_farming.dart';
import 'details.dart';
import 'report_data.dart';
import 'settings.dart';

const _greyColor = Color(0xFFBDBDBD); // Colors.grey.shade400;

class FgoAnnualReportPage extends StatefulWidget {
  final MasterDataManager mstData;
  final Region? region;

  const FgoAnnualReportPage({super.key, required this.mstData, required this.region});

  @override
  State<FgoAnnualReportPage> createState() => _FgoAnnualReportPageState();
}

class _FgoAnnualReportPageState extends State<FgoAnnualReportPage> {
  FgoAnnualReportData? _data;
  bool loading = false;
  Object? loadError;

  final _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData({bool refresh = false}) async {
    if (loading) return;
    try {
      Region? region = widget.region ?? _data?.region;
      loading = true;
      loadError = null;
      _data = null;
      await null;
      if (mounted) setState(() {});
      if (region == null) {
        if (!mounted) return;
        region = await router.showDialog<Region>(
          barrierDismissible: false,
          builder: (context) => SimpleDialog(
            title: Text(S.current.game_server),
            children: [
              for (final v in Region.values)
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, v);
                  },
                  child: Text(v.localName),
                ),
            ],
          ),
        );
        if (region == null) return;
      }

      _data = await FgoAnnualReportData.parse(
        mstData: widget.mstData,
        region: region,
        expireAfter: refresh ? Duration.zero : null,
      );
    } catch (e, s) {
      loadError = e;
      logger.e('load report data failed', e, s);
      if (mounted) {
        SimpleConfirmDialog(
          title: Text(S.current.error),
          content: Text(e.toString()),
          scrollable: true,
        ).showDialog(context);
      } else {
        EasyLoading.showError(e.toString());
      }
    } finally {
      loading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: db.settings.useMaterial3,
      colorSchemeSeed: db.settings.colorSeed?.color,
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
    );
    themeData = themeData.copyWith(
      appBarTheme: themeData.appBarTheme.copyWith(titleSpacing: 0, toolbarHeight: 48),
      listTileTheme: themeData.listTileTheme.copyWith(minLeadingWidth: 24),
    );
    return Theme(
      data: themeData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final data = _data;
          List<Widget> errors = [];
          if (data == null) {
            if (loading) {
              errors.add(const Center(child: CircularProgressIndicator()));
            }
            if (loadError != null) errors.add(Text('${S.current.error}:\n$loadError'));
          }
          final w = constraints.maxWidth, h = constraints.maxHeight;
          if (w > 700 || w < 200 || h < 400) {
            errors.add(Text('${S.current.chaldea_report_window_size_warn}\nw=200~700,h≥400\n(w=$w,h=$h)'));
          }
          final dataVersion2 = db.runtimeData.upgradableDataVersion;
          if (dataVersion2 != null && dataVersion2.timestamp > db.gameData.version.timestamp + 7 * kSecsPerDay) {
            errors.add(Text('${S.current.settings_tab_name} -> ${S.current.gamedata} -> ${S.current.update_dataset}'));
          }
          if (data != null) {
            if (!db.settings.spoilerRegion.isJP && db.settings.spoilerRegion != data.region) {
              errors.add(
                Text(
                  "${S.current.restart_to_apply_changes}: ${S.current.reset} ${S.current.gamedata} -> ${S.current.delete_unreleased_card}",
                ),
              );
            }
            if (db.settings.removeOldDataRegion != null) {
              errors.add(
                Text(
                  '${S.current.restart_to_apply_changes}: ${S.current.reset} ${S.current.gamedata}-> Delete Old Data',
                ),
              );
            }
          }

          Widget body;
          bool hasData = false;
          if (errors.isEmpty && data != null) {
            hasData = true;
            body = SingleChildScrollView(
              child: Screenshot(
                controller: _screenshotController,
                child: FgoAnnualReportRealPage(report: data),
              ),
            );
          } else {
            body = ListView(padding: .all(16), children: errors);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(S.current.chaldea_report_title),
              elevation: 0,
              centerTitle: true,
              actions: [
                if (data == null || data.errors.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      loadData(refresh: true);
                    },
                    icon: Icon(Icons.refresh),
                  ),
                IconButton(onPressed: hasData ? doScreenshot : null, icon: Icon(Icons.share)),
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }

  Future<void> doScreenshot() async {
    try {
      if (mounted) setState(() {});
      await null;
      EasyLoading.show(status: 'Rendering...');
      final pngBytes = await _screenshotController.capture();
      if (pngBytes != null) {
        EasyLoading.dismiss();
        if (mounted) {
          await ImageActions.showSaveShare(context: context, data: pngBytes, defaultFilename: 'fgo-chaldea-report.png');
        }
      } else {
        EasyLoading.showError('screenshot failed');
      }
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('screenshot report failed', e, s);
    } finally {
      if (mounted) setState(() {});
    }
  }
}

class FgoAnnualReportRealPage extends StatefulWidget {
  final FgoAnnualReportData report;
  const FgoAnnualReportRealPage({super.key, required this.report});

  @override
  State<FgoAnnualReportRealPage> createState() => _FgoAnnualReportRealPageState();
}

class _FgoAnnualReportRealPageState extends State<FgoAnnualReportRealPage> {
  late final report = widget.report;
  late final mstData = report.mstData;

  final options = ReportDisplayOptions();

  Random random = Random();
  // options
  // final String _defaultBackgroundImageUrl = 'https://static.atlasacademy.io/JP/Back/back255400_1344_626.png';
  final String _defaultBackgroundImageUrl = 'https://static.atlasacademy.io/JP/Back/back135100_1344_626.png';

  @override
  void initState() {
    super.initState();
    options.isGirl = report.userGame.genderType == Gender.female.value;
    options.masterEquipId = options.getDefaultMasterEquip(region: report.region);
  }

  @override
  Widget build(BuildContext context) {
    random = Random(hashCode);

    return Stack(
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.srcOver),
              child: CachedImage(
                imageUrl: _defaultBackgroundImageUrl,
                cachedOption: CachedImageOption(
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => CachedImage(imageUrl: _defaultBackgroundImageUrl),
                  placeholder: (context, url) => CachedImage(imageUrl: _defaultBackgroundImageUrl),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x332B2D42), Color(0x662B2D42)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _topTitle(),
              if (report.errors.isNotEmpty) _warningCard(),
              _userInfoCard(),
              ?_pushAndFavoriteSvts(),
              _gachaLuck(),
              _svtCollectionStats(),
              _bondCeStats(),
              _gachaTopPulls(true),
              _gachaTopPulls(false),
              _topQuestRun(),
              _miscTile(),
              _finalMessage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _warningCard() {
    return ReportCard(
      header: Text(S.current.error),
      color: Colors.red.withAlpha(100),
      child: Column(
        mainAxisSize: .min,
        children: [
          for (final error in report.errors)
            ListTile(
              dense: true,
              minTileHeight: 24,
              title: Text(
                '$kULLeading ${error.toString()}',
                maxLines: 3,
                overflow: .ellipsis,
                style: TextStyle(
                  // color:
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _userInfoCard() {
    DateTime createdAt = DateUtils.dateOnly(report.userGame.createdAt.sec2date()),
        today = DateUtils.dateOnly(DateTime.now());

    int totalDays = ((today.timestamp - report.userGame.createdAt) / kSecsPerDay).ceil();
    int month = DateUtils.monthDelta(createdAt, today);
    int day;
    if (today.day >= createdAt.day) {
      day = today.day - createdAt.day;
    } else {
      day = today.day - createdAt.day + DateUtils.getDaysInMonth(createdAt.year, createdAt.month);
      month -= 1;
    }
    int year = month ~/ DateTime.monthsPerYear;
    month %= DateTime.monthsPerYear;

    String friendCode = options.showFriendCode ? report.userGame.friendCode : '*' * 9;
    // double avatarWidth = 64;
    // double avatarRatio = 128 / 215;
    double graphRation = 150 / 1024;

    final equipUrl = options.getMasterEquipImageUrl();

    return ReportCard(
      onTap: () async {
        await MasterEquipChangeDialog(options: options).showDialog(context);
        if (mounted) setState(() {});
      },
      backgrounds: [
        Positioned(
          top: 5,
          left: 5,
          child: Opacity(
            opacity: 0.4,
            child: CachedImage(
              imageUrl: 'https://static.atlasacademy.io/JP/EventUI/questboard_icon_cap0301.png',
              width: 90 * 0.5,
              height: 106 * 0.5,
              placeholder: _blankPlaceholder,
            ),

            // ClipPath(
            //   clipper: const RelativePolygonClipper([Offset(0, 0), Offset(1, 0), Offset(1, 0.8), Offset(0, 0.8)]),
            //   child: Image.asset('res/img/chaldea.png'),
            //   // https://static.atlasacademy.io/JP/EventUI/questboard_icon_cap0301.png
            //   // https://static.atlasacademy.io/JP/EventUI/quest_board_icon_301.png
            // ),
          ),
        ),
      ],
      child: Row(
        children: [
          Container(
            width: 1024 * graphRation * 0.6,
            height: 1024 * graphRation * 0.65,
            decoration: BoxDecoration(),
            clipBehavior: Clip.hardEdge,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              fit: .deferToChild,
              maxWidth: 1024 * graphRation,
              maxHeight: 1024 * graphRation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: CachedImage(
                  key: Key(equipUrl),
                  imageUrl: equipUrl,
                  width: 1024 * graphRation,
                  height: 1024 * graphRation,
                  placeholder: _blankPlaceholder,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.userGame.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () {
                    setState(() {
                      options.showFriendCode = !options.showFriendCode;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(top: 6, bottom: 2),
                    child: Row(
                      crossAxisAlignment: .center,
                      children: [
                        SvgPicture.string(report.region.svgFlag, width: 18),
                        Flexible(child: AutoSizeText(' $friendCode', maxLines: 1, minFontSize: 8)),
                      ],
                    ),
                  ),
                ),
                AutoSizeText.rich(
                  TextSpan(
                    text: DateFormat('yyyy-MM-dd').format(report.userGame.createdAt.sec2date()),
                    children: [
                      TextSpan(
                        // text: ' 加入',
                        style: TextStyle(fontSize: 14, color: _greyColor),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  minFontSize: 8,
                ),
                const SizedBox(height: 2),
                AutoSizeText(
                  S.current.chaldea_report_since_account_created_date(year, month, day),
                  style: TextStyle(fontSize: 14, color: _greyColor),
                  maxLines: 1,
                  minFontSize: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(S.current.chaldea_report_account_created, style: TextStyle(color: _greyColor)),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$totalDays',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: S.current.chaldea_report_total_days,
                      style: const TextStyle(color: _greyColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(S.current.chaldea_report_total_login, style: TextStyle(color: _greyColor)),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${report.totalLogin}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: S.current.chaldea_report_total_days,
                      style: const TextStyle(color: _greyColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // bg: 215x167
          // avatar: w59-176，h12-145
          // SizedBox(
          //   width: avatarRatio * 215,
          //   height: avatarRatio * 167,
          //   child: Stack(
          //     // clipBehavior: Clip.none,
          //     children: [
          //       Positioned.fill(
          //         child: CachedImage(
          //           imageUrl:
          //               'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Battle/Common/BattleUIAtlas/frame_master_bg1.png',
          //           width: 215 * avatarRatio,
          //           height: 167 * avatarRatio,
          //         ),
          //       ),
          //       Positioned.fromRect(
          //         rect: Rect.fromLTRB(59 * avatarRatio, 12 * avatarRatio, 176 * avatarRatio, 145 * avatarRatio),
          //         child: ClipPath(
          //           clipper: const _MasterAvatarClipper(),
          //           child: db.getIconImage(
          //             'https://static.atlasacademy.io/JP/MasterFace/equip0000${report.userGame.genderType}.png',
          //             fit: BoxFit.cover,
          //             // width: 64,
          //             // height: 64,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget? _pushAndFavoriteSvts() {
    final pushUserSvt = report.mstData.getUserSvt(report.userGame.pushUserSvtId);
    final favoriteUserSvt = report.mstData.getUserSvt(report.userGame.favoriteUserSvtId);
    List<Widget> cards = [];
    for (final (isPush, isFavorite, userSvt) in [(true, false, pushUserSvt), (false, true, favoriteUserSvt)]) {
      // for (final (isPush, isFavorite, userSvt) in [(true, true, pushUserSvt)]) {
      if (userSvt == null) continue;
      final svt = userSvt.dbSvt;
      final collection = mstData.userSvtCollection[userSvt.svtId];

      final limitCount = userSvt.dispLimitCount;
      String? svtImage, rarityIcon, clsIcon;
      if (svt != null) {
        // svt image
        final status = svt.extraAssets.status;
        svtImage = status.ascension?[limitCount] ?? status.costume?[limitCount];
        if (svtImage == null && limitCount > 10) {
          final charaId = svt.costume.values.firstWhereOrNull((e) => e.id == limitCount)?.battleCharaId;
          svtImage = status.costume?[charaId];
        }
        svtImage ??= status.ascension?.values.last;

        // rarity icon
        final rarity = svt.getAscended(userSvt.dispLimitCount, (e) => e.overwriteRarity) ?? svt.rarity;
        int rarityType = 0;
        if (userSvt.exceedCount > 0) {
          rarityType = 1;
          if (userSvt.lv >= 100) {
            rarityType = 2;
          }
          if (userSvt.lv == 120) {
            rarityType = 3;
          }
        }
        if (rarity == 0) rarityType += 1;
        rarityIcon = "https://static.atlasacademy.io/JP/CharaGraphOption/rarity${rarity}_$rarityType.png";
        rarityIcon;

        // class icon
        bool isGrand = mstData.userSvtGrand.any((e) => e.userSvtId == userSvt.id);
        int clsIconRarity = rarity;
        if (userSvt.exceedCount > 0) clsIconRarity = max(clsIconRarity, 5);
        // if (!isGrand && clsIconRarity > 3) clsIconRarity = 3;
        clsIcon = SvtClassX.clsIcon(isGrand ? svt.classId + 10000 : svt.classId, clsIconRarity);
      }
      svtImage ??= 'https://static.atlasacademy.io/JP/Servants/Status/${userSvt.svtId}/status_servant_3.png';

      // bond icon
      if (collection != null) {
        collection.friendshipRank;
      }

      Widget card = ReportCard(
        onTap: svt?.routeTo,
        clipBehavior: .antiAlias,
        header: Text.rich(
          TextSpan(
            children: [
              if (isPush) ...[
                CenterWidgetSpan(
                  child: CachedImage(
                    imageUrl:
                        'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Terminal/Info/CommonUIAtlas/icon_push.png',
                    width: 18,
                    height: 18,
                    placeholder: _blankPlaceholder,
                  ),
                ),
                TextSpan(text: ' ${S.current.chaldea_report_push}  '),
              ],
              if (isFavorite) ...[
                CenterWidgetSpan(
                  child: CachedImage(
                    imageUrl:
                        'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Terminal/Info/CommonUIAtlas/icon_choice.png',
                    width: 18,
                    height: 18,
                    placeholder: _blankPlaceholder,
                  ),
                ),
                TextSpan(text: ' ${S.current.chaldea_report_favorite}  '),
              ],
            ],
            style: TextStyle(fontWeight: .bold),
          ),
        ),
        backgrounds: [
          // if (rarityIcon != null) CachedImage(imageUrl: rarityIcon, height: 10, placeholder: _blankPlaceholder),
          if (clsIcon != null)
            Positioned(
              top: 5,
              right: 5,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Opacity(
                  opacity: 0.5,
                  child: CachedImage(imageUrl: clsIcon, width: 40, height: 40, placeholder: _blankPlaceholder),
                ),
              ),
            ),
        ],
        padding: .fromLTRB(16, 16, 16, 8),
        child: Row(
          spacing: 8,
          crossAxisAlignment: .center,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 60),
                child: CachedImage(
                  imageUrl: svtImage,
                  placeholder: _blankPlaceholder,
                  // width: 48 /*height: 48 / (148 / 375) */,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  // CachedImage(imageUrl: rarityIcon, height: 12, placeholder: _blankPlaceholder),
                  AutoSizeText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Lv. ',
                          style: TextStyle(color: _greyColor),
                        ),
                        TextSpan(
                          text: '${userSvt.lv}',
                          style: TextStyle(
                            fontSize: 16,
                            color: userSvt.lv >= 120
                                ? Colors.amber.shade800
                                : userSvt.lv >= 100
                                ? Colors.amber.shade500
                                : userSvt.exceedCount > 0
                                ? Colors.amber.shade200
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: .center,
                    children: [
                      SizedBox(
                        width: 16,
                        child: Center(
                          child: CachedImage(
                            imageUrl:
                                'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Battle/Common/CommonUIAtlas/icon_np_on.png',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          '  ${userSvt.treasureDeviceLv1}',
                          style: TextStyle(fontSize: 16, color: userSvt.treasureDeviceLv1 >= 5 ? Colors.amber : null),
                          maxLines: 1,
                          minFontSize: 8,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: .center,
                    children: [
                      SizedBox(
                        width: 16,
                        child: Center(
                          child: CachedImage(
                            imageUrl:
                                'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Terminal/Info/CommonUIAtlas/img_bond_category.png',
                            width: 14,
                            height: 14,
                          ),
                        ),
                      ),
                      if (collection != null)
                        Expanded(
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '  ${collection.friendshipRank}', style: TextStyle(fontSize: 16)),
                                if (collection.maxFriendshipRank != collection.friendshipRank)
                                  TextSpan(
                                    text: ' /${collection.maxFriendshipRank}',
                                    style: TextStyle(color: _greyColor, fontSize: 10),
                                  ),
                              ],
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isPush && isFavorite)
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(svt?.lName.l ?? ""),
                    //
                  ],
                ),
              ),
          ],
        ),
      );
      card = Expanded(child: card);
      cards.add(card);
    }
    if (cards.isEmpty) return null;

    return Row(crossAxisAlignment: .center, children: cards);
  }

  Widget _bondCeStats() {
    List<int> years = range(
      Maths.min(report.bondEquipHistoryByYear.keys, 0),
      Maths.max(report.bondEquipHistoryByYear.keys, 0) + 1,
    ).toList();
    if (years.length > 10) {
      years = years.skip(years.length - 10).toList();
    }
    final bond10Count = report.bond10SvtCollections.length;
    final thisYearCount = report.bondEquipHistoryByYear[report.curYear]?.length ?? 0;
    final totalReleasedCount = report.ownedSvtCollections.values
        .where((e) => e.svtId != kMashSvtId || report.regionReleasedBondEquipIds.contains(9309050))
        .length;
    return ReportCard(
      header: Text(S.current.bond_craft, style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        router.pushPage(
          SvtBondDetailPage(
            friendCode: mstData.user?.friendCode,
            userSvtCollections: mstData.userSvtCollection.toList(),
            userSvts: mstData.userSvtAndStorage.toList(),
          ),
        );
      },
      backgroundAlignment: .topCenter,
      backgrounds: [
        Positioned(
          top: -50,
          // right: ,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Opacity(
              opacity: 0.8,
              child: CachedImage(
                imageUrl: 'https://static.atlasacademy.io/JP/EventUI/questboard_icon_cap03.png',
                placeholder: _blankPlaceholder,
                width: 150,
                height: 150,
                cachedOption: CachedImageOption(fit: .contain),
              ),
            ),
          ),
        ),
      ],
      child: Row(
        spacing: 4,
        crossAxisAlignment: .end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.total, style: TextStyle(color: _greyColor)),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$bond10Count',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' / $totalReleasedCount',
                        style: TextStyle(color: _greyColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(S.current.chaldea_report_cur_year(report.curYear), style: TextStyle(color: _greyColor)),
                Text('$thisYearCount', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                if (report.bond15SvtCollections.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('${S.current.bond}15', style: TextStyle(color: _greyColor)),
                  Text(
                    '${report.bond15SvtCollections.length}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${S.current.progress} ${(bond10Count / totalReleasedCount).format(percent: true, precision: 1)}',
                  style: TextStyle(color: _greyColor),
                ),
                const SizedBox(height: 2),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      for (final (index, count) in [
                        bond10Count - thisYearCount,
                        thisYearCount,
                        totalReleasedCount - bond10Count,
                      ].indexed)
                        if (count > 0)
                          Expanded(
                            flex: count,
                            child: Container(
                              height: 8,
                              color:
                                  [
                                    Color.fromARGB(255, 111, 26, 185),
                                    Color.fromARGB(255, 145, 26, 185),
                                    Colors.grey.shade200,
                                  ].getOrNull(index) ??
                                  Colors.grey.shade100,
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (report.bondEquipHistoryByYear.isNotEmpty)
            Expanded(
              child: SizedBox(
                height: 160,
                child: IgnorePointer(
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(v.round().toString().substring(2), style: const TextStyle(fontSize: 10)),
                            ),
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(years.length, (i) {
                        final year = years[i];
                        final y = report.bondEquipHistoryByYear[year]?.length ?? 0;
                        return BarChartGroupData(
                          showingTooltipIndicators: [0],
                          x: year,
                          barRods: [
                            BarChartRodData(
                              toY: y.toDouble(),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7B2CBF), Color.fromARGB(255, 173, 96, 235)],
                              ),
                            ),
                          ],
                        );
                      }),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 0,
                          getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                            if (rod.toY == 0) return null;
                            return BarTooltipItem(
                              rod.toY.round().toString(),
                              TextStyle(color: Color.fromARGB(255, 173, 96, 235), fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _svtCollectionStats() {
    final classColors = _classColorMap;
    final clsKeys = report.ownedSvtCollectionByClass.keys.toList()..sort2((e) => e.value);
    return ReportCard(
      header: Text(S.current.chaldea_report_compendium, style: TextStyle(fontWeight: FontWeight.bold)),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            flex: 3,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 240),
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: [
                      for (final svtClass in clsKeys)
                        PieChartSectionData(
                          value: (report.ownedSvtCollectionByClass[svtClass] ?? 0).toDouble(),
                          title: (report.ownedSvtCollectionByClass[svtClass] ?? 0).toString(),
                          titleStyle: const TextStyle(fontSize: 10),
                          color: (classColors[svtClass] ?? Colors.blueGrey).withAlpha(180),
                          badgeWidget: db.getIconImage(svtClass.icon(5), width: 24, height: 24),
                          badgePositionPercentageOffset: 0.99,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.chaldea_report_total_svts, style: TextStyle(color: _greyColor)),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${report.ownedSvtCollections.length}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' / ${report.regionReleasedPlayableSvtIds.length}',
                        style: TextStyle(color: _greyColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AutoSizeText(
                  S.current.chaldea_report_5star_svts_count(kStarChar2),
                  style: TextStyle(color: _greyColor),
                  maxLines: 1,
                  minFontSize: 8,
                ),
                AutoSizeText(
                  '${report.ownedSvtCollectionByRarity[5] ?? 0} / ${report.curSsrTdLv}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  minFontSize: 8,
                ),
                const SizedBox(height: 8),
                ...range(5, 0, -1).map((rarity) {
                  final count = report.ownedSvtCollectionByRarity[rarity] ?? 0,
                      totalCount = report.regionReleasedPlayableSvtCountByRarity[rarity] ?? 0;
                  double rate = count / totalCount;
                  if (!rate.isFinite) rate = 0;
                  final bar = ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: rate,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200.withAlpha(100),
                      // valueColor: const AlwaysStoppedAnimation(Color.fromARGB(255, 111, 26, 185)),
                      valueColor: AlwaysStoppedAnimation(
                        Color.fromARGB(255, 111, 26, 185).withAlpha(225 - 15 * (5 - rarity)),
                      ),
                    ),
                  );
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: AutoSizeText(
                            '$rarity$kStarChar2',
                            style: TextStyle(fontSize: 11, color: _greyColor),
                            textAlign: .end,
                            maxLines: 1,
                            minFontSize: 4,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Stack(
                            alignment: .center,
                            children: [
                              ConstrainedBox(constraints: BoxConstraints(maxWidth: 120), child: bar),
                              AutoSizeText(
                                '$count/$totalCount',
                                style: TextStyle(fontSize: 7, color: Colors.white54),
                                textAlign: .center,
                                maxLines: 1,
                                minFontSize: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gachaLuck() {
    double summonRate = report.summonSsrRate;
    final luckyGrade = report.luckyGrade;
    String bgImage = 'https://media.fgo.wiki/a/a6/圣晶石10个.png';
    if (luckyGrade == .veryUnlucky) {
      bgImage = 'https://static.atlasacademy.io/JP/Servants/Status/1100100/status_servant_1.png';
    }
    return ReportCard(
      header: Text(S.current.chaldea_report_5star_pull(kStarChar2), style: TextStyle(fontWeight: .bold)),
      onTap: () => SimpleConfirmDialog(
        showCancel: false,
        scrollable: true,
        title: Text(S.current.chaldea_report_5star_pull_prob(kStarChar2)),
        content: Text("""${S.current.chaldea_report_5star_stat_dis_detail}
${S.current.chaldea_report_5star_stat_dis_ent}"""),
      ).showDialog(context),
      backgrounds: [
        Positioned(
          right: 10,
          top: 0,
          child: ImageFiltered(
            imageFilter: .blur(sigmaX: 0.1, sigmaY: 0.1),
            child: Opacity(
              opacity: 0.8,
              child: CachedImage(imageUrl: bgImage, width: 80, height: 80 * 4 / 3, placeholder: _blankPlaceholder),
            ),
          ),
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${summonRate.toStringAsFixed(2)}%',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' ${S.current.gacha_draw_rate}',
                        style: TextStyle(color: _greyColor),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  minFontSize: 8,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: summonRate / 2,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    color: Color.lerp(Colors.amber.shade100, Colors.amber.shade900, summonRate / 2),
                  ),
                ),
                const SizedBox(height: 12),
                AutoSizeText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${report.summonSsrCount}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' / ${report.summonPullCount} ${S.current.summon_pull_unit}',
                        style: TextStyle(color: _greyColor),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  minFontSize: 8,
                ),
                // const SizedBox(height: 12),
                Divider(height: 12, endIndent: 12),
                InkWell(
                  borderRadius: .circular(8),
                  onTap: () {
                    router.pushPage(UserGachaListPage(report: report, userGachas: report.luckyBagGachas.toList()));
                  },
                  child: AutoSizeText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '+${report.luckyBagGachas.length}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${S.current.lucky_bag} ',
                          style: TextStyle(color: _greyColor),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    minFontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.chaldea_report_likely, style: TextStyle(color: _greyColor)),
                const SizedBox(height: 6),
                Text(luckyGrade.shownName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                AutoSizeText(luckyGrade.comment, maxLines: 3, minFontSize: 8, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gachaTopPulls(bool useThisYear) {
    const int kMaxShownQuestCount = 3;
    String titlePrefix = useThisYear
        ? S.current.chaldea_report_pull_stat_cur_year(report.curYear)
        : S.current.chaldea_report_pull_stat_all;
    final userGachas = useThisYear ? report.mostPullGachasThisYear : report.mostPullGachas;
    return ReportCard(
      header: Padding(
        padding: const .symmetric(horizontal: 16),
        child: Text(
          S.current.chaldea_report_pull_stat_top_title(titlePrefix, kMaxShownQuestCount),
          style: TextStyle(fontWeight: .bold),
        ),
      ),
      padding: .symmetric(vertical: 16),
      onTap: userGachas.isEmpty
          ? null
          : () {
              router.pushPage(
                UserGachaListPage(
                  report: report,
                  userGachas: userGachas.toList(),
                  title: S.current.chaldea_report_pull_cur_year(titlePrefix),
                ),
              );
            },
      backgrounds: [
        Positioned(
          top: useThisYear ? -30 : -80,
          // right: useThisYear ? 20 : 50,
          right: 0,
          // bottom: 0,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Opacity(
              opacity: 0.4,
              child: CachedImage(
                // imageUrl: 'https://media.fgo.wiki/5/5c/圣晶石16个.png',
                imageUrl: useThisYear
                    ? 'https://media.fgo.wiki/a/a6/圣晶石10个.png'
                    : 'https://media.fgo.wiki/5/5c/圣晶石16个.png',
                placeholder: _blankPlaceholder,
                height: useThisYear ? 100 : 140,
                // cachedOption: CachedImageOption(fit: .fitHeight),
              ),
            ),
          ),
        ),
      ],
      child: Column(mainAxisSize: .min, children: [...userGachas.take(kMaxShownQuestCount).map(_gachaTile)]),
    );
  }

  Widget _gachaTile(UserGachaEntity userGacha) {
    final gacha = report.mstGachas[userGacha.gachaId];
    return Stack(
      alignment: .centerLeft,
      children: [
        if (gacha != null)
          Positioned(
            left: 0,
            top: 0,
            width: 60,
            height: 99,
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent),
              clipBehavior: Clip.hardEdge,
              child: OverflowBox(
                maxWidth: 400,
                maxHeight: 200,
                minWidth: 10,
                minHeight: 19,
                fit: .deferToChild,
                alignment: .topLeft,
                child: CachedImage(
                  imageUrl: AssetURL(report.region).summonBanner(gacha.imageId),
                  placeholder: _blankPlaceholder,
                  height: 80,
                  width: 80 * 1344 / 576,
                ),
              ),
            ),
          ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsetsDirectional.only(end: 16, start: 16 + 50),
          title: Text(
            gacha?.lName.setMaxLines(1) ?? '${userGacha.gachaId}',
            textScaler: .linear(0.90),
            maxLines: 2,
            overflow: .ellipsis,
          ),
          subtitle: gacha == null
              ? null
              : Text(
                  [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toDateString()).join(' ~ '),
                  style: const TextStyle(color: _greyColor),
                ),
          trailing: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: ' ${userGacha.num}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextSpan(
                  text: ' ${S.current.summon_pull_unit}',
                  style: TextStyle(color: _greyColor),
                ),
              ],
            ),
          ),
          onTap: () {
            if (gacha != null) {
              gacha.routeTo(region: report.region);
            } else {
              router.push(url: Routes.gachaI(userGacha.gachaId), region: report.region);
            }
          },
        ),
      ],
    );
  }

  Widget _topQuestRun() {
    final List<(String tag, List<UserQuestStat> stats)> groups = [
      (S.current.chaldea_report_most_free, report.mostClearFreeQuests),
      (S.current.chaldea_report_most_event_free, report.mostClearEventFreeQuests),
      (S.current.chaldea_report_most_raid, report.mostClearRaidQuests),
      (S.current.chaldea_report_most_fail, report.mostChallengeFailQuests),
    ];
    List<Widget> children = [];
    for (final (tag, stats) in groups) {
      if (stats.isEmpty) continue;
      final stat = stats.first;
      String? spotIcon = stat.quest.spot?.shownImage;
      children.add(
        ListTile(
          dense: true,
          visualDensity: .compact,
          minTileHeight: 32,
          leading: CachedImage(
            imageUrl:
                spotIcon ??
                'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Battle/Common/CommonUIAtlas/img_arrow_under.png',
            width: spotIcon == null ? 24 : 28,
            placeholder: _blankPlaceholder,
          ),
          minLeadingWidth: 28,
          title: Text(stat.quest.lDispName.setMaxLines(1)),
          subtitle: Text(tag),
          trailing: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: ' ${stat.count}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                TextSpan(
                  text: S.current.chaldea_report_times,
                  style: TextStyle(color: _greyColor),
                ),
              ],
            ),
          ),
          onTap: stat.quest.routeTo,
        ),
      );
    }
    return ReportCard(
      padding: .symmetric(vertical: 16),
      header: Padding(padding: .symmetric(horizontal: 16), child: Text(S.current.chaldea_report_quests_stat)),
      onTap: () {
        router.pushPage(UserQuestFarmingStatPage(userQuests: mstData.userQuest.toList()));
      },
      backgrounds: [
        Positioned(
          top: -50,
          right: 60,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Opacity(
              opacity: 0.8,
              child: CachedImage(
                imageUrl: 'https://static.atlasacademy.io/JP/EventUI/questboard_icon_cap00.png',
                placeholder: _blankPlaceholder,
                width: 150,
                height: 150,
                cachedOption: CachedImageOption(fit: .contain),
              ),
            ),
          ),
        ),
      ],
      child: Column(mainAxisSize: .min, children: children),
    );
  }

  Widget _miscTile() {
    // 圣晶石购入
    const largeFontSize = 18.0;
    return ReportCard(
      padding: .symmetric(vertical: 16),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: db.getIconImage(
              Items.lantern?.icon ?? "https://static.atlasacademy.io/JP/Items/1000.png",
              width: 24,
              height: 24,
            ),
            title: Text(Items.lantern?.lName.l ?? 'カルデアの夢火'),
            trailing: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' ${report.usedLanternCount} ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: largeFontSize),
                  ),
                  TextSpan(
                    text: ' +${report.mstData.getItemOrSvtNum(Items.lanternId)} ',
                    style: TextStyle(color: _greyColor),
                  ),
                  TextSpan(
                    text: ' =${report.usedLanternCount + report.mstData.getItemOrSvtNum(Items.lanternId)} ',
                    style: TextStyle(color: _greyColor),
                  ),
                ],
              ),
              textAlign: .end,
            ),
            onTap: () {
              router.pushPage(
                UserSvtFiltratedPage.collection(
                  title: Text(Items.lantern?.lName.l ?? 'カルデアの夢火'),
                  userSvtCollections: report.usedLanternSvt,
                  getCollectionStatus: (collection) {
                    return [
                      '+${collection.usedLanternCount}',
                      '${collection.friendshipRank}/${collection.maxFriendshipRank}',
                    ].join('\n');
                  },
                ),
              );
            },
          ),
          ListTile(
            dense: true,
            leading: db.getIconImage(
              Items.grail?.icon ?? "https://static.atlasacademy.io/JP/Items/7999.png",
              width: 24,
              height: 24,
            ),
            title: Text(Items.grail?.lName.l ?? '聖杯'),
            trailing: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' ${report.usedGrailCount}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextSpan(
                    text: ' +${report.mstData.getItemOrSvtNum(Items.grailId)} ',
                    style: TextStyle(color: _greyColor),
                  ),
                  TextSpan(
                    text: ' =${report.usedGrailCount + report.mstData.getItemOrSvtNum(Items.grailId)} ',
                    style: TextStyle(color: _greyColor),
                  ),
                ],
              ),
              textAlign: .end,
            ),
            onTap: () {
              router.pushPage(
                UserSvtFiltratedPage.userSvt(
                  title: Text(Items.grail?.lName.l ?? '聖杯'),
                  userSvts: report.usedGrailUserSvts.keys.toList(),
                  getUserSvtStatus: (userSvt) {
                    return ['+${userSvt.getExceedCountByGrail()}', '${userSvt.lv}/${userSvt.maxLv}'].join('\n');
                  },
                ),
              );
            },
          ),
          ListTile(
            dense: true,
            leading: db.getIconImage(
              Items.crystal?.icon ?? "https://static.atlasacademy.io/JP/Items/6999.png",
              width: 24,
              height: 24,
            ),
            title: Text(Items.crystal?.lName.l ?? '伝承結晶'),
            trailing: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' ${report.usedCrystalCountActive}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: largeFontSize),
                  ),
                  const TextSpan(
                    text: ' +',
                    style: TextStyle(color: _greyColor),
                  ),
                  TextSpan(
                    text: '${report.usedCrystalCountPassive}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: largeFontSize),
                  ),
                  TextSpan(
                    text: ' +${report.mstData.getItemOrSvtNum(Items.crystalId)} ',
                    style: TextStyle(color: _greyColor),
                  ),
                  TextSpan(
                    text: ' =${report.usedCrystalCount + report.mstData.getItemOrSvtNum(Items.crystalId)} ',
                    style: TextStyle(color: _greyColor),
                  ),
                ],
              ),
              textAlign: .end,
            ),
          ),
          ListTile(
            dense: true,
            leading: db.getIconImage(
              Items.svtAnonymous?.icon ?? "https://static.atlasacademy.io/JP/Items/17.png",
              width: 24,
              height: 24,
            ),
            title: Text(Items.svtAnonymous?.lName.l ?? '無記名霊基'),
            trailing: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' ${report.usedSvtAnonymousCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: largeFontSize,
                      color: report.usedSvtAnonymousCount == 0 ? _greyColor : null,
                    ),
                  ),
                  TextSpan(
                    text: ' ×10 +${report.mstData.getItemOrSvtNum(Items.svtAnonymousId)} ',
                    style: TextStyle(color: _greyColor),
                  ),
                  TextSpan(
                    text:
                        ' =${report.usedSvtAnonymousCount * 10 + report.mstData.getItemOrSvtNum(Items.svtAnonymousId)} ',
                    style: TextStyle(color: _greyColor),
                  ),
                ],
              ),
              textAlign: .end,
            ),
            onTap: () {
              router.pushPage(UserShopAnonymousListPage(shops: report.svtAnonymousShops));
            },
          ),
        ],
      ),
    );
  }

  Widget _topTitle() {
    return Padding(
      padding: .symmetric(horizontal: 40),
      child: Column(
        children: [
          CachedImage(
            imageUrl:
                'https://static.atlasacademy.io/file/aa-fgo-extract-jp/GrandServantList/DownloadGrandServantListAtlas1/Name_BG_Pattern_Line.png',
            height: 30,
            placeholder: _blankPlaceholder,
          ),
          const SizedBox(height: 2),
          // AutoSizeText(
          //   ' Fate / Grand Order ',
          //   style: TextStyle(
          //     color: Colors.white.withAlpha(200),
          //     fontSize: 24,
          //     fontWeight: FontWeight.w100,
          //     letterSpacing: 15.2,
          //     fontFamily: 'helvetica',
          //   ),
          //   textAlign: TextAlign.center,
          //   maxLines: 1,
          //   minFontSize: 6,
          // ),
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              -1.0, 0.0, 0.0, 0.0, 255.0, //
              0.0, -1.0, 0.0, 0.0, 255.0, //
              0.0, 0.0, -1.0, 0.0, 255.0, //
              0.0, 0.0, 0.0, 1.0, 0.0, //
            ]),
            child: CachedImage(
              imageUrl: 'https://static.atlasacademy.io/JP/Title/logo_title_part2_final.png',
              height: 30,
              width: 30 * 604 / 40,
              placeholder: _blankPlaceholder,
              cachedOption: CachedImageOption(
                errorWidget: (context, url, error) => AutoSizeText(
                  'Fate / Grand Order',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                    fontFamily: 'helvetica',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _finalMessage() {
    return Padding(
      padding: .symmetric(vertical: 8),
      // color: Colors.grey.withAlpha(25).withAlpha(1),
      // color: Colors.transparent,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        spacing: 4,
        children: [
          Text(
            'by Chaldea App',
            style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: .center,
          ),
          Text(
            report.createdAt.toStringShort(omitSec: true),
            style: TextStyle(color: _greyColor.withAlpha(150), fontSize: 12),
            textAlign: .center,
          ),
        ],
      ),
    );
  }

  final Map<SvtClass, Color> _classColorMap = const {
    SvtClass.saber: Color(0xFFEF476F),
    SvtClass.archer: Color(0xFF06D6A0),
    SvtClass.lancer: Color(0xFF118AB2),
    SvtClass.rider: Color.fromARGB(255, 245, 181, 32),
    SvtClass.caster: Color(0xFF8338EC),
    SvtClass.assassin: Color(0xFF3A86FF),
    SvtClass.berserker: Color(0xFFFB5607),
    SvtClass.EXTRA1: Color(0xFF2A9D8F),
    SvtClass.EXTRA2: Color(0xFF0096C7),
    SvtClass.unknown: Color(0xFF1D3557),
  };
}

class ReportCard extends StatelessWidget {
  final Color? color;
  final EdgeInsetsGeometry padding;
  final Widget? header;
  final List<Widget> headerTailings;
  final Widget child;
  final List<Widget> backgrounds;
  final AlignmentGeometry backgroundAlignment;
  final VoidCallback? onTap;
  final Clip? clipBehavior;

  const ReportCard({
    super.key,
    this.color = const Color.fromARGB(60, 158, 158, 158),
    this.padding = const EdgeInsets.all(16),
    this.header,
    this.headerTailings = const [],
    required this.child,
    this.backgrounds = const [],
    this.backgroundAlignment = AlignmentDirectional.topStart,
    this.onTap,
    this.clipBehavior,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (header != null || headerTailings.isNotEmpty) {
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: .center,
            children: [
              Expanded(child: header ?? const SizedBox.shrink()),
              ...headerTailings,
            ],
          ),
        ),
      );
    }

    Widget content = Padding(
      padding: padding,
      child: children.isEmpty
          ? child
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...children, child]),
    );
    final borderRadius = BorderRadius.circular(16);
    if (onTap != null) {
      content = InkWell(borderRadius: borderRadius, onTap: onTap, child: content);
    }
    if (backgrounds.isNotEmpty) {
      content = Stack(alignment: backgroundAlignment, children: [...backgrounds, content]);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      color: color,
      clipBehavior: clipBehavior,
      child: content,
    );
  }
}

class RelativePolygonClipper extends CustomClipper<Path> {
  final List<Offset> points;
  const RelativePolygonClipper(this.points);

  @override
  Path getClip(Size size) {
    return Path()..addPolygon([for (final point in points) point.scale(size.width, size.height)], true);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

Widget _blankPlaceholder(BuildContext context, String url) => const SizedBox.shrink();

// ignore: unused_element
String _getTranslation(String zh, String en) {
  return Language.isZH ? zh : en;
}
