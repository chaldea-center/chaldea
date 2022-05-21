import 'dart:io';

import 'package:crypto/crypto.dart';

void main(List<String> args) {
  final fp = args.first;
  final contents = File(fp).readAsBytesSync();
  final checksum = sha1.convert(contents).toString().toLowerCase();
  File('$fp.sha1').writeAsStringSync(checksum);
  print('File: $fp');
  print('SHA1: $checksum');
}
