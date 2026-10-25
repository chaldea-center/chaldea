import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ServantBondCETableTab extends StatefulWidget {
  final List<Servant> initialSvts;
  const ServantBondCETableTab({super.key, this.initialSvts = const []});

  @override
  State<ServantBondCETableTab> createState() => _ServantBondCETableTabState();
}

class _ServantBondCETableTabState extends State<ServantBondCETableTab> with AutomaticKeepAliveClientMixin {
  late final List<_ServantWrap> selectedSvts = [
    for (final svt in widget.initialSvts) (_ServantWrap()..svt = svt),
    _ServantWrap(), // An empty _ServantWrap is a selection placeholder.
  ];
  late List<CraftEssence> bondCEs;
  final hovered = ValueNotifier<String?>(null);

  @override
  bool get wantKeepAlive => true;

  // Cache match results to avoid recalculation.
  final Map<String, Map<int, bool>> _matchCache = {};

  String _getCacheKey(int svtId, int ceId) => '$svtId-$ceId';

  @override
  void initState() {
    super.initState();
    bondCEs = _getBondCraftEssences();
  }

  @override
  void dispose() {
    hovered.dispose();
    super.dispose();
  }

  List<CraftEssence> _getBondCraftEssences() {
    final List<CraftEssence> ces = [];

    for (final ce in db.gameData.craftEssencesById.values) {
      if (ce.obtain != CEObtain.manaShop) continue;

      if (!ce
          .getActivatedSkills(true)
          .values
          .expand((t) => t)
          .any(
            (skill) => skill.functions.any(
              (func) =>
                  func.funcType == FuncType.servantFriendshipUp &&
                  (func.svals.firstOrNull?.EventId ?? 0) == 0 &&
                  (func.functvals.isNotEmpty || func.overWriteTvalsList.isNotEmpty) &&
                  (func.svals.firstOrNull?.RateCount ?? 0) > 0,
            ),
          )) {
        continue;
      }

      ces.add(ce);
    }
    // Sort by collectionNo.
    ces.sort((a, b) => b.collectionNo.compareTo(a.collectionNo));
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

    // Check whether the servant meets the Craft Essence's bond bonus conditions.
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

          // Collect trait restrictions.
          final List<List<int>> traitsList = [];
          for (final tvals in func.functvals) {
            traitsList.add([tvals]);
          }
          for (final tvals in func.overWriteTvalsList) {
            traitsList.add(tvals);
          }

          // If there are no trait restrictions, this applies to all servants.
          if (traitsList.isEmpty) {
            _matchCache[cacheKey]![limit] = true;
          }

          // The servant must match every trait in at least one group.
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
    super.build(context);
    if (bondCEs.isEmpty) {
      return Center(child: Text(S.current.empty_hint));
    }

    final textHeights = <String, double>{};
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: math.min(constraints.maxWidth, 60.0 * (selectedSvts.length + 1)),
            height: constraints.maxHeight,
            child: DataTable2(
              fixedTopRows: 1,
              fixedLeftColumns: 1,
              headingRowHeight: _headingHeight(),
              horizontalMargin: 0,
              columnSpacing: 0,
              bottomMargin: 8,
              minWidth: 60.0 * (selectedSvts.length + 1) + 1,
              border: TableBorder.all(color: Theme.of(context).dividerColor),
              columns: [
                DataColumn2(fixedWidth: 60, label: _buildHeaderCell()),
                for (var index = 0; index < selectedSvts.length; index++)
                  DataColumn2(fixedWidth: 60, label: _buildServantHeaderCell(index)),
              ],
              rows: [
                for (final ce in bondCEs)
                  DataRow2(
                    specificRowHeight: _rowHeight(ce, textHeights),
                    cells: [
                      DataCell(_buildCECell(ce)),
                      for (final svtWrap in selectedSvts) DataCell(_buildMatchCell(svtWrap, ce)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _textHeight(String text, TextStyle style, double width) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }

  double _headingHeight() {
    if (selectedSvts.every((svt) => svt.svt == null)) return 68;
    final style = Theme.of(context).textTheme.labelLarge!
        .merge(TextButtonTheme.of(context).style?.textStyle?.resolve({}));
    return math.max(68, _textHeight(S.current.clear, style, 36) + 16);
  }

  double _rowHeight(CraftEssence ce, Map<String, double> textHeights) {
    var height = 60.0;
    final baseStyle =
        DataTableTheme.of(context).dataTextStyle ??
        Theme.of(context).dataTableTheme.dataTextStyle ??
        Theme.of(context).textTheme.bodyMedium!;
    for (final svtWrap in selectedSvts) {
      final matches = _svtMatchesCE(svtWrap, ce);
      if (matches.isEmpty) continue;
      final allMatch = matches.values.every((match) => match);
      final allDismatch = matches.values.every((match) => !match);
      final text = _matchText(matches);
      height = math.max(
        height,
        textHeights.putIfAbsent(text, () {
          final style = baseStyle.copyWith(fontSize: allMatch || allDismatch ? 32 : 20);
          return _textHeight(text, style, 60);
        }),
      );
    }
    return height;
  }

  String _matchText(Map<int, bool> matches) {
    if (matches.values.every((match) => match)) return '\u2713'; // ✓
    if (matches.values.every((match) => !match)) return '\u00D7'; // ✗
    return '${matches.values.where((match) => match).length}/${matches.length}';
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
            child: Text(S.current.clear, softWrap: true, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
                // Add a new column when a servant is selected in the last slot.
                if (index == selectedSvts.length - 1 && svtWrap.svt != null) {
                  selectedSvts.add(_ServantWrap());
                }
                // Remove the column when a non-final slot is cleared.
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
            _matchText(matches),
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
  Widget build(BuildContext context) {
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
        pinged: db.settings.gameplay.pinnedSvtIds.toList(),
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
            decoration: ShapeDecoration(color: Theme.of(context).colorScheme.error, shape: const CircleBorder()),
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
