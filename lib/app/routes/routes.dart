import 'package:chaldea/app/modules/craft_essence/craft.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/event/events_page.dart';
import 'package:chaldea/app/modules/home/bootstrap.dart';
import 'package:chaldea/app/modules/item/item.dart';
import 'package:chaldea/app/modules/item/item_list.dart';
import 'package:chaldea/app/modules/servant/servant.dart';
import 'package:flutter/material.dart';

import '../../packages/split_route/split_route.dart';
import '../../utils/extension.dart';
import '../modules/common/not_found.dart';
import '../modules/common/splash.dart';
import '../modules/event/detail/limit_event_detail_page.dart';
import '../modules/event/detail/war_detail_page.dart';
import '../modules/home/home.dart';
import '../modules/servant/servant_list.dart';

class Routes {
  static const String home = '/';
  static const String bootstrap = '/welcome';
  static const String servants = '/servants';
  static const String servant = '/servant';
  static String servantI(int id) => '/servant/$id';
  static const String craftEssences = '/craft-essences';
  static const String craftEssence = '/craft-essence';
  static const String commandCodes = '/command-codes';
  static const String commandCode = '/command-code';
  static String commandCodeI(int id) => '/command-code/$id';
  static const String mysticCodes = '/mystic-codes';

  // static const String mystic_code = '/mystic-code';
  static const String events = '/events';
  static const String event = '/event';
  static String eventI(int id) => '/event/$id';
  static const String war = '/war';
  static String warI(int id) => '/war/$id';
  static const String items = '/items';
  static const String item = '/item';
  static String itemI(int id) => '/item/$id';
  static const String plans = '/plans';
  static const String freeCalc = '/free-calc';
  static const String masterMission = '/master-mission';
  static const String summons = '/summons';
  static const String summon = '/summon';
  static const String stats = '/stats';
  static const String notFound = '/404';

  static const List<String> masterRoutes = [
    home,
    servants,
    craftEssences,
    commandCodes,
    events,
    items,
    plans,
    summons,
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
    return '/' + uri!.pathSegments.first;
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
      case Routes.plans:
        break;
      case Routes.craftEssences:
        return CraftListPage();
      case Routes.craftEssence:
        return CraftDetailPage(id: _secondInt);
      case Routes.commandCodes:
        break;
      case Routes.mysticCodes:
        break;
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
      case Routes.summons:
        break;
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
