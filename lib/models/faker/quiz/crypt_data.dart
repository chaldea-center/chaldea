import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import 'package:chaldea/packages/logger.dart';
import 'cipher.dart';

// for bilibili ver
class CryptData {
  CryptData._();

  // invalid
  static String sign(Map<String, String> dic, bool isIos) {
    final keys = dic.keys.toList();
    keys.sort();
    String str = "";
    for (final key in keys) {
      if (key == "sign") continue;
      str += dic[key]!;
    }
    str += isIos ? "2a7ee43463114270bf2620ae5d6d59c4" : "a4e39619a09d49e9aead9b820980013a";
    return calcMd5(str);
  }

  static String calcMd5(String text) {
    return md5.convert(utf8.encode(text)).toString();
  }

  static String bytesToHexString(List<int> bytes) {
    return bytes.map((e) => e.toRadixString(16).padLeft(2, '0').toLowerCase()).join();
  }

  static const String kCKey = "b5nHjsMrqaeNliSs3jyOzgpD";
  static const String kCVec = "wuD6keVr";
  static const String kFunnyCKey = "ZmF0ZWdvX2FuZHJvaWRfZnVu";
  static const String kFunnyCVec = "ZGVzX2l2";
  static const int mask = 4;
  static const int kWriteBufferSize = 0x4000;

  static String decrypt(String str, {bool isPress = false}) {
    final buffer2 = base64Decode(str);
    final bytes = utf8.encode("b5nHjsMrqaeNliSs3jyOzgpD");
    final rgbIV = utf8.encode("wuD6keVr");
    List<int> buffer = decryptDES3(buffer2, bytes, rgbIV);

    if (isPress) {
      buffer = BZip2Encoder().encode(buffer);
    }
    return base64Encode(buffer);
  }

  // to add: rsa encrypt

  static bool compareByteArrays(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int i = 0;
    for (int c in a) {
      if (c != b[i]) return false;
      i++;
    }
    return true;
  }

  static String encryptMD5(String str) {
    final buffer2 = md5.convert(utf8.encode(str));
    //  cs: builder.AppendFormat("{0:x2}", num2);
    return buffer2.toString();
  }

  static String funnyKeyDecrypt(String str) {
    final buffer2 = base64Decode(str);
    final bytes = utf8.encode(kFunnyCKey);
    final rgbIV = utf8.encode(kFunnyCVec);
    // final bytes = utf8.encode("Af80jlDHNlubKJ76bkFGKNjg");
    // final rgbIV = utf8.encode("ld521lxj");
    // final bytes = utf8.encode("ZmF0ZWdvX2FuZHJvaWRfZnVu");
    // final rgbIV = utf8.encode("ZGVzX2l2");
    return utf8.decode(decryptDES3(buffer2, bytes, rgbIV));
  }

  static String responseDecrypt(String str) {
    return utf8.decode(base64Decode(Uri.decodeFull(str).trim()));
  }

  static String? textDecrypt(String str) {
    try {
      final Uint8List buffer = base64Decode(str);
      final Uint8List bytes = Uint8List(buffer.length);
      for (int i = 0; i < buffer.length; i++) {
        bytes[i] = (buffer[i] ^ 4);
      }
      return utf8.decode(bytes);
    } catch (e, s) {
      logger.e('text decrypt failed', e, s);
      return null;
    }
  }

  static String textEncrypt(String str) {
    final Uint8List bytes = utf8.encode(str);
    final Uint8List inArray = Uint8List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      inArray[i] = (bytes[i] ^ 4);
    }
    return base64Encode(inArray);
  }

  static String responseCacheDecrypt(String str, {bool isPress = false}) {
    final array = base64Decode(str);
    final bytes = utf8.encode("1EgjS2hL3zSgwjcwLVmoPTmp");
    final bytes2 = utf8.encode("lfAKRpm1");
    List<int> array2 = decryptDES3(array, bytes, bytes2);
    if (isPress) {
      array2 = BZip2Encoder().encode(array2);
    }
    return base64Encode(array2);
  }

  static String getDecryptFunnyKey() {
    return "B5UI78B3486A7B48IB9AUF8E8P97CPI9";
    // var str = "+eTq/PgKHhpvmMWboN+Flb3okskn3SD325tVSqPf5nCjqAtdR6BN7Q=="; // old
    // return funnyKeyDecrypt("KA3mHM0nFWc4dMw6MzRPxnv3+ADHs2xPlwoNX+Icq/4=");
  }

  static String encryptMD5Usk(String usk) {
    var decryptFunnyKey = getDecryptFunnyKey();
    var str = decryptFunnyKey + usk;
    return encryptMD5(str);
  }
}
