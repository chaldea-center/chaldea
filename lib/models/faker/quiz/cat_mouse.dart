import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

import '../../gamedata/common.dart';
import 'cipher.dart';

class CatMouseGame {
  final Region region;
  late final bool isJp = region == Region.jp;
  late final List<int> battleKey;
  late final List<int> battleIV;
  late final List<int> infoData = kAssetKey;
  List<int> infoTop = Uint8List(32);

  // SVEC+SKEY
  late final kBattleKey = utf8.encode(
    {
      Region.jp: 'kzdMtpmzqCHAfx00saU1gIhTjYCuOD1JstqtisXsGYqRVcqrHRydj3k6vJCySu3g',
      Region.na: 'xaVPXPtrkXlUZsJRa3Eu1o1kSDYtjlwhoRQI2MHq2Q4szmpVvDcbmpi7UIZF9Rle',
      Region.cn: 'd3b13d9093cc6b457fd89766bafa1626ee2ef76626d49ce0d424f4156231ce56',
    }[region]!,
  );

  // IKEY
  late final kAssetKey = utf8.encode(
    {
      Region.jp: 'W0Juh4cFJSYPkebJB9WpswNF51oa6Gm7',
      Region.na: 'nn33CYId2J1ggv0bYDMbYuZ60m4GZt5P',
      Region.cn: '',
    }[region]!,
  );

  CatMouseGame([this.region = Region.jp]) {
    if (region != Region.jp && region != Region.na && region != Region.cn) {
      throw ArgumentError.value(region, 'region', 'Only JP/NA/CN supported');
    }
    thirdHomeBuilding();
  }

  void thirdHomeBuilding() {
    final array = kBattleKey;
    battleKey = array.sublist(0, 32);
    battleIV = array.sublist(32);
  }

  String catGame5(String str) {
    final key = [for (final v in battleKey) v ^ 4];
    final iv = [for (final v in battleIV) v ^ 8];
    return catHome(utf8.encode(str), key, iv, false);
  }

  List<int> catGame5Bytes(List<int> data) {
    final key = [for (final v in battleKey) v ^ 4];
    final iv = [for (final v in battleIV) v ^ 8];
    return catHomeMain(data, key, iv, false);
  }

  String catHome(List<int> data, List<int> key, List<int> iv, bool isCompress /* = false*/) {
    final array = catHomeMain(data, key, iv, isCompress);
    return base64Encode(array);
  }

  List<int> catHomeMain(List<int> data, List<int> key, List<int> iv, bool isCompress /*= false*/) {
    return encryptRijndael(data, key, iv);
  }

  dynamic mouseInfoMsgpack(List<int> data) {
    // infoData=kAssetKey;
    infoTop = data.sublist(0, 32);
    final array = data.sublist(32);
    return mouseHomeMsgpack(array, infoData, infoTop, true);
  }

  dynamic mouseHomeMsgpack(List<int> data, List<int> key, List<int> iv, bool isCompress /*=false*/) {
    return msgpack.deserialize(Uint8List.fromList(mouseHomeSub(data, key, iv, isCompress)));
  }

  List<int> mouseHomeSub(List<int> data, List<int> key, List<int> iv, bool isCompress) {
    List<int> array = decryptRijndael(data, key, iv);
    if (isCompress) {
      array = gzip.decode(array);
    }
    return array;
  }

  final List<int> authsaveKey = utf8.encode('b5nHjsMrqaeNliSs3jyOzgpD');
  final List<int> authsaveIV = utf8.encode('wuD6keVr');

  String catGame1(String data, {bool isCompress = false}) {
    List<int> result = encryptDES3(utf8.encode(data), authsaveKey, authsaveIV);
    if (isCompress) {
      // to be verified
      result = BZip2Encoder().encode(result);
    }
    return base64Encode(result);
  }

  // user parts
  String encryptAuthsave(Map data) {
    return catGame1(jsonEncode(data), isCompress: false);
  }

  Map decryptAuthsave(List<int> data) {
    int start = -1;
    for (int index = 0; index < min(5, data.length - 3); index++) {
      if (data[index] == 0x5A && data[index + 1] == 0x53 && data[index + 2] == 0x76) {
        start = index;
        break;
      }
    }
    if (start > 0) {
      data = data.sublist(start);
    }
    String srcCode = utf8.decode(data);

    Map<String, dynamic> _decrypt(String _code) {
      List<int> result = base64Decode(_code);
      result = decryptDES3(result, authsaveKey, authsaveIV);
      String text = utf8.decode(result);
      int left = text.indexOf('{'), right = text.lastIndexOf('}');
      if (left >= 0 && right > 0) {
        text = text.substring(left, right + 1);
      }
      Map dict = jsonDecode(text);
      return Map<String, dynamic>.from(dict);
    }

    String code = srcCode;
    for (int i = 0; i < 4; i++) {
      try {
        return _decrypt(code);
      } on FormatException catch (e) {
        print('Decode error $e, retry after removing last 4 chars');
        if (code.length > 4) {
          code = code.substring(0, code.length - 4);
        }
      }
    }
    return _decrypt(srcCode);
  }

  String encryptBattleResult(Map dictionary) {
    final List<int> packed = msgpack.serialize(dictionary);
    final List<int> encryped = catGame5Bytes(packed);
    return base64Encode(encryped);
  }

  dynamic decryptBattleResult(String s) {
    final key = [for (final v in battleKey) v ^ 4];
    final iv = [for (final v in battleIV) v ^ 8];
    final result = msgpack.deserialize(Uint8List.fromList(decryptRijndael(base64Decode(s), key, iv)));
    // print(jsonEncode(result));
    return result;
  }

  //
  String encodeJsonMsgpackBase64(dynamic jsonData) {
    return base64Encode(msgpack.serialize(jsonData));
  }

  String encodeObjMsgpackBase64(dynamic data) {
    data = jsonDecode(jsonEncode(data));
    return encodeJsonMsgpackBase64(data);
  }

  dynamic decodeBase64Msgpack(String data) {
    return msgpack.deserialize(Uint8List.fromList(base64Decode(data)));
  }
}
