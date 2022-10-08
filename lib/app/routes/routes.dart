import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/buff/buff_list.dart';
import 'package:chaldea/app/modules/craft_essence/craft.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/creator/chara_list.dart';
import 'package:chaldea/app/modules/creator/cv_list.dart';
import 'package:chaldea/app/modules/creator/illustrator_list.dart';
import 'package:chaldea/app/modules/effect_search/effect_search_page.dart';
import 'package:chaldea/app/modules/enemy/enemy_detail.dart';
import 'package:chaldea/app/modules/enemy/enemy_list.dart';
import 'package:chaldea/app/modules/event/events_page.dart';
import 'package:chaldea/app/modules/home/bootstrap.dart';
import 'package:chaldea/app/modules/item/item.dart';
import 'package:chaldea/app/modules/item/item_list.dart';
import 'package:chaldea/app/modules/master_mission/master_mission_list.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/app/modules/servant/servant.dart';
import 'package:chaldea/app/modules/trait/trait.dart';
import 'package:chaldea/app/modules/trait/trait_list.dart';
import '../../packages/split_route/split_route.dart';
import '../../utils/extension.dart';
import '../modules/buff/buff_detail.dart';
import '../modules/command_code/cmd_code.dart';
import '../modules/command_code/cmd_code_list.dart';
import '../modules/common/not_found.dart';
import '../modules/common/splash.dart';
import '../modules/costume/costume_detail.dart';
import '../modules/costume/costume_list.dart';
import '../modules/event/event_detail_page.dart';
import '../modules/event/war/war_detail_page.dart';
import '../modules/free_quest_calc/free_calculator_page.dart';
import '../modules/func/func_detail.dart';
import '../modules/func/func_list.dart';
import '../modules/home/home.dart';
import '../modules/servant/servant_list.dart';
import '../modules/skill/skill_detail.dart';
import '../modules/skill/skill_list.dart';
import '../modules/skill/td_detail.dart';
import '../modules/skill/td_list.dart';
import '../modules/statistics/game_stat.dart';
import '../modules/summon/summon_detail_page.dart';
import '../modules/summon/summon_list_page.dart';

class Routes {
  static const String home = '/';
  static const String bootstrap = '/welcome';

  static String servantI(int id) => '/servant/$id';
  static const String servant = '/servant';
  static const String servants = '/servants';

  static String enemyI(int id) => '/enemy/$id';
  static const String enemy = '/enemy';
  static const String enemies = '/enemies';

  static String craftEssenceI(int id) => '/craft-essence/$id';
  static const String craftEssence = '/craft-essence';
  static const String craftEssences = '/craft-essences';

  static String commandCodeI(int id) => '/command-code/$id';
  static const String commandCode = '/command-code';
  static const String commandCodes = '/command-codes';

  static String mysticCodeI(int id) => '/mystic-code/$id';
  static const String mysticCode = '/mystic-code';
  static const String mysticCodes = '/mystic-codes';

  static String eventI(int id) => '/event/$id';
  static const String event = '/event';
  static const String events = '/events';

  static String warI(int id) => '/war/$id';
  static const String war = '/war';

  static String questI(int id) => '/quest/$id';
  static const String quest = '/quest';

  static String itemI(int id) => '/item/$id';
  static const String item = '/item';
  static const String items = '/items';

  static String summonI(String id) => '/summon/$id';
  static const String summon = '/summon';
  static const String summons = '/summons';

  static String costumeI(int id) => '/costume/$id';
  static const String costume = '/costume';
  static const String costumes = '/costumes';

  static String traitI(int id) => '/trait/$id';
  static const String trait = '/trait';
  static const String traits = '/traits';

  static String buffI(int id) => '/buff/$id';
  static const String buff = '/buff';
  static const String buffs = '/buffs';

  static String funcI(int id) => '/func/$id';
  static const String func = '/func';
  static const String funcs = '/funcs';

  static String skillI(int id) => '/skill/$id';
  static const String skill = '/skill';
  static const String skills = '/skills';

  static String tdI(int id) => '/noble-phantasm/$id';
  static const String td = '/noble-phantasm';
  static const String tds = '/noble-phantasms';

  static String masterMissionI(int id) => '/master-mission/$id';
  static const String masterMission = '/master-mission';
  static const String masterMissions = '/master-missions';

  static const String cvs = '/cvs';
  static const String illustrators = '/illustrators';
  static const String characters = '/characters';
  static const String plans = '/plans';
  static const String freeCalc = '/free-calc';
  static const String expCard = '/expCard';
  static const String sqPlan = '/sqPlan';
  static const String stats = '/stats';
  static const String importData = '/import_data';
  static const String scriptHome = '/scripts';
  static const String ffo = '/ffo';
  static const String effectSearch = '/effect-search';
  static const String notFound = '/404';

  static const List<String> masterRoutes = [
    home,
    servants,
    craftEssences,
    commandCodes,
    mysticCodes,
    events,
    items,
    plans,
    summons,
    traits,
    funcs,
    buffs,
    skills,
    tds,
  ];
}

class RouteConfiguration {
  final String? url;
  final Uri? uri;
  final bool? detail;
  final dynamic arguments;
  final Widget? child;

  RouteConfiguration({this.url, this.child, this.detail, this.arguments})
      : uri = url == null ? null : Uri.tryParse(url);

  RouteConfiguration.fromUri(
      {this.uri, this.child, this.detail, this.arguments})
      : url = uri.toString();

  RouteConfiguration.slash({required String nextPageUrl})
      : url = null,
        uri = null,
        detail = null,
        arguments = null,
        child = SplashPage(nextPageUrl: nextPageUrl);

  String? get path => uri?.path ?? url;

  String? get first {
    if (uri == null) return url;
    if (uri!.path.isEmpty || uri!.path == Routes.home) return Routes.home;
    return '/${uri!.pathSegments.first}';
  }

  String? get second => uri?.pathSegments.getOrNull(1);

  Map<String, String> get query => uri?.queryParameters ?? {};

  RouteConfiguration.notFound([this.arguments])
      : url = Routes.notFound,
        uri = Uri.parse(Routes.notFound),
        child = null,
        detail = null;

  RouteConfiguration.home()
      : url = Routes.home,
        uri = Uri.parse(Routes.home),
        child = null,
        arguments = null,
        detail = false;

  RouteConfiguration.bootstrap([String? next])
      : url = Routes.bootstrap,
        uri = Uri.parse(Routes.bootstrap),
        child = BootstrapPage(),
        arguments = null,
        detail = null;

  SplitPage createPage() {
    return SplitPage(
      child: resolvedChild ?? NotFoundPage(configuration: this),
      detail: detail ?? !Routes.masterRoutes.contains(url),
      name: url,
      arguments: this,
      key: UniqueKey(),
    );
  }

  @override
  String toString() {
    return '$runtimeType(url=$url, detail=$detail)';
  }

  RouteConfiguration copyWith({
    String? url,
    Widget? child,
    bool? detail,
    dynamic arguments,
  }) {
    return RouteConfiguration(
      url: url ?? this.url,
      child: child ?? this.child,
      detail: detail ?? this.detail,
      arguments: arguments ?? this.arguments,
    );
  }

  Widget? get resolvedChild {
    if (child != null) return child!;
    int? _secondInt = second == null ? null : int.tryParse(second!);
    switch (first) {
      case Routes.home:
        return HomePage();
      case Routes.notFound:
        return NotFoundPage(configuration: this);
      case Routes.servants:
        return ServantListPage();
      case Routes.servant:
        return ServantDetailPage(id: _secondInt);
      case Routes.enemies:
        return EnemyListPage();
      case Routes.enemy:
        if (_secondInt == null) break;
        return EnemyDetailPage(id: _secondInt);
      case Routes.plans:
        return ServantListPage(planMode: true);
      case Routes.craftEssences:
        return CraftListPage();
      case Routes.craftEssence:
        return CraftDetailPage(id: _secondInt);
      case Routes.commandCodes:
        return CmdCodeListPage();
      case Routes.commandCode:
        return CmdCodeDetailPage(id: _secondInt);
      case Routes.mysticCodes:
        return MysticCodeListPage();
      case Routes.mysticCode:
        return MysticCodePage(id: _secondInt);
      case Routes.events:
        return EventListPage();
      case Routes.war:
        return WarDetailPage(warId: _secondInt);
      case Routes.event:
        return EventDetailPage(eventId: _secondInt);
      case Routes.items:
        return ItemListPage();
      case Routes.item:
        return ItemDetailPage(itemId: _secondInt ?? 0);
      case Routes.quest:
        return QuestDetailPage(id: _secondInt);
      case Routes.summons:
        return SummonListPage();
      case Routes.summon:
        return SummonDetailPage(id: second);
      case Routes.costumes:
        return CostumeListPage();
      case Routes.costume:
        return CostumeDetailPage(id: _secondInt);
      case Routes.freeCalc:
        return FreeQuestCalcPage();
      case Routes.cvs:
        return CvListPage();
      case Routes.illustrators:
        return IllustratorListPage();
      case Routes.characters:
        return CharaListPage();
      case Routes.stats:
        return GameStatisticsPage();
      case Routes.traits:
        return const TraitListPage();
      case Routes.trait:
        return TraitDetailPage(id: _secondInt ?? 0);
      case Routes.funcs:
        return const FuncListPage();
      case Routes.func:
        return FuncDetailPage(id: _secondInt);
      case Routes.buffs:
        return const BuffListPage();
      case Routes.buff:
        return BuffDetailPage(id: _secondInt);
      case Routes.masterMissions:
        return MasterMissionListPage();
      case Routes.effectSearch:
        return EffectSearchPage();
      case Routes.skills:
        return const SkillListPage();
      case Routes.skill:
        return SkillDetailPage(id: _secondInt);
      case Routes.tds:
        return const TdListPage();
      case Routes.td:
        return TdDetailPage(id: _secondInt);
    }
    return null;
  }
}

class SplitPage extends MaterialPage {
  final bool? detail;

  const SplitPage({
    required Widget child,
    this.detail,
    bool maintainState = true,
    bool fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          child: child,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  @override
  Route createRoute(BuildContext context) {
    return SplitRoute(
      settings: this,
      builder: (context, _) => child,
      detail: detail,
      // masterRatio: _kSplitMasterRatio,
      opaque: detail != true,
      maintainState: maintainState,
      // this.title,
      fullscreenDialog: fullscreenDialog,
    );
  }

  @override
  String toString() {
    return '$runtimeType("$name", $key, $arguments, ${child.runtimeType})';
  }
}
