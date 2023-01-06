import 'package:flutter/material.dart';

class LayoutTryBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;
  const LayoutTryBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    if (DisableLayoutBuilder.of(context)) {
      return builder(context, const BoxConstraints.tightForFinite());
    }
    return LayoutBuilder(builder: builder);
  }
}

class DisableLayoutBuilder extends StatelessWidget {
  final bool disabled;
  final Widget child;
  const DisableLayoutBuilder(
      {super.key, required this.child, this.disabled = true});

  @override
  Widget build(BuildContext context) {
    return _DisableLayout(disabled: disabled, child: child);
  }

  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_DisableLayout>()
            ?.disabled ??
        false;
  }
}

class _DisableLayout extends InheritedWidget {
  final bool disabled;

  const _DisableLayout({
    required this.disabled,
    required super.child,
  });

  @override
  bool updateShouldNotify(_DisableLayout oldWidget) {
    return oldWidget.disabled != disabled;
  }
}
