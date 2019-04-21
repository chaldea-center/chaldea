import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/settings_item.dart';
import 'package:flutter/material.dart';

typedef CustomCallback<T, V>=T Function(V value);

class AccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<String> accounts;

  TextEditingController _textEditingController = TextEditingController();
  bool _validate = true;

  void showInputDialog(context,
      {title = "", CustomCallback<bool, String> validation,
        CustomCallback<void, String>onSubmit}) {
    showDialog(
        context: context,
        builder: (context) {
          _textEditingController.clear();
          _validate = true;

          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                  errorText: _validate ? null : "Invalid input."),
              onChanged: (v){
                setState(() {
                  _validate=validation(v.trim());
                });
              },
              onSubmitted: (v) => onSubmit(v.trim()),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  String _value =
                  _textEditingController.text.trim();
                  setState(() {
                    if (validation(_value)) {
                      _validate = false;
                    } else {
                      onSubmit(_value);
                      Navigator.pop(context);
                    }
                  });
                },
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    db.data.users['JP'] = User(id: 'JP', server: 'jp');
    return Scaffold(
      appBar: AppBar(
        title: Text(S
            .of(context)
            .cur_account),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add), onPressed: () {

          },

          )
        ],
      ),
      body: TileGroup(
        tiles: db.data.userIDs.map((account) {
          return RadioListTile(
            groupValue: db.data.curUser,
            value: account,
            onChanged: (_cur) {
              db.data.curUser = _cur;
              db.onDataChange();
            },
            title: Text(account),
            secondary: PopupMenuButton(
              itemBuilder: (BuildContext context) =>
              [
                PopupMenuItem(
                  child: GestureDetector(
                    child: Text('Rename'),
                    onTap: () {
                      Navigator.pop(context);
                      showInputDialog(context, title: 'Rename',
                          validation: (v) =>
                          !(v.trim() == '' || db.data.userIDs.contains(v)),
                          onSubmit: (v) {
                            db.data.users[v] = db.data.users[account];
                            db.data.users.remove(account);
                            db.data.curUser = v;
                          });
                    },
                  ),
                ),
                PopupMenuItem(
                  child: GestureDetector(
                    child: Text('Delete'),
                    onTap: () {
                      setState(() {
                        //confirm
                        Navigator.pop(context);
                        print(db.data.userIDs);
                        db.data.users.remove(account);
                        print(db.data.userIDs);
                      });
                    },
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
