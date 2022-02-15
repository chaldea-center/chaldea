import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:flutter/material.dart';

import 'gallery_item.dart';

class GridGallery extends StatefulWidget {
  final double? maxWidth;

  const GridGallery({Key? key, this.maxWidth}) : super(key: key);

  @override
  _GridGalleryState createState() => _GridGalleryState();
}

class _GridGalleryState extends State<GridGallery> {
  bool _editMode = false;

  Map<String, bool> get galleries => db2.settings.galleries;

  @override
  void initState() {
    super.initState();
    db2.settings.galleries.removeWhere(
        (key, value) => GalleryItem.allItems.every((item) => item.name != key));
  }

  @override
  Widget build(BuildContext context) {
    int crossCount;
    if (widget.maxWidth != null &&
        widget.maxWidth! > 0 &&
        widget.maxWidth != double.infinity) {
      crossCount = widget.maxWidth! ~/ 80;
      crossCount = Maths.fixValidRange(crossCount, 2, 8);
    } else {
      crossCount = 4;
    }
    if (crossCount < 4) {
      crossCount = 4;
    }

    Widget grid = _editMode
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getGrid(crossCount, true),
              const Divider(indent: 16, endIndent: 16),
              _getGrid(crossCount, false),
            ],
          )
        : _getGrid(crossCount, true);

    if (db2.gameData.version.timestamp <= 0) {
      grid = GestureDetector(
        onTap: () {
          const SimpleCancelOkDialog(
            title: Text('Warning'),
            content: Text('Game data not found, please download data first'),
            hideCancel: true,
          ).showDialog(context);
        },
        child: AbsorbPointer(
          child: Opacity(
            opacity: 0.5,
            child: grid,
          ),
        ),
      );
    }
    return grid;
  }

  Widget _getGrid(int crossCount, bool active) {
    final themeData = Theme.of(context);
    final items = GalleryItem.allItems
        .where((e) => (galleries[e.name] ?? true) == active)
        .toList();
    if (active) items.add(_editMode ? GalleryItem.done : GalleryItem.edit);
    List<Widget> children = List.generate(items.length, (index) {
      final item = items[index];
      Widget child = item.buildIcon(context,
          color: active ? null : themeData.disabledColor);
      if (item.titleBuilder == null) {
        child = Center(child: child);
      } else {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AutoSizeText(
                    item.titleBuilder!(),
                    style: const TextStyle(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    maxFontSize: 14,
                    minFontSize: 6,
                  ),
                ),
              ),
            )
          ],
        );
      }

      if (_editMode && item != GalleryItem.edit && item != GalleryItem.done) {
        final editIcon = active
            ? Icon(Icons.remove_circle,
                color: themeData.isDarkMode
                    ? themeData.disabledColor
                    : themeData.colorScheme.secondary)
            : Icon(Icons.add_circle,
                color: themeData.colorScheme.secondaryContainer);
        child = Stack(
          alignment: Alignment.topRight,
          children: [
            child,
            editIcon,
          ],
        );
      }
      return InkWell(
        child: child,
        onTap: () {
          if (item == GalleryItem.done) {
            setState(() {
              _editMode = false;
            });
            return;
          } else if (item == GalleryItem.edit) {
            setState(() {
              _editMode = true;
            });
            return;
          }
          if (_editMode) {
            setState(() {
              galleries[item.name] = !active;
            });
          } else {
            if (item.page != null) {
              SplitRoute.push(
                context,
                item.page!,
                detail: item.isDetail,
                popDetail: true,
              );
            }
          }
        },
      );
    });
    return GridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: crossCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: 1,
      children: children,
    );
  }
}
