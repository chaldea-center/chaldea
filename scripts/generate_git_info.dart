import 'dart:io';

void main(List<String> args) async {
  try {
    final gitInfo = (await Process.run('git', ['show', '-s', '--pretty=format:"%h - %ct"', "HEAD"])).stdout as String;
    final hash = gitInfo.substring(1, 9);
    final date = int.parse(gitInfo.substring(12, gitInfo.length - 1));

    final String content = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
const String kCommitHash = "$hash";
const int kCommitTimestamp = $date;''';
    File('lib/generated/git_info.dart').writeAsStringSync(content);
  } catch (e, s) {
    if (args.contains('-s')) {
      print(e);
      print(s);
    } else {
      rethrow;
    }
  }
}
