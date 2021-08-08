import 'package:chaldea/components/utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_list_page.dart';
import 'package:chaldea/modules/craft/craft_list_page.dart';
import 'package:chaldea/modules/damage_calc/damage_calc_page.dart';
import 'package:chaldea/modules/debug/theme_palette.dart';
import 'package:chaldea/modules/event/events_page.dart';
import 'package:chaldea/modules/extras/ap_calc_page.dart';
import 'package:chaldea/modules/extras/cv_illustrator_list.dart';
import 'package:chaldea/modules/extras/exp_card_cost_page.dart';
import 'package:chaldea/modules/extras/faq_page.dart';
import 'package:chaldea/modules/extras/mystic_code_page.dart';
import 'package:chaldea/modules/ffo/ffo_page.dart';
import 'package:chaldea/modules/free_quest_calculator/free_calculator_page.dart';
import 'package:chaldea/modules/home/subpage/edit_gallery_page.dart';
import 'package:chaldea/modules/import_data/home_import_page.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/master_mission/master_mission_page.dart';
import 'package:chaldea/modules/servant/costume_list_page.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:chaldea/modules/statistics/game_statistics_page.dart';
import 'package:chaldea/modules/summon/summon_list_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GalleryItem {
  // instant part
  final String name;
  final String Function() titleBuilder;
  final IconData? icon;
  final Widget? child;

  // final SplitPageBuilder? builder;
  final Widget? page;
  final bool isDetail;

  const GalleryItem({
    required this.name,
    required this.titleBuilder,
    this.icon,
    this.child,
    this.page,
    this.isDetail = false,
  }) : assert(icon != null || child != null);

  Widget buildIcon(BuildContext context, {double size = 40}) {
    if (child != null) return child!;
    bool fa = icon!.fontFamily?.toLowerCase().startsWith('fontawesome') == true;
    final _iconColor = Utils.isDarkMode(context)
        ? Theme.of(context).colorScheme.secondaryVariant
        : Theme.of(context).colorScheme.secondary;
    return fa
        ? Padding(
            padding: EdgeInsets.all(size * 0.05),
            child: FaIcon(icon, size: size * 0.9, color: _iconColor))
        : Icon(icon, size: size, color: _iconColor);
  }

  @override
  String toString() {
    return '$runtimeType($name)';
  }

  static List<GalleryItem> get persistentPages => [faq, more];

  static List<GalleryItem> allItems = [
    servant,
    craftEssence,
    commandCode,
    item,
    event,
    plan,
    freeCalculator,
    masterMission,
    mysticCode,
    costume,
    gacha,
    ffo,
    cvList,
    illustratorList,
    expCard,
    statistics,
    importData,
    faq,
    if (kDebugMode) palette,
    more,
    // // unpublished
    // _apCal,
    // _damageCalc,
  ];

  static GalleryItem servant = GalleryItem(
    name: 'servant',
    titleBuilder: () => S.current.servant_title,
    icon: FontAwesomeIcons.users,
    page: ServantListPage(),
  );
  static GalleryItem craftEssence = GalleryItem(
    name: 'craft',
    titleBuilder: () => S.current.craft_essence,
    icon: FontAwesomeIcons.streetView,
    page: CraftListPage(),
  );
  static GalleryItem commandCode = GalleryItem(
    name: 'cmd_code',
    titleBuilder: () => S.current.command_code,
    icon: FontAwesomeIcons.expand,
    page: CmdCodeListPage(),
  );
  static GalleryItem item = GalleryItem(
    name: 'item',
    titleBuilder: () => S.current.item_title,
    icon: Icons.category,
    page: ItemListPage(),
  );
  static GalleryItem event = GalleryItem(
    name: 'event',
    titleBuilder: () => S.current.event_title,
    icon: Icons.flag,
    page: EventListPage(),
  );
  static GalleryItem plan = GalleryItem(
    name: 'plan',
    titleBuilder: () => S.current.plan_title,
    icon: Icons.article_outlined,
    page: ServantListPage(planMode: true),
    isDetail: false,
  );
  static GalleryItem freeCalculator = GalleryItem(
    name: 'free_calculator',
    titleBuilder: () => S.current.free_quest_calculator_short,
    icon: FontAwesomeIcons.mapMarked,
    page: FreeQuestCalculatorPage(),
    isDetail: true,
  );
  static GalleryItem masterMission = GalleryItem(
    name: 'master_mission',
    titleBuilder: () => S.current.master_mission,
    icon: FontAwesomeIcons.tasks,
    page: MasterMissionPage(),
    isDetail: true,
  );
  static GalleryItem mysticCode = GalleryItem(
    name: 'mystic_code',
    titleBuilder: () => S.current.mystic_code,
    icon: FontAwesomeIcons.diagnoses,
    page: MysticCodePage(),
    isDetail: true,
  );
  static GalleryItem costume = GalleryItem(
    name: 'costume',
    titleBuilder: () => S.current.costume,
    icon: FontAwesomeIcons.tshirt,
    page: CostumeListPage(),
    isDetail: false,
  );
  static GalleryItem gacha = GalleryItem(
    name: 'gacha',
    titleBuilder: () => S.current.summon_title,
    icon: FontAwesomeIcons.dice,
    page: SummonListPage(),
    isDetail: false,
  );
  static GalleryItem ffo = GalleryItem(
    name: 'ffo',
    titleBuilder: () => 'Freedom Order',
    icon: FontAwesomeIcons.layerGroup,
    page: FreedomOrderPage(),
    isDetail: true,
  );
  static GalleryItem cvList = GalleryItem(
    name: 'cv_list',
    titleBuilder: () => S.current.info_cv,
    icon: Icons.keyboard_voice,
    page: CvListPage(),
    isDetail: true,
  );
  static GalleryItem illustratorList = GalleryItem(
    name: 'illustrator_list',
    titleBuilder: () => S.current.illustrator,
    icon: FontAwesomeIcons.paintBrush,
    page: IllustratorListPage(),
    isDetail: true,
  );
  static GalleryItem expCard = GalleryItem(
    name: 'exp_card',
    titleBuilder: () => S.current.exp_card_title,
    icon: FontAwesomeIcons.breadSlice,
    page: ExpCardCostPage(),
    isDetail: true,
  );
  static GalleryItem statistics = GalleryItem(
    name: 'statistics',
    titleBuilder: () => S.current.statistics_title,
    icon: Icons.analytics,
    page: GameStatisticsPage(),
    isDetail: true,
  );
  static GalleryItem importData = GalleryItem(
    name: 'import_data',
    titleBuilder: () => S.current.import_data,
    icon: Icons.cloud_download,
    page: ImportPageHome(),
    isDetail: false,
  );
  static GalleryItem faq = GalleryItem(
    name: 'faq',
    titleBuilder: () => 'FAQ',
    icon: Icons.report_problem_rounded,
    page: FAQPage(),
    isDetail: true,
  );
  static GalleryItem more = GalleryItem(
    name: 'more',
    titleBuilder: () => S.current.more,
    icon: Icons.add,
    page: EditGalleryPage(),
    isDetail: true,
  );

  /// debug only
  static GalleryItem palette = GalleryItem(
    name: 'palette',
    titleBuilder: () => 'Palette',
    icon: Icons.palette_outlined,
    page: DarkLightThemePalette(),
    isDetail: true,
  );

  /// unpublished pages
  static GalleryItem apCal = GalleryItem(
    name: 'ap_cal',
    titleBuilder: () => S.current.ap_calc_title,
    icon: Icons.directions_run,
    page: APCalcPage(),
    isDetail: true,
  );
  static GalleryItem damageCalc = GalleryItem(
    name: 'damage_calc',
    titleBuilder: () => S.current.calculator,
    icon: Icons.keyboard,
    page: DamageCalcPage(),
    isDetail: true,
  );
}
