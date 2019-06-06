import 'dart:math';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/dialog.dart';
import 'package:chaldea/modules/home/settings_item.dart';
import 'package:flutter/material.dart';



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
                builder: (context){
                  return InputCancelOkDialog(
                    title: S.of(context).new_account,
                    errorText: S.of(context).input_error,
                    validate: (v){
                      return v==v.trim()&&!db.data.userIDs.contains(v);
                    },
                    onSubmit: (v){
                      final keys=db.data.users.keys;
                      String newKey;
                      do{
                        newKey=Random().nextInt(100000).toString();
                        print('new key $newKey');
                      }while(keys.contains(newKey));
                      db.data.users[newKey]=User(name: v);
                      db.onDataChange();
                    },
                  );
                }
              );
              db.onDataChange();
              print('Add account');
            },
          )
        ],
      ),
      body: TileGroup(
        tiles: db.data.users.keys.map((key) {
          final user=db.data.users[key];
          final bool _isCurUser = key == db.data.curUser;
          var tile = ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Icon(
                    Icons.check,
                    size: 18.0,
                    color: _isCurUser ? Theme.of(context).primaryColor : Color(0x00),
                  ),
                ),
                Text(
                  '${user.name} - ${user.server}',
                  style: TextStyle(),
                )
              ],
            ),
            selected: _isCurUser,
            trailing: PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      child: GestureDetector(
                        child: Text(S.of(context).rename),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context)=>InputCancelOkDialog(
                              title: '${S.of(context).rename} - ${user.name}',
                              defaultText: user.name,
                              errorText: S.of(context).input_error,
                              validate: (v){
                                return v==v.trim()&&!db.data.userIDs.contains(v);
                              },
                              onSubmit: (v){
                                user.name = v;
                                db.onDataChange();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: GestureDetector(
                        child: Text(S.of(context).delete),
                        onTap: () {
                          setState(() {
                            //confirm
                            print('delete ${db.data.users[key].toJson()}');
                            Navigator.pop(context);
                            db.data.users.remove(key);
                            if(_isCurUser){
                              db.data.curUser=db.data.userIDs[0];
                            }
                            db.onDataChange();
                            print('accounts: ${db.data.userIDs}');
                          });
                        },
                      ),
                    )
                  ],
            ),
            onTap: () {
              db.data.curUser = key;
              db.onDataChange();
            },
          );

          return tile;
        }).toList(),
      ),
    );
  }
}
