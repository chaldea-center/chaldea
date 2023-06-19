import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<T> showUserConfirm<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, Completer<T> completer) builder,
  bool barrierDismissible = false,
  bool allowNull = false,
  String? action,
}) async {
  final completer = Completer<T>();
  showDialog<T>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return WillPopScope(
        child: builder(context, completer),
        onWillPop: () => SynchronousFuture(barrierDismissible),
      );
    },
  ).then((result) {
    if (completer.isCompleted) return;
    if (result == null && !allowNull) {
      completer.completeError(InvalidUserAction(action ?? 'showUserConfirm', 'Cannot be null. Required type:$T'));
    } else {
      completer.complete(result as T);
    }
  }).catchError((e, s) {
    if (!completer.isCompleted) {
      completer.completeError(e);
    }
  });
  return completer.future;
}

class InvalidUserAction implements Exception {
  final String action;
  final String message;
  const InvalidUserAction(this.action, this.message);

  @override
  String toString() {
    return 'InvalidUserAction($action, $message)';
  }
}
