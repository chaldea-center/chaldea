import 'dart:io';
import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

/// Personal Usage
class HiddenToolsPage extends StatefulWidget {
  const HiddenToolsPage({super.key});

  @override
  State<HiddenToolsPage> createState() => _HiddenToolsPageState();
}

class _HiddenToolsPageState extends State<HiddenToolsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Y(^o^)Y')),
      body: ListView(children: [spaceTile]),
    );
  }

  Widget get spaceTile {
    final folder = joinPaths(db.paths.tempDir, '__temp_fill_space');
    return ListTile(
      title: const Text('Create Temp File'),
      onTap: () {
        InputCancelOkDialog(
          title: "Size(MB)",
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSubmit: (s) async {
            if (!mounted) return;
            final sizeInMB = double.tryParse(s);
            if (sizeInMB == null || sizeInMB <= 0) return;
            String fmtMB(int v) => '${(v / 1024 / 1024).toStringAsFixed(1)}MB';

            IOSink? ioSink;
            try {
              Directory(folder).createSync(recursive: true);
              final file = File(joinPaths(folder, 'tmp_${DateTime.now().timestamp}.bin'));
              int bytesToWrite = (sizeInMB * 1024 * 1024).toInt();

              ioSink = file.openWrite(mode: FileMode.writeOnlyAppend);
              const int piece = 10 * 1024 * 1024;
              int writtenBytes = 0;
              while (writtenBytes < bytesToWrite) {
                final len = min(piece, bytesToWrite - writtenBytes);
                ioSink.add(List.filled(len, 0));
                writtenBytes += len;
                await ioSink.flush();
                EasyLoading.showProgress(writtenBytes / bytesToWrite, status: '${fmtMB(writtenBytes)}/${sizeInMB}MB');
              }
              EasyLoading.showSuccess('Done');
            } catch (e, s) {
              logger.e('create tmp file failed ($sizeInMB)MB', e, s);
              EasyLoading.showError(e.toString(), duration: const Duration(seconds: 10));
            } finally {
              ioSink?.close();
            }
          },
        ).showDialog(context);
      },
      onLongPress: () {
        try {
          final dir = Directory(folder);
          if (dir.existsSync()) dir.deleteSync(recursive: true);
          EasyLoading.showToast('Deleted');
        } catch (e) {
          EasyLoading.showError(e.toString());
        }
      },
    );
  }
}
