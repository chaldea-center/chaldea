import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';

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
import 'report_data.dart';

class FgoAnnualReportPage extends StatefulWidget {
  final MasterDataManager mstData;
  final Region? region;

  const FgoAnnualReportPage({super.key, required this.mstData, required this.region});

  @override
  State<FgoAnnualReportPage> createState() => _FgoAnnualReportPageState();
}

class _FgoAnnualReportPageState extends State<FgoAnnualReportPage> {
  FgoAnnualReportData2? _data;
  bool loading = false;

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
      _data = await FgoAnnualReportData2.parse(mstData: widget.mstData, region: region);
      EasyLoading.dismiss();
    } catch (e, s) {
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
          Widget? body;
          if (data == null) {
            body = loading ? CircularProgressIndicator() : Text(S.current.error);
          } else {
            final w = constraints.maxWidth, h = constraints.maxHeight;
            if (w > 700 || w < 200 || h < 400) {
              body = Text('window size not suitable\n窗口尺寸不合适\nw=200~700,h≥400\n(w=$w,h=$h)');
            }
          }
          if (body != null) {
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
              body: Center(child: body),
            );
          }
          return FgoAnnualReportRealPage(report: data!);
        },
      ),
    );
  }
}

class FgoAnnualReportRealPage extends StatefulWidget {
  final FgoAnnualReportData2 report;
  const FgoAnnualReportRealPage({super.key, required this.report});

  @override
  State<FgoAnnualReportRealPage> createState() => _FgoAnnualReportRealPageState();
}

class _FgoAnnualReportRealPageState extends State<FgoAnnualReportRealPage> {
  late final FgoAnnualReportData2 report = widget.report;

  Random random = Random();
  // options
  bool _showFriendCode = false;
  bool _screenshotMode = false;
  // final String _defaultBackgroundImageUrl = 'https://static.atlasacademy.io/JP/Back/back255400_1344_626.png';
  final String _defaultBackgroundImageUrl = 'https://static.atlasacademy.io/JP/Back/back135100_1344_626.png';

  final _screenshotController = ScreenshotController();

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
    final pushSvt =
        db.gameData.servantsById[(report.mstData.userSvt[report.userGame.pushUserSvtId] ??
                report.mstData.userSvtStorage[report.userGame.pushUserSvtId])
            ?.svtId];
    String backgroundImageUrl =
        pushSvt?.extraAssets.charaGraph.ascension?.values.lastOrNull ?? _defaultBackgroundImageUrl;
    backgroundImageUrl = _defaultBackgroundImageUrl;

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
                      imageUrl: backgroundImageUrl,
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
                    _bondCeStats(),
                    _summonedStats(),
                    _gachaLuck(),
                    _gachaTopPools(),
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

    String friendCode = _showFriendCode ? report.userGame.friendCode : '*' * 9;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey.withAlpha(60),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipPath(
              clipper: const _MasterAvatarClipper(),
              child: db.getIconImage(
                'https://static.atlasacademy.io/JP/MasterFace/equip0000${report.userGame.genderType}.png',
                width: 64,
                height: 64,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.userGame.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        CenterWidgetSpan(child: SvgPicture.string(report.region.svgFlag, width: 18)),
                        TextSpan(
                          text: ' $friendCode',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _showFriendCode = !_showFriendCode;
                              });
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: DateFormat('yyyy-MM-dd').format(report.userGame.createdAt.sec2date()),
                      children: [
                        TextSpan(
                          text: ' 加入',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('已经$year年$month月$day日', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }

  Widget _bondCeStats() {
    List<int> years = range(
      Maths.min(report.bondEquipHistoryByYear.keys, 0),
      Maths.max(report.bondEquipHistoryByYear.keys, 0) + 1,
    ).toList();
    if (years.length > 10) {
      years = years.skip(years.length - 10).toList();
    }
    return Column(
      children: [
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey.withAlpha(90),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.bond, style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  spacing: 4,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('羁绊礼装', style: TextStyle(color: Colors.grey)),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${report.bond10SvtCollections.length}',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      ' / ${report.ownedSvtCollections.values.where((e) => e.svtId != 800100 || report.regionReleasedBondEquipIds.contains(9309050)).length}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('羁绊礼装(${report.curYear}年)', style: TextStyle(color: Colors.grey)),
                          Text(
                            '${report.bondEquipHistoryByYear[report.curYear]?.length ?? 0}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          if (report.bond15SvtCollections.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('羁绊15', style: TextStyle(color: Colors.grey)),
                            Text(
                              '${report.bond15SvtCollections.length}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (report.bondEquipHistoryByYear.isNotEmpty)
                      Expanded(
                        child: SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, meta) => Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        v.round().toString().substring(2),
                                        style: const TextStyle(fontSize: 10),
                                      ),
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
                                  getTooltipItem:
                                      (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summonedStats() {
    final classColors = _classColorMap;
    final clsKeys = report.ownedSvtCollectionByClass.keys.toList()..sort2((e) => e.value);
    return Column(
      children: [
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey.withAlpha(120),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('英灵', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 200,
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
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: ' / ${report.regionReleasedPlayableSvtIds.length}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('5$kStarChar2宝具数', style: TextStyle(color: Colors.grey)),
                          Text(
                            '${report.curSsrTdLv}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _gachaLuck() {
    final rate = report.summonSsrRate.toDouble() * 100;
    final (grade, comment) = _luckGrade(rate);
    return Column(
      children: [
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey.withAlpha(120),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('英灵召唤', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('5$kStarChar2概率', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(
                            '${rate.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: rate / 2,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation(Color.fromARGB(255, 111, 26, 185)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('疑似', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(grade, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          Text(comment),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _gachaTopPools() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey.withAlpha(120),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text('${report.curYear}年度抽卡次数最多', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                ...report.mostPullGachasThisYear.map(_gachaTile),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey.withAlpha(120),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: const Text('历史抽卡次数前三', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                ...report.mostPullGachas.map(_gachaTile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _gachaTile(UserGachaEntity userGacha) {
    final gacha = report.mstGachas[userGacha.gachaId];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SizedBox(
          //   width: 240,
          //   height: 240 / 1280 * 720,
          //   child: GachaBanner(region: report.region, imageId: gacha?.imageId ?? 0),
          // ),
          ListTile(
            dense: true,
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
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
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
      ),
    );
  }

  Widget _topTitle() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.blueAccent.withAlpha(50),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '-  Fate / Grand Order  -',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _finalMessage() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey.withAlpha(25),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'by Chaldea App',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
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
    if (ssrRatePercent >= 1.4) return ('Grand欧皇', '圣晶石在此，恭迎天选之人！');
    if (ssrRatePercent >= 1.2) return ('欧皇', '闪耀星之光芒，命运格外垂青。');
    if (ssrRatePercent >= 1.05) return ('中庸', '稳定即是福气，旅程方见真谛。');
    if (ssrRatePercent >= 1.0) return ('略非', '小遇波澜无碍，蓄力以待转机。');
    return ('非酋', '心之所向，下次必达！运气守恒，未来可期。');
  }
}

class _MasterAvatarClipper extends CustomClipper<Path> {
  const _MasterAvatarClipper();

  @override
  Path getClip(Size size) {
    return Path()..addPolygon([
      Offset(0, size.height / 2),
      Offset(size.width / 2, 0),
      Offset(size.width, size.height / 2),
      Offset(size.width / 2, size.height),
    ], true);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
