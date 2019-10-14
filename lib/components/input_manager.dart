import 'package:flutter/material.dart';

class InputComponent<T> {
  T data;
  TextEditingController textEditingController;
  FocusNode focusNode;

  InputComponent(
      {@required this.data, this.textEditingController, this.focusNode})
      : assert(data != null);

  void dispose() {
    textEditingController?.dispose();
    focusNode?.dispose();
  }
}

class TextInputsManager<T> {
  List<InputComponent<T>> components = [];

  // for focus switching
  List<FocusNode> _focusList = [];

  void addEntry({T datum, TextEditingController controller, FocusNode node}) {
    // whether they are all required?
    components.add(InputComponent(
        data: datum, textEditingController: controller, focusNode: node));
  }

  InputComponent<T> getComponentByData(T datum){
    //TODO: what if multi elements have the same datum
    return components.firstWhere((e)=>e.data==datum,orElse: ()=>null);
  }
  // focus part
  void addFocus(FocusNode node) {
    // could node of _focusList not in _focusNodes list?
    // if could, it's just two functionality
    _focusList.add(node);
  }

  void moveNextFocus(BuildContext context, FocusNode node) {
    final index = _focusList.indexOf(node);
    node.unfocus();
    if (index < 0) {
      print('WARNING: focus node not in list!');
    } else if (index == _focusList.length - 1) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).requestFocus(_focusList[index + 1]);
    }
  }

  void resetFocusList() {
    _focusList.clear();
  }

  void dispose() {
    components.forEach((e) => e.dispose());
  }
}
