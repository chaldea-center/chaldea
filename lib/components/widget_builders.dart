// @dart=2.12
import 'package:flutter/material.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

typedef ValueStatefulWidgetBuilder<T> = Widget Function(
    BuildContext context, _ValueStatefulBuilderState<T> state);

class ValueStatefulBuilder<T> extends StatefulWidget {
  final T value;
  final ValueStatefulWidgetBuilder<T> builder;

  const ValueStatefulBuilder(
      {Key? key, required this.value, required this.builder})
      : super(key: key);

  @override
  _ValueStatefulBuilderState<T> createState() =>
      _ValueStatefulBuilderState<T>(value);
}

class _ValueStatefulBuilderState<T> extends State<ValueStatefulBuilder<T>> {
  T value;

  _ValueStatefulBuilderState(this.value);

  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, this);
}

class KeepAliveBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  final bool wantKeepAlive;

  const KeepAliveBuilder(
      {Key? key, required this.builder, this.wantKeepAlive = true})
      : super(key: key);

  @override
  _KeepAliveBuilderState createState() => _KeepAliveBuilderState(wantKeepAlive);
}

class _KeepAliveBuilderState extends State<KeepAliveBuilder>
    with AutomaticKeepAliveClientMixin {
  bool _wantKeepAlive;

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

  AutoUnfocusBuilder({Key? key, required this.builder}) : super(key: key);

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

mixin DefaultScrollBarMixin<T extends StatefulWidget> on State<T> {
  Widget wrapDefaultScrollBar({
    required ScrollController controller,
    required Widget child,
    bool isAlwaysShown = false,
  }) {
    return VsScrollbar(
      controller: controller,
      scrollDirection: Axis.vertical,
      radius: 8,
      thickness: 8,
      scrollbarTimeToFade: Duration(seconds: 3),
      child: child,
      isAlwaysShown: isAlwaysShown,
    );
  }
}
