import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'utils.dart';

const Divider kHorizontalDivider = Divider(
    color: Color.fromRGBO(162, 169, 177, 1), thickness: 0.5, height: 0.5);
const VerticalDivider kVerticalDivider = VerticalDivider(
    color: Color.fromRGBO(162, 169, 177, 1), thickness: 0.5, width: 0.5);

class CustomTable extends StatelessWidget {
  final List<Widget> children;
  final Divider horizontalDivider;
  final VerticalDivider verticalDivider;

  /// could hide outline if table inside another table
  final bool hideOutline;

  const CustomTable(
      {Key? key,
      required this.children,
      this.hideOutline = false,
      this.horizontalDivider = kHorizontalDivider,
      this.verticalDivider = kVerticalDivider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _all = [];
    for (int i = 0; i < children.length; i++) {
      _all.add(children[i]);
      if (i < children.length - 1) {
        _all.add(horizontalDivider);
      }
    }
    final outlineDecoration = hideOutline
        ? null
        : BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                  color: horizontalDivider.color ?? kHorizontalDivider.color!,
                  width: horizontalDivider.thickness ??
                      kHorizontalDivider.thickness!),
              vertical: BorderSide(
                  color: verticalDivider.color ?? kVerticalDivider.color!,
                  width:
                      verticalDivider.thickness ?? kVerticalDivider.thickness!),
            ),
          );
    return Container(
      decoration: outlineDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _all,
      ),
    );
  }
}

class CustomTableRow extends StatefulWidget {
  final List<TableCellData> children;

  /// background color of table row
  final Color? color;
  final VerticalDivider divider;

  CustomTableRow(
      {Key? key,
      required this.children,
      this.color,
      this.divider = kVerticalDivider})
      : super(key: key) {
    children.forEach((cell) {
      cell.key ??= GlobalKey();
    });
  }

  CustomTableRow.fromTexts(
      {required List<String> texts,
      TableCellData? defaults,
      Color? color,
      VerticalDivider divider = kVerticalDivider})
      : this(
          children: texts
              .map((text) => defaults == null
                  ? TableCellData(text: text)
                  : defaults.copyWith(text: text))
              .toList(),
          color: color,
          divider: divider,
        );

  CustomTableRow.fromChildren(
      {required List<Widget> children,
      TableCellData? defaults,
      Color? color,
      VerticalDivider divider = kVerticalDivider})
      : this(
          children: children
              .map((child) => defaults == null
                  ? TableCellData(child: child)
                  : defaults.copyWith(child: child))
              .toList(),
          color: color,
          divider: divider,
        );

  @override
  _CustomTableRowState createState() => _CustomTableRowState();
}

class _CustomTableRowState extends State<CustomTableRow> {
  /// first build without constraints, then calculated the max height
  /// of children, then rebuild to fit the constraints
  BoxConstraints? _calculatedConstraints;
  bool _needRebuild = true;
  bool _fit = false;

  @override
  Widget build(BuildContext context) {
    BoxConstraints? constraints;
    if (_needRebuild) {
      calculateConstraints();
    } else {
      constraints = _calculatedConstraints;
    }
    List<Widget> children = [];
    for (int index = 0; index < widget.children.length; index++) {
      final cell = widget.children[index];
      late Widget _child;
      if (_needRebuild && cell.fitHeight == true) {
        // if fitHeight, render the child at second frame
        _child = Container();
      } else {
        if (cell.child != null) {
          _child = cell.child!;
        } else {
          /// TODO: AutoSizeText supported here:
          /// LayoutBuilder does not support returning intrinsic dimensions
          /// see https://github.com/leisim/auto_size_text/issues/77
          if (cell.maxLines == null) {
            _child = Text(cell.text!, textAlign: cell.textAlign);
          } else if (cell.maxLines == 1) {
            _child = FittedBox(
              child: Text(
                cell.text!,
                maxLines: cell.maxLines,
                textAlign: cell.textAlign,
              ),
            );
          } else {
            assert(false,
                'CustomTable: maxLines=${cell.maxLines} > 1 not supported yet!!!');
            _child = FittedBox(
              child: Text(
                cell.text!,
                maxLines: cell.maxLines,
                textAlign: cell.textAlign,
              ),
            );
            // _child = AutoSizeText(
            //   cell.text,
            //   maxLines: cell.maxLines,
            //   textAlign: cell.textAlign,
            // );
          }
        }
      }

      children.add(Flexible(
        key: cell.key,
        flex: cell.flex,
        child: Container(
          constraints: constraints,
          color: cell.resolveColor(context) ?? widget.color,
          child: Align(
            alignment: cell.alignment,
            child: Padding(
              padding: cell.padding,
              child: _child,
            ),
          ),
        ),
      ));

      if (index < widget.children.length - 1) {
        children.add(widget.divider);
      }
    }
    if (!_needRebuild) _needRebuild = true;
    return Container(
      constraints: constraints,
      child: IntrinsicHeight(child: Row(children: children)),
    );
  }

  void calculateConstraints() {
    // if all children don't need to fit, don't calculate
    if (widget.children.where((data) => data.fitHeight == true).isEmpty) {
      _needRebuild = false;
      _calculatedConstraints = null;
      return;
    }

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      double _maxHeight = -1;
      widget.children.forEach((cell) {
        if (cell.fitHeight != true) {
          RenderBox? box =
              cell.key?.currentContext?.findRenderObject() as RenderBox?;
          _maxHeight = max(_maxHeight, box?.size.height ?? _maxHeight);
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
  String? text;
  Widget? child;
  int flex;
  bool isHeader;
  Color? color;
  int? maxLines;
  Alignment alignment;
  TextAlign? textAlign;
  EdgeInsets padding;

  /// TODO: whether to remove it?
  bool fitHeight;
  GlobalKey? key;

  static const headerColorLight = Color.fromRGBO(234, 235, 238, 1);
  static const headerColorDark = Color.fromRGBO(70, 70, 70, 1);

  static Color resolveHeaderColor(BuildContext context) {
    return Utils.isDarkMode(context) ? headerColorDark : headerColorLight;
  }

  Color? resolveColor(BuildContext context) {
    if (color != null) return color;
    if (isHeader) {
      return resolveHeaderColor(context);
    }
  }

  TableCellData({
    this.key,
    this.text,
    this.child,
    this.flex = 1,
    this.isHeader = false,
    this.color,
    this.maxLines,
    this.alignment = Alignment.center,
    this.textAlign,
    this.padding = const EdgeInsets.all(4),
    this.fitHeight = false,
  }) : assert(text == null || child == null) {
    if (isHeader == true) {
      maxLines ??= 1;
    }
  }

  static List<TableCellData> list({
    List<String>? texts,
    List<Widget>? children,
    int? flex,
    List<int>? flexList,
    bool? isHeader,
    List<bool>? isHeaderList,
    Color? color,
    List<Color>? colorList,
    int? maxLines,
    List<int>? maxLinesList,
    Alignment? alignment,
    List<Alignment>? alignmentList,
    TextAlign? textAlign,
    List<TextAlign>? textAlignList,
    EdgeInsets? padding,
    List<EdgeInsets>? paddingList,
    bool? fitHeight,
    List<bool>? fitHeightList,
  }) {
    assert(texts == null || children == null);
    final length = (texts ?? children)!.length;
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
    final List<TableCellData> rowDataList = []..length = length;
    for (int index = 0; index < rowDataList.length; index++) {
      final data = TableCellData(
        text: texts?.elementAt(index),
        child: children?.elementAt(index),
      );
      data.flex = flex ?? flexList?.elementAt(index) ?? data.flex;
      data.color = color ?? colorList?.elementAt(index);
      data.maxLines =
          maxLines ?? maxLinesList?.elementAt(index) ?? data.maxLines;
      if (isHeader ?? isHeaderList?.elementAt(index) == true) {
        data.maxLines ??= 1;
      }
      data.alignment =
          alignment ?? alignmentList?.elementAt(index) ?? data.alignment;
      data.textAlign =
          textAlign ?? textAlignList?.elementAt(index) ?? data.textAlign;
      data.padding = padding ?? paddingList?.elementAt(index) ?? data.padding;
      data.fitHeight =
          fitHeight ?? fitHeightList?.elementAt(index) ?? data.fitHeight;
      rowDataList[index] = data;
    }
    return rowDataList;
  }

  TableCellData copyWith(
      {String? text,
      Widget? child,
      int? flex,
      bool? isHeader,
      Color? color,
      int? maxLines,
      Alignment? alignment,
      TextAlign? textAlign,
      EdgeInsets? padding,
      bool? fitHeight}) {
    text ??= this.text;
    child ??= this.child;
    assert(text == null || child == null);
    return TableCellData(
      text: text,
      child: child,
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
