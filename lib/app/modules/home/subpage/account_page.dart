import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';

class AccountPage extends StatefulWidget {
  AccountPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<User> get users => db.userData.users;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.game_account),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: S.current.new_account,
            onPressed: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  return InputCancelOkDialog(
                    title: S.current.new_account,
                    errorText: S.current.input_invalid_hint,
                    validate: (v) => v == v.trim() && v.isNotEmpty && users.every((e) => e.name != v),
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
              groupValue: db.userData.curUserKey,
              onChanged: (v) {
                if (v != null) {
                  db.userData.curUserKey = v;
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
                    enabled: index != 0,
                    onTap: () => moveUser(index, -1),
                    child: Text(S.current.move_up),
                  ),
                  PopupMenuItem(
                    enabled: index != users.length - 1,
                    onTap: () => moveUser(index, 1),
                    child: Text(S.current.move_down),
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
                    enabled: users.length > 1,
                    onTap: () => deleteUser(index),
                    child: Text(S.current.delete),
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
    db.userData.curUserKey = users.length - 1;
    updateData(true);
  }

  void renameUser(User user) async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => InputCancelOkDialog(
        title: '${S.current.rename} - ${user.name}',
        text: user.name,
        errorText: S.current.input_invalid_hint,
        validate: (v) {
          return v == v.trim() && v.isNotEmpty && users.every((e) => e.name != v);
        },
        onSubmit: (v) {
          user.name = v;
          updateData();
        },
      ),
    );
  }

  void moveUser(int key, int dx) {
    int newIndex = key + dx;
    final user = users.removeAt(key);
    users.insert(newIndex, user);
    db.userData.curUserKey = users.indexOf(user);
    updateData();
  }

  void copyUser(int key) {
    final originUser = users[key];
    final newUser = User.fromJson(originUser.toJson());
    newUser.name = db.userData.validUsername(newUser.name);
    users.add(newUser);
    updateData();
  }

  void clearUser(int key) async {
    final user = users[key];
    await null;
    if (!mounted) return;
    SimpleCancelOkDialog(
      title: Text(S.current.clear_data),
      content: Text('${S.current.account_title}: ${user.name}'),
      onTapOk: () {
        user.servants.clear();
        user.items.clear();
        user.plans.forEach((e) => e.clear());
        user.mysticCodes.clear();
        updateData(key == db.userData.curUserKey);
      },
    ).showDialog(context);
  }

  void deleteUser(int key) async {
    await null;
    print('delete user key $key...');
    final user = users[key];
    if (!mounted) return;
    SimpleCancelOkDialog(
      title: Text('${S.current.delete} ${user.name}'),
      onTapOk: () {
        bool needCalc = key == db.userData.curUserKey;
        users.removeAt(key);
        db.userData.validate();
        updateData(needCalc);
      },
    ).showDialog(context);
  }

  void updateData([bool needCalc = false]) {
    if (mounted) setState(() {});
    if (needCalc) {
      EasyDebounce.debounce('itemCenter.init', const Duration(seconds: 1), () {
        db.itemCenter.init();
      });
    }
    db.notifyUserdata();
  }
}
