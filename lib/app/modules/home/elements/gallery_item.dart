import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/modules/creator/chara_list.dart';
import 'package:chaldea/app/modules/creator/cv_list.dart';
import 'package:chaldea/app/modules/creator/illustrator_list.dart';
import 'package:chaldea/app/modules/quest/svt_quest_timeline.dart';
import 'package:chaldea/app/routes/routes.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/basic.dart';
import '../../command_code/cmd_code_list.dart';
import '../../costume/costume_list.dart';
import '../../craft_essence/craft_list.dart';
import '../../effect_search/effect_search_page.dart';
import '../../enemy/enemy_list.dart';
import '../../event/events_page.dart';
import '../../exp/exp_card_cost_page.dart';
import '../../ffo/ffo.dart';
import '../../free_quest_calc/free_calculator_page.dart';
import '../../import_data/home_import_page.dart';
import '../../item/item_list.dart';
import '../../master_mission/master_mission_list.dart';
import '../../mystic_code/mystic_code_list.dart';
import '../../saint_quartz/sq_main.dart';
import '../../servant/servant_list.dart';
import '../../statistics/game_stat.dart';
import '../../summon/summon_list_page.dart';

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
    icon: FontAwesomeIcons.penToSquare,
    isDetail: false,
  );

  static GalleryItem done = GalleryItem(
    name: 'done',
    titleBuilder: () => '',
    icon: FontAwesomeIcons.circleCheck,
    isDetail: false,
  );

  static List<GalleryItem> get allItems => [
        servants,
        craftEssences,
        commandCodes,
        items,
        events,
        plans,
        freeCalculator,
        masterMissions,
        saintQuartz,
        mysticCodes,
        effectSearch,
        costumes,
        summons,
        ffo,
        cvList,
        illustratorList,
        charaList,
        enemyList,
        svtQuestTimeline,
        expCard,
        statistics,
        importData,
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
  static GalleryItem plans = GalleryItem(
    name: 'plans',
    titleBuilder: () => S.current.plan_title,
    icon: Icons.article_outlined,
    url: Routes.plans,
    page: ServantListPage(planMode: true),
    isDetail: false,
  );
  static GalleryItem freeCalculator = GalleryItem(
    name: 'free_calculator',
    titleBuilder: () => S.current.free_quest_calculator_short,
    icon: FontAwesomeIcons.mapLocation,
    url: Routes.freeCalc,
    page: FreeQuestCalcPage(),
    isDetail: true,
  );
  static GalleryItem masterMissions = GalleryItem(
    name: 'master_missions',
    titleBuilder: () => S.current.master_mission,
    icon: FontAwesomeIcons.listCheck,
    page: MasterMissionListPage(),
    isDetail: true,
  );
  static GalleryItem saintQuartz = GalleryItem(
    name: 'saint_quartz',
    titleBuilder: () => S.current.saint_quartz_plan,
    icon: FontAwesomeIcons.gem,
    url: Routes.sqPlan,
    page: SaintQuartzPlanning(),
    isDetail: true,
  );
  static GalleryItem mysticCodes = GalleryItem(
    name: 'mystic_codes',
    titleBuilder: () => S.current.mystic_code,
    icon: FontAwesomeIcons.personDotsFromLine,
    url: Routes.mysticCodes,
    page: MysticCodeListPage(),
    isDetail: false,
  );
  static GalleryItem effectSearch = GalleryItem(
    name: 'effect_search',
    titleBuilder: () => S.current.effect_search,
    icon: FontAwesomeIcons.searchengin,
    page: EffectSearchPage(),
    isDetail: false,
  );
  static GalleryItem costumes = GalleryItem(
    name: 'costumes',
    titleBuilder: () => S.current.costume,
    icon: FontAwesomeIcons.shirt,
    url: Routes.costumes,
    page: CostumeListPage(),
    isDetail: false,
  );
  static GalleryItem summons = GalleryItem(
    name: 'summons',
    titleBuilder: () => S.current.summon_title,
    icon: FontAwesomeIcons.dice,
    url: Routes.summons,
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
    url: Routes.cvs,
    page: CvListPage(),
    isDetail: true,
  );
  static GalleryItem illustratorList = GalleryItem(
    name: 'illustrator_list',
    titleBuilder: () => S.current.illustrator,
    icon: FontAwesomeIcons.paintbrush,
    url: Routes.illustrators,
    page: IllustratorListPage(),
    isDetail: true,
  );
  static GalleryItem charaList = GalleryItem(
    name: 'chara_list',
    titleBuilder: () => S.current.characters_in_card,
    icon: FontAwesomeIcons.personRays,
    url: Routes.characters,
    page: CharaListPage(),
    isDetail: true,
  );
  static GalleryItem enemyList = GalleryItem(
    name: 'enemy_list',
    titleBuilder: () => S.current.enemy_list,
    icon: FontAwesomeIcons.dragon,
    page: EnemyListPage(),
    isDetail: false,
  );
  static GalleryItem svtQuestTimeline = GalleryItem(
    name: 'svt_quest_timeline',
    titleBuilder: () => S.current.interlude_and_rankup,
    icon: FontAwesomeIcons.timeline,
    page: const SvtQuestTimeline(),
    isDetail: false,
  );
  static GalleryItem expCard = GalleryItem(
    name: 'exp_card',
    titleBuilder: () => S.current.exp_card_title,
    icon: FontAwesomeIcons.breadSlice,
    url: Routes.expCard,
    page: ExpCardCostPage(),
    isDetail: true,
  );
  static GalleryItem statistics = GalleryItem(
    name: 'statistics',
    titleBuilder: () => S.current.statistics_title,
    icon: Icons.analytics,
    url: Routes.stats,
    page: GameStatisticsPage(),
    isDetail: true,
  );
  static GalleryItem importData = GalleryItem(
    name: 'import_data',
    titleBuilder: () => S.current.import_data,
    icon: Icons.cloud_download,
    url: Routes.importData,
    page: ImportPageHome(),
    isDetail: false,
  );
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
