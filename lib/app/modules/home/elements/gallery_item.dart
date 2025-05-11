import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/modules/creator/chara_list.dart';
import 'package:chaldea/app/modules/creator/cv_list.dart';
import 'package:chaldea/app/modules/creator/illustrator_list.dart';
import 'package:chaldea/app/modules/enemy_master/enemy_master_list.dart';
import 'package:chaldea/app/modules/quest/svt_quest_timeline.dart';
import 'package:chaldea/app/modules/script/reader_entry.dart';
import 'package:chaldea/app/modules/svt_class/svt_class_list.dart';
import 'package:chaldea/app/modules/tools/bond_bonus.dart';
import 'package:chaldea/app/modules/tools/myroom_assets_page.dart';
import 'package:chaldea/app/modules/tools/tool_list_page.dart';
import 'package:chaldea/app/modules/trait/trait_list.dart';
import 'package:chaldea/app/modules/war/wars_page.dart';
import 'package:chaldea/app/routes/routes.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/widgets/theme.dart';
import '../../april_fool/april_fool_home.dart';
import '../../bgm/bgm_list.dart';
import '../../buff/buff_list.dart';
import '../../charge/np_charge_page.dart';
import '../../class_board/class_board_list_page.dart';
import '../../command_code/cmd_code_list.dart';
import '../../costume/costume_list.dart';
import '../../craft_essence/craft_list.dart';
import '../../effect_search/effect_search_page.dart';
import '../../enemy/enemy_list.dart';
import '../../event/events_page.dart';
import '../../exp/exp_card_cost_page.dart';
import '../../faker/accounts.dart';
import '../../ffo/ffo.dart';
import '../../free_quest_calc/free_calculator_page.dart';
import '../../func/func_list.dart';
import '../../import_data/home_import_page.dart';
import '../../item/item_list.dart';
import '../../master_mission/master_mission_list.dart';
import '../../mc/mc_home.dart';
import '../../misc/apk_list.dart';
import '../../misc/app_route_entrance.dart';
import '../../mystic_code/mystic_code_list.dart';
import '../../saint_quartz/sq_main.dart';
import '../../servant/servant_list.dart';
import '../../shop/shop_list.dart';
import '../../skill/skill_list.dart';
import '../../skill/td_list.dart';
import '../../statistics/game_stat.dart';
import '../../summon/summon_list_page.dart';
import '../lost_room.dart';

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
  final bool shownDefault;
  final bool persist;

  const GalleryItem({
    required this.name,
    required this.titleBuilder,
    this.icon,
    this.child,
    this.url,
    this.page,
    required this.isDetail,
    this.shownDefault = true,
    this.persist = false,
  }) : assert(icon != null || child != null);

  Widget buildIcon(BuildContext context, {double size = 40, Color? color}) {
    if (child != null) return child!;
    bool fa = icon!.fontFamily?.toLowerCase().startsWith('fontawesome') == true;
    var _iconColor =
        color ?? (Theme.of(context).useMaterial3 ? Theme.of(context).colorScheme.primary : AppTheme(context).tertiary);
    return fa
        ? Padding(padding: EdgeInsets.all(size * 0.05), child: FaIcon(icon, size: size * 0.9, color: _iconColor))
        : Icon(icon, size: size, color: _iconColor);
  }

  @override
  String toString() {
    return 'GalleryItem($name)';
  }

  static List<GalleryItem> get persistentPages => [
    /*more*/
  ];
  static GalleryItem edit = GalleryItem(
    name: 'edit',
    titleBuilder: () => '',
    icon: FontAwesomeIcons.penToSquare,
    isDetail: false,
    persist: true,
  );

  static GalleryItem done = GalleryItem(
    name: 'done',
    titleBuilder: () => '',
    icon: FontAwesomeIcons.circleCheck,
    isDetail: false,
    persist: true,
  );

  static List<GalleryItem> get allItems => [
    servants,
    craftEssences,
    commandCodes,
    items,
    events,
    wars,
    plans,
    freeCalculator,
    masterMissions,
    classBoards,
    saintQuartz,
    mysticCodes,
    effectSearch,
    costumes,
    summons,
    enemyList,
    expCard,
    npCharge,
    bondBonus,
    statistics,
    if (!kIsWeb && AppInfo.isDebugOn) fakeGrandOrder,
    importData,
    if (!db.settings.hideApple) apk,
    // default hide
    shops,
    scriptHome,
    bgms,
    // ffo,
    aprilFool,
    cvList,
    illustratorList,
    charaList,
    svtQuestTimeline,
    svtClass,
    traits,
    skills,
    tds,
    funcs,
    buffs,
    enemyMasters,
    myRoom,
    appRoutes,
    // mooncell,
    toolbox,
  ];

  static GalleryItem servants = GalleryItem(
    name: 'servants',
    titleBuilder: () => S.current.servant,
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
    titleBuilder: () => S.current.item,
    icon: Icons.category,
    url: Routes.items,
    page: ItemListPage(),
    isDetail: false,
  );
  static GalleryItem events = GalleryItem(
    name: 'events',
    titleBuilder: () => S.current.event,
    icon: Icons.flag,
    url: Routes.events,
    page: EventListPage(),
    isDetail: false,
  );
  static GalleryItem wars = GalleryItem(
    name: 'wars',
    titleBuilder: () => S.current.war,
    icon: FontAwesomeIcons.flagCheckered,
    url: Routes.wars,
    page: const WarsPage(),
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
    url: Routes.masterMissions,
    page: MasterMissionListPage(),
    isDetail: true,
  );
  static GalleryItem classBoards = GalleryItem(
    name: 'class_boards',
    titleBuilder: () => S.current.class_board,
    icon: FontAwesomeIcons.starOfDavid,
    url: Routes.classBoards,
    page: ClassBoardListPage(),
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
    url: Routes.effectSearch,
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
    titleBuilder: () => S.current.summon_banner,
    icon: FontAwesomeIcons.dice,
    url: Routes.summons,
    page: SummonListPage(),
    isDetail: false,
  );
  static GalleryItem enemyList = GalleryItem(
    name: 'enemy_list',
    titleBuilder: () => S.current.enemy_list,
    icon: FontAwesomeIcons.dragon,
    url: Routes.enemies,
    page: EnemyListPage(),
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
  static GalleryItem npCharge = GalleryItem(
    name: 'np_charge',
    titleBuilder: () => S.current.np_charge,
    icon: FontAwesomeIcons.batteryHalf,
    page: const NpChargePage(),
    isDetail: false,
  );
  static GalleryItem bondBonus = GalleryItem(
    name: 'bond_bonus',
    titleBuilder: () => S.current.bond_bonus,
    icon: FontAwesomeIcons.diamond,
    page: const BondBonusPage(),
    isDetail: false,
  );
  static GalleryItem statistics = GalleryItem(
    name: 'statistics',
    titleBuilder: () => S.current.statistics_title,
    icon: Icons.analytics,
    url: Routes.stats,
    page: GameStatisticsPage(),
    isDetail: true,
  );
  static GalleryItem fakeGrandOrder = GalleryItem(
    name: 'fake_grand_order',
    titleBuilder: () => 'Faker',
    icon: FontAwesomeIcons.fishFins,
    url: null,
    page: const FakerAccountsPage(),
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
  static GalleryItem lostRoom = GalleryItem(
    name: 'lost_room',
    titleBuilder: () => 'LOSTROOM',
    icon: FontAwesomeIcons.unity, // atom
    page: const LostRoomPage(),
    isDetail: false,
    persist: true,
  );
  static GalleryItem apk = GalleryItem(
    name: 'apk',
    titleBuilder: () => db.settings.hideApple ? 'App' : 'APK',
    icon: FontAwesomeIcons.android,
    url: Routes.apk,
    page: const ApkListPage(),
    isDetail: true,
    shownDefault: !PlatformU.isApple,
  );
  // show in Lost Room
  static GalleryItem shops = GalleryItem(
    name: 'shops',
    titleBuilder: () => S.current.shop,
    icon: FontAwesomeIcons.shop,
    url: Routes.shopHome,
    page: const ShopListHome(),
    isDetail: true,
    shownDefault: false,
  );
  static GalleryItem scriptHome = GalleryItem(
    name: 'script_home',
    titleBuilder: () => S.current.script_story,
    icon: FontAwesomeIcons.book,
    url: Routes.scriptHome,
    page: const ScriptReaderEntryPage(),
    isDetail: true,
    shownDefault: false,
  );
  static GalleryItem bgms = GalleryItem(
    name: 'bgms',
    titleBuilder: () => S.current.bgm,
    icon: FontAwesomeIcons.music,
    url: Routes.bgms,
    page: BgmListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem ffo = GalleryItem(
    name: 'ffo',
    titleBuilder: () => 'Freedom Order',
    icon: FontAwesomeIcons.layerGroup,
    url: Routes.ffo,
    page: FreedomOrderPage(),
    isDetail: true,
    shownDefault: false,
  );
  static GalleryItem aprilFool = GalleryItem(
    name: 'april-fool',
    titleBuilder: () => S.current.april_fool,
    icon: FontAwesomeIcons.hatWizard,
    url: Routes.aprilFool,
    page: const AprilFoolHome(),
    isDetail: true,
    shownDefault: false,
  );
  static GalleryItem cvList = GalleryItem(
    name: 'cv_list',
    titleBuilder: () => S.current.info_cv,
    icon: Icons.keyboard_voice,
    url: Routes.cvs,
    page: CvListPage(),
    isDetail: true,
    shownDefault: false,
  );
  static GalleryItem illustratorList = GalleryItem(
    name: 'illustrator_list',
    titleBuilder: () => S.current.illustrator,
    icon: FontAwesomeIcons.paintbrush,
    url: Routes.illustrators,
    page: IllustratorListPage(),
    isDetail: true,
    shownDefault: false,
  );
  static GalleryItem charaList = GalleryItem(
    name: 'chara_list',
    titleBuilder: () => S.current.characters_in_card,
    icon: FontAwesomeIcons.personRays,
    url: Routes.characters,
    page: CharaListPage(),
    isDetail: true,
    shownDefault: false,
  );
  static GalleryItem enemyMasters = GalleryItem(
    name: 'enemy_masters',
    titleBuilder: () => S.current.enemy_master,
    icon: FontAwesomeIcons.userSecret,
    url: Routes.enemyMasters,
    page: const EnemyMasterListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem svtQuestTimeline = GalleryItem(
    name: 'svt_quest_timeline',
    titleBuilder: () => S.current.interlude_and_rankup,
    icon: FontAwesomeIcons.timeline,
    page: const SvtQuestTimeline(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem svtClass = GalleryItem(
    name: 'svt_class',
    titleBuilder: () => S.current.svt_class,
    icon: FontAwesomeIcons.chessKing,
    url: Routes.svtClasses,
    page: const SvtClassListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem traits = GalleryItem(
    name: 'traits',
    titleBuilder: () => S.current.trait,
    icon: FontAwesomeIcons.diceD20,
    url: Routes.traits,
    page: TraitListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem skills = GalleryItem(
    name: 'skills',
    titleBuilder: () => S.current.skill,
    icon: FontAwesomeIcons.s,
    url: Routes.skills,
    page: const SkillListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem tds = GalleryItem(
    name: 'tds',
    titleBuilder: () => S.current.noble_phantasm,
    icon: FontAwesomeIcons.n,
    url: Routes.tds,
    page: const TdListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem funcs = GalleryItem(
    name: 'funcs',
    titleBuilder: () => 'Functions',
    icon: FontAwesomeIcons.f, // FontAwesomeIcons.hurricane
    url: Routes.funcs,
    page: const FuncListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem buffs = GalleryItem(
    name: 'buffs',
    titleBuilder: () => 'Buffs',
    icon: FontAwesomeIcons.b, // FontAwesomeIcons.fire
    url: Routes.buffs,
    page: const BuffListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem myRoom = GalleryItem(
    name: 'myroom',
    titleBuilder: () => S.current.my_room,
    icon: FontAwesomeIcons.bedPulse,
    url: Routes.myroom,
    page: const MyRoomAssetsPage(),
    isDetail: true,
    shownDefault: false,
  );

  static GalleryItem appRoutes = GalleryItem(
    name: 'app_routes',
    titleBuilder: () => 'Routes',
    icon: FontAwesomeIcons.route,
    url: Routes.routes,
    page: const AppRouteEntrancePage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem toolbox = GalleryItem(
    name: 'toolbox',
    titleBuilder: () => 'Tools',
    url: null,
    icon: FontAwesomeIcons.toolbox,
    page: const ToolListPage(),
    isDetail: false,
    shownDefault: false,
  );
  static GalleryItem mooncell = GalleryItem(
    name: 'Mooncell',
    titleBuilder: () => 'Mooncell',
    url: null,
    icon: FontAwesomeIcons.cube,
    page: const MooncellToolsPage(),
    isDetail: true,
    shownDefault: false,
  );
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
