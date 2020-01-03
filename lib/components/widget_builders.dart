import 'package:flutter/material.dart';

typedef ValueStatefulWidgetBuilder<T> = Widget Function(
    BuildContext context, _ValueStatefulBuilderState<T> state);

class ValueStatefulBuilder<T> extends StatefulWidget {
  final T value;
  final ValueStatefulWidgetBuilder<T> builder;

  const ValueStatefulBuilder({Key key, this.value, @required this.builder})
      : assert(builder != null),
        super(key: key);

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
      {Key key, @required this.builder, this.wantKeepAlive = true})
      : assert(builder != null && wantKeepAlive != null),
        super(key: key);

  @override
  _KeepAliveBuilderState createState() =>
      _KeepAliveBuilderState(wantKeepAlive);
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
