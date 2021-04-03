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
  String? url;
  late GitTool gitTool;

  @override
  void initState() {
    super.initState();
    gitTool = GitTool.fromDb();
    gitTool
        .latestAppRelease((asset) => asset.name == 'ffo.zip')
        .then((_release) {
      release = _release;
      url = release?.targetAsset?.browserDownloadUrl;
    }).catchError((error, stackTrace) {
      logger.e('resolve ${gitTool.source.toShortString()} release failed', error, stackTrace);
    }).whenComplete(() {
      resolving = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.import_data + ' FFO data'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resolving) Text('resolving download url'),
          if (!resolving && url != null) Text('将从以下地址下载或自行下载后导入：'),
          if (!resolving && url == null) Text('url解析失败，请前往以下网址查找并下载ffo-data'),
          InkWell(
            child: Text(
              url ?? gitTool.ffoDataReleaseUrl,
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            onTap: () {
              launch(url ?? gitTool.ffoDataReleaseUrl);
            },
          )
        ],
      ),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: () async {
            try {
              final file = await FilePickerCross.importFromStorage();
              await _extractZip(file.path);
              Navigator.pop(context);
            } on FileSelectionCanceledError {}
            if (mounted) setState(() {});
          },
          child: Text(S.current.import_data),
        ),
        TextButton(
          onPressed: () {
            String fp = join(db.paths.tempDir, 'ffo.zip');
            if (url == null) {
              launch(gitTool.ffoDataReleaseUrl);
              return;
            } else {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => DownloadDialog(
                  url: url,
                  savePath: fp,
                  notes: release?.body,
                  confirmText: S.of(context).import_data.toUpperCase(),
                  onComplete: () async {
                    await _extractZip(fp);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if (mounted) setState(() {});
                  },
                ),
              );
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
      if (File(join(_baseDir, 'ServantDB-Parts.csv')).existsSync()) {
        EasyLoading.showSuccess(S.current.import_data_success);
        widget.onSuccess();
      } else {
        EasyLoading.showError('文件错误或文件缺失');
      }
    } on FileSelectionCanceledError {
      EasyLoading.dismiss();
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('extract zip error', e, s);
    }
  }
}
