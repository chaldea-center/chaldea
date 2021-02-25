//@dart=2.12
import 'dart:io';

import 'package:chaldea/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:github/github.dart' as github;
import 'package:path/path.dart' as pathlib;

import 'logger.dart';
import 'utils.dart';

const String _owner = 'narumishi';
const String _appRepo = 'chaldea';
const String _datasetRepo = 'chaldea-dataset';

enum GitSource { gitee, github }

// for most enum
extension GitSourceExtension on GitSource {
  String toShortString() => this.toString().split('.').last;

  String toTitleString() {
    String s = this.toShortString();
    if (s.length > 1) {
      return s[0].toUpperCase() + s.substring(1);
    } else {
      return s;
    }
  }
}

class Version extends Comparable<Version> {
  /// valid format:
  ///   - v1.2.3+4,'v' and +4 is optional
  ///   - 1.2.3.4, windows format
  static final RegExp _fullVersionRegex =
      RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:[+.](\d+))?$', caseSensitive: false);
  final int major;
  final int minor;
  final int patch;
  final int? build;

  Version(this.major, this.minor, this.patch, [this.build]);

  String get version => '$major.$minor.$patch';

  String get fullVersion => version + (build == null ? '' : '+$build');

  bool equalTo(String other) {
    Version? _other = Version.tryParse(other);
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

  static Version? tryParse(String versionString, [int? build]) {
    versionString = versionString.trim();
    if (!_fullVersionRegex.hasMatch(versionString)) {
      logger.e(ArgumentError.value(
          versionString, 'versionString', 'Invalid version format'));
      return null;
    }
    Match match = _fullVersionRegex.firstMatch(versionString)!;
    int major = int.parse(match.group(1)!);
    int minor = int.parse(match.group(2)!);
    int patch = int.parse(match.group(3)!);
    int? _build = int.tryParse(match.group(4) ?? '');
    return Version(major, minor, patch, build ?? _build);
  }

  @override
  int compareTo(Version other) {
    // build(nullable) than major/minor/patch
    if (build != null && other.build != null && build != other.build) {
      return build!.compareTo(other.build!);
    } else {
      if (major != other.major) return major.compareTo(other.major);
      if (minor != other.minor) return minor.compareTo(other.minor);
      if (patch != other.patch) return patch.compareTo(other.patch);
      return 0;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Version && compareTo(other) == 0;
  }

  bool operator <(Version other) => compareTo(other) < 0;

  bool operator <=(Version other) => compareTo(other) <= 0;

  bool operator >(Version other) => compareTo(other) > 0;

  bool operator >=(Version other) => compareTo(other) >= 0;

  @override
  int get hashCode => toString().hashCode;
}

class GitRelease {
  int id;
  String name;
  String tagName;
  String? body;
  DateTime createdAt;
  List<GitAsset> assets;
  GitAsset? targetAsset;
  GitSource? source;

  GitRelease(
      {required this.id,
      required this.name,
      required this.tagName,
      required this.body,
      required this.createdAt,
      required this.assets,
      this.targetAsset,
      this.source});

  GitRelease.fromGithub({required github.Release release})
      : id = release.id!,
        name = release.name!,
        tagName = release.tagName!,
        body = release.body,
        createdAt = release.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        assets = release.assets
                ?.map((asset) => GitAsset(
                    name: asset.name!,
                    browserDownloadUrl: asset.browserDownloadUrl))
                .toList() ??
            [],
        source = GitSource.github;

  GitRelease.fromGitee({required Map<String, dynamic> data})
      : id = data['id'] ?? 0,
        tagName = data['tag_name'] ?? '',
        name = data['name'] ?? '',
        body = data['body'] ?? '',
        createdAt = DateTime.parse(data['created_at'] ?? '20200101'),
        assets = List.generate(
          data['assets']?.length ?? 0,
          (index) => GitAsset(
            name: data['assets'][index]['name'] ?? '',
            browserDownloadUrl:
                data['assets'][index]['browser_download_url'] ?? '',
          ),
        ),
        source = GitSource.gitee;

  @override
  String toString() {
    final src = source?.toString().split('.').last;
    return '$runtimeType($name, tagName=$tagName,'
        ' targetAsset=${targetAsset?.name}, source=$src)';
  }
}

class GitAsset {
  String name;
  String? browserDownloadUrl;

  GitAsset({required this.name, required this.browserDownloadUrl});
}

class GitTool {
  GitSource source;

  GitTool([this.source = GitSource.gitee]);

  GitTool.fromIndex(int? index)
      : source =
            (index == null || index < 0 || index >= GitSource.values.length)
                ? GitSource.values.first
                : GitSource.values[index];

  static String getReleasePageUrl(int? sourceIndex, bool appOrDataset) {
    if (sourceIndex == null ||
        sourceIndex < 0 ||
        sourceIndex >= GitSource.values.length) sourceIndex = 0;
    final source = GitSource.values[sourceIndex];
    String repo = appOrDataset ? _appRepo : _datasetRepo;
    switch (source) {
      case GitSource.github:
        return 'https://github.com/$_owner/$repo/releases';
      case GitSource.gitee:
        return 'https://gitee.com/$_owner/$repo/releases';
    }
  }

  String get owner => _owner;

  String get appRep => _appRepo;

  String get datasetRepo => _datasetRepo;

  /// For Gitee, release list is from old to new
  /// For Github, release list is from new to old
  /// sort list at last
  Future<List<GitRelease>> resolveReleases(String repo) async {
    List<GitRelease> releases = [];
    if (source == GitSource.github) {
      final slug = github.RepositorySlug(owner, repo);
      final _github = github.GitHub();
      // tags: newest->oldest
      releases = (await _github.repositories.listReleases(slug).toList())
          .map((e) => GitRelease.fromGithub(release: e))
          .toList();
    } else if (source == GitSource.gitee) {
      // response: List<Release>
      final response = await Dio().get(
        'https://gitee.com/api/v5/repos/$owner/$repo/releases',
        queryParameters: {'page': 0, 'per_page': 50},
        options: Options(
            contentType: 'application/json;charset=UTF-8',
            responseType: ResponseType.json),
      );
      // don't use map().toList(), List<dynamic> is not subtype ...
      releases = List.generate(response.data?.length ?? 0,
          (index) => GitRelease.fromGitee(data: response.data[index]));
    }
    releases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    print('resolve ${releases.length} releases from $source');
    print(releases.map((e) => e.name).toList());
    return releases;
  }

  GitRelease? _latestReleaseWhereAsset(
      Iterable<GitRelease> releases, bool test(GitAsset asset)) {
    // since releases have been sorted, don't need to traverse all releases.
    for (var release in releases) {
      for (var asset in release.assets) {
        if (test(asset)) {
          release.targetAsset = asset;
          logger.i('latest release: $release');
          return release;
        }
      }
    }
  }

  Future<GitRelease?> latestAppRelease() async {
    if (Platform.isAndroid || Platform.isWindows) {
      final releases = await resolveReleases(appRep);
      String keyword = Platform.operatingSystem;
      return _latestReleaseWhereAsset(releases, (asset) {
        return asset.name.toLowerCase().contains(keyword);
      });
    }
  }

  Future<GitRelease?> latestDatasetRelease([bool fullSize = true]) async {
    final releases = await resolveReleases(datasetRepo);
    return _latestReleaseWhereAsset(releases, (asset) {
      return asset.name.toLowerCase() ==
          (fullSize ? 'dataset.zip' : 'dataset-text.zip');
    });
  }
}

/// specific [asset] in [release]
class ReleaseInfo {
  github.Release release;
  github.ReleaseAsset asset;

  ReleaseInfo(this.release, this.asset);
}

/// TODO: move to other place, more customizable
class DownloadDialog extends StatefulWidget {
  final String? url;
  final String savePath;
  final String? notes;
  final VoidCallback? onComplete;

  const DownloadDialog(
      {Key? key,
      required this.url,
      required this.savePath,
      this.notes,
      this.onComplete})
      : super(key: key);

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  final CancelToken _cancelToken = CancelToken();
  String progress = '-';
  int status = -1;
  Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  String _sizeInMB(int bytes) {
    return (bytes / 1000000).toStringAsFixed(2) + 'MB';
  }

  Future<void> startDownload() async {
    status = 0;
    print('download from ${widget.url}');
    final t0 = DateTime.now();
    if (widget.url?.isNotEmpty != true) {
      print('url cannot be null or empty');
      return;
    }
    try {
      final response = await _dio.download(
        widget.url!,
        widget.savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      onDownloadComplete(response);
    } on DioError catch (e) {
      if (e.type != DioErrorType.CANCEL) {
        EasyLoading.showError(e.toString());
        rethrow;
      }
    }
    logger.i('Download time usage:'
        ' ${DateTime.now().difference(t0).inMilliseconds}');
  }

  void onReceiveProgress(int count, int total) {
    if (total < 0) {
      progress = _sizeInMB(count);
    } else {
      String percent = formatNumber(count / total, percent: true);
      String size = _sizeInMB(total);
      String downSize = _sizeInMB(count);
      progress = '$downSize/$size ($percent)';
    }
    setState(() {});
  }

  void onDownloadComplete(Response response) {
    status = 1;
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final fn = pathlib.basename(widget.savePath);
    final headerStyle = TextStyle(fontWeight: FontWeight.bold);
    return AlertDialog(
      title: Text(S.of(context).download),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${S.current.filename}:', style: headerStyle),
          Text(fn),
          if (widget.notes != null) Text('更新内容:', style: headerStyle),
          if (widget.notes != null) Text(widget.notes!),
          Text('下载进度:', style: headerStyle),
          widget.url?.isNotEmpty == true
              ? Text(progress)
              : Text(S.of(context).query_failed)
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _cancelToken.cancel('user canceled');
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).cancel),
        ),
        if (status < 0 && widget.url?.isNotEmpty == true)
          TextButton(
              onPressed: startDownload, child: Text(S.of(context).download)),
        if (status > 0)
          TextButton(
            onPressed: () {
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(S.of(context).ok),
          )
      ],
    );
  }
}

class StaticS extends S {}
