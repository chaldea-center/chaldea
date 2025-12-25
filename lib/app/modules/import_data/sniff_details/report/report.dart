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
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../bond_detail_page.dart';
import 'report_data.dart';
import 'settings.dart';

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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData({bool refresh = false}) async {
    if (loading) return;
    await null;
    if (mounted) setState(() {});
    try {
      loading = true;
      loadError = null;
      Region? region = widget.region;
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

      EasyLoading.show(status: 'Loading data');
      _data = await FgoAnnualReportData.parse(mstData: widget.mstData, region: region);
      EasyLoading.dismiss();
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
              errors.add(const CircularProgressIndicator());
            }
            if (loadError != null) errors.add(Text('${S.current.error}:\n$loadError'));
          }
          final w = constraints.maxWidth, h = constraints.maxHeight;
          if (w > 700 || w < 200 || h < 400) {
            errors.add(Text('window size not suitable\n窗口长宽尺寸不合适\nw=200~700,h≥400\n(w=$w,h=$h)'));
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

          if (errors.isNotEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Chaldea - FGO报告'),
                actions: [
                  IconButton(
                    onPressed: () {
                      loadData(refresh: true);
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
              body: ListView(padding: .all(16), children: errors),
            );
          }
          return FgoAnnualReportRealPage(report: data!);
        },
      ),
    );
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
  bool _screenshotMode = false;
  // final String _defaultBackgroundImageUrl = 'https://static.atlasacademy.io/JP/Back/back255400_1344_626.png';
  final String _defaultBackgroundImageUrl = 'https://static.atlasacademy.io/JP/Back/back135100_1344_626.png';

  final _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    options.isGirl = report.userGame.genderType == Gender.female.value;
    options.masterEquipId = options.getDefaultMasterEquip(region: report.region);
  }

  Future<void> doScreenshot() async {
    if (_screenshotMode) _screenshotMode;
    try {
      _screenshotMode = true;
      if (mounted) setState(() {});
      await null;
      final pngBytes = await _screenshotController.capture();
      if (pngBytes != null) {
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
      _screenshotMode = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    random = Random(hashCode);
    // backgroundImageUrl = _defaultBackgroundImageUrl;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Chaldea - FGO报告', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(onPressed: doScreenshot, icon: Icon(Icons.share))],
      ),
      body: SingleChildScrollView(
        child: Screenshot(
          controller: _screenshotController,
          child: Stack(
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
                    _userInfoCard(),
                    ?pushAndFavoriteSvts(),
                    _gachaLuck(),
                    _summonedStats(),
                    _bondCeStats(),
                    _gachaTopPulls(true),
                    _gachaTopPulls(false),
                    _topQuestRun(),
                    _finalMessage(),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      background: Positioned.fill(
        top: 16,
        bottom: 0,
        // right: 50,
        child: Align(
          alignment: .xy(0.3, 0),
          child: Opacity(
            opacity: 0.1,
            child: ClipPath(
              clipper: const RelativePolygonClipper([Offset(0, 0), Offset(1, 0), Offset(1, 0.8), Offset(0, 0.8)]),
              child: Image.asset('res/img/chaldea.png'),
            ),
          ),
        ),
      ),
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
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  minFontSize: 8,
                ),
                const SizedBox(height: 2),
                AutoSizeText(
                  '入职$year年$month月$day日',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 1,
                  minFontSize: 8,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('成为御主', style: TextStyle(color: Colors.grey)),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$totalDays',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' 天',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('连续登录', style: TextStyle(color: Colors.grey)),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${report.totalLogin}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' 天',
                      style: const TextStyle(color: Colors.grey),
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

  Widget? pushAndFavoriteSvts() {
    final pushUserSvt = report.mstData.getUserSvt(report.userGame.pushUserSvtId);
    final favoriteUserSvt = report.mstData.getUserSvt(report.userGame.favoriteUserSvtId);
    List<Widget> cards = [];
    for (final userSvt in [?pushUserSvt, ?favoriteUserSvt]) {
      final bool isPush = userSvt.id == report.userGame.pushUserSvtId,
          isFavorite = userSvt.id == report.userGame.favoriteUserSvtId;
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
        clsIcon = SvtClassX.clsIcon(isGrand ? svt.classId + 10000 : svt.classId, clsIconRarity);
      }
      svtImage ??= 'https://static.atlasacademy.io/JP/Servants/Status/${userSvt.svtId}/status_servant_3.png';

      // bond icon
      if (collection != null) {
        collection.friendshipRank;
      }

      Widget card = ReportCard(
        onTap: svt?.routeTo,
        header: Text.rich(
          TextSpan(
            children: [
              CenterWidgetSpan(
                child: CachedImage(
                  imageUrl:
                      'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Terminal/Info/CommonUIAtlas/${isPush ? "icon_push" : "icon_choice"}.png',
                  width: 18,
                  height: 18,
                  placeholder: _blankPlaceholder,
                ),
              ),
              const TextSpan(text: ' '),
              if (isPush) TextSpan(text: '单推'),
              if (isFavorite) TextSpan(text: '中意'),
            ],
            style: TextStyle(fontWeight: .bold),
          ),
        ),
        headerTailings: [
          // if (rarityIcon != null) CachedImage(imageUrl: rarityIcon, height: 10, placeholder: _blankPlaceholder),
          if (clsIcon != null) CachedImage(imageUrl: clsIcon, width: 20, height: 20, placeholder: _blankPlaceholder),
        ],
        padding: .fromLTRB(16, 16, 16, 8),
        child: Row(
          spacing: 8,
          crossAxisAlignment: .start,
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
                          style: TextStyle(color: Colors.grey),
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
                                    style: TextStyle(color: Colors.grey, fontSize: 10),
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
        .where((e) => e.svtId != 800100 || report.regionReleasedBondEquipIds.contains(9309050))
        .length;
    return ReportCard(
      header: Text(S.current.bond_craft, style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        router.push(
          child: SvtBondDetailPage(
            friendCode: mstData.user?.friendCode,
            userSvtCollections: mstData.userSvtCollection.toList(),
            userSvts: mstData.userSvtAndStorage.toList(),
          ),
        );
      },
      child: Row(
        spacing: 4,
        crossAxisAlignment: .end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.total, style: TextStyle(color: Colors.grey)),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$bond10Count',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' / $totalReleasedCount',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('${report.curYear}年', style: TextStyle(color: Colors.grey)),
                Text('$thisYearCount', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                if (report.bond15SvtCollections.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('羁绊15', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${report.bond15SvtCollections.length}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${S.current.progress} ${(bond10Count / totalReleasedCount).format(percent: true, precision: 1)}',
                  style: TextStyle(color: Colors.grey),
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
        ],
      ),
    );
  }

  Widget _summonedStats() {
    final classColors = _classColorMap;
    final clsKeys = report.ownedSvtCollectionByClass.keys.toList()..sort2((e) => e.value);
    return ReportCard(
      header: Text('英灵图鉴', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          color: classColors[svtClass] ?? Colors.blueGrey,
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
                Text('契约从者', style: TextStyle(color: Colors.grey)),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${report.ownedSvtCollections.length}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' / ${report.regionReleasedPlayableSvtIds.length}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AutoSizeText('5$kStarChar2契约/宝具数', style: TextStyle(color: Colors.grey), maxLines: 1, minFontSize: 8),
                Text(
                  '${report.ownedSvtCollectionByRarity[5] ?? 0} / ${report.curSsrTdLv}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                    padding: EdgeInsets.symmetric(vertical: 0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: AutoSizeText(
                            '$rarity$kStarChar2',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                            textAlign: .end,
                            maxLines: 1,
                            minFontSize: 4,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Stack(
                            alignment: .center,
                            children: [
                              bar,
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
    double summonRate = report.summonSsrRate * 100;
    final (luckyGrade, comment) = _luckGrade(summonRate);
    return ReportCard(
      header: Text('5$kStarChar2英灵召唤', style: TextStyle(fontWeight: .bold)),
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
                        text: ' 概率',
                        style: TextStyle(color: Colors.grey),
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
                        text: ' / ${report.summonPullCount} 抽',
                        style: TextStyle(color: Colors.grey),
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
                    //
                  },
                  child: AutoSizeText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${report.luckyBagGachas.length}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${S.current.lucky_bag} ',
                          style: TextStyle(color: Colors.grey),
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
            child: Stack(
              clipBehavior: .none,
              children: [
                Positioned(
                  right: -10,
                  top: -60,
                  child: Opacity(
                    opacity: 0.6,
                    child: CachedImage(
                      imageUrl: 'https://media.fgo.wiki/a/a6/圣晶石10个.png',
                      width: 90,
                      height: 90 * 4 / 3,
                      placeholder: _blankPlaceholder,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('疑似', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(luckyGrade, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    AutoSizeText(comment, maxLines: 3, minFontSize: 8, style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gachaTopPulls(bool useThisYear) {
    return ReportCard(
      header: Padding(
        padding: const .symmetric(horizontal: 16),
        child: Text('${useThisYear ? '${report.curYear}年度' : '历年'}抽卡次数前三', style: TextStyle(fontWeight: .bold)),
      ),
      padding: .symmetric(vertical: 16),
      background: Positioned(
        // left: useThisYear ? null : 20,
        top: useThisYear ? -30 : -90,
        right: useThisYear ? 20 : 50,
        bottom: -10,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Opacity(
            opacity: 0.2,
            child: CachedImage(
              // imageUrl: 'https://media.fgo.wiki/5/5c/圣晶石16个.png',
              imageUrl: useThisYear
                  ? 'https://media.fgo.wiki/a/a6/圣晶石10个.png'
                  : 'https://media.fgo.wiki/5/5c/圣晶石16个.png',
              placeholder: _blankPlaceholder,
              cachedOption: CachedImageOption(fit: .fitHeight),
            ),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [...(useThisYear ? report.mostPullGachasThisYear : report.mostPullGachas).map(_gachaTile)],
      ),
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
                  cachedOption: CachedImageOption(
                    // fit: .scaleDown,
                    //
                  ),
                ),
              ),
            ),
          ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsetsDirectional.only(end: 16, start: 16 + 50),
          title: Text(gacha?.lName.setMaxLines(1) ?? '${userGacha.gachaId}', maxLines: 2),
          subtitle: gacha == null
              ? null
              : Text(
                  [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toDateString()).join(' ~ '),
                  style: const TextStyle(color: Colors.grey),
                ),
          trailing: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: ' ${userGacha.num}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const TextSpan(
                  text: ' 抽',
                  style: TextStyle(color: Colors.grey),
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
      ('地铺本', report.mostClearFreeQuests),
      ('活动Free', report.mostClearEventFreeQuests),
      ('柱子战', report.mostClearRaidQuests),
      ('挑战失败', report.mostChallengeFailQuests),
    ];
    List<Widget> children = [];
    for (final (tag, stats) in groups) {
      if (stats.isEmpty) continue;
      final stat = stats.first;
      String spotIcon =
          stat.quest.spot?.shownImage ??
          'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Battle/Common/CommonUIAtlas/img_arrow_under.png';
      children.add(
        ListTile(
          dense: true,
          leading: CachedImage(imageUrl: spotIcon, width: 28, placeholder: _blankPlaceholder),
          title: Text(stat.quest.lDispName.setMaxLines(1)),
          subtitle: Text(tag),
          trailing: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: ' ${stat.count}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                // const TextSpan(
                //   text: ' 抽',
                //   style: TextStyle(color: Colors.grey),
                // ),
              ],
            ),
          ),
          onTap: stat.quest.routeTo,
        ),
      );
    }
    return ReportCard(
      padding: .symmetric(vertical: 16),
      header: Padding(padding: .symmetric(horizontal: 16), child: Text('关卡之最')),
      child: Column(mainAxisSize: .min, children: children),
    );
  }

  Widget _topTitle() {
    return Column(
      children: [
        CachedImage(
          imageUrl:
              'https://static.atlasacademy.io/file/aa-fgo-extract-jp/GrandServantList/DownloadGrandServantListAtlas1/Name_BG_Pattern_Line.png',
          height: 40,
          placeholder: _blankPlaceholder,
        ),
        Padding(
          padding: .symmetric(vertical: 8),
          child: Text(
            ' Fate / Grand Order ',
            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 22, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
      ],
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
            style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w700),
            textAlign: .center,
          ),
          Text(
            report.createdAt.toStringShort(omitSec: true),
            style: TextStyle(color: Colors.grey.withAlpha(150), fontSize: 12),
            textAlign: .center,
          ),
        ],
      ),
    );
  }

  Map<SvtClass, Color> get _classColorMap => const {
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

  (String luckyGrade, String comment) _luckGrade(double ssrRatePercent) {
    if (ssrRatePercent >= 1.25) return ('Grand 欧皇', '圣晶石在此，恭迎天选之人！');
    if (ssrRatePercent >= 1.15) return ('欧皇', '闪耀星之光芒，命运格外垂青。');
    if (ssrRatePercent >= 1.05) return ('中庸', '稳定即是福气，旅程方见真谛。');
    if (ssrRatePercent >= 1.0) return ('略非', '小遇波澜无碍，蓄力以待转机。');
    return ('非酋', '心之所向，下次必达！运气守恒，未来可期。');
  }
}

class ReportCard extends StatelessWidget {
  final Color? color;
  final EdgeInsetsGeometry padding;
  final Widget? header;
  final List<Widget> headerTailings;
  final Widget child;
  final Widget? background;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    this.color = const Color.fromARGB(60, 158, 158, 158),
    this.padding = const EdgeInsets.all(16),
    this.header,
    this.headerTailings = const [],
    required this.child,
    this.background,
    this.onTap,
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
    if (background != null) {
      content = Stack(children: [?background, content]);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      color: color,
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
