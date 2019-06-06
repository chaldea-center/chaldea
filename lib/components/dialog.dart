import 'package:chaldea/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCancelOkDialog extends StatefulWidget {
  final String title;
  final String defaultText;
  final String hintText;
  final String errorText;
  final bool Function(String) validate;
  final void Function(String) onSubmit;

  const InputCancelOkDialog(
      {Key key,
      this.title,
      this.defaultText,
      this.hintText,
      this.errorText,
      this.validate,
      this.onSubmit})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputCancelOkDialogState();
}

class _InputCancelOkDialogState extends State<InputCancelOkDialog> {
  TextEditingController _controller;
  bool validation = true;

  bool _validate(String v) {
    return widget.validate == null ? true : widget.validate(v);
  }

  @override
  void initState() {
    super.initState();
    _controller= TextEditingController(text: widget.defaultText);
  }

  @override
  Widget build(BuildContext context) {
    validation = _validate(_controller.text);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: validation ? null : "Invalid input."),
        onChanged: (v) {
          if (widget.validate != null) {
            setState(() {
              validation = _validate(v);
            });
          }
        },
        onSubmitted: (v) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(S.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text(S.of(context).ok),
          onPressed: () {
            String _value = _controller.text;
            validation = _validate(_value);
            setState(() {
              if (validation && widget.onSubmit != null) {
                widget.onSubmit(_value);
                Navigator.pop(context);
              }
            });
          },
        )
      ],
    );
  }
}
