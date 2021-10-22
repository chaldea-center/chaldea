import 'package:flutter/material.dart';

class Route404Page extends StatelessWidget {
  final RouteSettings settings;

  const Route404Page({Key? key, required this.settings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '${settings.name}\n\n404 Not Found',
          style: Theme.of(context).textTheme.headline3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
