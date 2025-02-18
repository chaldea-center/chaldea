import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';

typedef ValueStatefulWidgetBuilder<T> = Widget Function(BuildContext context, ValueNotifier<T> value);

class ValueStatefulBuilder<T> extends StatefulWidget {
  final T initValue;
  final ValueStatefulWidgetBuilder<T> builder;

  const ValueStatefulBuilder({super.key, required this.initValue, required this.builder});

  @override
  _ValueStatefulBuilderState<T> createState() => _ValueStatefulBuilderState<T>();
}

class _ValueStatefulBuilderState<T> extends State<ValueStatefulBuilder<T>> {
  late final ValueNotifier<T> value;

  @override
  void initState() {
    super.initState();
    value = ValueNotifier(widget.initValue);
    value.addListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    value.removeListener(updateState);
  }

  void updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, value);
}

/// Make sure all keep-alive widgets won't share the [PrimaryScrollController]
/// If will, assign a unique [ScrollController] to every (at least n-1)
/// scrollable widget who will use [PrimaryScrollController] by default
class KeepAliveBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  final bool wantKeepAlive;

  const KeepAliveBuilder({super.key, required this.builder, this.wantKeepAlive = true});

  @override
  // ignore: no_logic_in_create_state
  _KeepAliveBuilderState createState() => _KeepAliveBuilderState(wantKeepAlive);
}

class _KeepAliveBuilderState extends State<KeepAliveBuilder> with AutomaticKeepAliveClientMixin {
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

  const AutoUnfocusBuilder({super.key, required this.builder});

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

// Incorrect align top with html renderer
// https://github.com/flutter/flutter/issues/98588
class CenterWidgetSpan extends WidgetSpan {
  const CenterWidgetSpan({
    required super.child,
    super.alignment = PlaceholderAlignment.middle,
    super.baseline,
    super.style,
  });
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
  const PrimaryScrollBuilder({super.key, required this.builder});

  @override
  State<PrimaryScrollBuilder> createState() => _PrimaryScrollBuilderState();
}

class _PrimaryScrollBuilderState extends State<PrimaryScrollBuilder> {
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(controller: controller, child: widget.builder(context));
  }
}

class ScrollControlWidget extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller) builder;
  const ScrollControlWidget({super.key, required this.builder});

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

class RefreshButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  const RefreshButton({super.key, this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final btn = TextButton(
      onPressed: onPressed,
      child: Text(MaterialLocalizations.of(context).refreshIndicatorSemanticLabel),
    );
    if (text == null) return btn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text(text!), btn],
    );
  }
}

class ScrollRestoration extends StatefulWidget {
  final String? restorationId;
  final Widget Function(BuildContext context, ScrollController controller) builder;
  final bool keepScrollOffset;
  final String? debugLabel;

  const ScrollRestoration({
    super.key,
    required this.restorationId,
    required this.builder,
    this.keepScrollOffset = true,
    this.debugLabel,
  });

  @override
  State<ScrollRestoration> createState() => _ScrollRestorationState();

  static final Map<String, double> _offsets = {};

  static double? get(String restorationId) => _offsets[restorationId];
  static void set(String restorationId, double offset) => _offsets[restorationId] = offset;

  static void reset(String restorationId) {
    _offsets.remove(restorationId);
  }
}

class _ScrollRestorationState extends State<ScrollRestoration> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: ScrollRestoration._offsets[widget.restorationId] ?? 0,
      keepScrollOffset: widget.keepScrollOffset,
      debugLabel: widget.debugLabel,
    );
    if (widget.restorationId != null) {
      _scrollController.addListener(_onScrollChanged);
    }
  }

  void _onScrollChanged() {
    if (_scrollController.hasClients && widget.restorationId != null) {
      ScrollRestoration._offsets[widget.restorationId!] = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _scrollController);
  }
}

class CopyLongPress extends StatelessWidget {
  final String text;
  final Widget child;
  const CopyLongPress({super.key, required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: text));
        final shownText = text.length > 100 ? '${text.substring(0, 100)}...' : text;
        EasyLoading.showToast('${S.current.copied}\n$shownText');
      },
      child: child,
    );
  }
}
