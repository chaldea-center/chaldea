class AppVersion implements Comparable<AppVersion> {
  /// valid format:
  ///   - v1.2.3+4,'v' and +4 is optional
  ///   - 1.2.3.4, windows format
  static final RegExp _fullVersionRegex =
      RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:[+.](\d+))?$', caseSensitive: false);
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
    if (major == _other.major &&
        minor == _other.minor &&
        patch == _other.patch) {
      return build == null || _other.build == null || build == _other.build;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return '$runtimeType($major, $minor, $patch${build == null ? "" : ", $build"})';
  }

  static AppVersion parse(String versionString) {
    return tryParse(versionString)!;
  }

  static AppVersion? tryParse(String versionString, [int? build]) {
    versionString = versionString.trim();
    if (!_fullVersionRegex.hasMatch(versionString)) {
      if (versionString.isNotEmpty &&
          !['svt_icons', 'ffo-data'].contains(versionString)) {
        print('invalid version string');
      }
      return null;
    }
    Match match = _fullVersionRegex.firstMatch(versionString)!;
    int major = int.parse(match.group(1)!);
    int minor = int.parse(match.group(2)!);
    int patch = int.parse(match.group(3)!);
    int? _build = int.tryParse(match.group(4) ?? '');
    return AppVersion(major, minor, patch, build ?? _build);
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
