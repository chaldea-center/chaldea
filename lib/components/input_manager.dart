import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InputComponent<T> {
  T data;
  TextEditingController controller;
  FocusNode focusNode;

  InputComponent({@required this.data, this.controller, this.focusNode})
      : assert(data != null);

  void selectAll() {
    if (controller != null) {
      controller.selection =
          TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    }
  }

  void unSelect() {
    if (controller != null) {
      controller.selection = TextSelection(baseOffset: 0, extentOffset: 0);
    }
  }

  void dispose() {
    controller?.dispose();
    focusNode?.dispose();
  }
}

class TextInputsManager<T> {
  List<InputComponent<T>> components = [];

  // for focus switching
  List<InputComponent<T>> _observerList = [];

  InputComponent<T> getComponentByData(T datum) {
    //TODO: what if multi elements have the same datum
    return components.firstWhere((e) => e.data == datum, orElse: () => null);
  }

  // focus part
  void addObserver(InputComponent component) {
    // could node of _focusList not in _focusNodes list?
    // if could, it's just two functionality
    _observerList.add(component);
  }

  void moveNextFocus(BuildContext context, InputComponent component) {
    final index = _observerList.indexOf(component);
    component.unSelect();
    if (index < 0) {
      print('WARNING: focus node not in list!');
    } else if (index == _observerList.length - 1) {
      FocusScope.of(context).unfocus();
    } else {
      final next = _observerList[index + 1];
      FocusScope.of(context).requestFocus(next.focusNode);
      next.controller.selection = TextSelection(
          baseOffset: 0, extentOffset: next.controller.text.length);
    }
  }

  void resetFocusList() {
    _observerList.clear();
  }

  void dispose() {
    components.forEach((e) => e.dispose());
  }
}
