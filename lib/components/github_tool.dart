//@dart=2.12
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:github/github.dart';
import 'package:path/path.dart' as pathlib;

/// specific [asset] in [release]
class ReleaseInfo {
  Release release;
  ReleaseAsset asset;

  ReleaseInfo(this.release, this.asset);
}

class GithubTool {
  static Future<ReleaseInfo?> _latestReleaseAsset(
      RepositorySlug slug, bool test(String assetName)) async {
    final github = GitHub();
    // tags: newest->oldest
    final releases = await github.repositories.listReleases(slug).toList();
    for (var release in releases) {
      for (var asset in release.assets) {
        if (test(asset.name)) {
          return ReleaseInfo(release, asset);
        }
      }
    }
  }

  static Future<ReleaseInfo?> latestAppRelease() async {
    if (Platform.isAndroid || Platform.isWindows) {
      RepositorySlug slug = RepositorySlug('narumishi', 'chaldea');
      String keyword = Platform.operatingSystem;
      return _latestReleaseAsset(slug, (assetName) {
        print(assetName);
        return assetName.toLowerCase().contains(keyword);
      });
    }
  }

  static Future<ReleaseInfo?> latestDatasetRelease(
      [bool fullSize = true]) async {
    RepositorySlug slug = RepositorySlug('narumishi', 'chaldea-dataset');
    return _latestReleaseAsset(
      slug,
      (assetName) =>
          assetName.toLowerCase() ==
          (fullSize ? 'dataset.zip' : 'dataset-text.zip'),
    );
  }
}

/// TODO: move to other place, more customizable
class DownloadDialog extends StatefulWidget {
  final String url;
  final String savePath;

  /// displayed if Dio cannot resolve file size
  final int? fileSize;
  final VoidCallback? onComplete;

  const DownloadDialog(
      {Key? key,
      required this.url,
      required this.savePath,
      this.fileSize,
      this.onComplete})
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
    String statusText = status == 0 ? '下载中' : '下载完成';
    if (total < 0) {
      if (widget.fileSize == null) {
        progress = '$statusText...';
      } else {
        String size = _sizeInMB(widget.fileSize!);
        progress = '共$size, $statusText...';
      }
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
      title: Text('下载'),
      content: Text('文件名: $fn\n$progress'),
      actions: [
        if (status <= 0)
          TextButton(
            onPressed: () {
              _cancelToken.cancel('user canceled');
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).cancel),
          ),
        if (status < 0) TextButton(onPressed: startDownload, child: Text('下载')),
        if (status > 0)
          TextButton(
            onPressed: () {
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text('完成'),
          )
      ],
    );
  }
}
