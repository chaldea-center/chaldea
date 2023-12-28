import 'dart:convert';

import 'package:chaldea/packages/rijndael/rijndael.dart';
import '../../gamedata/common.dart';

class CatMouseGame {
  final Region region;
  late final bool isJp = region == Region.jp;
  late final List<int> battleKey;
  late final List<int> battleIV;

  CatMouseGame(this.region) {
    if (region != Region.jp && region != Region.na) {
      throw ArgumentError.value(region, 'region', 'Only JP/NA supported');
    }
    thirdHomeBuilding();
  }

  void thirdHomeBuilding() {
    final array = utf8.encode(isJp
        ? 'kzdMtpmzqCHAfx00saU1gIhTjYCuOD1JstqtisXsGYqRVcqrHRydj3k6vJCySu3g'
        : 'xaVPXPtrkXlUZsJRa3Eu1o1kSDYtjlwhoRQI2MHq2Q4szmpVvDcbmpi7UIZF9Rle');
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

  String catHome(List<int> data, List<int> home, List<int> info, bool isCompress /* = false*/) {
    final array = catHomeMain(data, home, info, isCompress);
    return base64Encode(array);
  }

  List<int> catHomeMain(List<int> data, List<int> home, List<int> info, bool isCompress/*= false*/) {
    final rijndaelCbc = RijndaelCbc(
      key: home,
      iv: info,
      padding: Pkcs7Padding(32),
      blockSize: 32,
    );
    return rijndaelCbc.encrypt(data);
  }
}
