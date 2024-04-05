import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/db.dart';

class _NetworkStat {
  List<ConnectivityResult>? _connectivity;
  List<ConnectivityResult>? get connectivity => _connectivity;

  bool get available =>
      db.settings.forceOnline || (_connectivity != null && _connectivity!.any((e) => e != ConnectivityResult.none));

  bool get unavailable => !available;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> init() async {
    await check();
    _subscription?.cancel();
    _subscription = Connectivity().onConnectivityChanged.asBroadcastStream().listen((result) {
      _connectivity = result.toList();
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<List<ConnectivityResult>> check() async {
    return _connectivity = await Connectivity().checkConnectivity();
  }
}

final network = _NetworkStat();

bool get hasNetwork => network.available;
