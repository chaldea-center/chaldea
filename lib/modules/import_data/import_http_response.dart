import 'dart:collection';
import 'dart:convert';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/account_page.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bond_detail_page.dart';

class ImportHttpResponse extends StatefulWidget {
  ImportHttpResponse({Key? key}) : super(key: key);

  @override
  ImportHttpResponseState createState() => ImportHttpResponseState();
}

class ImportHttpResponseState extends State<ImportHttpResponse> {
  late ScrollController _scrollController;

  // settings
  bool _includeItem = true;
  bool _includeSvt = true;
  bool _includeSvtStorage = true;
  bool _includeCraft = true;
  bool _isLocked = true;
  bool _allowDuplicated = false;

  // mapping, from gamedata, key=game id
  late final Map<int, Servant> svtIdMap;
  late final Map<int, CraftEssence> craftIdMap;
  late final Map<int, Item> itemIdMap;

  // from response,key=game id
  Map<int, UserSvtCollection> cardCollections = {};

  // data
  BiliTopLogin? topLogin;
  List<List<UserSvt>> servants = [];
  List<UserItem> items = [];
  Set<int> ignoreSvts = {};

  Map<int, int> crafts = {}; // craft.no: status

  HashSet<UserSvt> _shownSvts = HashSet();

  BiliReplaced? get replacedResponse => topLogin?.body;

  String get tmpPath =>
      join(db.paths.tempDir, 'http_packages', db.curUser.key!);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    svtIdMap = db.gameData.servants.map((key, svt) => MapEntry(svt.svtId, svt));
    craftIdMap =
        db.gameData.crafts.map((key, craft) => MapEntry(craft.gameId, craft));
    itemIdMap = db.gameData.items
        .map((key, item) => MapEntry(item.itemId, item))
          ..removeWhere((key, value) => key < 0);
    try {
      final f = File(tmpPath);
      if (f.existsSync()) {
        parseResponseBody(f.readAsBytesSync());
      }
    } catch (e, s) {
      logger.e('reading http packages cache failed', e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    _shownSvts.clear();
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(top: 6)),
        Expanded(
          child: topLogin == null
              ? Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        LocalizedText.of(
                            chs: '目前仅国服可用',
                            jpn: '現在、中国サーバーのみがサポートされています',
                            eng: 'Only Chinese server is supported yet'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(S.current.import_http_body_hint),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) => ListView(
                    controller: _scrollController,
                    children: [
                      if (replacedResponse!.firstUser != null)
                        userInfoAccordion,
                      kDefaultDivider,
                      itemsAccordion,
                      kDefaultDivider,
                      svtAccordion(false, constraints),
                      kDefaultDivider,
                      svtAccordion(true, constraints),
                      kDefaultDivider,
                      craftAccordion,
                    ],
                  ),
                ),
        ),
        kDefaultDivider,
        buttonBar,
        Text(
          S.current.import_http_body_hint_hide,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        )
      ],
    );
  }

  final double _with = 56;
  final double _height = 56 / Constants.iconAspectRatio; // ignore: unused_field

  Widget get userInfoAccordion {
    final user = replacedResponse!.firstUser!;
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) => ListTile(
        leading: Icon(Icons.supervised_user_circle),
        title: Text('账号信息'),
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: divideTiles([
          ListTile(
            title: Text('获取时间'),
            trailing: Text(topLogin!.cache.serverTime?.toStringShort() ?? '?'),
          ),
          ListTile(
            title: Text('用户名'),
            trailing: Text(user.name),
          ),
          ListTile(
            title: Text('性别'),
            trailing: Text(user.genderType == 1 ? '咕哒夫' : '咕哒子'),
          ),
          ListTile(
            title: Text('用户ID'),
            trailing: Text(formatNumber(user.friendCode)),
          ),
          ListTile(
            title: Text('QP'),
            trailing: Text(formatNumber(user.qp)),
          ),
          ListTile(
            title: Text('魔力棱镜'),
            trailing: Text(formatNumber(user.mana)),
          ),
          ListTile(
            title: Text('稀有魔力棱镜'),
            trailing: Text(formatNumber(user.rarePri)),
          ),
        ]),
      ),
    );
  }

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
      disableAnimation: true,
      headerBuilder: (context, _) => ListTile(
        leading: Checkbox(
          value: _includeItem,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (v) => setState(() {
            _includeItem = v ?? _includeItem;
          }),
        ),
        title: Text(S.current.item),
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

  Widget svtAccordion(bool inStorage, BoxConstraints constraints) {
    int crossCount = max(2, constraints.maxWidth ~/ 210);
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

        String text = '宝具${svt.treasureDeviceLv1} ';
        text += ' 绊${cardCollections[svt.svtId]!.friendshipRank}\n';
        text += '灵基${svt.limitCount} 圣杯${svt.exceedCount} Lv.${svt.lv}\n';
        if (db.gameData.servants[svt.indexKey]!.itemCost.dress.isEmpty) {
          text += '';
        } else {
          text +=
              '灵衣 ${cardCollections[svt.svtId]!.costumeIdsTo01().join('/')}\n';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 6, top: 2),
                  child: db.getIconImage(
                      db.gameData.servants[svt.indexKey]!.icon,
                      width:
                          min(_with, constraints.maxWidth / crossCount * 0.25),
                      aspectRatio: 132 / 144),
                ),
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
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: richText,
                ),
              ),
            )
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
          onLongPress: () {
            final _svt2 = db.gameData.servants[svt.indexKey];
            EasyLoading.showToast(
                'No.${_svt2?.no} - ${_svt2?.info.localizedName}');
          },
          child: child,
        ));
      }
    }

    return SimpleAccordion(
      expanded: true,
      disableAnimation: true,
      headerBuilder: (context, _) => ListTile(
        title: Text(inStorage ? '保管室从者' : '从者'),
        leading: Checkbox(
          value: inStorage ? _includeSvtStorage : _includeSvt,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (v) => setState(() {
            if (inStorage) {
              _includeSvtStorage = v ?? _includeSvtStorage;
            } else {
              _includeSvt = v ?? _includeSvt;
            }
          }),
        ),
        trailing: Text(children.length.toString()),
      ),
      contentBuilder: (context) {
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
              crossAxisCount: crossCount,
              height: _height + 6,
              crossAxisSpacing: 4),
          itemBuilder: (context, index) => children[index],
          itemCount: children.length,
        );
      },
    );
  }

  Widget get craftAccordion {
    return SimpleAccordion(
      expanded: true,
      disableAnimation: true,
      headerBuilder: (context, _) => ListTile(
        leading: Checkbox(
          value: _includeCraft,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (v) => setState(() {
            _includeCraft = v ?? _includeCraft;
          }),
        ),
        title: Text('礼装图鉴'),
      ),
      contentBuilder: (context) {
        final notMeet = crafts.values.where((v) => v == 0).length;
        final meet = crafts.values.where((v) => v == 1).length;
        final own = crafts.values.where((v) => v == 2).length;
        return ListTile(
          leading: Text(''),
          title: Text(
              '已契约: $own\n已遭遇: $meet\n未遭遇: $notMeet\n总计:   ${crafts.length}'),
        );
      },
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      buttonPadding: EdgeInsets.zero,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 3,
          alignment: WrapAlignment.center,
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
            CheckboxWithLabel(
              value: _isLocked,
              onChanged: (v) {
                setState(() {
                  _isLocked = v ?? _isLocked;
                });
              },
              label: Text(S.current.import_http_body_locked),
            ),
            CheckboxWithLabel(
              value: _allowDuplicated,
              onChanged: (v) {
                setState(() {
                  _allowDuplicated = v ?? _allowDuplicated;
                });
              },
              label: Text(S.current.import_http_body_duplicated),
            ),
            ElevatedButton(
              onPressed: replacedResponse == null
                  ? null
                  : () {
                      SplitRoute.push(
                        context: context,
                        builder: (ctx, _) => SvtBondDetailPage(
                            svtIdMap: svtIdMap,
                            cardCollections: cardCollections),
                      );
                    },
              child: Text('羁绊详情'),
            ),
            ElevatedButton(
              onPressed: replacedResponse == null ? null : didImportData,
              child: Text(S.current.import_data),
            ),
          ],
        )
      ],
    );
  }

  void didImportData() async {
    bool? confirmed = await SimpleCancelOkDialog(
      title: Text(S.current.import_data),
      content: Text(S.current.cur_account + ': ' + db.curUser.name),
    ).showDialog(context);
    if (confirmed != true) return;
    final user = db.curUser;
    user.isMasterGirl = replacedResponse!.firstUser!.genderType == 2;
    if (_includeItem) {
      // user.items.clear();
      if (replacedResponse!.firstUser != null) {
        user.items[Item.qp] = replacedResponse!.firstUser!.qp;
        user.items[Item.mana] = replacedResponse!.firstUser!.mana;
        user.items[Item.rarePri] = replacedResponse!.firstUser!.rarePri;
      }
      items.forEach((item) {
        user.items[item.indexKey!] = item.num;
      });
    }
    if (_includeCraft) {
      user.crafts = Map.of(crafts);
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
        status.favorite = true;
        status.curVal
          ..ascension = svt.limitCount
          ..skills = [svt.skillLv1, svt.skillLv2, svt.skillLv3]
          ..grail = svt.exceedCount;

        final costumeVals = cardCollections[svt.svtId]!.costumeIdsTo01();
        // should always be non-null
        if (status.curVal.dress.length < costumeVals.length) {
          status.curVal.dress.addAll(List.generate(
              costumeVals.length - status.curVal.dress.length, (index) => 0));
        }
        status.curVal.dress.setRange(0, costumeVals.length, costumeVals);
      }
    }
    db.gameData.updateUserDuplicatedServants();
    EasyLoading.showSuccess(S.current.success);
  }

  void importResponseBody() async {
    try {
      bool? confirmed = await SimpleCancelOkDialog(
        title: Text(S.current.import_data),
        content: Text(S.current.cur_account + ': ' + db.curUser.name),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SplitRoute.push(
                  context: context, builder: (ctx, _) => AccountPage());
            },
            child: Text(LocalizedText.of(chs: '切换', jpn: '切替', eng: 'Switch')),
          )
        ],
      ).showDialog(context);
      if (confirmed != true) return;
      final error = await SimpleDialog(
        title: Text(S.current.import_data),
        children: [
          ListTile(
            leading: Icon(Icons.paste),
            title: Text(LocalizedText.of(
                chs: '从剪切板', jpn: 'クリップボードから', eng: 'From Clipboard')),
            onTap: () async {
              try {
                String? text =
                    (await Clipboard.getData(Clipboard.kTextPlain))?.text;
                if (text?.isNotEmpty != true) {
                  EasyLoading.showError('Clipboard is empty!');
                } else {
                  final bytes = utf8.encode(text!);
                  parseResponseBody(bytes);
                  File(tmpPath)
                    ..createSync(recursive: true)
                    ..writeAsBytesSync(bytes);
                }
                EasyLoading.showSuccess(S.current.import_data_success);
                Navigator.of(context).pop();
              } catch (e, s) {
                logger.e('import http body from clipboard failed', e, s);
                Navigator.of(context).pop(e);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.file_present),
            title: Text(LocalizedText.of(
                chs: '从文本文件', jpn: 'テキストファイルから', eng: 'From Text File')),
            onTap: () async {
              try {
                FilePickerCross filePickerCross =
                    await FilePickerCross.importFromStorage();
                parseResponseBody(filePickerCross.toUint8List());
                File(tmpPath)
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(filePickerCross.toUint8List());
                EasyLoading.showSuccess(S.current.import_data_success);
                Navigator.of(context).pop();
              } on FileSelectionCanceledError {} catch (e, s) {
                logger.e('import http body from text file failed', e, s);
                Navigator.of(context).pop(e);
              }
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.clear),
          ),
        ],
      ).showDialog(context);
      if (error != null) throw error;
    } on FileSelectionCanceledError {} catch (e, s) {
      logger.e('fail to load http response', e, s);
      if (mounted)
        SimpleCancelOkDialog(
          title: Text('Error'),
          content: Text('''$e\n\n请检查以下步骤是否正确：
- 所捕获的URL格式类似为：
https://line3-s2-xxx-fate.bilibiligame.net/rongame_beta//rgfate/60_1001/ac.php?_userId=xxxxxx&_key=toplogin
其中域名前缀、数字及xxx可能随着地区、所在服务器和用户ID而不同
- 确保保存的文件编码为UTF8(默认)且已解码为ey开头的英文+数字，内容未手动更改'''),
        ).showDialog(context);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void parseResponseBody(List<int> bytes) {
    BiliTopLogin _topLogin = BiliTopLogin.fromBase64(utf8.decode(bytes));

    // clear before import
    ignoreSvts.clear();
    cardCollections.clear();
    servants.clear();
    items.clear();
    crafts.clear();
    _shownSvts.clear();

    // items
    _topLogin.body.userItem.forEach((item) {
      if (itemIdMap.containsKey(item.itemId)) {
        item.indexKey = itemIdMap[item.itemId]!.name;
        items.add(item);
      }
    });
    items.sort((a, b) {
      if (a.indexKey != null && b.indexKey != null) {
        return db.gameData.items[a.indexKey!]!.id -
            db.gameData.items[b.indexKey!]!.id;
      } else if (a.indexKey == null && b.indexKey == null) {
        return a.itemId - b.itemId;
      } else {
        return 0;
      }
    });

    // collections
    cardCollections = Map.fromEntries(
        _topLogin.body.userSvtCollection.map((e) => MapEntry(e.svtId, e)));

    // svt
    _topLogin.body.userSvt.forEach((svt) {
      if (svtIdMap.containsKey(svt.svtId)) {
        svt.indexKey = svtIdMap[svt.svtId]!.originNo;
        svt.inStorage = false;
        // cardCollections[svt.svtId] = _response.userSvtCollection
        //     .firstWhere((element) => element.svtId == svt.svtId);
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
    _topLogin.body.userSvtStorage.forEach((svt) {
      if (svtIdMap.containsKey(svt.svtId)) {
        svt.indexKey = svtIdMap[svt.svtId]!.originNo;
        svt.inStorage = true;
        // cardCollections[svt.svtId] = _response.userSvtCollection
        //     .firstWhere((element) => element.svtId == svt.svtId);
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
      final aa = db.gameData.servants[a.first.indexKey];
      final bb = db.gameData.servants[b.first.indexKey];
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
    // crafts
    crafts = craftIdMap.map((gameId, craft) {
      int status = cardCollections[gameId]?.status ?? 0;
      return MapEntry(craft.no, status);
    });

    // assign last
    topLogin = _topLogin;
  }

  void showHelp() {
    SimpleCancelOkDialog(
      hideCancel: true,
      title: Text(S.of(context).help),
      content: SingleChildScrollView(
        child: Text("""1.使用方法
- 目前仅适用于国服，如有解包大佬知晓如何解析日服数据，恳请指点迷津
- 首先通过下面的教程借助Stream(iOS)或Fiddler(Windows)等工具解析HTTPS响应保存为如a.txt
- 上面导出的文件在任一平台的Chaldea应用中均可导入
- 在Chaldea中点击右上角导入按钮导入a.txt
- 筛选想要导入的资料
  - 素材/从者/保管室从者
  - 仅“已锁定”从者
  - 是否包含重复从者(多个2号机)，若存在多个，以3个技能和最大者为默认从者，其余为2号机（表现为其序号值变化No.xxxxx），若技能相同，按获取时间排序。
- 最终点击“导入到”选择一个账户导入
- 注意：考虑到同学们会规划未来待抽从者，因此导入时仅覆盖解析出的数据，而未实装/未抽到的则不做更改
2. 简易教程
Stream(iOS): https://www.bilibili.com/read/cv10437953
Fiddler(Win+Android): https://www.bilibili.com/read/cv10437954
3. 关于HTTPS解密 
通过拦截并解析游戏在登陆时向客户端发送的包含账户信息的HTTPS响应导入素材和从者信息。
客户端与服务器之间的HTTPS通信是经过加密的，解密需要在本机或电脑通过Charles/Fiddler(PC)或Stream(iOS)等工具伪造证书服务器并安装其提供的证书以实现。
因此在导入结束后请及时取消信任或删除证书以保障设备安全。
本软件源码已开源，不涉及https捕获解密等过程，只将以上工具导出的结果解析素材和从者信息，不做其他用途。
Android 7.0及以上设备因系统不再信任用户证书，请在Android 6及以下的设备或模拟器中进行上述操作。"""),
      ),
      actions: [
        TextButton(
          onPressed: () {
            launch('https://www.bilibili.com/read/cv10437953');
          },
          child: Text('iOS'),
        ),
        TextButton(
          onPressed: () {
            launch('https://www.bilibili.com/read/cv10437954');
          },
          child: Text('Win+Android'),
        ),
      ],
    ).showDialog(context);
  }
}
