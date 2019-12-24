import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'datatypes/datatypes.dart';
import 'utils.dart' show showToast;

class GLPKSolver {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  bool solverReady;

  GLPKSolver();

  /// must call [dispose]!!!
  void dispose() {
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.dispose();
  }

  Future<bool> initial() async {
    // should only load once
    print('load js libs...');
    try {
      if (solverReady == true) {
        print('closing...');
        await flutterWebViewPlugin.close();
      }
      solverReady = false;
      final t0 = DateTime.now();
      print('launching...');
      await flutterWebViewPlugin.launch(
        Uri.dataFromString(
            '<html><body><h3>Logs:</h3><div id="logs"></div></body></html>',
            mimeType: 'text/html',
            parameters: {'charset': 'utf-8'}).toString(),
        hidden: true,
      );
      print('eval glpk...');
      await flutterWebViewPlugin
          .evalJavascript(await rootBundle.loadString('res/lib/glpk.min.js'));
      print('eval solver func...');
      await flutterWebViewPlugin
          .evalJavascript(await rootBundle.loadString('res/lib/solver.js'));
      print('eval log...');
      await flutterWebViewPlugin.evalJavascript(
          '''add_log(`${DateTime.now().toString()}: Load libs finished.`)''');
      solverReady = true;
      print('=========load libs finish:'
          ' ${DateTime.now().difference(t0).inMilliseconds / 1000} sec.=========');
      return true;
    } catch (e, s) {
      print('initial js error:\n$e\n-----statck----\n$s');
      FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: s));
      showToast('ERROR: fail to initial solver.\n$e');
      return false;
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
