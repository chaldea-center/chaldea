import 'package:flutter/material.dart';

import 'routes.dart';

class AppRouteInformationParser
    extends RouteInformationParser<RouteConfiguration> {
  @override
  Future<RouteConfiguration> parseRouteInformation(
      RouteInformation routeInformation) async {
    // return RouteConfiguration.bootstrap(routeInformation.location);
    final uri = routeInformation.location == null
        ? null
        : Uri.tryParse(routeInformation.location!);
    if (uri != null) {
      if (uri.pathSegments.isEmpty || uri.path == Routes.home) {
        return RouteConfiguration.home();
      }
      return RouteConfiguration.fromUri(
          uri: uri, detail: !Routes.masterRoutes.contains(uri.path));
    }
    return RouteConfiguration.notFound(routeInformation.location);
  }

  @override
  RouteInformation? restoreRouteInformation(RouteConfiguration configuration) {
    return configuration.url != null
        ? RouteInformation(location: configuration.url)
        : null;
  }
}
