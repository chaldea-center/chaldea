import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'gallery_item.dart';

class GridGallery extends StatefulWidget {
  final bool isHome;
  final double? maxWidth;

  const GridGallery({super.key, required this.isHome, this.maxWidth});

  @override
  _GridGalleryState createState() => _GridGalleryState();
}

class _GridGalleryState extends State<GridGallery> {
  bool _editMode = false;

  Map<String, bool> get galleries => db.settings.galleries;

  @override
  Widget build(BuildContext context) {
    int crossCount;
    if (widget.maxWidth != null &&
        widget.maxWidth! > 0 &&
        widget.maxWidth != double.infinity) {
      crossCount = widget.maxWidth! ~/ 80;
      crossCount = crossCount.clamp(2, 8);
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

    if (!db.gameData.isValid) {
      grid = GestureDetector(
        onTap: () {
          SimpleCancelOkDialog(
            title: Text(S.current.warning),
            content: Text(S.current.game_data_not_found),
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
    List<GalleryItem> items = GalleryItem.allItems.where((item) {
      final v = galleries[item.name] ?? item.shownDefault;
      return widget.isHome && active ? v : !v;
    }).toList();

    if (widget.isHome && active) {
      items.addAll([
        GalleryItem.lostRoom,
        _editMode ? GalleryItem.done : GalleryItem.edit
      ]);
    }
    if (!widget.isHome && active) {
      items.add(GalleryItem.chaldeas);
    }

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

      if (_editMode && !item.persist) {
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
            if (item.url != null || item.page != null) {
              router.popDetailAndPush(
                url: item.url,
                child: item.page,
                detail: item.isDetail,
              );
            } else if (item == GalleryItem.chaldeas) {
              EasyLoading.showToast('・観測中・');
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
