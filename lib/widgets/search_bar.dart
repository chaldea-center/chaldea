import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const double _kSearchBarPaddingBottom = 8.0;

class SearchBar extends StatefulWidget with PreferredSizeWidget, RouteAware {
  final TextEditingController? controller;
  @override
  final Size preferredSize;
  final FocusNode? focusNode;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final StatefulWidgetBuilder? searchOptionsBuilder;

  const SearchBar({
    Key? key,
    this.controller,
    this.preferredSize = const Size.fromHeight(36 + _kSearchBarPaddingBottom),
    this.focusNode,
    this.style,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.searchOptionsBuilder,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  PersistentBottomSheetController? _bottomSheetController;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      child: SizedBox.fromSize(
        size: widget.preferredSize,
        child: _realBuild(context),
      ),
      preferredSize: widget.preferredSize,
    );
  }

  Widget _realBuild(BuildContext context) {
    TextStyle textStyle = widget.style ?? const TextStyle();
    textStyle = textStyle.copyWith(
      color: textStyle.color ?? Theme.of(context).hintColor,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : colorScheme.onPrimary;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        widget.searchOptionsBuilder == null ? 16 : 0,
        _kSearchBarPaddingBottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CupertinoSearchTextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: textStyle,
              // don't set other language
              // placeholder height will change
              placeholder: 'Search',
              prefixInsets: const EdgeInsetsDirectional.fromSTEB(6, 0, 0, 0),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              suffixIcon: const Icon(Icons.clear),
            ),
          ),
          if (widget.searchOptionsBuilder != null)
            InkWell(
              onTap: () {
                _bottomSheetController = Scaffold.of(context).showBottomSheet(
                  (context) => _optionIcon(),
                  backgroundColor: Colors.transparent,
                );
              },
              child: Tooltip(
                message: S.current.search_options,
                child: Padding(
                  padding: const EdgeInsets.all((36 - 24) / 2),
                  child: Icon(
                    Icons.settings,
                    color: iconColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _optionIcon() {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _bottomSheetController?.close();
                    },
                    icon: const Icon(Icons.keyboard_arrow_down),
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                  ),
                  Text(S.current.search_options),
                ],
              ),
            ),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
            elevation: 4,
            color: Theme.of(context).secondaryHeaderColor,
          ),
          Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: widget.searchOptionsBuilder!(context, setState),
            ),
            elevation: 4,
            color: Theme.of(context).secondaryHeaderColor,
          )
        ],
      ),
    );
  }
}

abstract class SearchOptionsMixin<T> {
  ValueChanged? get onChanged;

  Widget builder(BuildContext context, StateSetter setState);

  Future<void> updateParent() async {
    if (onChanged != null) {
      await Future.delayed(const Duration(milliseconds: 200));
      return onChanged!(this);
    }
  }

  String getSummary(T datum);

  final Map<int, String> _caches = {};

  String getCache(T datum, String subKey, List<String?> Function() ifAbsent) {
    int key = hashValues(datum, subKey);
    return _caches[key] ??=
        ifAbsent().whereType<String>().toSet().join('\t') + '\t';
  }
}
