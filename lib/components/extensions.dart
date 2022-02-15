import 'package:chaldea/components/components.dart' hide showDialog;

/// Some convenient extensions on build-in classes

extension SafeSetState<T extends StatefulWidget> on State<T> {
  void safeSetState() {
    if (mounted) {
      setState(() {}); //ignore: invalid_use_of_protected_member
    }
  }
}
