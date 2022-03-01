import 'package:chaldea/app/routes/routes.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../command_code/cmd_code_list.dart';
import '../../craft_essence/craft_list.dart';
import '../../event/events_page.dart';
import '../../item/item_list.dart';
import '../../servant/servant_list.dart';

class GalleryItem {
  // instant part
  final String name;
  final String Function()? titleBuilder;
  final IconData? icon;
  final Widget? child;

  // final SplitPageBuilder? builder;
  final String? url;
  final Widget? page;
  final bool isDetail;

  const GalleryItem({
    required this.name,
    required this.titleBuilder,
    this.icon,
    this.child,
    this.url,
    this.page,
    required this.isDetail,
  }) : assert(icon != null || child != null);

  Widget buildIcon(BuildContext context, {double size = 40, Color? color}) {
    if (child != null) return child!;
    bool fa = icon!.fontFamily?.toLowerCase().startsWith('fontawesome') == true;
    final _iconColor = color ??
        (Utility.isDarkMode(context)
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.secondary);
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

  static List<GalleryItem> get persistentPages => [
        /*more*/
      ];
  static GalleryItem edit = GalleryItem(
    name: 'edit',
    titleBuilder: () => '',
    icon: FontAwesomeIcons.edit,
    isDetail: false,
  );

  static GalleryItem done = GalleryItem(
    name: 'done',
    titleBuilder: () => '',
    icon: FontAwesomeIcons.checkCircle,
    isDetail: false,
  );

  static List<GalleryItem> get allItems => [
        servants,
        craftEssences,
        commandCodes,
        items,
        events,
        // plan,
        // freeCalculator,
        // masterMission,
        // saintQuartz,
        // mysticCode,
        // effectSearch,
        // costume,
        // gacha,
        // ffo,
        // cvList,
        // illustratorList,
        // enemyList,
        // expCard,
        // statistics,
        // importData,
        // faq,
        // if (kDebugMode) ...[lostRoom, palette],
        // more,
        // // unpublished
        // _apCal,
        // _damageCalc,
      ];

  static GalleryItem servants = GalleryItem(
    name: 'servants',
    titleBuilder: () => S.current.servant_title,
    icon: FontAwesomeIcons.users,
    url: Routes.servants,
    page: ServantListPage(),
    isDetail: false,
  );
  static GalleryItem craftEssences = GalleryItem(
    name: 'crafts',
    titleBuilder: () => S.current.craft_essence,
    icon: FontAwesomeIcons.streetView,
    url: Routes.craftEssences,
    page: CraftListPage(),
    isDetail: false,
  );
  static GalleryItem commandCodes = GalleryItem(
    name: 'cmd_codes',
    titleBuilder: () => S.current.command_code,
    icon: FontAwesomeIcons.expand,
    url: Routes.commandCodes,
    page: CmdCodeListPage(),
    isDetail: false,
  );
  static GalleryItem items = GalleryItem(
    name: 'items',
    titleBuilder: () => S.current.item_title,
    icon: Icons.category,
    url: Routes.items,
    page: ItemListPage(),
    isDetail: false,
  );
  static GalleryItem events = GalleryItem(
    name: 'events',
    titleBuilder: () => S.current.event_title,
    icon: Icons.flag,
    url: Routes.events,
    page: EventListPage(),
    isDetail: false,
  );
// static GalleryItem plan = GalleryItem(
//   name: 'plan',
//   titleBuilder: () => S.current.plan_title,
//   icon: Icons.article_outlined,
//   page: ServantListPage(planMode: true),
//   isDetail: false,
// );
// static GalleryItem freeCalculator = GalleryItem(
//   name: 'free_calculator',
//   titleBuilder: () => S.current.free_quest_calculator_short,
//   icon: FontAwesomeIcons.mapMarked,
//   page: FreeQuestCalculatorPage(),
//   isDetail: true,
// );
// static GalleryItem masterMission = GalleryItem(
//   name: 'master_mission',
//   titleBuilder: () => S.current.master_mission,
//   icon: FontAwesomeIcons.tasks,
//   page: MasterMissionPage(),
//   isDetail: true,
// );
// static GalleryItem saintQuartz = GalleryItem(
//   name: 'saint_quartz',
//   titleBuilder: () => Item.lNameOf(Items.quartz),
//   icon: FontAwesomeIcons.gem,
//   page: SaintQuartzPlanning(),
//   isDetail: true,
// );
// static GalleryItem mysticCode = GalleryItem(
//   name: 'mystic_code',
//   titleBuilder: () => S.current.mystic_code,
//   icon: FontAwesomeIcons.diagnoses,
//   page: MysticCodePage(),
//   isDetail: true,
// );
// static GalleryItem effectSearch = GalleryItem(
//   name: 'effect_search',
//   titleBuilder: () => S.current.effect_search,
//   icon: FontAwesomeIcons.searchengin,
//   page: EffectSearchPage(),
//   isDetail: false,
// );
// static GalleryItem costume = GalleryItem(
//   name: 'costume',
//   titleBuilder: () => S.current.costume,
//   icon: FontAwesomeIcons.tshirt,
//   page: CostumeListPage(),
//   isDetail: false,
// );
// static GalleryItem gacha = GalleryItem(
//   name: 'gacha',
//   titleBuilder: () => S.current.summon_title,
//   icon: FontAwesomeIcons.dice,
//   page: SummonListPage(),
//   isDetail: false,
// );
// static GalleryItem ffo = GalleryItem(
//   name: 'ffo',
//   titleBuilder: () => 'Freedom Order',
//   icon: FontAwesomeIcons.layerGroup,
//   page: FreedomOrderPage(),
//   isDetail: true,
// );
// static GalleryItem cvList = GalleryItem(
//   name: 'cv_list',
//   titleBuilder: () => S.current.info_cv,
//   icon: Icons.keyboard_voice,
//   page: CvListPage(),
//   isDetail: true,
// );
// static GalleryItem illustratorList = GalleryItem(
//   name: 'illustrator_list',
//   titleBuilder: () => S.current.illustrator,
//   icon: FontAwesomeIcons.paintBrush,
//   page: IllustratorListPage(),
//   isDetail: true,
// );
// static GalleryItem enemyList = GalleryItem(
//   name: 'enemy_list',
//   titleBuilder: () => S.current.enemy_list,
//   icon: FontAwesomeIcons.dragon,
//   page: EnemyListPage(),
//   isDetail: false,
// );
// static GalleryItem expCard = GalleryItem(
//   name: 'exp_card',
//   titleBuilder: () => S.current.exp_card_title,
//   icon: FontAwesomeIcons.breadSlice,
//   page: ExpCardCostPage(),
//   isDetail: true,
// );
// static GalleryItem statistics = GalleryItem(
//   name: 'statistics',
//   titleBuilder: () => S.current.statistics_title,
//   icon: Icons.analytics,
//   page: GameStatisticsPage(),
//   isDetail: true,
// );
// static GalleryItem importData = GalleryItem(
//   name: 'import_data',
//   titleBuilder: () => S.current.import_data,
//   icon: Icons.cloud_download,
//   page: ImportPageHome(),
//   isDetail: false,
// );
// static GalleryItem faq = GalleryItem(
//   name: 'faq',
//   titleBuilder: () => 'FAQ',
//   icon: Icons.help_center,
//   page: FAQPage(),
//   isDetail: true,
// );
// static GalleryItem lostRoom = GalleryItem(
//   name: 'lost_room',
//   titleBuilder: () => 'LOSTROOM',
//   icon: FontAwesomeIcons.ghost,
//   page: LostRoomPage(),
//   isDetail: false,
// );
// static GalleryItem more = GalleryItem(
//   name: 'more',
//   titleBuilder: () => S.current.more,
//   icon: Icons.add,
//   page: EditGalleryPage(),
//   isDetail: true,
// );

  /// debug only
// static GalleryItem palette = GalleryItem(
//   name: 'palette',
//   titleBuilder: () => 'Palette',
//   icon: Icons.palette_outlined,
//   page: DarkLightThemePalette(),
//   isDetail: true,
// );

  /// unpublished pages
// static GalleryItem apCal = GalleryItem(
//   name: 'ap_cal',
//   titleBuilder: () => S.current.ap_calc_title,
//   icon: Icons.directions_run,
//   page: APCalcPage(),
//   isDetail: true,
// );
// static GalleryItem damageCalc = GalleryItem(
//   name: 'damage_calc',
//   titleBuilder: () => S.current.calculator,
//   icon: Icons.keyboard,
//   page: DamageCalcPage(),
//   isDetail: true,
// );
}
