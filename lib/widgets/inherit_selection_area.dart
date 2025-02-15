import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InheritSelectionArea extends StatelessWidget {
  final Widget child;
  final TextSelectionControls? selectionControls;
  final FocusNode? focusNode;
  final bool inherit;

  const InheritSelectionArea({
    super.key,
    required this.child,
    this.selectionControls,
    this.focusNode,
    this.inherit = true,
  });

  @override
  Widget build(BuildContext context) {
    TextSelectionControls? parentControls = of(context);
    if (selectionControls != null) {
      return inherit && selectionControls == parentControls ? child : wrap(selectionControls!);
    }
    if (parentControls != null) {
      return inherit ? child : wrap(parentControls);
    }
    TextSelectionControls? controls;
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        controls ??= materialTextSelectionControls;
        break;
      case TargetPlatform.iOS:
        controls ??= cupertinoTextSelectionControls;
        break;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        controls ??= desktopTextSelectionControls;
        break;
      case TargetPlatform.macOS:
        controls ??= cupertinoDesktopTextSelectionControls;
        break;
    }
    return wrap(controls);
  }

  Widget wrap(TextSelectionControls controls) {
    return _InheritedSelectionControls(
      selectionControls: controls,
      child: SelectionArea(selectionControls: controls, focusNode: focusNode, child: child),
    );
  }

  static TextSelectionControls? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedSelectionControls>()?.selectionControls;
  }
}

class _InheritedSelectionControls extends InheritedWidget {
  final TextSelectionControls selectionControls;

  const _InheritedSelectionControls({required this.selectionControls, required super.child});

  @override
  bool updateShouldNotify(_InheritedSelectionControls oldWidget) {
    return oldWidget.selectionControls != selectionControls;
  }
}
