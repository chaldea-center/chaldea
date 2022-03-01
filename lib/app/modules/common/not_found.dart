import 'package:flutter/material.dart';

import '../../routes/routes.dart';

class NotFoundPage extends StatelessWidget {
  final String? title;
  final String? url;
  final RouteConfiguration? configuration;

  const NotFoundPage({Key? key, this.title, this.url, this.configuration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? '404'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '${url ?? configuration?.url}\n\nWhy you got here?',
          style: Theme.of(context).textTheme.headline3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
