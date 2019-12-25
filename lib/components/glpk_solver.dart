import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'datatypes/datatypes.dart';
import 'utils.dart' show showToast;

class GLPKSolver {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  StreamSubscription<WebViewStateChanged> onStateChange;
  bool solverReady;

  GLPKSolver() {
    onStateChange =
        flutterWebViewPlugin.onStateChanged.listen((state) async {});
  }

  /// must call [dispose]!!!
  void dispose() {
    onStateChange.cancel();
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.dispose();
  }

  Future<Null> initial({VoidCallback callback}) async {
    // only load once
    // use callback to setState, not Future.
    print('=========loading js libs=========');
    try {
      if (solverReady == true) {
        print('closing...');
        onStateChange?.cancel();
        await flutterWebViewPlugin.close();
      }
      solverReady = false;
      print('launching...');
      onStateChange = flutterWebViewPlugin.onStateChanged.listen((state) async {
        print('state changed: ${state.type}');
        if (state.type == WebViewState.finishLoad && solverReady != true) {
          print('eval glpk...');
          await flutterWebViewPlugin.evalJavascript(
              await rootBundle.loadString('res/lib/glpk.min.js'));
          print('eval solver func...');
          await flutterWebViewPlugin
              .evalJavascript(await rootBundle.loadString('res/lib/solver.js'));
          print('eval log...');
          await flutterWebViewPlugin.evalJavascript(
              '''add_log(`${DateTime.now().toString()}: Load libs finished.`)''');
          await flutterWebViewPlugin.evalJavascript(
              '''add_log(`${DateTime.now().toString()}: Load libs finished.`)''');
          solverReady = true;
          print('=========js libs loaded.=========');
          if (callback != null) {
            callback();
          }
        }
      });
      await flutterWebViewPlugin.launch(
        Uri.dataFromString(
            '''<html><body><h3>Logs:</h3><div id="logs"></div></body></html>''',
            mimeType: 'text/html',
            parameters: {'charset': 'utf-8'}).toString(),
        hidden: true,
      );
    } catch (e, s) {
      print('initial js error:\n$e\n-----statck----\n$s');
      FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: s));
      showToast('ERROR: fail to initial solver.\n$e');
    }
  }

  Future<GLPKSolution> calculate({GLPKData data, GLPKParams params}) async {
    assert(data != null && params != null);
    GLPKSolution solution;
    try {
      if (solverReady != true) {
        await initial();
      }
      print('solveing...\nparams="${json.encode(params)}"');
      final String resultString = await flutterWebViewPlugin.evalJavascript(
          '''solve_glpk( `${json.encode(data)}`,`${json.encode(params)}`);''');
      if (resultString == null) {
        throw 'evalJavascript return null!';
      }
      solution = GLPKSolution.fromJson(Map.from(json.decode(resultString)));
      solution.sortByValue();
      print('result: ${json.encode(solution)}');
      await flutterWebViewPlugin.evalJavascript(
          '''add_log(`${DateTime.now().toString()}: solve result: ${json.encode(solution)}`)''');
    } catch (e, s) {
      showToast('ERROR: failt to execute GLPK solver:\n$e');
      FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: s));
    }
    return solution;
  }
}
