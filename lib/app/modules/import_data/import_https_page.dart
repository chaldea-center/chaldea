import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/analysis/analysis.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app.dart';
import '../../faker/user_deck/deck_list.dart';
import '../common/builders.dart';
import 'autologin/autologin_page.dart';
import 'sniff_details/bond_detail_page.dart';
import 'sniff_details/class_board_mission_demand.dart';
import 'sniff_details/gacha_history.dart';
import 'sniff_details/present_box.dart';
import 'sniff_details/quest_farming.dart';
import 'sniff_details/report/report.dart';

class ImportHttpPage extends StatefulWidget {
  final String? toploginText;
  final MasterDataManager? mstData;
  final Region? region;

  ImportHttpPage({super.key, this.toploginText, this.mstData, this.region})
    : assert(toploginText == null || mstData == null);

  @override
  ImportHttpPageState createState() => ImportHttpPageState();
}

class ImportHttpPageState extends State<ImportHttpPage> {
  // settings
  bool _includeItem = true;
  bool _includeSvt = true;
  bool _includeSvtStorage = true;
  bool _includeCraft = true;
  bool _includeCmdCode = true;
  bool _includeClassBoard = true;

  bool _onlyLocked = true;
  bool _allowDuplicated = false;

  bool _showAccount = true;
  bool _showItem = false;
  bool _showSvt = false;
  bool _showStorage = false;
  bool _showCraft = false;
  bool _showCmdCode = false;
  bool _showClassBoard = false;
  final Set<UserServantEntity> _validSvts = {};

  // from response,key=game id
  Map<int, UserServantCollectionEntity> cardCollections = {};

  // data
  // FateTopLogin? topLogin;
  List<List<UserServantEntity>> servants = [];
  List<UserItemEntity> items = [];
  Map<int, CraftStatus> crafts = {}; // craft.no: status
  Map<int, CmdCodeStatus> cmdCodes = {}; // code.no: status

  MasterDataManager? mstData;
  late Region? _region = widget.region;

  String get tmpPath => joinPaths(db.paths.userDir, 'sniff', db.curUser.id);

  @override
  void initState() {
    super.initState();
    loadOrSave();
  }

  Future<void> loadOrSave() async {
    try {
      if (widget.toploginText != null) {
        mstData = loadMstData(utf8.encode(widget.toploginText!), true);
        updateFromMstData();
        await FilePlus(tmpPath).create(recursive: true);
        await FilePlus(tmpPath).writeAsString(widget.toploginText!);
      } else if (widget.mstData != null) {
        mstData = widget.mstData;
        updateFromMstData();
      } else {
        final file = FilePlus(tmpPath);
        if (file.existsSync()) {
          mstData = loadMstData(await file.readAsBytes(), false);
          updateFromMstData();
          if (mounted) setState(() {});
        }
      }
    } catch (e, s) {
      logger.e('init http packages cache failed', e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = ChaldeaUrl.doc('import_https/');
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(S.current.https_sniff),
        actions: [
          ChaldeaUrl.docsHelpBtn('import_https/'),
          IconButton(
            onPressed: importResponseBody,
            icon: const FaIcon(FontAwesomeIcons.fileImport),
            tooltip: S.current.import_source_file,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: mstData?.userShop.isNotEmpty == true,
                onTap: () {
                  db.runtimeData.clipBoard.mstData = mstData;
                  EasyLoading.showToast(S.current.copied);
                },
                child: const Text('Copy Data (In-app)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: mstData == null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(S.current.usage, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("${S.current.import_source_file} ↗↗"),
                        TextButton(
                          onPressed: () {
                            launch(url);
                          },
                          child: Text(url),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "For JP/NA, login via ",
                            children: [
                              SharedBuilder.textButtonSpan(
                                context: context,
                                text: S.current.import_auth_file,
                                onTap: kIsWeb
                                    ? null
                                    : () {
                                        router.pushPage(const AutoLoginPage());
                                      },
                              ),
                              const TextSpan(text: ' first'),
                            ],
                          ),
                          textAlign: TextAlign.center,
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
                        cmdCodeSliver,
                        classBoardSlider,
                      ],
                    ),
                  ),
          ),
          kDefaultDivider,
          SafeArea(
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), child: buttonBar),
          ),
        ],
      ),
    );
  }

  final double _with = 42;
  final double _height = 42 / (132 / 144);

  Widget get userInfoSliver {
    final user = mstData?.user;
    if (user == null) {
      return MultiSliver(children: const [ListTile(title: Text("??? no user info found"))]);
    }
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            leading: const Icon(Icons.supervised_user_circle),
            title: Text('${user.displayName}\n${user.friendCode}'),
            //  ${user.genderType == 1 ? '♂ ${S.current.guda_male}' : '♀ ${S.current.guda_female}'}
            subtitle: Text(mstData?.userLogin.firstOrNull?.lastLoginAt.sec2date().toStringShort() ?? '?'),
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
            child: MultiSliver(
              children: [
                // ListTile(
                //   dense: true,
                //   title: Text(S.current.obtain_time),
                //   trailing: Text(topLogin!.serverTime?.toStringShort() ?? '?'),
                // ),
                // ListTile(
                //   dense: true,
                //   title: Text(S.current.gender),
                //   trailing: Text(),
                // ),
                ListTile(
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final (itemId, text) in {
                        Items.stoneId: '${user.stone}(${user.freeStone}+${user.chargeStone})',
                        Items.summonTicketId: mstData?.userItem[Items.summonTicketId]?.num.toString() ?? '0',
                        Items.rarePrismId: user.rarePri.format(compact: false, groupSeparator: ','),
                        Items.manaPrismId: user.mana.format(compact: false, groupSeparator: ','),
                        Items.qpId: user.qp.format(compact: false, groupSeparator: ','),
                      }.items)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Item.iconBuilder(context: context, item: null, itemId: itemId, width: 32),
                            Text('$text  '),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget itemSliver(BoxConstraints constraints) {
    final shownItems = items.where((item) {
      final dbItem = db.gameData.items[item.itemId];
      if (dbItem != null) {
        final category = dbItem.category;
        if (category == ItemCategory.event || category == ItemCategory.itemSelectMonth) return false;
        if (category == ItemCategory.eventAscension && item.num == 0) return false;
        if (category == ItemCategory.other) {
          if (item.num == 0) return false;
          if (dbItem.type == ItemType.continueItem) return false;
        }
      }
      return true;
    }).toList();
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
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: _with,
                  childAspectRatio: 132 / 144,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = shownItems[index];
                  return Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: item.itemId,
                    width: _with,
                    text: item.num.toString(),
                  );
                }, childCount: shownItems.length),
              ),
            ),
          ),
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

        int? coin = mstData?.userSvtCoin[svt.svtId]?.num;
        Widget _wrapCellStyle(List<String> texts) {
          return CustomTableRow.fromTexts(
            texts: texts,
            defaults: TableCellData(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
            divider: null,
          );
        }

        List<Widget> infoRows = [
          _wrapCellStyle([
            'Lv.${svt.lv}',
            '${S.current.ascension_short} ${svt.limitCount}',
            '${S.current.grail} ${svt.exceedCount}',
          ]),
          _wrapCellStyle([
            '${S.current.np_short} ${svt.treasureDeviceLv1}',
            '${S.current.bond} ${cardCollections[svt.svtId]!.friendshipRank}',
            coin == null ? '' : ('${S.current.servant_coin_short} $coin'),
          ]),
          _wrapCellStyle([
            '${S.current.active_skill_short} ${svt.skillLv1}/${svt.skillLv2}/${svt.skillLv3}',
            svt.appendLvs == null
                ? ''
                : '${S.current.append_skill_short} ${svt.appendLvs!.map((e) => e == 0 ? '-' : e).join('/')}',
          ]),
          if (db.gameData.servantsById[svt.svtId]!.profile.costume.isNotEmpty)
            _wrapCellStyle(['${S.current.costume} ${cardCollections[svt.svtId]!.costumeIdsTo01()}']),
          if (group.length > 1 || svt.isWithdraw())
            CustomTableRow.fromChildren(
              defaults: TableCellData(padding: EdgeInsets.zero),
              divider: null,
              children: [
                Text(
                  [
                    '[${group.indexOf(svt) + 1}] ${DateFormat('yyyy-MM-dd').format(svt.createdAt.sec2date())}',
                    if (svt.isWithdraw()) S.current.event_svt_withdraw,
                  ].join(' '),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
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
                child: db.gameData.servantsById[svt.svtId]?.iconBuilder(context: context, height: 56),
              ),
              if (svt.isLocked()) const Icon(Icons.lock, size: 13, color: Colors.white),
              if (svt.isLocked()) Icon(Icons.lock, size: 12, color: Colors.yellow[900]),
            ],
          ),
          title: DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
            child: CustomTable(
              hideOutline: true,
              verticalDivider: const VerticalDivider(width: 0, color: Colors.transparent),
              horizontalDivider: const Divider(height: 0, color: Colors.transparent),
              children: infoRows,
            ),
          ),
          onTap: _onTapSvt,
        );
        if (_validSvts.contains(svt)) {
          validCount += 1;
        } else {
          child = Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 0.45, child: child),
              GestureDetector(
                onTap: _onTapSvt,
                child: Icon(Icons.clear_rounded, color: Colors.red, size: _height * 0.8),
              ),
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
            title: Text(inStorage ? '${S.current.servant}(${S.current.svt_second_archive})' : S.current.servant),
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
                ExpandIcon(onPressed: null, isExpanded: inStorage ? _showStorage : _showSvt),
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
              delegate: SliverChildBuilderDelegate((context, index) => children[index], childCount: children.length),
            ),
          ),
      ],
    );
  }

  Widget get craftSliver {
    int owned = crafts.values.where((e) => e.status == CraftStatus.owned).length,
        met = crafts.values.where((e) => e.status == CraftStatus.met).length,
        notMet = crafts.values.where((e) => e.status == CraftStatus.notMet).length;
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
                  title: Text(
                    '${CraftStatus.shownText(CraftStatus.owned)}: $owned\n'
                    '${CraftStatus.shownText(CraftStatus.met)}: $met\n'
                    '${CraftStatus.shownText(CraftStatus.notMet)}: $notMet\n'
                    'ALL:   ${crafts.length}',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget get cmdCodeSliver {
    int owned = cmdCodes.values.where((e) => e.status == CmdCodeStatus.owned).length,
        met = cmdCodes.values.where((e) => e.status == CmdCodeStatus.met).length,
        notMet = cmdCodes.values.where((e) => e.status == CmdCodeStatus.notMet).length;
    int svtCount = 0, ccCount = 0;
    if (mstData != null) {
      for (final svtcc in mstData!.userSvtCommandCode) {
        final count = svtcc.userCommandCodeIds.where((e) => e != 0).length;
        ccCount += count;
        if (count > 0) svtCount += 1;
      }
    }
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            leading: Checkbox(
              value: _includeCmdCode,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => setState(() {
                _includeCmdCode = v ?? _includeCmdCode;
              }),
            ),
            title: Text('${S.current.command_code} & ${S.current.beast_footprint}'),
            trailing: ExpandIcon(onPressed: null, isExpanded: _showCmdCode),
            onTap: () {
              setState(() {
                _showCmdCode = !_showCmdCode;
              });
            },
          ),
        ),
        if (_showCmdCode)
          SliverClip(
            child: MultiSliver(
              children: [
                SHeader(S.current.command_code),
                ListTile(
                  leading: const Text(''),
                  title: Text(
                    '${CmdCodeStatus.shownText(CmdCodeStatus.owned)}: $owned\n'
                    '${CmdCodeStatus.shownText(CmdCodeStatus.met)}: $met\n'
                    '${CmdCodeStatus.shownText(CmdCodeStatus.notMet)}: $notMet\n'
                    'ALL:   ${cmdCodes.length}\n'
                    '${S.current.cc_equipped_svt}: $svtCount ${S.current.servant}, $ccCount ${S.current.command_code}.',
                    textScaler: const TextScaler.linear(0.8),
                  ),
                ),
                if (mstData!.userSvtCommandCard.isNotEmpty) SHeader(S.current.beast_footprint),
                for (final svt in mstData!.userSvtCommandCard)
                  if (svt.commandCardParam.any((e) => e > 0))
                    ListTile(
                      dense: true,
                      leading: db.gameData.servantsById[svt.svtId]?.iconBuilder(context: context, width: 32),
                      title: Text(db.gameData.servantsById[svt.svtId]?.lName.l ?? 'SVT ${svt.svtId}'),
                      subtitle: Text(svt.commandCardParam.join(", ")),
                    ),
              ],
            ),
          ),
      ],
    );
  }

  Widget get classBoardSlider {
    final boards = mstData?.userClassBoardSquare.toList() ?? [];
    boards.sort2((e) => e.classBoardBaseId);
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            leading: Checkbox(
              value: _includeClassBoard,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => setState(() {
                _includeClassBoard = v ?? _includeClassBoard;
              }),
            ),
            title: Text(S.current.class_board),
            trailing: ExpandIcon(onPressed: null, isExpanded: _showClassBoard),
            onTap: () {
              setState(() {
                _showClassBoard = !_showClassBoard;
              });
            },
          ),
        ),
        if (_showClassBoard)
          SliverClip(
            child: MultiSliver(
              children: boards.map((userBoard) {
                final board = db.gameData.classBoards[userBoard.classBoardBaseId];
                return ListTile(
                  dense: true,
                  leading: db.getIconImage(board?.uiIcon, width: 32),
                  title: Text(board?.dispName ?? "${S.current.class_board} ${userBoard.classBoardBaseId}"),
                  subtitle: Text(
                    "${S.current.unlock}: ${userBoard.classBoardUnlockSquareIds.length}. ${S.current.enhance}: ${userBoard.classBoardSquareIds.length}",
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget get buttonBar {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        Wrap(
          spacing: 4,
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
                setState(() {
                  _allowDuplicated = v ?? _allowDuplicated;
                  _refreshValidSvts();
                });
              },
              label: Text(S.current.import_http_body_duplicated),
            ),
          ],
        ),
        Wrap(
          spacing: 4,
          runSpacing: 2,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton(
              onPressed: mstData == null
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (context) => buildStatDialog(context, mstData!),
                      );
                    },
              child: Text(S.current.statistics_title),
            ),
            FilledButton.tonal(
              onPressed: mstData == null
                  ? null
                  : () async {
                      final region = await getDecidedRegion();
                      router.pushPage(FgoAnnualReportPage(mstData: mstData!, region: region));
                    },
              child: Text(Language.isZH ? '统计报告' : 'Report'),
            ),
            FilledButton.tonal(
              onPressed: mstData?.user == null ? null : didImportData,
              child: Text(S.current.import_data),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildStatDialog(BuildContext context, MasterDataManager _mstData) {
    return SimpleDialog(
      title: Text(S.current.statistics_title),
      children: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            router.push(
              child: SvtBondDetailPage(
                friendCode: _mstData.user?.friendCode,
                userSvtCollections: _mstData.userSvtCollection.toList(),
                userSvts: [..._mstData.userSvt, ..._mstData.userSvtStorage],
              ),
            );
          },
          child: Text(S.current.bond),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            router.pushPage(
              SniffPresentBoxDetailPage(
                presents: _mstData.userPresentBox.toList(),
                missions: _mstData.userEventMission.toList(),
                items: _mstData.userItem.toList(),
                userGame: _mstData.userGame.firstOrNull,
              ),
            );
          },
          child: Text(S.current.present_box),
        ),
        SimpleDialogOption(
          onPressed: () async {
            Navigator.pop(context);
            final gachas = _mstData.userGacha;
            final region = await getDecidedRegion(context);
            if (region == null) return;
            router.pushPage(
              SniffGachaHistory(
                records: gachas.toList(),
                userSvt: _mstData.userSvt.toList(),
                userSvtStorage: _mstData.userSvtStorage.toList(),
                userSvtCollection: _mstData.userSvtCollection.toList(),
                userShops: _mstData.userShop.toList(),
                userItems: _mstData.userItem.toList(),
                region: region,
              ),
            );
          },
          child: Text(S.current.gacha),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            router.pushPage(ClassBoardMissionDemand(userSvtCollection: _mstData.userSvtCollection.toList()));
          },
          child: Text(S.current.class_board),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            router.pushPage(UserQuestFarmingStatPage(userQuests: _mstData.userQuest.toList()));
          },
          child: Text(S.current.quest),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            router.pushPage(UserDeckListPage(mstData: _mstData));
          },
          child: const Text("Formation Decks"),
        ),
      ],
    );
  }

  void _refreshValidSvts() {
    _validSvts.clear();
    for (final group in servants) {
      for (final svt in group) {
        if (svt.isWithdraw()) continue;
        if (_onlyLocked && !svt.isLocked()) continue;
        if (!_allowDuplicated && group.indexOf(svt) > 0) continue;
        _validSvts.add(svt);
      }
    }
  }

  void didImportData() async {
    final user = db.curUser;
    final userGame = mstData?.user;
    if (mstData == null || userGame == null) {
      EasyLoading.showError('No user data found.\nIs it valid?');
      return;
    }
    final lastImportDifferent = user.lastImportId != null && user.lastImportId != userGame.friendCode;
    bool? confirm = await SimpleConfirmDialog(
      title: Text(S.current.import_data),
      content: Text(
        [
          'Import ${userGame.name} (${userGame.friendCode})',
          'to [${db.curUser.name}]',
          if (lastImportDifferent) 'Last imported: ${user.lastImportId}!!!',
        ].join('\n'),
      ),
    ).showDialog(context);
    if (confirm != true || !mounted) return;

    if (lastImportDifferent) {
      final diffConfirm = await SimpleConfirmDialog(
        title: Text(S.current.warning),
        content: Text(
          'Last imported:\n${user.lastImportId}\n\n'
          'Current import:\n${userGame.friendCode}\n\n\n${S.current.confirm}?',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ).showDialog(context);
      if (diffConfirm != true || !mounted) return;
    }

    user.isGirl = userGame.genderType == 2;
    if (_includeItem) {
      // user.items.clear();
      for (final svtCoin in mstData!.userSvtCoin) {
        final coinId = db.gameData.servantsById[svtCoin.svtId]?.coin?.item.id;
        if (coinId == null) continue;
        user.items[coinId] = svtCoin.num;
      }
      for (final item in items) {
        user.items[item.itemId] = item.num;
      }
      user.items[Items.stoneId] = userGame.stone;
      user.items[Items.qpId] = userGame.qp;
      user.items[Items.manaPrismId] = userGame.mana;
      user.items[Items.rarePrismId] = userGame.rarePri;
    }
    if (_includeCraft) {
      user.craftEssences.addAll(crafts.map((key, value) => MapEntry(key, CraftStatus.fromJson(value.toJson()))));
    }
    if (_includeCmdCode) {
      user.cmdCodes.addAll(cmdCodes.map((key, value) => MapEntry(key, CmdCodeStatus.fromJson(value.toJson()))));

      if (mstData != null) {
        final userCCMap = <int, int>{for (final cc in mstData!.userCommandCode) cc.id: cc.commandCodeId};
        for (final svtcc in mstData!.userSvtCommandCode) {
          final svtNo = db.gameData.servantsById[svtcc.svtId]?.collectionNo;
          if (svtNo == null || svtNo == 0) continue;
          final status = user.svtStatusOf(svtNo);
          for (int index = 0; index < svtcc.userCommandCodeIds.length; index++) {
            final cc = db.gameData.commandCodesById[userCCMap[svtcc.userCommandCodeIds[index]]];
            status.setCmdCode(index, cc?.collectionNo);
          }
        }
        for (final card in mstData!.userSvtCommandCard) {
          final svtNo = db.gameData.servantsById[card.svtId]?.collectionNo;
          if (svtNo == null || svtNo == 0) continue;
          final status = user.svtStatusOf(svtNo);
          status.cmdCardStrengthen = List.generate(5, (index) => (card.commandCardParam.getOrNull(index) ?? 0) ~/ 20);
        }
      }
    }
    if (_includeClassBoard) {
      final userBoards = mstData?.userClassBoardSquare.toList() ?? [];
      for (final userBoard in userBoards) {
        final status = user.classBoardStatusOf(userBoard.classBoardBaseId);
        status.unlockedSquares = userBoard.classBoardUnlockSquareIds.toSet();
        status.enhancedSquares = userBoard.classBoardSquareIds.toSet();
      }
    }
    // 不删除原本信息
    // 记录1号机。1号机使用Servant.no, 2-n号机使用UserSvt.id
    HashSet<int> _alreadyAdded = HashSet();
    for (var group in servants) {
      for (var svt in group) {
        if (!_validSvts.contains(svt)) continue;
        if (!_includeSvt && !svt.inStorage) continue;
        if (!_includeSvtStorage && svt.inStorage) continue;
        final dbSvt = svt.dbSvt;
        if (dbSvt == null || !dbSvt.isUserSvt) continue;

        SvtStatus status = SvtStatus();
        UserServantCollectionEntity collection = cardCollections[svt.svtId]!;
        if (_alreadyAdded.contains(svt.svtId) && dbSvt.collectionNo > 0) {
          user.dupServantMapping[svt.id] = dbSvt.collectionNo;
          status = user.svtStatusOf(svt.id);
        } else {
          status = user.svtStatusOf(dbSvt.collectionNo);
        }
        _alreadyAdded.add(svt.svtId);

        status
          ..favorite = true
          ..bond = collection.friendshipRank
          ..grandSvt = mstData?.userSvtGrand.any((e) => e.userSvtId == svt.id) == true;
        status.favorite = true;
        status.bond = collection.friendshipRank;
        status.cur
          ..npLv = svt.treasureDeviceLv1
          ..ascension = svt.limitCount
          ..skills = [svt.skillLv1, svt.skillLv2, svt.skillLv3]
          ..grail = svt.exceedCount
          ..fouHp3 = min(100, svt.adjustHp ~/ 5)
          ..fouAtk3 = min(100, svt.adjustAtk ~/ 5)
          ..fouHp = max(0, (svt.adjustHp - 100) ~/ 2)
          ..fouAtk = max(0, (svt.adjustAtk - 100) ~/ 2)
          ..bondLimit = collection.maxFriendshipRank;
        if (svt.appendLvs != null) {
          status.cur.appendSkills = List.generate(kAppendSkillNums.length, (i) => svt.appendLvs!.getOrNull(i) ?? 0);
        }
        status.cur.costumes = collection.costumeIdsTo01();
      }
    }
    for (final equip in mstData!.userEquip) {
      user.mysticCodes[equip.equipId] = equip.lv;
    }
    user.lastImportId = userGame.friendCode;

    EasyLoading.showSuccess(S.current.success);
    db.itemCenter.init();
    db.saveUserData();
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
            onTap: () {
              Navigator.of(context).pop(false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_present),
            title: Text(S.current.import_from_file),
            onTap: () {
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
      List<int>? bytes;
      if (fromFile == true) {
        final result = await FilePickerU.pickFiles(clearCache: true);
        bytes = result?.files.first.bytes;
      } else if (fromFile == false) {
        String? text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
        if (text != null && text.isNotEmpty) {
          bytes = utf8.encode(text);
        } else {
          EasyLoading.showError('Clipboard is empty!');
        }
      }
      if (bytes == null) return;
      mstData = loadMstData(bytes, true);
      updateFromMstData();
      await FilePlus(tmpPath).create(recursive: true);
      await FilePlus(tmpPath).writeAsBytes(bytes);
    } catch (e, s) {
      logger.e('fail to load http response', e, s);
      if (mounted) {
        SimpleConfirmDialog(
          title: const Text('Error'),
          content: Text('$e\n\n${ChaldeaUrl.doc("import_https/")}'),
        ).showDialog(context);
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  MasterDataManager loadMstData(List<int> bytes, bool logEvent) {
    FateTopLogin _topLogin = FateTopLogin.fromBytes(bytes);
    if (!_topLogin.responses.any((res) => res.nid == 'login' && res.isSuccess())) {
      throw const FormatException('This is not login data');
    }
    if (logEvent) {
      AppAnalysis.instance.logEvent("import_toplogin", {"region": _topLogin.region?.upper ?? "unknown"});
    }
    return _topLogin.mstData;
  }

  void updateFromMstData() {
    final mstData = this.mstData;
    if (mstData == null) {
      throw Exception('mstData null!');
    }
    // clear before import
    _validSvts.clear();
    cardCollections.clear();
    servants.clear();
    items = mstData.userItem.toList();
    crafts.clear();
    cmdCodes.clear();

    items.sort((a, b) => Item.compare2(a.itemId, b.itemId));

    // collections
    cardCollections = Map.fromEntries(mstData.userSvtCollection.map((e) => MapEntry(e.svtId, e)));

    // svt
    for (final svt in mstData.userSvt) {
      if ((svt.dbSvt?.collectionNo ?? 0) <= 0) continue;
      svt.inStorage = false;
      svt.appendLvs = mstData.getSvtAppendSkillLvs(svt);
      final group = servants.firstWhereOrNull((group) => group.any((element) => element.svtId == svt.svtId));
      if (group == null) {
        servants.add([svt]);
      } else {
        group.add(svt);
      }
    }
    // svtStorage
    for (final svt in mstData.userSvtStorage) {
      if ((svt.dbSvt?.collectionNo ?? 0) <= 0) continue;
      svt.inStorage = true;
      svt.appendLvs = mstData.getSvtAppendSkillLvs(svt);
      final group = servants.firstWhereOrNull((group) => group.any((element) => element.svtId == svt.svtId));
      if (group == null) {
        servants.add([svt]);
      } else {
        group.add(svt);
      }
    }

    servants.sort((a, b) => SvtFilterData.compare(a.first.dbSvt, b.first.dbSvt));
    for (final group in servants) {
      group.sort((a, b) {
        // lv higher, active skills higher, created earlier, id
        final aa = [a.lv, a.skillLv1 + a.skillLv2 + a.skillLv3, -a.createdAt, a.id];
        final bb = [b.lv, b.skillLv1 + b.skillLv2 + b.skillLv3, -b.createdAt, b.id];
        for (int i = 0; i < aa.length; i++) {
          final ia = aa[i], ib = bb[i];
          if (ia != ib) return ib - ia;
        }
        return 0;
      });
    }

    // crafts
    for (final card in cardCollections.values) {
      final ce = db.gameData.craftEssencesById[card.svtId];
      if (ce == null) continue;
      crafts.putIfAbsent(ce.collectionNo, () => CraftStatus()).status = card.status;
    }

    for (final ce in [...mstData.userSvt, ...mstData.userSvtStorage]) {
      if (ce.dbCE == null) continue;
      final status = crafts.putIfAbsent(ce.dbCE!.collectionNo, () => CraftStatus());
      if (status.lv < ce.lv || (status.lv == ce.lv && status.limitCount < ce.limitCount)) {
        status.lv = ce.lv;
        status.limitCount = ce.limitCount;
      }
    }
    for (final code in mstData.userCommandCodeCollection) {
      final cc = code.dbCC;
      if (cc == null) continue;
      final status = cmdCodes.putIfAbsent(cc.collectionNo, () => CmdCodeStatus());
      status.status = code.status;
    }
    for (final code in mstData.userCommandCode) {
      final cc = code.dbCC;
      if (cc == null) continue;
      final status = cmdCodes.putIfAbsent(cc.collectionNo, () => CmdCodeStatus());
      status.count += 1;
    }

    _refreshValidSvts();
  }

  Future<Region?> getDecidedRegion([BuildContext? context]) async {
    if (_region != null) return _region!;
    _region = await router.showDialog(
      barrierDismissible: false,
      context: context ?? (mounted ? this.context : null),
      builder: (context) => SimpleDialog(
        title: Text(S.current.game_server),
        children: [
          for (final value in Region.values)
            SimpleDialogOption(
              child: Text(value.localName),
              onPressed: () {
                Navigator.pop(context, value);
              },
            ),
        ],
      ),
    );
    return _region;
  }
}
