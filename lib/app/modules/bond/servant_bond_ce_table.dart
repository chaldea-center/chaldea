import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
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
  final List<_ServantWrap> selectedSvts = [_ServantWrap()]; // 空 _ServantWrap 表示待选择
  late List<CraftEssence> bondCEs;
  final hovered = ValueNotifier<String?>(null);
  late ScrollController _headerScrollController;
  late ScrollController _bodyScrollController;

  // 缓存匹配结果，避免重复计算
  final Map<String, Map<int, bool>> _matchCache = {};

  String _getCacheKey(int svtId, int ceId) => '$svtId-$ceId';

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

  Set<int> _getSvtAllLimits(Servant svt) {
    return {...range(5), ...svt.costume.keys, ...svt.ascensionAdd.individuality2.all.keys};
  }

  Map<int, bool> _svtMatchesCE(_ServantWrap svtWrap, CraftEssence ce) {
    final svt = svtWrap.svt;
    if (svt == null) return {};

    final cacheKey = _getCacheKey(svt.id, ce.id);
    if (_matchCache.containsKey(cacheKey)) {
      return _matchCache[cacheKey]!;
    }

    // 检查从者是否符合礼装的羁绊加成条件
    final skills = ce.getActivatedSkills(true)[1] ?? <NiceSkill>[];
    if (skills.isEmpty) {
      _matchCache[cacheKey] = {};
      return {};
    }

    _matchCache[cacheKey] = {};

    for (final limit in _getSvtAllLimits(svt)) {
      final svtIndivs = svt.getIndividuality(0, limit);

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
            _matchCache[cacheKey]![limit] = true;
          }

          // 检查从者是否包含所有 trait（只要有一个 traits 组满足条件即可）
          for (final traits in traitsList) {
            if (traits.isEmpty) {
              continue;
            }
            if (traits.every((traitId) => svtIndivs.contains(traitId))) {
              _matchCache[cacheKey]![limit] = true;
            }
          }
        }
      }
      if (!_matchCache[cacheKey]!.containsKey(limit)) {
        _matchCache[cacheKey]![limit] = false;
      }
    }

    return _matchCache[cacheKey]!;
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
                selectedSvts.add(_ServantWrap());
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
    final svtWrap = selectedSvts[index];

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
        child: _ServantSelectorNoOption(
          svtWrap: svtWrap,
          onChanged: () {
            if (mounted) {
              setState(() {
                // 如果是最后一个位置且选择了从者，添加新列
                if (index == selectedSvts.length - 1 && svtWrap.svt != null) {
                  selectedSvts.add(_ServantWrap());
                }
                // 如果当前列被清空且不是最后一个位置，移除该列
                if (index != selectedSvts.length - 1 && svtWrap.svt == null) {
                  selectedSvts.remove(svtWrap);
                }
              });
            }
          },
          hovered: hovered,
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
          final svtWrap = selectedSvts[svtIndex];
          return _buildMatchCell(svtWrap, ce);
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

  Widget _buildMatchCell(_ServantWrap svtWrap, CraftEssence ce) {
    if (svtWrap.svt == null) {
      return const SizedBox(width: 48, height: 48);
    }

    final matches = _svtMatchesCE(svtWrap, ce);
    if (matches.isEmpty) {
      return const SizedBox(width: 48, height: 48);
    }

    final isAllMatch = matches.values.every((match) => match);
    final isAllDismatch = matches.values.every((match) => !match);

    String msg;
    if (isAllMatch || isAllDismatch) {
      msg = '';
    } else {
      msg = matches.keys
          .where((limitCount) => matches[limitCount] == true)
          .map((limitCount) {
            String name;
            if (limitCount < 10) {
              int stage = BattleUtils.limitCountToStage(limitCount);
              name = '${S.current.ascension_short} $limitCount (${S.current.ascension_stage_short} $stage)';
            } else {
              final costume = svtWrap.svt?.costume[limitCount];
              name = costume?.lName.l ?? '${S.current.costume} $limitCount';
            }
            return '- $name';
          })
          .join('\n');
      msg = '${svtWrap.svt?.lName.l}\n$msg';
    }

    return Container(
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Center(
        child: Tooltip(
          message: msg,
          child: Text(
            isAllMatch
                ? '\u2713'
                : isAllDismatch
                ? '\u00D7'
                : '${matches.values.where((match) => match).length}/${matches.length}', // ✓ or ✗ or 部分匹配
            style: TextStyle(
              color: isAllMatch
                  ? Colors.green
                  : isAllDismatch
                  ? Colors.red
                  : Colors.orange,
              fontSize: isAllMatch || isAllDismatch ? 32 : 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServantWrap {
  Servant? svt;
}

class _ServantSelectorNoOption extends StatelessWidget {
  final _ServantWrap svtWrap;
  final VoidCallback onChanged;
  final ValueNotifier<String?> hovered;

  _ServantSelectorNoOption({required this.svtWrap, required this.onChanged, required this.hovered});

  SvtFilterData get svtFilterData => db.runtimeData.svtFilters.current;

  @override
  Widget build(final BuildContext context) {
    List<Widget> children = [];

    // svt icon
    Widget svtIcon = GameCardMixin.cardIconBuilder(
      context: context,
      icon: svtWrap.svt?.ascendIcon(0) ?? Atlas.common.emptySvtIcon,
      width: 80,
      aspectRatio: 132 / 144,
      option: ImageWithTextOption(
        textAlign: TextAlign.left,
        fontSize: 10,
        alignment: Alignment.bottomLeft,
        errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
      ),
    );
    svtIcon = _HoverWidget(
      hovered: hovered,
      hoverKey: '${svtWrap.hashCode}-svt',
      hoveredBuilder: (context, child) {
        return _stackActions(
          context: context,
          child: child,
          onTapSelect: _openServantSelector,
          onTapClear: () {
            svtWrap.svt = null;
            onChanged();
          },
          iconSize: 16,
        );
      },
      onTap: _openServantSelector,
      child: svtIcon,
    );
    children.add(svtIcon);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: children),
    );
  }

  void _openServantSelector() {
    router.pushPage(
      ServantListPage(
        planMode: false,
        onSelected: (selectedSvt) {
          svtWrap.svt = selectedSvt;
          onChanged();
        },
        filterData: svtFilterData,
        pinged: db.curUser.battleSim.pingedSvts.toList(),
        showSecondaryFilter: true,
      ),
    );
  }

  Widget _stackActions({
    required BuildContext context,
    required Widget child,
    required VoidCallback? onTapSelect,
    required VoidCallback? onTapClear,
    double iconSize = 24,
  }) {
    if (!Theme.of(context).platform.isDesktop) return child;
    const double padding = 4;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          left: 0,
          top: -iconSize / 2,
          child: Container(
            decoration: ShapeDecoration(color: Theme.of(context).colorScheme.primary, shape: const CircleBorder()),
            child: IconButton(
              onPressed: onTapSelect,
              icon: const Icon(Icons.people),
              color: Colors.white,
              iconSize: iconSize,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(padding),
              splashRadius: 20,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: -iconSize / 2,
          child: Container(
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              shape: const CircleBorder(),
            ),
            child: IconButton(
              onPressed: onTapClear,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.white,
              iconSize: iconSize,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(padding),
              splashRadius: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _HoverWidget extends StatefulWidget {
  final String hoverKey;
  final Widget child;
  final Widget Function(BuildContext context, Widget child) hoveredBuilder;
  final VoidCallback? onTap;
  final ValueNotifier<String?> hovered;

  const _HoverWidget({
    required this.hoverKey,
    required this.child,
    required this.hoveredBuilder,
    this.onTap,
    required this.hovered,
  });

  @override
  State<_HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<_HoverWidget> {
  @override
  Widget build(BuildContext context) {
    Widget child = InkWell(
      onHover: (hovered) {
        setState(() {
          if (hovered) {
            widget.hovered.value = widget.hoverKey;
          } else if (widget.hovered.value == widget.hoverKey) {
            widget.hovered.value = null;
          }
        });
      },
      onTap: widget.onTap,
      child: widget.child,
    );

    if (widget.hoverKey == widget.hovered.value) {
      child = widget.hoveredBuilder(context, child);
    }
    return child;
  }
}
