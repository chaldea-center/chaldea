import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<User> get users => db2.userData.users;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.cur_account),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: S.current.new_account,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return InputCancelOkDialog(
                    title: S.current.new_account,
                    errorText: S.current.input_invalid_hint,
                    validate: (v) =>
                        v == v.trim() &&
                        v.isNotEmpty &&
                        users.every((e) => e.name != v),
                    onSubmit: addUser,
                  );
                },
              );
            },
          )
        ],
      ),
      body: TileGroup(
        children: List.generate(
          users.length,
          (index) {
            final user = users[index];
            return RadioListTile<int>(
              value: index,
              groupValue: db2.userData.curUserKey,
              onChanged: (v) {
                if (v != null) {
                  db2.userData.curUserKey = v;
                  updateData(true);
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(user.name),
              secondary: PopupMenuButton(
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: Text(S.current.rename),
                    onTap: () => renameUser(user),
                  ),
                  PopupMenuItem(
                    child: Text(S.current.move_up),
                    enabled: index != 0,
                    onTap: () => moveUser(index, -1),
                  ),
                  PopupMenuItem(
                    child: Text(S.current.move_down),
                    enabled: index != users.length - 1,
                    onTap: () => moveUser(index, 1),
                  ),
                  PopupMenuItem(
                    child: Text(S.current.copy),
                    onTap: () => copyUser(index),
                  ),
                  PopupMenuItem(
                    child: Text(S.current.clear),
                    onTap: () => clearUser(index),
                  ),
                  PopupMenuItem(
                    child: Text(S.current.delete),
                    enabled: users.length > 1,
                    onTap: () => deleteUser(index),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void addUser(String name) {
    users.add(User(name: name));
    db2.userData.curUserKey = users.length - 1;
    updateData(true);
  }

  void renameUser(User user) async {
    await Future.delayed(Duration.zero);
    showDialog(
      context: context,
      builder: (context) => InputCancelOkDialog(
        title: '${S.current.rename} - ${user.name}',
        text: user.name,
        errorText: S.current.input_invalid_hint,
        validate: (v) {
          return v == v.trim() &&
              v.isNotEmpty &&
              users.every((e) => e.name != v);
        },
        onSubmit: (v) {
          user.name = v;
          updateData();
        },
      ),
    );
  }

  void moveUser(int key, int dx) {
    int newIndex = dx < 0 ? key - dx : key + dx - 1;
    final user = users.removeAt(key);
    users.insert(newIndex, user);
    db2.userData.curUserKey = users.indexOf(user);
    updateData();
  }

  void copyUser(int key) {
    final originUser = users[key];
    final newUser = User.fromJson(originUser.toJson());
    newUser.name = db2.userData.validUsername(newUser.name);
    users.add(newUser);
    updateData();
  }

  void clearUser(int key) async {
    final user = users[key];
    await Future.delayed(Duration.zero);
    SimpleCancelOkDialog(
      title: const Text('Clear Data'),
      content: Text('Account: ${user.name}'),
      onTapOk: () {
        user.servants.clear();
        user.items.clear();
        user.svtPlanGroups.forEach((e) => e.clear());
        user.mysticCodes.clear();
        updateData(key == db2.userData.curUserKey);
      },
    ).showDialog(context);
  }

  void deleteUser(int key) async {
    await Future.delayed(Duration.zero);
    print('delete user key $key...');
    final user = users[key];
    SimpleCancelOkDialog(
      title: Text('Delete ${user.name}'),
      onTapOk: () {
        bool needCalc = key == db2.userData.curUserKey;
        users.removeAt(key);
        db2.userData.validate();
        updateData(needCalc);
      },
    ).showDialog(context);
  }

  void updateData([bool needCalc = false]) async {
    if (mounted) setState(() {});
    if (needCalc) {
      db2.itemCenter.init();
    }
    db2.notifyUserdata();
  }
}
