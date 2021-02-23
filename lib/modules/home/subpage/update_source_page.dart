//@dart=2.9
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateSourcePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpdateSourcePageState();
}

class _UpdateSourcePageState extends State<UpdateSourcePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).download_source),
        leading: BackButton(),
      ),
      body: TileGroup(
        children: List.generate(GitSource.values.length, (index) {
          final bool _isCur = index == db.userData.updateSource;
          String source = GitSource.values[index].toTitleString();
          return ListTile(
            leading: Icon(
              Icons.check,
              // size: 18.0,
              color:
                  _isCur ? Theme.of(context).primaryColor : Colors.transparent,
            ),
            title: Text(source),
            selected: _isCur,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    launch(GitTool.getReleasePageUrl(index, false));
                  },
                  child: Text('DATA'),
                ),
                TextButton(
                  onPressed: () {
                    // macOS has App Store version and Developer distribution
                    if (Platform.isIOS) {
                      launch(kAppStoreLink);
                    } else {
                      launch(GitTool.getReleasePageUrl(index, true));
                    }
                  },
                  child: Text('APP'),
                )
              ],
            ),
            onTap: () {
              db.userData.updateSource = index;
              db.onAppUpdate();
            },
            horizontalTitleGap: 0,
          );
        }).toList(),
      ),
    );
  }

  void addUser(String name) {
    String newKey = DateTime.now().millisecondsSinceEpoch.toString();
    db.userData.users[newKey] = User(name: name);
    db.userData.curUserKey = newKey;
    db.onAppUpdate();
    logger.d('Add account $newKey(name:$name)');
  }

  void renameUser(String key) {
    final user = db.userData.users[key];
    showDialog(
      context: context,
      builder: (context) => InputCancelOkDialog(
        title: '${S.of(context).rename} - ${user.name}',
        text: user.name,
        errorText: S.of(context).input_invalid_hint,
        validate: (v) {
          return v == v.trim() && !db.userData.userNames.contains(v);
        },
        onSubmit: (v) {
          user.name = v;
          db.onAppUpdate();
        },
      ),
    );
  }

  void copyUser(String key) {
    int i = 2;
    String newName;
    String oldName = db.userData.users[key].name;
    do {
      newName = '$oldName ($i)';
      i++;
    } while (db.userData.users.values.any((user) => user.name == newName));
    String newKey = DateTime.now().millisecondsSinceEpoch.toString();
    db.userData.users[newKey] =
        User.fromJson(json.decode(json.encode(db.userData.users[key])))
          ..name = newName;
    logger.d('Copy user $key($oldName)->$newKey($newName)');
  }

  void deleteUser(String key) {
    print('delete user key $key...');
    final canDelete = db.userData.users.length > 1;
    setState(() {
      SimpleCancelOkDialog(
        title: Text('Delete ${db.userData.users[key].name}'),
        content:
            canDelete ? null : Text('Cannot delete, at least one account!'),
        onTapOk: canDelete
            ? () {
                db.userData.users.remove(key);
                if (db.userData.curUserKey == key) {
                  db.userData.curUserKey = db.userData.users.keys.first;
                }
                db.onAppUpdate();
                print('accounts: ${db.userData.users.keys.toList()}');
              }
            : null,
      ).show(context);
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }
}
