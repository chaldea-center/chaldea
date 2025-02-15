import 'dart:convert';

import 'package:dart_des/dart_des.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

import 'package:chaldea/packages/rijndael/rijndael.dart';

List<int> encryptRijndael(List<int> data, List<int> key, List<int> iv) {
  final rijndaelCbc = RijndaelCbc(key: key, iv: iv, padding: Pkcs7Padding(32), blockSize: 32);
  return rijndaelCbc.encrypt(data);
}

List<int> decryptRijndael(List<int> data, List<int> key, List<int> iv) {
  final rijndaelCbc = RijndaelCbc(key: key, iv: iv, padding: Pkcs7Padding(32), blockSize: 32);
  return rijndaelCbc.decrypt(data);
}

List<int> encryptDES3(List<int> data, List<int> key, List<int> iv) {
  DES3 des3CBC = DES3(key: key, mode: DESMode.CBC, iv: iv, paddingType: DESPaddingType.PKCS7);
  return des3CBC.encrypt(data);
}

List<int> decryptDES3(List<int> data, List<int> key, List<int> iv) {
  DES3 des3CBC = DES3(key: key, mode: DESMode.CBC, iv: iv, paddingType: DESPaddingType.PKCS7);
  return des3CBC.decrypt(data);
}

String encryptMsgpackB64(dynamic data) {
  assert(data is List || data is Map, data.runtimeType);
  final packed = msgpack.serialize(data);
  return base64Encode(packed);
}

dynamic decryptB64Msgpack(String data) {
  return msgpack.deserialize(base64Decode(data));
}
