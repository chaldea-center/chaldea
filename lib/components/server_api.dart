library server_api;

import 'dart:convert';
import 'dart:typed_data';

import 'package:chaldea/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'custom_dialogs.dart';
import 'extensions.dart';
import 'logger.dart';

part 'server_api.g.dart';

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

@JsonSerializable()
class SvtRecResults {
  String? uuid;
  List<OneSvtRecResult> results;

  SvtRecResults({this.uuid, List<OneSvtRecResult>? results})
      : results = results ?? [];

  factory SvtRecResults.fromJson(Map<String, dynamic> data) =>
      _$SvtRecResultsFromJson(data);

  Map<String, dynamic> toJson() => _$SvtRecResultsToJson(this);
}

@JsonSerializable()
class OneSvtRecResult {
  int? svtNo;
  int? maxLv;
  int? skill1;
  int? skill2;
  int? skill3;
  String? image;

  OneSvtRecResult({
    this.svtNo,
    this.maxLv,
    this.skill1,
    this.skill2,
    this.skill3,
    this.image,
  });

  bool checked = true;

  List<int?> get skills => [skill1, skill2, skill3];
  Uint8List? _imgBytes;

  Uint8List? get imgBytes {
    if (image == null) return null;
    if (_imgBytes != null) return _imgBytes;
    try {
      _imgBytes = base64Decode(image!);
    } catch (e, s) {
      logger.e('decode image base64 string failed', e, s);
    }
    return _imgBytes;
  }

  bool get isValid {
    return svtNo != null &&
        svtNo! > 0 &&
        skills.every((e) => e != null && e >= 1 && e <= 10);
  }

  factory OneSvtRecResult.fromJson(Map<String, dynamic> data) =>
      _$OneSvtRecResultFromJson(data);

  Map<String, dynamic> toJson() => _$OneSvtRecResultToJson(this);
}
