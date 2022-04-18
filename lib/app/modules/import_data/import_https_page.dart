import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app.dart';
import 'bond_detail_page.dart';

class ImportHttpPage extends StatefulWidget {
  ImportHttpPage({Key? key}) : super(key: key);

  @override
  ImportHttpPageState createState() => ImportHttpPageState();
}

class ImportHttpPageState extends State<ImportHttpPage> {
  // settings
  bool _includeItem = true;
  bool _includeSvt = true;
  bool _includeSvtStorage = true;
  bool _includeCraft = true;

  bool _onlyLocked = true;
  final bool _allowDuplicated = false;

  bool _showAccount = true;
  bool _showItem = false;
  bool _showSvt = false;
  bool _showStorage = false;
  bool _showCraft = false;
  final Set<UserSvt> _validSvts = {};

  // from response,key=game id
  Map<int, UserSvtCollection> cardCollections = {};

  // data
  BiliTopLogin? topLogin;
  List<List<UserSvt>> servants = [];
  List<UserItem> items = [];
  Map<int, int> crafts = {}; // craft.no: status

  BiliReplaced? get replacedResponse => topLogin?.body;

  String tmpPath =
      joinPaths(db.paths.tempDir, 'http_packages', calcMd5(db.curUser.name));

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    try {
      final f = FilePlus(tmpPath);
      if (f.existsSync()) {
        parseResponseBody(await f.readAsString());
        if (mounted) setState(() {});
      }
    } catch (e, s) {
      logger.e('reading http packages cache failed', e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = '$kProjectDocRoot${Language.isZH ? "/zh" : ""}/import_https/';
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(S.current.https_sniff),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'import_https_response.md'),
          IconButton(
            onPressed: importResponseBody,
            icon: const FaIcon(FontAwesomeIcons.fileImport),
            tooltip: S.current.import_source_file,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: topLogin == null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          S.current.usage,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            launch(url);
                          },
                          child: Text(url),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => CustomScrollView(
                      slivers: [
                        userInfoSliver,
                        itemSliver(constraints),
                        svtSliver(false),
                        svtSliver(true),
                        craftSliver,
                      ],
                    ),
                  ),
          ),
          kDefaultDivider,
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  final double _with = 56;
  final double _height = 56 / (132 / 144);

  Widget get userInfoSliver {
    final user = replacedResponse?.firstUser;
    if (user == null) {
      return MultiSliver(children: const [
        ListTile(
          title: Text("??? no user info found"),
        )
      ]);
    }
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            leading: const Icon(Icons.supervised_user_circle),
            title: Text(S.current.account_title),
            trailing: ExpandIcon(onPressed: null, isExpanded: _showAccount),
            onTap: () {
              setState(() {
                _showAccount = !_showAccount;
              });
            },
          ),
        ),
        if (_showAccount)
          SliverClip(
            child: MultiSliver(children: [
              ListTile(
                title: Text(S.current.obtain_time),
                trailing:
                    Text(topLogin!.cache.serverTime?.toStringShort() ?? '?'),
              ),
              ListTile(
                title: Text(S.current.login_username),
                trailing: Text(user.name),
              ),
              ListTile(
                title: Text(S.current.info_gender),
                trailing: Text(user.genderType == 1
                    ? '♂ ' + S.current.guda_male
                    : '♀ ' + S.current.guda_female),
              ),
              ListTile(
                title: const Text('ID'),
                trailing: Text(user.friendCode),
              ),
              ListTile(
                title: Text(Items.qp.lName.l),
                trailing: Text(user.qp.format()),
              ),
              ListTile(
                title: Text(Items.manaPrism.lName.l),
                trailing: Text(user.mana.format()),
              ),
              ListTile(
                title: Text(Items.rarePrism.lName.l),
                trailing: Text(user.rarePri.format()),
              ),
            ]),
          )
      ],
    );
  }

  Widget itemSliver(BoxConstraints constraints) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            leading: Checkbox(
              value: _includeItem,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => setState(() {
                _includeItem = v ?? _includeItem;
              }),
            ),
            title: Text(S.current.item),
            trailing: ExpandIcon(onPressed: null, isExpanded: _showItem),
            onTap: () {
              setState(() {
                _showItem = !_showItem;
              });
            },
          ),
        ),
        if (_showItem)
          SliverClip(
            child: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: item.itemId,
                    width: _with,
                    text: item.num.toString(),
                  );
                }, childCount: items.length),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                  crossAxisCount: constraints.maxWidth ~/ _with,
                  height: _height,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget svtSliver(bool inStorage) {
    List<Widget> children = [];
    int validCount = 0;

    for (var group in servants) {
      for (var svt in group) {
        if ((inStorage && !svt.inStorage) || (!inStorage && svt.inStorage)) {
          continue;
        }

        int? coin = replacedResponse?.coinMap[svt.svtId]?.num;
        Widget _wrapCellStyle(List<String> texts) {
          return CustomTableRow.fromTexts(
            texts: texts,
            defaults: TableCellData(
                padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
            divider: null,
          );
        }

        List<Widget> infoRows = [
          _wrapCellStyle([
            'Lv.${svt.lv}',
            S.current.ascension_short + ' ${svt.limitCount}',
            S.current.grail + ' ${svt.exceedCount}',
          ]),
          _wrapCellStyle([
            S.current.np_short + ' ${svt.treasureDeviceLv1}',
            S.current.bond + ' ${cardCollections[svt.svtId]!.friendshipRank}',
            coin == null ? '' : (S.current.servant_coin_short + ' $coin'),
          ]),
          _wrapCellStyle([
            S.current.active_skill +
                ' ${svt.skillLv1}/${svt.skillLv2}/${svt.skillLv3}',
            svt.appendLvs == null
                ? ''
                : S.current.append_skill_short +
                    ' ${svt.appendLvs!.map((e) => e == 0 ? '-' : e).join('/')}',
          ]),
          if (db.gameData.servantsById[svt.svtId]!.profile.costume.isNotEmpty)
            _wrapCellStyle([
              S.current.costume +
                  ' ${cardCollections[svt.svtId]!.costumeIdsTo01()}',
            ]),
          if (group.length > 1)
            CustomTableRow.fromChildren(
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(svt.createdAt),
                  style: TextStyle(color: Theme.of(context).errorColor),
                )
              ],
              defaults: TableCellData(padding: EdgeInsets.zero),
              divider: null,
            ),
        ];

        void _onTapSvt() {
          if (_validSvts.contains(svt)) {
            _validSvts.remove(svt);
          } else {
            _validSvts.add(svt);
          }
          setState(() {});
        }

        // image+text
        Widget child = CustomTile(
          leading: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 2),
                child: db.gameData.servantsById[svt.svtId]
                    ?.iconBuilder(context: context, height: 56),
              ),
              if (svt.locked)
                const Icon(
                  Icons.lock,
                  size: 13,
                  color: Colors.white,
                ),
              if (svt.locked)
                Icon(
                  Icons.lock,
                  size: 12,
                  color: Colors.yellow[900],
                ),
            ],
          ),
          title: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
              child: CustomTable(
                children: infoRows,
                hideOutline: true,
                verticalDivider:
                    const VerticalDivider(width: 0, color: Colors.transparent),
                horizontalDivider:
                    const Divider(height: 0, color: Colors.transparent),
              )),
          onTap: _onTapSvt,
        );
        if (_validSvts.contains(svt)) {
          validCount += 1;
        } else {
          child = Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.45,
                child: child,
              ),
              GestureDetector(
                child: Icon(
                  Icons.clear_rounded,
                  color: Colors.red,
                  size: _height * 0.8,
                ),
                onTap: _onTapSvt,
              )
            ],
          );
        }
        children.add(child);
      }
    }

    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            title: Text(inStorage
                ? S.current.servant + '(${S.current.svt_second_archive})'
                : S.current.servant),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$validCount/${children.length}'),
                ExpandIcon(
                  onPressed: null,
                  isExpanded: inStorage ? _showStorage : _showSvt,
                )
              ],
            ),
            onTap: () {
              if (inStorage) {
                _showStorage = !_showStorage;
              } else {
                _showSvt = !_showSvt;
              }
              setState(() {});
            },
          ),
        ),
        if ((inStorage && _showStorage) || (!inStorage && _showSvt))
          SliverClip(
            child: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => children[index],
                childCount: children.length,
              ),
            ),
          )
      ],
    );
  }

  Widget get craftSliver {
    int owned = crafts.values.where((e) => e == CraftStatus.owned).length,
        met = crafts.values.where((e) => e == CraftStatus.met).length,
        notMet = crafts.values.where((e) => e == CraftStatus.notMet).length;
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            leading: Checkbox(
              value: _includeCraft,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => setState(() {
                _includeCraft = v ?? _includeCraft;
              }),
            ),
            title: Text(S.current.craft_essence),
            trailing: ExpandIcon(onPressed: null, isExpanded: _showCraft),
            onTap: () {
              setState(() {
                _showCraft = !_showCraft;
              });
            },
          ),
        ),
        if (_showCraft)
          SliverClip(
            child: MultiSliver(
              children: [
                ListTile(
                  leading: const Text(''),
                  title: Text('Owned: $owned\n'
                      'Met: $met\n'
                      'NotMet: $notMet\n'
                      'ALL:   ${crafts.length}'),
                )
              ],
            ),
          )
      ],
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      buttonPadding: EdgeInsets.zero,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 2,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CheckboxWithLabel(
              value: _onlyLocked,
              onChanged: (v) {
                setState(() {
                  _onlyLocked = v ?? _onlyLocked;
                  _refreshValidSvts();
                });
              },
              label: Text(S.current.import_http_body_locked),
            ),
            CheckboxWithLabel(
              value: _allowDuplicated,
              onChanged: (v) {
                EasyLoading.showInfo(S.current.not_implemented);
                // setState(() {
                //   _allowDuplicated = v ?? _allowDuplicated;
                //   _refreshValidSvts();
                // });
              },
              label: Text(S.current.import_http_body_duplicated),
            ),
            ElevatedButton(
              onPressed: replacedResponse == null
                  ? null
                  : () {
                      router.push(
                        child: SvtBondDetailPage(
                          cardCollections: cardCollections,
                        ),
                      );
                    },
              child: Text(S.current.bond),
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

  void _refreshValidSvts() {
    _validSvts.clear();
    for (final group in servants) {
      for (final svt in group) {
        if (_onlyLocked && !svt.locked) continue;
        if (!_allowDuplicated && group.indexOf(svt) > 0) continue;
        _validSvts.add(svt);
      }
    }
  }

  void didImportData() async {
    bool? confirmed = await SimpleCancelOkDialog(
      title: Text(S.current.import_data),
      content: Text(S.current.cur_account + ': ' + db.curUser.name),
    ).showDialog(context);
    if (confirmed != true) return;
    final user = db.curUser;
    user.isGirl = replacedResponse!.firstUser!.genderType == 2;
    if (_includeItem) {
      // user.items.clear();
      if (replacedResponse!.firstUser != null) {
        user.items[Items.qpId] = replacedResponse!.firstUser!.qp;
        user.items[Items.manaPrismId] = replacedResponse!.firstUser!.mana;
        user.items[Items.rarePrismId] = replacedResponse!.firstUser!.rarePri;
      }
      items.forEach((item) {
        user.items[item.itemId] = item.num;
      });
    }
    if (_includeCraft) {
      user.craftEssences = Map.of(crafts);
    }
    // 不删除原本信息
    // 记录1号机。1号机使用Servant.no, 2-n号机使用UserSvt.id
    HashSet<int> _alreadyAdded = HashSet();
    for (var group in servants) {
      for (var svt in group) {
        if (!_validSvts.contains(svt)) continue;
        if (!_includeSvt && !svt.inStorage) continue;
        if (!_includeSvtStorage && svt.inStorage) continue;

        SvtStatus status;
        UserSvtCollection collection = cardCollections[svt.svtId]!;
        if (_alreadyAdded.contains(svt.svtId)) {
          // user.duplicatedServants[svt.id] = svt.indexKey!;
          // status = user.svtStatusOf(svt.id);
          continue;
        } else {
          status = user
              .svtStatusOf(db.gameData.servantsById[svt.svtId]!.collectionNo);
        }
        _alreadyAdded.add(svt.svtId);

        status.cur.npLv = svt.treasureDeviceLv1;
        status.favorite = true;
        status.cur
          ..ascension = svt.limitCount
          ..skills = [svt.skillLv1, svt.skillLv2, svt.skillLv3]
          ..grail = svt.exceedCount
          ..fouHp = max(0, (svt.adjustHp - 100) ~/ 2)
          ..fouAtk = max(0, (svt.adjustAtk - 100) ~/ 2)
          ..bondLimit = min(collection.friendshipRank + 1,
              collection.friendshipExceedCount + 10);
        if (svt.appendLvs != null) {
          status.cur.appendSkills = svt.appendLvs!;
        }
        status.coin = replacedResponse!.coinMap[svt.svtId]?.num ?? 0;

        status.cur.costumes = collection.costumeIdsTo01();
      }
    }
    // db2.gameData.updateUserDuplicatedServants();
    EasyLoading.showSuccess(S.current.success);
  }

  void importResponseBody() async {
    var fromFile = await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => SimpleDialog(
        title: Text(S.current.import_data),
        children: [
          ListTile(
            leading: const Icon(Icons.paste),
            title: Text(S.current.import_from_clipboard),
            onTap: () async {
              Navigator.of(context).pop(false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_present),
            title: Text(S.current.import_from_file),
            onTap: () async {
              Navigator.of(context).pop(true);
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
    );
    try {
      if (fromFile == true) {
        final result = await FilePicker.platform.pickFiles(withData: true);
        final bytes = result?.files.first.bytes;
        if (bytes == null) return;
        parseResponseBody(utf8.decode(bytes));
        await FilePlus(tmpPath).create(recursive: true);
        await FilePlus(tmpPath).writeAsBytes(bytes);
      } else if (fromFile == false) {
        String? text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
        if (text != null && text.isNotEmpty) {
          parseResponseBody(text);
          await FilePlus(tmpPath).create(recursive: true);
          await FilePlus(tmpPath).writeAsString(text);
        } else {
          EasyLoading.showError('Clipboard is empty!');
        }
      }
    } catch (e, s) {
      logger.e('fail to load http response', e, s);
      if (mounted) {
        SimpleCancelOkDialog(
          title: const Text('Error'),
          content: Text('$e\n'
              '\nhttps://docs.chaldea.center/import_https/'
              '\nhttps://docs.chaldea.center/zh/import_https/'),
        ).showDialog(context);
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void parseResponseBody(String contents) {
    BiliTopLogin _topLogin = BiliTopLogin.tryBase64(contents);

    // clear before import
    _validSvts.clear();
    cardCollections.clear();
    servants.clear();
    items = _topLogin.body.userItem
        .where((e) =>
            e.num > 0 &&
            db.gameData.items[e.itemId]?.skillUpItemType !=
                SkillUpItemType.none)
        .toList();
    crafts.clear();

    items.sort2((e) => db.gameData.items[e.itemId]?.priority ?? e.itemId);

    // collections
    cardCollections = Map.fromEntries(
        _topLogin.body.userSvtCollection.map((e) => MapEntry(e.svtId, e)));

    // svt
    _topLogin.body.userSvt.forEach((svt) {
      if (db.gameData.servantsById.containsKey(svt.svtId)) {
        // svt.indexKey = svtIdMap[svt.svtId]!.originNo;
        svt.inStorage = false;
        svt.appendLvs = _topLogin.body.getSvtAppendSkillLv(svt);
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
      if (db.gameData.servantsById.containsKey(svt.svtId)) {
        // svt.indexKey = svtIdMap[svt.svtId]!.originNo;
        svt.inStorage = true;
        svt.appendLvs = _topLogin.body.getSvtAppendSkillLv(svt);
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
      final aa = db.gameData.servantsById[a.first.svtId];
      final bb = db.gameData.servantsById[b.first.svtId];
      return SvtFilterData.compare(aa, bb,
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
    crafts = db.gameData.craftEssencesById.map((gameId, craft) {
      int status = cardCollections[gameId]?.status ?? 0;
      return MapEntry(craft.collectionNo, status);
    });

    _refreshValidSvts();

    // assign last
    topLogin = _topLogin;
  }
}
