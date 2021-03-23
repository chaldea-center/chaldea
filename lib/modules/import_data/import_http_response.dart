import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatypes/datatypes.dart';
import 'package:file_picker_cross/file_picker_cross.dart';

class ImportHttpResponse extends StatefulWidget {
  ImportHttpResponse({Key? key}) : super(key: key);

  @override
  ImportHttpResponseState createState() => ImportHttpResponseState();
}

class ImportHttpResponseState extends State<ImportHttpResponse> {
  // settings
  bool _includeItem = true;
  bool _includeSvt = true;
  bool _includeSvtStorage = true;
  bool _isLocked = true;
  bool _allowDuplicated = false;

  // mapping, from gamedata
  late final Map<int, Servant> svtIdMap;
  late final Map<int, Item> itemIdMap;

  // from response
  Map<int, UserSvtCollection> collectionMap = {};

  // data
  BiliResponse? response;
  List<List<UserSvt>> servants = [];
  List<UserItem> items = [];
  Set<int> ignoreSvts = {};

  HashSet<UserSvt> _shownSvts = HashSet();

  @override
  void initState() {
    super.initState();
    svtIdMap = db.gameData.servants.map((key, svt) => MapEntry(svt.svtId, svt));
    itemIdMap = db.gameData.items
        .map((key, item) => MapEntry(item.itemId, item))
          ..removeWhere((key, value) => key < 0);
  }

  @override
  Widget build(BuildContext context) {
    _shownSvts.clear();
    return Column(
      children: [
        Expanded(
          child: response == null
              ? SingleChildScrollView(
                  child: Center(child: Text('\n点击帮助以查看如何导入HTTPS响应内容\n')),
                )
              : ListView(
                  children: [
                    itemsAccordion,
                    kDefaultDivider,
                    svtAccordion(false),
                    kDefaultDivider,
                    svtAccordion(true),
                  ],
                ),
        ),
        kDefaultDivider,
        buttonBar
      ],
    );
  }

  final double _with = 56;
  final double _height = 56 / Constants.iconAspectRatio; // ignore: unused_field

  Widget get itemsAccordion {
    List<Widget> children = [];
    items.forEach((item) {
      children.add(ImageWithText(
        image: db.getIconImage(item.indexKey!, width: _with),
        text: item.num.toString(),
        width: _with,
        padding: EdgeInsets.only(right: 2, bottom: 3),
      ));
    });
    return SimpleAccordion(
      expanded: true,
      canTapOnHeader: false,
      headerBuilder: (context, _) => CheckboxListTile(
        value: _includeItem,
        title: Text(S.current.item),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (v) => setState(() {
          _includeItem = v ?? _includeItem;
        }),
      ),
      contentBuilder: (context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget svtAccordion(bool inStorage) {
    List<Widget> children = [];
    final _textStyle = TextStyle(
        fontSize: 11, color: DefaultTextStyle.of(context).style.color);
    for (var group in servants) {
      for (var svt in group) {
        if ((inStorage && !svt.inStorage) || (!inStorage && svt.inStorage))
          continue;
        if (_isLocked && !svt.isLock) continue;
        if (!_allowDuplicated && group.indexOf(svt) > 0) continue;
        bool hidden = ignoreSvts.contains(svt.id);

        if (!hidden) {
          _shownSvts.add(svt);
        }

        String text = '宝具${svt.treasureDeviceLv1} '
            '圣杯${svt.exceedCount} ';
        text += '灵基${svt.limitCount}  Lv.${svt.lv}\n';
        if (db.gameData.servants[svt.indexKey]!.itemCost.dress.isEmpty) {
          text += '\n';
        } else {
          text +=
              '灵衣 ${collectionMap[svt.svtId]!.costumeIdsTo01().join('/')}\n';
        }
        text += '技能 ${svt.skillLv1}/${svt.skillLv2}/${svt.skillLv3}\n';

        final richText = RichText(
          text: TextSpan(
            text: text,
            style: _textStyle,
            children: [
              TextSpan(
                text: group.length == 1
                    ? ''
                    : DateFormat('yyyy-MM-dd').format(svt.createdAt),
                style: group.indexOf(svt) == 0
                    ? TextStyle(color: Colors.red)
                    : null,
              ),
            ],
          ),
        );
        // image+text
        Widget child = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(padding: EdgeInsets.only(left: 6)),
            db.getIconImage(db.gameData.servants[svt.indexKey]!.icon,
                height: _height, width: _with),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: richText,
                  ),
                ),
              ),
            )
          ],
        );
        // add lock
        child = Stack(
          alignment: Alignment.centerLeft,
          children: [
            child,
            // if (!_isLocked && svt.isLock)
            Icon(
              Icons.lock,
              size: 13,
              color: Colors.white,
            ),
            // if (!_isLocked && svt.isLock)
            Icon(
              Icons.lock,
              size: 12,
              color: Colors.yellow[900],
            ),
          ],
        );
        if (hidden) {
          child = Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: hidden ? 0.25 : 1,
                child: child,
              ),
              Icon(
                Icons.clear_rounded,
                color: Colors.red,
                size: _height * 0.8,
              )
            ],
          );
        }
        children.add(GestureDetector(
          onTap: () {
            setState(() {
              if (ignoreSvts.contains(svt.id)) {
                ignoreSvts.remove(svt.id);
              } else {
                ignoreSvts.add(svt.id);
              }
            });
          },
          child: child,
        ));
      }
    }
    return SimpleAccordion(
      expanded: true,
      canTapOnHeader: false,
      disableAnimation: true,
      headerBuilder: (context, _) => CheckboxListTile(
        value: inStorage ? _includeSvtStorage : _includeSvt,
        title: Text(inStorage ? '保管室从者' : '从者'),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (v) => setState(() {
          if (inStorage) {
            _includeSvtStorage = v ?? _includeSvtStorage;
          } else {
            _includeSvt = v ?? _includeSvt;
          }
        }),
      ),
      contentBuilder: (context) {
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
              crossAxisCount: 2, height: _height + 6, crossAxisSpacing: 4),
          itemBuilder: (context, index) => children[index],
          itemCount: children.length,
        );
      },
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              onPressed: showHelp,
              tooltip: S.current.help,
              icon: Icon(
                Icons.help,
                color: Colors.blue,
              ),
            ),
            CheckboxWithText(
              value: _isLocked,
              onChanged: (v) {
                setState(() {
                  _isLocked = v ?? _isLocked;
                });
              },
              label: Text('仅锁定'),
            ),
            CheckboxWithText(
              value: _allowDuplicated,
              onChanged: (v) {
                setState(() {
                  _allowDuplicated = v ?? _allowDuplicated;
                });
              },
              label: Text('允许2号机'),
            ),
            ElevatedButton(
                onPressed: didImportData,
                child: Text(S.of(context).import_data))
          ],
        )
      ],
    );
  }

  void didImportData() {
    showDialog(
      context: context,
      builder: (context) {
        List<Widget> children = [];
        for (String key in db.userData.users.keys) {
          children.add(ListTile(
            leading: Icon(Icons.person),
            horizontalTitleGap: 0,
            title: Text(db.userData.users[key]!.name),
            onTap: () {
              final user = db.userData.users[key]!;
              if (_includeItem) {
                user.items.clear();
                items.forEach((item) {
                  user.items[item.indexKey!] = item.num;
                });
              }
              // 不删除原本信息
              // 记录1号机。1号机使用Servant.no, 2-n号机使用UserSvt.id
              HashSet<int> _alreadyAdded = HashSet();
              for (var group in servants) {
                for (var svt in group) {
                  if (!_shownSvts.contains(svt)) continue;
                  if (!_includeSvt && !svt.inStorage) continue;
                  if (!_includeSvtStorage && svt.inStorage) continue;

                  ServantStatus status;
                  if (_alreadyAdded.contains(svt.indexKey!)) {
                    user.duplicatedServants[svt.id] = svt.indexKey!;
                    status = user.svtStatusOf(svt.id);
                  } else {
                    status = user.svtStatusOf(svt.indexKey!);
                  }
                  _alreadyAdded.add(svt.indexKey!);

                  status.npLv = svt.treasureDeviceLv1;
                  status.curVal.favorite = true;
                  status.curVal
                    ..ascension = svt.limitCount
                    ..skills = [svt.skillLv1, svt.skillLv2, svt.skillLv3]
                    ..grail = svt.exceedCount;

                  final costumeVals =
                      collectionMap[svt.svtId]!.costumeIdsTo01();
                  // should always be non-null
                  if (status.curVal.dress.length < costumeVals.length) {
                    status.curVal.dress.addAll(List.generate(
                        costumeVals.length - status.curVal.dress.length,
                        (index) => 0));
                  }
                  status.curVal.dress
                      .setRange(0, costumeVals.length, costumeVals);
                }
              }

              // finish
              db.userData.curUserKey = key;
              db.notifyAppUpdate();
              Navigator.pop(context);
              SimpleCancelOkDialog(
                hideCancel: true,
                title: Text(S.current.import_data_success),
                content: Text('已切换到账户 ${user.name}'),
              ).show(context);
            },
          ));
        }
        children.add(IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.clear),
        ));
        return SimpleDialog(
          title: Text(
            '导入${items.length}个素材, ${servants.length}从者到',
            style: TextStyle(fontSize: 16),
          ),
          children: divideTiles(children, top: true),
        );
      },
    );
  }

  void importResponseBody() async {
    ignoreSvts.clear();
    collectionMap.clear();
    servants.clear();
    items.clear();
    _shownSvts.clear();
    try {
      FilePickerCross filePickerCross =
          await FilePickerCross.importFromStorage();
      String body =
          Uri.decodeFull(File(filePickerCross.path).readAsStringSync());
      response =
          BiliResponse.fromJson(jsonDecode(b64(body))['cache']['replaced']);
      // items
      response!.userItem.forEach((item) {
        if (itemIdMap.containsKey(item.itemId)) {
          item.indexKey = itemIdMap[item.itemId]!.name;
          items.add(item);
        }
      });
      items.sort((a, b) => a.itemId - b.itemId);

      // svt
      collectionMap.clear();
      response!.userSvt.forEach((svt) {
        if (svtIdMap.containsKey(svt.svtId)) {
          svt.indexKey = svtIdMap[svt.svtId]!.originNo;
          svt.inStorage = false;
          collectionMap[svt.svtId] = response!.userSvtCollection
              .firstWhere((element) => element.svtId == svt.svtId);
          final group = servants.firstWhereOrNull(
              (group) => group.any((element) => element.svtId == svt.svtId));
          if (group == null) {
            servants.add([svt]);
          } else {
            group.add(svt);
          }
        }
      });
      // svtStorage
      response!.userSvtStorage.forEach((svt) {
        if (svtIdMap.containsKey(svt.svtId)) {
          svt.indexKey = svtIdMap[svt.svtId]!.originNo;
          svt.inStorage = true;
          collectionMap[svt.svtId] = response!.userSvtCollection
              .firstWhere((element) => element.svtId == svt.svtId);
          final group = servants.firstWhereOrNull(
              (group) => group.any((element) => element.svtId == svt.svtId));
          if (group == null) {
            servants.add([svt]);
          } else {
            group.add(svt);
          }
        }
      });
      servants.sort((a, b) {
        final aa = db.gameData.servants[a.first.indexKey]!;
        final bb = db.gameData.servants[b.first.indexKey]!;
        return Servant.compare(aa, bb,
            keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
            reversed: [true, false, false]);
      });
      servants.forEach((group) {
        group.sort((a, b) {
          // reversed, skill high to low
          int d = (b.skillLv1 + b.skillLv2 + b.skillLv3) -
              (a.skillLv1 + a.skillLv2 + a.skillLv3);
          if (d == 0) {
            // created from old to new
            d = a.createdAt.millisecondsSinceEpoch -
                b.createdAt.millisecondsSinceEpoch;
          }
          return d;
        });
      });
    } on FileSelectionCanceledError {} catch (e, s) {
      logger.e('fail to load http response', e, s);
      if (mounted)
        SimpleCancelOkDialog(
          title: Text('Error'),
          content: Text('$e\n请确保保存为UTF8编码文本文件，文件内容未更改'),
        ).show(context);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void showHelp() {
    SimpleCancelOkDialog(
      hideCancel: true,
      title: Text(S.of(context).help),
      content: SingleChildScrollView(
        child: Text("""通过拦截并解析游戏在登陆时向客户端发送的包含账户信息的HTTPS响应导入素材和从者信息。
BGO客户端与服务器之间的HTTPS通信是经过加密的，解密需要在本机或电脑通过Charles/Fiddler(PC)或Stream(iOS)等工具伪造证书服务器并安装其提供的证书以实现。
因此在导入结束后请及时取消信任或删除证书以保障设备安全。
本软件源码已开源，不涉及https捕获解密等过程，只将以上工具导出的结果解析，不做其他用途。
Android 7.0及以上设备因系统不再信任用户证书，请在Android 6及以下的设备或模拟器中进行上述操作。
详细教程可见https://b23.tv/xxxxxx
考虑到可能会规划国服未实装的从者，因此导入时不会清除已有数据，而是覆盖更新。
仅确认了国服导入方法，如有解包大佬知晓如何解析日服数据，恳请指点迷津"""),
      ),
    ).show(context);
  }
}

class CheckboxWithText extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget label;

  const CheckboxWithText(
      {Key? key,
      required this.value,
      required this.onChanged,
      required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        GestureDetector(
          onTap: () {
            if (onChanged != null) {
              onChanged!(!value);
            }
          },
          child: label,
        )
      ],
    );
  }
}
