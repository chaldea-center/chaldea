import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import 'custom_dialogs.dart';

class ReorderableListPage<T> extends StatefulWidget {
  final Widget title;
  final List<T> items;
  final T Function()? onCreate;
  final void Function(int, int)? onReorder;
  final Widget Function(BuildContext context, T item, bool sorting) itemBuilder;
  final List<Widget>? actions;
  final bool showDeleteButton;

  const ReorderableListPage({
    super.key,
    required this.title,
    required this.items,
    required this.onCreate,
    this.onReorder,
    required this.itemBuilder,
    this.actions,
    this.showDeleteButton = true,
  });

  @override
  State<ReorderableListPage<T>> createState() => _ReorderableListPageState();
}

class _ReorderableListPageState<T> extends State<ReorderableListPage<T>> {
  bool sorting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: [
          ...?widget.actions,
          if (!sorting && widget.onCreate != null)
            IconButton(
              onPressed: () {
                widget.onCreate?.call();
                setState(() {});
              },
              icon: const Icon(Icons.add),
              tooltip: S.current.add,
            ),
          IconButton(
            onPressed: () {
              setState(() {
                sorting = !sorting;
              });
            },
            icon: Icon(sorting ? Icons.done : Icons.sort),
            tooltip: S.current.sort_order,
          ),
        ],
      ),
      body: sorting
          ? ReorderableListView(
              onReorder:
                  widget.onReorder ??
                  (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = widget.items.removeAt(oldIndex);
                    widget.items.insert(newIndex, item);
                    setState(() {});
                  },
              children: [for (final item in widget.items) itemBuilder(context, item)],
            )
          : ListView.separated(
              itemCount: widget.items.length,
              itemBuilder: (context, index) => itemBuilder(context, widget.items[index]),
              separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
            ),
    );
  }

  Widget itemBuilder(BuildContext context, T item) {
    Widget child = widget.itemBuilder(context, item, sorting);
    if (!sorting && widget.showDeleteButton) {
      child = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: child),
          IconButton(
            onPressed: () {
              SimpleConfirmDialog(
                title: Text(S.current.delete),
                onTapOk: () {
                  if (mounted) {
                    setState(() {
                      widget.items.remove(item);
                    });
                  }
                },
              ).showDialog(context);
            },
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            iconSize: 20,
          ),
        ],
      );
    }
    return child;
  }
}
