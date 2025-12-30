import 'package:chaldea/models/gamedata/_helper.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';

part '../../generated/models/userdata/version.g.dart';

class AppVersion implements Comparable<AppVersion> {
  /// valid format:
  ///   - v1.2.3+4,'v' and +4 is optional
  ///   - 1.2.3.4, windows format
  static final RegExp _fullVersionRegex = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:[+.](\d+))?$', caseSensitive: false);
  final int major;
  final int minor;
  final int patch;
  final int? build;

  const AppVersion(this.major, this.minor, this.patch, [this.build]);

  String get versionString => '$major.$minor.$patch';

  String get fullVersion => versionString + (build == null ? '' : '+$build');

  /// compare [build] here
  bool equalTo(String other) {
    AppVersion? _other = AppVersion.tryParse(other);
    if (_other == null) return false;
    if (major == _other.major && minor == _other.minor && patch == _other.patch) {
      return build == null || _other.build == null || build == _other.build;
    } else {
      return false;
    }
  }

  factory AppVersion.fromJson(String s) => tryParse(s) ?? AppVersion(0, 0, 0);

  String toJson() => fullVersion;

  @override
  String toString() {
    return '$runtimeType($major, $minor, $patch${build == null ? "" : ", $build"})';
  }

  static AppVersion parse(String versionString) {
    return tryParse(versionString)!;
  }

  static AppVersion? tryParse(String versionString, [int? build]) {
    versionString = versionString.trim();
    Match? match = _fullVersionRegex.firstMatch(versionString);
    if (match == null) return null;
    int major = int.parse(match.group(1)!);
    int minor = int.parse(match.group(2)!);
    int patch = int.parse(match.group(3)!);
    int? _build = int.tryParse(match.group(4) ?? '');
    return AppVersion(major, minor, patch, build ?? _build);
  }

  static int compare(String a, String b) {
    return AppVersion.parse(a).compareTo(AppVersion.parse(b));
  }

  @override
  int compareTo(AppVersion other) {
    // build(nullable) then major/minor/patch
    // if (build != null && other.build != null && build != other.build) {
    //   return build!.compareTo(other.build!);
    // }
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    return 0;
  }

  @override
  bool operator ==(Object other) {
    return other is AppVersion && compareTo(other) == 0;
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;

  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  bool operator >(AppVersion other) => compareTo(other) > 0;

  bool operator >=(AppVersion other) => compareTo(other) >= 0;

  @override
  int get hashCode => toString().hashCode;
}

@JsonSerializable()
class VersionConstraints {
  int? maxTimestamp; // fail if t<=maxT
  int? minTimestamp; // fail if t>=maxT
  AppVersion? maxVersion;
  AppVersion? minVersion;

  VersionConstraints({this.maxTimestamp, this.minTimestamp, this.maxVersion, this.minVersion});

  factory VersionConstraints.fromJson(Map<String, dynamic> json) => _$VersionConstraintsFromJson(json);
  Map<String, dynamic> toJson() => _$VersionConstraintsToJson(this);

  bool validate({int? timestamp, AppVersion? version}) {
    if (timestamp != null) {
      if (maxTimestamp != null && timestamp <= maxTimestamp!) return false;
      if (minTimestamp != null && timestamp >= minTimestamp!) return false;
    }
    if (version != null) {
      if (maxVersion != null && version <= maxVersion!) return false;
      if (minVersion != null && version >= minVersion!) return false;
    }
    return true;
  }

  bool isThisAppInvalid() => !validate(timestamp: AppInfo.commitTimestamp, version: AppInfo.version);

  String toFriendlyString() {
    final buffer = StringBuffer();
    if (minTimestamp != null || maxTimestamp != null) {
      if (minTimestamp != null) buffer.write(minTimestamp!.sec2date().toDateString());
      buffer.write('~');
      if (maxTimestamp != null) buffer.write(maxTimestamp!.sec2date().toDateString());
    }
    if (minVersion != null || maxVersion != null) {
      if (buffer.isNotEmpty) buffer.write(', ');
      if (minVersion != null) buffer.write(minVersion!.toString());
      if (maxVersion != null) buffer.write(maxVersion!.toString());
    }
    return buffer.toString();
  }
}

@JsonSerializable()
class VersionConstraintsSetting {
  VersionConstraints? app;
  VersionConstraints? laplace;
  VersionConstraints? sniff;

  VersionConstraintsSetting({this.app, this.laplace, this.sniff});

  factory VersionConstraintsSetting.fromJson(Map<String, dynamic> json) => _$VersionConstraintsSettingFromJson(json);
  Map<String, dynamic> toJson() => _$VersionConstraintsSettingToJson(this);
}
