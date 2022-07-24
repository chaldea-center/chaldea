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

mixin ScrollControllerMixin<T extends StatefulWidget> on State<T> {
  late ScrollController _scrollController;

  ScrollController get scrollController => _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}

class PrimaryScrollBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  const PrimaryScrollBuilder({Key? key, required this.builder})
      : super(key: key);

  @override
  State<PrimaryScrollBuilder> createState() => _PrimaryScrollBuilderState();
}

class _PrimaryScrollBuilderState extends State<PrimaryScrollBuilder> {
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
        controller: controller, child: widget.builder(context));
  }
}

class ScrollControlWidget extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller)
      builder;
  const ScrollControlWidget({Key? key, required this.builder})
      : super(key: key);

  @override
  State<ScrollControlWidget> createState() => _ScrollControlWidgetState();
}

class _ScrollControlWidgetState extends State<ScrollControlWidget> {
  late final controller = ScrollController();
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, controller);
  }
}

mixin PrimaryScrollMixin on StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PrimaryScrollBuilder(builder: (contex) => buildContent(context));
  }

  Widget buildContent(BuildContext context);
}

class RefreshButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  const RefreshButton({Key? key, this.text, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final btn = TextButton(
      onPressed: onPressed,
      child:
          Text(MaterialLocalizations.of(context).refreshIndicatorSemanticLabel),
    );
    if (text == null) return btn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text!),
        btn,
      ],
    );
  }
}
