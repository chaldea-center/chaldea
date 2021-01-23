//@dart=2.12
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:github/github.dart' as github;
import 'package:path/path.dart' as pathlib;

const String _owner = 'narumishi';
const String _appRepo = 'chaldea';
const String _datasetRepo = 'chaldea-dataset';

enum GitSource { gitee, github }

class GitRelease {
  int id;
  String name;
  String tagName;
  String body;
  DateTime createdAt;
  List<GitAsset> assets;
  GitAsset? targetAsset;

  GitRelease(
      {required this.id,
      required this.name,
      required this.tagName,
      required this.body,
      required this.createdAt,
      required this.assets,
      this.targetAsset});

  GitRelease.fromGithub({required github.Release release})
      : id = release.id,
        name = release.name,
        tagName = release.tagName,
        body = release.body,
        createdAt = release.createdAt,
        assets = release.assets
            .map((asset) => GitAsset(
                name: asset.name, browserDownloadUrl: asset.browserDownloadUrl))
            .toList();

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
        );

  @override
  String toString() {
    return '$runtimeType($name, targetAsset=${targetAsset?.name})';
  }
}

class GitAsset {
  String name;
  String browserDownloadUrl;

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
    print('resolve ${releases.length} releases from $source');
    return releases;
  }

  GitRelease? _latestReleaseWhereAsset(
      Iterable<GitRelease> releases, bool test(GitAsset asset)) {
    for (var release in releases)
      for (var asset in release.assets)
        if (test(asset)) {
          release.targetAsset = asset;
        }
    for (var release in releases) {
      for (var asset in release.assets) {
        if (test(asset)) {
          release.targetAsset = asset;
          print('latest release: $release');
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
  final String url;
  final String savePath;
  final VoidCallback? onComplete;

  const DownloadDialog(
      {Key? key, required this.url, required this.savePath, this.onComplete})
      : super(key: key);

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  final CancelToken _cancelToken = CancelToken();
  String progress = '';
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
    try {
      final response = await _dio.download(widget.url, widget.savePath,
          cancelToken: _cancelToken, onReceiveProgress: onReceiveProgress);
      onDownloadComplete(response);
    } on DioError catch (e) {
      if (e.type != DioErrorType.CANCEL) {
        EasyLoading.showError(e.toString());
        rethrow;
      }
    }
  }

  void onReceiveProgress(int count, int total) {
    String statusText =
        status == 0 ? S.current.downloading : S.current.downloaded;
    if (total < 0) {
      progress = '$statusText...';
    } else {
      String percent = formatNumber(count / total, percent: true);
      String size = _sizeInMB(total);
      String downSize = _sizeInMB(count);
      progress = '$statusText: $downSize/$size ($percent)';
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
    return AlertDialog(
      title: Text(S.of(context).download),
      content: widget.url.isNotEmpty
          ? Text('${S.of(context).filename}: $fn\n$progress')
          : Text(S.of(context).query_failed),
      actions: [
        if (status <= 0)
          TextButton(
            onPressed: () {
              _cancelToken.cancel('user canceled');
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).cancel),
          ),
        if (status < 0 && widget.url.isNotEmpty)
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
