import 'dart:convert';
import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/tools/backup_backend/github.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class GithubBackupPage extends StatefulWidget {
  const GithubBackupPage({super.key});

  @override
  State<GithubBackupPage> createState() => _GithubBackupPageState();
}

class _GithubBackupPageState extends State<GithubBackupPage> {
  late TextEditingController _ownerController;
  late TextEditingController _repoController;
  late TextEditingController _pathController;
  late TextEditingController _tokenController;
  late TextEditingController _branchController;
  late TextEditingController _messageController;

  GithubSetting get config => db.settings.github;

  late GithubBackup backend;
  bool _enableEdit = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    _ownerController = TextEditingController(text: config.owner);
    _repoController = TextEditingController(text: config.repo);
    _pathController = TextEditingController(text: config.path);
    _tokenController = TextEditingController(text: config.token);
    _branchController = TextEditingController(text: config.branch);
    _messageController = TextEditingController();
    backend = GithubBackup<UserData>(config: config, encode: encodeUserdata, decode: decodeUserdata);
    _enableEdit = validate() != null;
  }

  List<int> encodeUserdata() {
    String content;
    if (config.indent) {
      content = const JsonEncoder.withIndent('  ').convert(db.userData);
    } else {
      content = jsonEncode(db.userData);
    }
    return utf8.encode(content);
  }

  UserData decodeUserdata(List<int> content) {
    final data = jsonDecode(utf8.decode(content)) as Map;
    if (data['version'] == null) {
      throw const FormatException("Not chaldea data format");
    }
    return db.userData = UserData.fromJson(Map.from(data));
  }

  Future<void> backup() async {
    try {
      await showEasyLoading(() => backend.backup(message: message.isNotEmpty ? message : null));
      EasyLoading.showSuccess(S.current.success);
      db.saveAll();
    } on ConflictError catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) {
          return SimpleCancelOkDialog(
            title: const Text('Conflict'),
            content: Text('$e\n\nYou can clear local sha then upload again to overwrite remote content.'),
          );
        },
      );
    } catch (e, s) {
      EasyLoading.dismiss();
      logger.e('github backup failed', e, s);
      if (!mounted) return;
      SimpleCancelOkDialog(
        title: const Text('Error'),
        content: Text(escapeDioException(e)),
        hideCancel: true,
      ).showDialog(context);
    }
    if (mounted) setState(() {});
  }

  Future<void> restore() async {
    try {
      await showEasyLoading(() => backend.restore());
      EasyLoading.showSuccess(S.current.success);
      db.saveAll();
    } catch (e, s) {
      EasyLoading.dismiss();
      logger.e('github restore failed', e, s);
      if (!mounted) return;
      SimpleCancelOkDialog(
        title: const Text('Error'),
        content: Text(escapeDioException(e)),
        hideCancel: true,
      ).showDialog(context);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Github Backup'),
        actions: [
          IconButton(
            icon: Icon(_enableEdit ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _enableEdit = !_enableEdit;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (!_enableEdit) ...[
            ListTile(dense: true, title: const Text('owner'), trailing: Text(config.owner)),
            ListTile(dense: true, title: const Text('repo'), trailing: Text(config.repo)),
            ListTile(
              dense: true,
              title: const Text('branch/ref'),
              trailing: Text(
                config.branch.trim().isEmpty ? '(default)' : config.branch.substring(0, min(7, config.branch.length)),
              ),
            ),
            ListTile(dense: true, title: const Text('path'), trailing: Text(config.path)),
            ListTile(
              dense: true,
              title: const Text('token'),
              trailing: Text(config.token.isEmpty ? 'empty' : '******'),
            ),
          ],
          if (_enableEdit) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextFormField(
                enabled: _enableEdit,
                controller: _ownerController,
                decoration: const InputDecoration(labelText: 'owner', border: OutlineInputBorder()),
                onChanged: (s) {
                  config.owner = s.trim();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextFormField(
                enabled: _enableEdit,
                controller: _repoController,
                decoration: const InputDecoration(labelText: 'repo', border: OutlineInputBorder()),
                onChanged: (s) {
                  config.repo = s.trim();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextFormField(
                enabled: _enableEdit,
                controller: _branchController,
                decoration: const InputDecoration(
                  labelText: 'branch (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'ref for download',
                ),
                onChanged: (s) {
                  config.branch = s.trim();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextFormField(
                enabled: _enableEdit,
                controller: _pathController,
                decoration: const InputDecoration(
                  labelText: 'path',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. chaldea-backup.json',
                ),
                onChanged: (s) {
                  config.path = s.trim();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextFormField(
                enabled: _enableEdit,
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'token',
                  border: OutlineInputBorder(),
                  helperText: '<repo> scope permission is required.',
                ),
                obscureText: true,
                onChanged: (s) {
                  config.token = s.trim();
                },
              ),
            ),
          ],
          SwitchListTile.adaptive(
            dense: true,
            value: config.indent,
            title: const Text('Indent with 2 spaces'),
            subtitle: const Text('saved in json format'),
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged:
                _enableEdit
                    ? (v) {
                      setState(() {
                        config.indent = v;
                      });
                    }
                    : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'commit message',
                border: const OutlineInputBorder(),
                hintText: DateTime.now().toStringShort(omitSec: false),
              ),
              onChanged: (s) {
                message = s.trim();
              },
            ),
          ),
          ListTile(
            dense: true,
            title: const Text('Local SHA'),
            subtitle: Text(config.sha?.substring(0, min(8, config.sha?.length ?? 0)) ?? 'null'),
            trailing: IconButton(
              onPressed: () {
                SimpleCancelOkDialog(
                  title: const Text('Clear local sha'),
                  content: const Text("Will use the latest sha and make it possible to overwrite remote content"),
                  onTapOk: () {
                    config.sha = null;
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              },
              icon: const Icon(Icons.clear),
              tooltip: 'Clear local sha (able to overwrite remote content)',
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              FilledButton(
                onPressed: () {
                  final error = validate();
                  if (error != null) {
                    EasyLoading.showError(error);
                    return;
                  }
                  backup();
                },
                child: Text(S.current.upload),
              ),
              FilledButton(
                onPressed: () {
                  final error = validate();
                  if (error != null) {
                    EasyLoading.showError(error);
                    return;
                  }
                  restore();
                },
                child: Text(S.current.download),
              ),
            ],
          ),
          const Divider(),
          Center(
            child: TextButton(
              onPressed: () {
                launch('https://github.com/settings/tokens/new?description=chaldea&scopes=repo');
              },
              style: kTextButtonDenseStyle,
              child: const Text('Create token for chaldea', textScaler: TextScaler.linear(0.9)),
            ),
          ),
          Text('~~~ Github docs ~~~', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          Center(
            child: TextButton(
              onPressed: () {
                launch(
                  'https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token',
                );
              },
              style: kTextButtonDenseStyle,
              child: const Text('Create a personal access token', textScaler: TextScaler.linear(0.9)),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                launch('https://docs.github.com/en/rest/repos/contents#create-or-update-file-contents');
              },
              style: kTextButtonDenseStyle,
              child: const Text('Create or update file contents', textScaler: TextScaler.linear(0.9)),
            ),
          ),
          const SafeArea(child: SizedBox()),
        ],
      ),
    );
  }

  String? validate() {
    List<String> msg = [];
    void _check(String s, String key) {
      if (s.isEmpty) {
        msg.add('$key is empty');
      } else if (s.contains(' ')) {
        msg.add('$key cannot contains space');
      }
    }

    _check(config.owner, 'owner');
    _check(config.repo, 'repo');
    _check(config.path, 'path');
    if (config.path.startsWith('/')) {
      msg.add('Path cannot start with /');
    }
    if (!(config.token.length == 40 || config.token.length == 93)) {
      msg.add('Token must be 40 or 93 chars');
    }
    return msg.isEmpty ? null : msg.join('\n');
  }

  @override
  void dispose() {
    super.dispose();
    _ownerController.dispose();
    _repoController.dispose();
    _pathController.dispose();
    _tokenController.dispose();
    _branchController.dispose();
    _messageController.dispose();
  }
}
