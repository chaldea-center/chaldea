import 'package:chaldea/components/components.dart' hide showDialog;
import 'package:flutter/material.dart' as material;

/// Some convenient extensions on build-in classes

/// This widget should not have any dependency of outer [context]
extension DialogShowMethod on Widget {
  /// Don't use this when dialog children depends on [context]
  Future<T?> showDialog<T>(BuildContext? context,
      {bool barrierDismissible = true}) {
    context ??= kAppKey.currentContext;
    if (context == null) return Future.value();
    return material.showDialog<T>(
      context: context,
      builder: (context) => this,
      barrierDismissible: barrierDismissible,
    );
  }
}

extension SafeSetState<T extends StatefulWidget> on State<T> {
  void safeSetState() {
    if (mounted) {
      setState(() {}); //ignore: invalid_use_of_protected_member
    }
  }
}
