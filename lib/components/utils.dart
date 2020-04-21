import 'package:chaldea/components/components.dart';

/// e.g. standalone functions
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String msg) {
  Fluttertoast.showToast(msg: msg);
}

void showInformDialog(BuildContext context, {String title, String content}) {
  assert(title != null || content != null);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: content == null ? null : Text(content),
      actions: <Widget>[
        FlatButton(
          child: Text(S.of(context).ok),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    ),
  );
}

typedef SheetBuilder = Widget Function(BuildContext, StateSetter);

void showSheet(BuildContext context,
    {@required SheetBuilder builder, double size = 0.75}) {
  assert(size >= 0.25 && size <= 1);

  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return DraggableScrollableSheet(
                initialChildSize: size,
                minChildSize: 0.25,
                maxChildSize: 1,
                expand: false,
                builder: (context, scrollController) =>
                    builder(sheetContext, setSheetState),
              );
            },
          ));
}
