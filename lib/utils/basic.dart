import 'package:path/path.dart' as pathlib;

String joinPaths(
  String part1, [
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
  String? part8,
]) {
  return pathlib.join(part1, part2, part3, part4, part5, part6, part7, part8);
}
