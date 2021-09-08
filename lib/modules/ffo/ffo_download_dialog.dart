part of ffo;

class FfoDownloadDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  FfoDownloadDialog({required this.onSuccess});

  @override
  _FfoDownloadDialogState createState() => _FfoDownloadDialogState();
}

class _FfoDownloadDialogState extends State<FfoDownloadDialog> {
  bool resolving = true;
  GitRelease? release;
  List<GitAsset> assets = [];
  late GitTool gitTool;

  @override
  void initState() {
    super.initState();
    gitTool = GitTool.fromDb();
    gitTool
        .latestAppRelease(
            test: (asset) =>
                asset.name.contains('ffo') && asset.name.contains('zip'))
        .then((_release) {
      release = _release;
      release?.assets.forEach((asset) {
        if (asset.name.contains('ffo') && asset.browserDownloadUrl != null) {
          assets.add(asset);
        }
      });
    }).catchError((error, stackTrace) {
      logger.e('resolve ${gitTool.source.toShortString()} release failed',
          error, stackTrace);
    }).whenComplete(() {
      resolving = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformU.isWeb) {
      return SimpleCancelOkDialog(
        title: Text(S.current.import_data + ' FFO data'),
        content: Text('Not supported on web'),
        hideCancel: true,
      );
    }
    return SimpleCancelOkDialog(
      title: Text(S.current.import_data + ' FFO data'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resolving) Text('resolving download url'),
          if (!resolving && assets.isNotEmpty) Text('将从以下地址下载或自行下载后导入：'),
          if (!resolving && assets.isEmpty)
            Text('url解析失败，请前往以下网址查找并下载ffo-data'),
          for (var asset in assets)
            InkWell(
              child: Text(
                asset.browserDownloadUrl!,
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
              onTap: () {
                launch(asset.browserDownloadUrl!);
              },
            ),
          if (assets.isEmpty)
            InkWell(
              child: Text(
                gitTool.ffoDataReleaseUrl,
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
              onTap: () {
                launch(gitTool.ffoDataReleaseUrl);
              },
            ),
        ],
      ),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: () async {
            try {
              final file = await FilePickerCross.importFromStorage();
              if (file.path != null) await _extractZip(file.path!);
              Navigator.pop(context);
            } on FileSelectionCanceledError {}
            if (mounted) setState(() {});
          },
          child: Text(S.current.import_data),
        ),
        TextButton(
          onPressed: () async {
            if (assets.isEmpty) {
              launch(gitTool.ffoDataReleaseUrl);
              return;
            } else {
              for (var asset in assets) {
                String fp = join(db.paths.tempDir, asset.name);
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => DownloadDialog(
                    url: asset.browserDownloadUrl!,
                    savePath: fp,
                    notes: release?.body,
                    confirmText: S.of(context).import_data.toUpperCase(),
                    onComplete: () async {
                      await _extractZip(fp);
                      Navigator.pop(context);
                      if (mounted) setState(() {});
                    },
                  ),
                );
                await Future.delayed(Duration(seconds: 1));
              }
            }
          },
          child: Text(S.current.download),
        )
      ],
    );
  }

  Future<void> _extractZip(String fp) async {
    try {
      EasyLoading.show();
      await db.extractZip(
        bytes: File(fp).readAsBytesSync().cast<int>(),
        savePath: _baseDir,
      );
      EasyLoading.showSuccess(S.current.import_data_success);
      widget.onSuccess();
    } on FileSelectionCanceledError {
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('extract zip error', e, s);
    } finally {
      EasyLoadingUtil.dismiss();
    }
  }
}
