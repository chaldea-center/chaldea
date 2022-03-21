// ignore_for_file: unused_element, unused_import
import 'package:chaldea/app/app.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:flutter/material.dart';

import 'models/models.dart';

void testFunction([BuildContext? context]) async {
  final limiter = RateLimiter();
  final start = DateTime.now();
  final futures =
      List.generate(100, (index) => limiter.limited(() => _run(start, index)));
  await Future.wait(futures);
  print('all finished: ${DateTime.now().difference(start).inMilliseconds} ms');
}

Future _run(DateTime start, int id) async {
  print('$id start: ${DateTime.now().difference(start).inMilliseconds} ms');
  await Future.delayed(const Duration(milliseconds: 1500));
  print('$id ended: ${DateTime.now().difference(start).inMilliseconds} ms');
}
