import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';

class SingleCupertinoPicker extends StatefulWidget {
  final Widget? title;
  final int initialItem;
  final List<Widget> Function(BuildContext context) builder;
  final double itemExtent;
  final double? maxHeight;
  final ValueChanged<int>? onSelected;

  const SingleCupertinoPicker({
    super.key,
    this.title,
    this.initialItem = 0,
    required this.builder,
    required this.itemExtent,
    this.maxHeight = 216.0,
    this.onSelected,
  });

  @override
  State<SingleCupertinoPicker> createState() => _SingleCupertinoPickerState();
}

class _SingleCupertinoPickerState extends State<SingleCupertinoPicker> {
  int? selected;
  late final controller = FixedExtentScrollController(initialItem: widget.initialItem);

  @override
  Widget build(BuildContext context) {
    Widget picker = CupertinoPicker(
      itemExtent: widget.itemExtent,
      scrollController: controller,
      onSelectedItemChanged: (idx) {
        selected = idx;
      },
      children: widget.builder(context),
    );
    final constraints = widget.maxHeight == null ? null : BoxConstraints(maxHeight: widget.maxHeight!);
    Widget child = AlertDialog(
      title: widget.title,
      content: constraints == null ? picker : ConstrainedBox(constraints: constraints, child: picker),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selected);
            widget.onSelected?.call(controller.selectedItem);
          },
          child: Text(S.current.confirm),
        ),
      ],
    );
    return child;
  }
}
