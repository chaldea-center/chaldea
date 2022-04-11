import 'package:flutter/material.dart';

typedef ValueStatefulWidgetBuilder<T> = Widget Function(
    BuildContext context, _ValueStatefulBuilderState<T> state);

class ValueStatefulBuilder<T> extends StatefulWidget {
  final T initValue;
  final ValueStatefulWidgetBuilder<T> builder;

  const ValueStatefulBuilder(
      {Key? key, required this.initValue, required this.builder})
      : super(key: key);

  @override
  _ValueStatefulBuilderState<T> createState() =>
      _ValueStatefulBuilderState<T>();
}

class _ValueStatefulBuilderState<T> extends State<ValueStatefulBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.initValue;
  }

  void updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, this);
}

/// Make sure all keep-alive widgets won't share the [PrimaryScrollController]
/// If will, assign a unique [ScrollController] to every (at least n-1)
/// scrollable widget who will use [PrimaryScrollController] by default
class KeepAliveBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  final bool wantKeepAlive;

  const KeepAliveBuilder(
      {Key? key, required this.builder, this.wantKeepAlive = true})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _KeepAliveBuilderState createState() => _KeepAliveBuilderState(wantKeepAlive);
}

class _KeepAliveBuilderState extends State<KeepAliveBuilder>
    with AutomaticKeepAliveClientMixin {
  final bool _wantKeepAlive;

  _KeepAliveBuilderState(this._wantKeepAlive);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(context);
  }

  @override
  bool get wantKeepAlive => _wantKeepAlive;
}

class AutoUnfocusBuilder extends StatelessWidget {
  final WidgetBuilder builder;

  const AutoUnfocusBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: builder(context),
    );
  }
}

class CenterWidgetSpan extends WidgetSpan {
  const CenterWidgetSpan({
    required Widget child,
    PlaceholderAlignment alignment = PlaceholderAlignment.middle,
    TextBaseline? baseline,
    TextStyle? style,
  }) : super(
          child: child,
          alignment: alignment,
          baseline: baseline,
          style: style,
        );
}
