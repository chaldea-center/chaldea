import 'package:flutter/material.dart';

import 'routes.dart';

class AppRouteInformationParser extends RouteInformationParser<RouteConfiguration> {
  @override
  Future<RouteConfiguration> parseRouteInformation(RouteInformation routeInformation) async {
    // return RouteConfiguration.bootstrap(routeInformation.location);
    final uri = routeInformation.uri;
    if (uri.pathSegments.isEmpty || uri.path == Routes.home) {
      return RouteConfiguration.home();
    }
    return RouteConfiguration.fromUri(uri: uri, detail: !Routes.masterRoutes.contains(uri.path));
  }

  @override
  RouteInformation? restoreRouteInformation(RouteConfiguration configuration) {
    Uri? uri = configuration.uri;
    uri ??= configuration.url == null ? null : Uri.tryParse(configuration.url!);
    return uri != null ? RouteInformation(uri: uri) : null;
  }
}
