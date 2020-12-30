import 'package:chaldea/components/components.dart';

class AccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<String> accounts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).cur_account),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return InputCancelOkDialog(
                      title: S.of(context).new_account,
                      errorText: S.of(context).input_error,
                      validate: (v) =>
                          v == v.trim() && !db.userData.users.containsKey(v),
                      onSubmit: (v) {
                        String newKey =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        db.userData.users[newKey] = User(name: v);
                        db.userData.curUserKey = newKey;
                        db.onAppUpdate();
                        print('Add account $v(key:$newKey)');
                      },
                    );
                  });
            },
          )
        ],
      ),
      body: TileGroup(
        children: db.userData.users.keys.map((userKey) {
          final user = db.userData.users[userKey];
          final bool _isCurUser = userKey == db.userData.curUserKey;
          return ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Icon(
                    Icons.check,
                    size: 18.0,
                    color: _isCurUser
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                  ),
                ),
                Text(user.name)
              ],
            ),
            selected: _isCurUser,
            trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                    value: 'rename', child: Text(S.of(context).rename)),
                PopupMenuItem(
                    value: 'delete', child: Text(S.of(context).delete))
              ],
              onSelected: (k) {
                switch (k) {
                  case 'rename':
                    renameUser(userKey);
                    break;
                  case 'delete':
                    deleteUser(userKey);
                    break;
                  default:
                    break;
                }
              },
            ),
            onTap: () {
              db.userData.curUserKey = userKey;
              db.onAppUpdate();
            },
          );
        }).toList(),
      ),
    );
  }

  void renameUser(String key) {
    final user = db.userData.users[key];
    showDialog(
      context: context,
      builder: (context) => InputCancelOkDialog(
        title: '${S.of(context).rename} - ${user.name}',
        text: user.name,
        errorText: S.of(context).input_error,
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
