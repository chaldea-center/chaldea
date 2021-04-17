import 'dart:convert';

import 'package:chaldea/components/components.dart';

class AccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
                    errorText: S.of(context).input_invalid_hint,
                    validate: (v) =>
                        v == v.trim() && !db.userData.users.containsKey(v),
                    onSubmit: addUser,
                  );
                },
              );
            },
          )
        ],
      ),
      body: TileGroup(
        children: db.userData.users.keys.map((userKey) {
          final bool _isCurUser = userKey == db.userData.curUserKey;
          int index = db.userData.users.keys.toList().indexOf(userKey);
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
                Text(db.userData.users[userKey]!.name)
              ],
            ),
            selected: _isCurUser,
            trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Text(S.of(context).rename),
                ),
                PopupMenuItem(
                  value: 'move_up',
                  child: Text('上移'),
                  enabled: index != 0,
                ),
                PopupMenuItem(
                  value: 'move_down',
                  child: Text('下移'),
                  enabled: index != db.userData.users.length - 1,
                ),
                PopupMenuItem(value: 'copy', child: Text(S.of(context).copy)),
                PopupMenuItem(
                  value: 'clear',
                  child: Text(S.of(context).clear),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(S.of(context).delete),
                ),
              ],
              onSelected: (k) {
                switch (k) {
                  case 'rename':
                    renameUser(userKey);
                    break;
                  case 'copy':
                    copyUser(userKey);
                    break;
                  case 'clear':
                    clearUser(userKey);
                    break;
                  case 'delete':
                    deleteUser(userKey);
                    break;
                  case 'move_up':
                    moveUser(userKey, -1);
                    break;
                  case 'move_down':
                    moveUser(userKey, 1);
                    break;
                  default:
                    break;
                }
              },
            ),
            onTap: () {
              db.userData.curUserKey = userKey;
              updateData();
            },
          );
        }).toList(),
      ),
    );
  }

  void addUser(String name) {
    String newKey = DateTime.now().millisecondsSinceEpoch.toString();
    db.userData.users[newKey] = User(name: name);
    db.userData.curUserKey = newKey;
    updateData();
    logger.d('Add account $newKey(name:$name)');
  }

  void renameUser(String key) {
    final user = db.userData.users[key]!;
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
          db.notifyAppUpdate();
        },
      ),
    );
  }

  void moveUser(String key, int dx) {
    final keys = db.userData.users.keys.toList();
    int curIndex = keys.indexOf(key);
    int nextIndex = curIndex + dx;
    nextIndex = fixValidRange(nextIndex, 0, keys.length - 1);
    keys.insert(nextIndex, keys.removeAt(curIndex));
    db.userData.users =
        Map.fromIterable(keys, value: (k) => db.userData.users[k]!);
    setState(() {});
  }

  void copyUser(String key) {
    int i = 2;
    String newName;
    String oldName = db.userData.users[key]!.name;
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

  void clearUser(String key) {
    final user = db.userData.users[key]!;
    user.servants.clear();
    user.duplicatedServants.clear();
    user.items.clear();
    user.events.mainRecords.clear();
    user.events.limitEvents.clear();
    user.events.exchangeTickets.clear();
    user.servantPlans.forEach((e) => e.clear());
    user.mysticCodes.clear();
    user.plannedSummons.clear();
    user.msProgress = -1;
    db.gameData.updateUserDuplicatedServants();
    db.notifyDbUpdate();
  }

  void deleteUser(String key) {
    print('delete user key $key...');
    final canDelete = db.userData.users.length > 1;
    if (!db.userData.users.containsKey(key)) {
      SimpleCancelOkDialog(
        content: Text('User key $key not found'),
      ).showDialog(context);
      return;
    }
    setState(() {
      final user = db.userData.users[key]!;
      SimpleCancelOkDialog(
        title: Text('Delete ${user.name}'),
        content:
            canDelete ? null : Text('Cannot delete, at least one account!'),
        onTapOk: canDelete
            ? () {
                db.userData.users.remove(key);
                if (db.userData.curUserKey == key) {
                  db.userData.curUserKey = db.userData.users.keys.first;
                }
                updateData();
                print('accounts: ${db.userData.users.keys.toList()}');
              }
            : null,
      ).showDialog(context);
    });
  }

  void updateData() {
    setState(() {});
    db.itemStat.update(lapse: Duration(seconds: 1));
    db.notifyAppUpdate();
  }
}
