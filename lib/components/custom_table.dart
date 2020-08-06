import 'dart:math' show max;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const BorderSide kCustomTableSide =
    BorderSide(color: Color.fromRGBO(162, 169, 177, 1), width: 0.5);

class CustomTable extends StatelessWidget {
  final List<Widget> children;
  final BorderSide side;

  /// could hide outline if table inside another table
  final bool hideOutline;

  const CustomTable(
      {Key key,
      this.children,
      this.hideOutline = false,
      this.side = kCustomTableSide})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: hideOutline ? null : Border.fromBorderSide(side)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(children.length, (index) {
          return Container(
            decoration:
                BoxDecoration(border: index > 0 ? Border(top: side) : null),
            child: children[index],
          );
        }),
      ),
    );
  }
}

class CustomTableRow extends StatefulWidget {
  final List<TableCellData> children;

  /// background color of table row
  final Color color;
  final BorderSide side;

  CustomTableRow(
      {Key key, this.children, this.color, this.side = kCustomTableSide})
      : super(key: key) {
    children.forEach((cell) {
      cell.key ??= GlobalKey();
    });
  }

  CustomTableRow.fromTexts(
      {@required List<String> texts,
      TableCellData defaults,
      Color color,
      BorderSide side = kCustomTableSide})
      : this(
          children: texts
              .map((text) => defaults == null
                  ? TableCellData(text: text)
                  : defaults.copyWith(text: text))
              .toList(),
          color: color,
          side: side,
        );

  CustomTableRow.fromChildren(
      {@required List<Widget> children,
      TableCellData defaults,
      Color color,
      BorderSide side = kCustomTableSide})
      : this(
          children: children
              .map((child) => defaults == null
                  ? TableCellData(child: child)
                  : defaults.copyWith(child: child))
              .toList(),
          color: color,
          side: side,
        );

  @override
  _CustomTableRowState createState() => _CustomTableRowState();
}

class _CustomTableRowState extends State<CustomTableRow> {
  /// first build without constraints, then calculated the max height
  /// of children, then rebuild to fit the constraints
  BoxConstraints _calculatedConstraints;
  bool _needRebuild = true;
  bool _fit = false;

  @override
  Widget build(BuildContext context) {
    BoxConstraints constraints;
    if (_needRebuild) {
      calculateConstraints();
    } else {
      constraints = _calculatedConstraints;
    }

    List<Widget> children = List.generate(widget.children.length, (index) {
      final cell = widget.children[index];
      Widget _child;
      if (_needRebuild && cell.fitHeight == true) {
        // if fitHeight, render the child at second frame
        _child = Container();
      } else {
        if (cell.child != null) {
          _child = cell.child;
        } else {
          _child = cell.maxLines == null
              ? Text(cell.text, textAlign: cell.textAlign)
              : AutoSizeText(
                  cell.text,
                  maxLines: cell.maxLines,
                  textAlign: cell.textAlign,
                );
        }
      }

      return Flexible(
        key: cell.key,
        flex: cell.flex,
        child: Container(
          constraints: constraints,
          decoration: BoxDecoration(
            color: cell.color,
            border: index > 0 ? Border(left: kCustomTableSide) : null,
          ),
          child: Align(
            alignment: cell.alignment,
            child: Padding(
              padding: cell.padding,
              child: _child,
            ),
          ),
        ),
      );
    });
    if (!_needRebuild) _needRebuild = true;
    return Container(constraints: constraints, child: Row(children: children));
  }

  void calculateConstraints() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      double _maxHeight = -1;
      widget.children.forEach((cell) {
        if (cell.fitHeight != true) {
          RenderBox box = cell.key.currentContext?.findRenderObject();
          _maxHeight = max(_maxHeight, box?.size?.height ?? _maxHeight);
        }
      });
      if (_maxHeight > 0) {
        setState(() {
          if (_fit) print('set to false');
          _needRebuild = false;
          _calculatedConstraints = BoxConstraints.expand(height: _maxHeight);
        });
      }
    });
  }
}

class TableCellData {
  String text;
  Widget child;
  int flex;
  bool isHeader;
  Color color;
  int maxLines;
  Alignment alignment;
  TextAlign textAlign;
  EdgeInsets padding;
  bool fitHeight;
  GlobalKey key;

  static const headerColor = Color.fromRGBO(234, 235, 238, 1);

  TableCellData(
      {this.key,
        this.text,
      this.child,
      this.flex = 1,
      this.isHeader,
      this.color,
      this.maxLines,
      this.alignment = Alignment.center,
      this.textAlign,
      this.padding = const EdgeInsets.all(4),
      this.fitHeight})
      : assert(text == null || child == null) {
    if (isHeader == true) {
      color = headerColor;
    }
  }

  static List<TableCellData> list({
    List<String> texts,
    List<Widget> children,
    int flex,
    List<int> flexList,
    bool isHeader,
    List<bool> isHeaderList,
    Color color,
    List<Color> colorList,
    int maxLines,
    List<int> maxLinesList,
    Alignment alignment,
    List<Alignment> alignmentList,
    TextAlign textAlign,
    List<TextAlign> textAlignList,
    EdgeInsets padding,
    List<EdgeInsets> paddingList,
    bool fitHeight,
    List<bool> fitHeightList,
  }) {
    final length = (texts ?? children).length;
    assert(texts == null || children == null);
    assert(flex == null || flexList == null);
    assert(isHeader == null || isHeaderList == null);
    assert(color == null || colorList == null);
    assert(maxLines == null || maxLinesList == null);
    assert(alignment == null || alignmentList == null);
    assert(textAlign == null || textAlignList == null);
    assert(padding == null || paddingList == null);
    assert(fitHeight == null || fitHeightList == null);
    assert([
      flexList?.length,
      isHeaderList?.length,
      colorList?.length,
      maxLinesList?.length,
      alignmentList?.length,
      paddingList?.length,
      fitHeightList?.length
    ].toSet().every((e) => e == null || e == length));
    final List<TableCellData> rowDataList = List()..length = length;
    for (int index = 0; index < rowDataList.length; index++) {
      final data = TableCellData(
        text: texts?.elementAt(index),
        child: children?.elementAt(index),
      );
      data.flex = flex ?? flexList?.elementAt(index) ?? data.flex;
      data.color = (isHeader ?? isHeaderList?.elementAt(index) == true)
          ? headerColor
          : color ?? colorList?.elementAt(index);
      data.maxLines = maxLines ?? maxLinesList?.elementAt(index);
      data.alignment =
          alignment ?? alignmentList?.elementAt(index) ?? data.alignment;
      data.textAlign =
          textAlign ?? textAlignList?.elementAt(index) ?? data.textAlign;
      data.padding = padding ?? paddingList?.elementAt(index) ?? data.padding;
      data.fitHeight = fitHeight ?? fitHeightList?.elementAt(index);
      rowDataList[index] = data;
    }
    return rowDataList;
  }

  TableCellData copyWith(
      {String text,
      Widget child,
      int flex,
      bool isHeader,
      Color color,
      int maxLines,
      Alignment alignment,
      TextAlign textAlign,
      EdgeInsets padding,
      bool fitHeight}) {
    return TableCellData(
      text: text ?? this.text,
      child: child ?? this.child,
      flex: flex ?? this.flex,
      isHeader: isHeader ?? this.isHeader,
      color: color ?? this.color,
      maxLines: maxLines ?? this.maxLines,
      alignment: alignment ?? this.alignment,
      textAlign: textAlign ?? this.textAlign,
      padding: padding ?? this.padding,
      fitHeight: fitHeight ?? this.fitHeight,
    );
  }
}
