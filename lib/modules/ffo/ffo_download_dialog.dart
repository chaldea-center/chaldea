part of ffo;

class FfoDownloadDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const FfoDownloadDialog({Key? key, required this.onSuccess})
      : super(key: key);

  @override
  _FfoDownloadDialogState createState() => _FfoDownloadDialogState();
}

class _FfoDownloadDialogState extends State<FfoDownloadDialog> {
  String url = '';

  @override
  void initState() {
    super.initState();
    url = db.appSetting.gitSource == GitSource.github
        ? 'https://github.com/chaldea-center/chaldea/releases/download/ffo-data/ffo.zip'
        : 'https://download.fastgit.org/chaldea-center/chaldea/releases/download/ffo-data/ffo.zip';
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformU.isWeb) {
      return SimpleCancelOkDialog(
        title: Text(S.current.import_data + ' FFO data'),
        content: const Text('Not supported on web'),
        hideCancel: true,
      );
    }
    return SimpleCancelOkDialog(
      title: Text(S.current.import_data + ' FFO data'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(LocalizedText.of(
            chs: '自动下载或手动下载后导入zip',
            jpn: '自動ダウンロードまたは手動ダウンロード後にzipをインポートする',
            eng: 'Auto Download or import manual downloaded zip file',
          )),
          InkWell(
            child: Text(
              url,
              style: const TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            onTap: () {
              launch(url);
            },
          ),
          Text(LocalizedText.of(
            chs: '若导入出错，请参考文档手动解压至目标文件夹',
            jpn: 'インポート中にエラーが発生した場合は、ドキュメントを参照して、ターゲットフォルダに手動で抽出してください。',
            eng:
                'If there is an error in importing, please refer to the docs to manually extract it to the target folder',
          ))
        ],
      ),
      hideOk: true,
      hideCancel: true,
      actions: [
        TextButton(
          onPressed: () async {
            final file = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
            if (file?.paths.first != null) {
              await _extractZip(file!.paths.first!);
            }
            Navigator.pop(context);
            if (mounted) setState(() {});
          },
          child: Text(S.current.import_data),
        ),
        TextButton(
          onPressed: () async {
            String fp = join(db.paths.tempDir, 'ffo.zip');
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => DownloadDialog(
                url: url,
                savePath: fp,
                confirmText: S.of(context).import_data.toUpperCase(),
                onComplete: () async {
                  await _extractZip(fp);
                  Navigator.pop(context);
                  if (mounted) setState(() {});
                },
              ),
            );
            await Future.delayed(const Duration(seconds: 1));
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
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('extract zip error', e, s);
    } finally {
      EasyLoadingUtil.dismiss();
    }
  }
}
