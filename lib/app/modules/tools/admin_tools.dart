import 'package:dio/dio.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class AdminToolsPage extends StatefulWidget {
  const AdminToolsPage({super.key});

  @override
  State<AdminToolsPage> createState() => _AdminToolsPageState();
}

class _AdminToolsPageState extends State<AdminToolsPage> {
  List<Response> responses = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Tools')),
      body: ListView(
        children: [
          TileGroup(
            header: 'Actions',
            children: [
              ListTile(title: Text('DB GC'), onTap: () => callRequest('POST', '/api/v4/admin/db-gc')),
              ListTile(
                title: Text('Chaldea Update'),
                onTap: () => callRequest('POST', '/webhook/check-chaldea-update'),
              ),
              ListTile(title: Text('Neon Metrics'), onTap: () => callRequest('GET', '/api/v4/admin/neon-metrics')),
            ],
          ),
          for (final resp in responses.reversed)
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${resp.statusCode} ${resp.requestOptions.method} ${resp.realUri}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(resp.data.toString()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<Response?> callRequest(String method, String url) async {
    final confirm = await SimpleConfirmDialog(title: Text(S.current.confirm)).showDialog(context);
    if (confirm != true) return null;
    final resp = await showEasyLoading(() async {
      return await ChaldeaWorkerApi.createDio().request(
        url,
        options: ChaldeaWorkerApi.addAuthHeader(options: Options(validateStatus: (_) => true, method: method)),
      );
    });
    responses.add(resp);
    if (mounted) setState(() {});
    return resp;
  }
}
