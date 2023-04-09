import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<T> showUserConfirm<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
  bool allowNull = false,
  String? action,
}) async {
  final result = await showDialog<T>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return WillPopScope(
        child: builder(context),
        onWillPop: () => SynchronousFuture(barrierDismissible),
      );
    },
  );
  if (result == null && !allowNull) {
    throw InvalidUserAction(action ?? 'showUserConfirm', 'Cannot be null. Required type:$T');
  }
  return result as T;
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
