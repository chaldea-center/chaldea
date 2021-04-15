import 'dart:convert';

import 'package:chaldea/generated/l10n.dart';
import 'package:flutter/material.dart';

import 'custom_dialogs.dart';
import 'extensions.dart';
import 'logger.dart';

class ChaldeaResponse {
  bool success;
  String? msg;
  dynamic body;

  ChaldeaResponse({this.success = false, this.msg, this.body});

  static ChaldeaResponse fromResponse(dynamic data) {
    try {
      var map;
      if (data is String) {
        map = jsonDecode(data);
      } else {
        map = Map.from(data);
      }
      return ChaldeaResponse(
          success: map['success'] ?? false, msg: map['msg'], body: map['body']);
    } catch (e, s) {
      logger.e('parse ChaldeaResponse error', e, s);
      return ChaldeaResponse();
    }
  }

  Future showMsg(BuildContext? context,
      {String? title, bool showBody = false}) {
    title ??= 'Result';
    title += ' ' + (success ? S.current.success : S.current.failed);
    String content = msg.toString();
    if (showBody) content += '\n$body';
    return SimpleCancelOkDialog(
      title: Text(title),
      content: Text(content),
    ).showDialog(context);
  }
}
