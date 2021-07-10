import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Placed in [AppBar.bottom]
class SearchBar extends StatelessWidget with PreferredSizeWidget {
  final TextEditingController? controller;
  final Size preferredSize;
  final FocusNode? focusNode;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  const SearchBar({
    Key? key,
    this.controller,
    this.preferredSize = const Size.fromHeight(36 + 4),
    this.focusNode,
    this.style,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = style ?? TextStyle();
    textStyle = textStyle.copyWith(
      color: textStyle.color ?? Theme.of(context).hintColor,
    );
    return PreferredSize(
      child: SizedBox.fromSize(
        size: preferredSize,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: CupertinoSearchTextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: textStyle,
            // don't set other language
            // placeholder height will change
            placeholder: 'Search',
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ),
      preferredSize: preferredSize,
    );
  }
}
