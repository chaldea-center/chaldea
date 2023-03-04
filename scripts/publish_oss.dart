/// LastModifiedTime                   Size(B)  StorageClass   ETAG                                  ObjectName
/// 2022-03-28 22:06:50 +0800 CST      4005164      Standard   B7EF8BBFD632A51EFCB527AF68B73094      oss://{bucket-name}/main.dart.js.map

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as pathlib;

const ossutil = 'ossutil';

void main(List<String> args) async {
  if (args.isEmpty) {
    throw ArgumentError('must provide bucket name');
  }
  final bucketName = args.first;
  final listResult = await Process.run(ossutil, ['ls', 'oss://${args.first}']);
  if (listResult.exitCode != 0) {
    throw 'Failed to list bucket objects.\n${listResult.stderr}\n${listResult.stdout}';
  }

  final regex = RegExp(r'(?<=\n)(.{29})\s+(\d+)\s+(.+)\s+([0-9A-Z]{32})\s+(oss://.+)\n');

  const exclude = ['main.dart.js.map']; // and hidden files
  const buildDir = 'build/web/';

  Map<String, String> remoteFiles = {};
  int uploaded = 0, deleted = 0, remained = 0;

  for (final match in regex.allMatches(listResult.stdout.toString())) {
    remoteFiles[match[5]!.substring('oss://$bucketName/'.length)] = match[4]!.toUpperCase();
  }
  final _excludedFiles = exclude.map((e) => File(pathlib.join(buildDir, e)).absolute).toList();
  if (!File(pathlib.join(buildDir, 'index.html')).existsSync()) {
    throw 'index.html not found';
  }

  for (final file in Directory(buildDir).listSync(recursive: true)) {
    if (file is! File) continue;
    if (pathlib.basename(file.path).startsWith('.')) continue;
    if (_excludedFiles.any((e) => e.existsSync() && FileSystemEntity.identicalSync(file.path, e.path))) {
      continue;
    }

    final key = pathlib.relative(file.path, from: buildDir);
    final hash = md5.convert(file.readAsBytesSync()).toString().toUpperCase();
    final etag = remoteFiles.remove(key);
    if (etag == hash) {
      remained += 1;
      continue;
    }

    print('>>> Uploading $key ...');
    final res = await Process.run(ossutil, [
      'cp',
      file.absolute.path,
      'oss://$bucketName/$key',
      '-f',
      if (key.endsWith('.html')) ...['--meta', 'Cache-Control:no-cache']
    ]);
    if (res.exitCode == 0) {
      uploaded += 1;
      print(res.stdout);
    } else {
      print('failed to upload $key: ${res.stderr}');
      throw res.stderr;
    }
  }

  for (final key in remoteFiles.keys) {
    print('>>> Deleting $key ...');
    final res = await Process.run(ossutil, ['rm', 'oss://$bucketName/$key']);
    if (res.exitCode == 0) {
      deleted += 1;
      print(res.stdout);
    } else {
      print('failed to delete $key: ${res.stderr}');
      throw res.stderr;
    }
  }

  print('>>> Published to OSS:'
      ' $uploaded uploaded, $deleted deleted, $remained remained unchanged.');
}
