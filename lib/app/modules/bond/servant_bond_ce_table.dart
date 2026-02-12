import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/modules/battle/formation/svt_selector.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ServantBondCETableTab extends StatefulWidget {
  const ServantBondCETableTab({super.key});

  @override
  State<ServantBondCETableTab> createState() => _ServantBondCETableTabState();
}

class _ServantBondCETableTabState extends State<ServantBondCETableTab> {
  final List<PlayerSvtData> selectedSvts = [PlayerSvtData.base()]; // 空 PlayerSvtData 表示待选择
  late List<CraftEssence> bondCEs;
  final hovered = ValueNotifier<String?>(null);
  late ScrollController _headerScrollController;
  late ScrollController _bodyScrollController;

  // 缓存匹配结果，避免重复计算
  final Map<String, bool> _matchCache = {};

  String _getCacheKey(int svtId, int limitCount, int ceId) => '$svtId-$limitCount-$ceId';

  @override
  void initState() {
    super.initState();
    bondCEs = _getBondCraftEssences();
    _headerScrollController = ScrollController();
    _bodyScrollController = ScrollController();

    // 同步水平滚动
    _headerScrollController.addListener(() {
      if (_bodyScrollController.hasClients && _bodyScrollController.offset != _headerScrollController.offset) {
        _bodyScrollController.jumpTo(_headerScrollController.offset);
      }
    });

    _bodyScrollController.addListener(() {
      if (_headerScrollController.hasClients && _headerScrollController.offset != _bodyScrollController.offset) {
        _headerScrollController.jumpTo(_bodyScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    hovered.dispose();
    super.dispose();
  }

  List<CraftEssence> _getBondCraftEssences() {
    final List<CraftEssence> ces = [];
    // 使用与 equip_bond_bonus.dart 相同的逻辑
    for (final ce in db.gameData.craftEssencesById.values) {
      if (ce.collectionNo <= 0 || ce.isRegionSpecific) continue;
      if (ce.rarity < 5) continue;
      final skills = ce.getActivatedSkills(true)[1] ?? <NiceSkill>[];
      if (skills.isEmpty) continue;
      if (skills.length > 1) continue;

      final skill = skills.single;
      final funcs = [
        for (final func in skill.functions)
          if (func.funcType == FuncType.servantFriendshipUp &&
              (func.svals.firstOrNull?.EventId ?? 0) == 0 &&
              (func.functvals.isNotEmpty || func.overWriteTvalsList.isNotEmpty))
            func,
      ];
      if (funcs.isEmpty) continue;
      if (funcs.length > 1) continue;

      final func = funcs.single;
      final rateCount = func.svals.firstOrNull?.RateCount ?? 0;
      if (rateCount <= 0) continue;

      // 英霊逢魔: 1973-1979, FSN servant +10%
      if (ce.collectionNo >= 1973 && ce.collectionNo <= 1979) continue;

      ces.add(ce);
    }
    // 按 collectionNo 排序
    ces.sort((a, b) => a.collectionNo.compareTo(b.collectionNo));
    return ces;
  }

  bool _svtMatchesCE(PlayerSvtData playerSvtData, CraftEssence ce) {
    final svt = playerSvtData.svt;
    if (svt == null) return false;

    final cacheKey = _getCacheKey(svt.id, playerSvtData.limitCount, ce.id);
    if (_matchCache.containsKey(cacheKey)) {
      return _matchCache[cacheKey]!;
    }

    // 检查从者是否符合礼装的羁绊加成条件
    final skills = ce.getActivatedSkills(true)[1] ?? <NiceSkill>[];
    if (skills.isEmpty) {
      _matchCache[cacheKey] = false;
      return false;
    }

    final svtIndivs = svt.getIndividuality(0, playerSvtData.limitCount);

    for (final skill in skills) {
      for (final func in skill.functions) {
        if (func.funcType != FuncType.servantFriendshipUp) continue;

        // 获取 trait 限制
        final List<List<int>> traitsList = [];
        for (final tvals in func.functvals) {
          traitsList.add([tvals]);
        }
        for (final tvals in func.overWriteTvalsList) {
          traitsList.add(tvals);
        }

        // 如果没有 trait 限制，对所有从者有效
        if (traitsList.isEmpty) {
          _matchCache[cacheKey] = true;
          return true;
        }

        // 检查从者是否包含所有 trait（只要有一个 traits 组满足条件即可）
        for (final traits in traitsList) {
          if (traits.isEmpty) {
            continue;
          }
          if (traits.every((traitId) => svtIndivs.contains(traitId))) {
            _matchCache[cacheKey] = true;
            return true;
          }
        }
      }
    }

    _matchCache[cacheKey] = false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (bondCEs.isEmpty) {
      return Center(child: Text(S.current.empty_hint));
    }

    return Column(
      children: [
        // 固定的表头
        Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _headerScrollController,
            child: Padding(padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0), child: _buildHeader()),
          ),
        ),
        // 可滚动的表体
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _bodyScrollController,
                child: Padding(padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 8.0), child: _buildBody()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    const double ceColWidth = 60;
    const double svtColWidth = 60;

    return ValueListenableBuilder(
      valueListenable: hovered,
      builder: (context, _, _) => Table(
        border: TableBorder.all(color: Theme.of(context).dividerColor),
        defaultColumnWidth: const FixedColumnWidth(svtColWidth),
        columnWidths: {0: const FixedColumnWidth(ceColWidth)},
        children: [_buildHeaderRow()],
      ),
    );
  }

  Widget _buildBody() {
    const double ceColWidth = 60;
    const double svtColWidth = 60;

    return Table(
      border: TableBorder(
        left: BorderSide(color: Theme.of(context).dividerColor),
        right: BorderSide(color: Theme.of(context).dividerColor),
        bottom: BorderSide(color: Theme.of(context).dividerColor),
        horizontalInside: BorderSide(color: Theme.of(context).dividerColor),
        verticalInside: BorderSide(color: Theme.of(context).dividerColor),
      ),
      defaultColumnWidth: const FixedColumnWidth(svtColWidth),
      columnWidths: {0: const FixedColumnWidth(ceColWidth)},
      children: List.generate(bondCEs.length, (index) => _buildCERow(index)),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      children: [_buildHeaderCell(), ...List.generate(selectedSvts.length, (index) => _buildServantHeaderCell(index))],
    );
  }

  Widget _buildHeaderCell() {
    if (selectedSvts.any((data) => data.svt != null)) {
      return Container(
        constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
        child: Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                selectedSvts.clear();
                selectedSvts.add(PlayerSvtData.base());
                _matchCache.clear();
              });
            },
            child: Text(S.current.clear, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ),
      );
    }
    return Container(constraints: const BoxConstraints(minWidth: 60, minHeight: 60), child: Center());
  }

  Widget _buildServantHeaderCell(int index) {
    final playerSvtData = selectedSvts[index];

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
        child: ServantSelector(
          playerSvtData: playerSvtData,
          playerRegion: Region.jp,
          questPhase: null,
          onChanged: () {
            if (mounted) {
              setState(() {
                // 如果是最后一个位置且选择了从者，添加新列
                if (index == selectedSvts.length - 1 && playerSvtData.svt != null) {
                  selectedSvts.add(PlayerSvtData.base());
                }
                // 如果当前列被清空且不是最后一个位置，移除该列
                if (index != selectedSvts.length - 1 && playerSvtData.svt == null) {
                  selectedSvts.remove(playerSvtData);
                }
              });
            }
          },
          enableEdit: true,
          hovered: hovered,
          isShowSvtInfo: false,
          isShowCE: false,
        ),
      ),
    );
  }

  TableRow _buildCERow(int index) {
    final ce = bondCEs[index];

    return TableRow(
      children: [
        _buildCECell(ce),
        ...List.generate(selectedSvts.length, (svtIndex) {
          final playerSvtData = selectedSvts[svtIndex];
          return _buildMatchCell(playerSvtData, ce);
        }),
      ],
    );
  }

  Widget _buildCECell(CraftEssence ce) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
        child: Center(
          child: db.getIconImage(
            ce.borderedIcon,
            width: 48,
            height: 48,
            onTap: () {
              router.push(url: ce.route);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCell(PlayerSvtData playerSvtData, CraftEssence ce) {
    if (playerSvtData.svt == null) {
      return const SizedBox(width: 48, height: 48);
    }

    final matches = _svtMatchesCE(playerSvtData, ce);

    return Container(
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Center(
        child: Text(
          matches ? '\u2713' : '\u00D7', // ✓ or ✗
          style: TextStyle(color: matches ? Colors.green : Colors.red, fontSize: 32),
        ),
      ),
    );
  }
}
