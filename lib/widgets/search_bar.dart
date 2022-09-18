import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../models/models.dart';

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
    super.key,
    this.controller,
    this.preferredSize = const Size.fromHeight(36 + _kSearchBarPaddingBottom),
    this.focusNode,
    this.style,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.searchOptionsBuilder,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: SizedBox.fromSize(
        size: widget.preferredSize,
        child: _realBuild(context),
      ),
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
      padding: EdgeInsetsDirectional.fromSTEB(
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
              placeholder: 'Search: A B -C',
              prefixInsets: const EdgeInsetsDirectional.fromSTEB(6, 0, 0, 0),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              suffixIcon: const Icon(Icons.clear),
            ),
          ),
          if (widget.searchOptionsBuilder != null)
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) =>
                      SafeArea(child: _optionBuilder(context)),
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

  Widget _optionBuilder(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.keyboard_arrow_down),
            title: Text(S.current.search_options),
            horizontalTitleGap: 0,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: widget.searchOptionsBuilder!(context, setState),
          ),
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

  Iterable<String?> getSummary(T datum) => [];

  final Map<int, String> _caches = {};

  String getCache(T datum, String subKey, List<String?> Function() ifAbsent) {
    int key = Object.hash(datum, subKey);
    return _caches[key] ??=
        '${ifAbsent().whereType<String>().toSet().join('\t')}\t';
  }

  Iterable<String?> getAllKeys(Transl<dynamic, String> transl) =>
      SearchUtil.getAllKeys(transl);

  Iterable<String?> getListKeys(
      List<String>? items, String? Function(String word) getter) sync* {
    if (items == null) return;
    for (final item in items) {
      yield getter(item);
    }
  }

  Iterable<String?> getSkillKeys(SkillOrTd skill) =>
      SearchUtil.getSkillKeys(skill);
}
