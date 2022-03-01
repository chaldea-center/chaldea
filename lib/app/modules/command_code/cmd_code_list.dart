import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_tile.dart';
import 'package:chaldea/widgets/searchable_list_state.dart';
import 'package:flutter/material.dart';

import '../common/filter_page_base.dart';
import 'cmd_code.dart';
import 'filter.dart';

class CmdCodeListPage extends StatefulWidget {
  final void Function(CommandCode)? onSelected;

  CmdCodeListPage({Key? key, this.onSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CmdCodeListPageState();
}

class CmdCodeListPageState extends State<CmdCodeListPage>
    with SearchableListState<CommandCode, CmdCodeListPage> {
  @override
  Iterable<CommandCode> get wholeData => db2.gameData.commandCodes.values;

  CmdCodeFilterData get filterData => db2.settings.cmdCodeFilterData;

  @override
  void initState() {
    super.initState();
    if (db2.settings.autoResetFilter) {
      filterData.reset();
    }
    // options = _CraftSearchOptions(onChanged: (_) => safeSetState());
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => CmdCodeFilterData.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(S.current.command_code,
            maxLines: 1, overflow: TextOverflow.fade),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CmdCodeFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          // searchIcon,
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(CommandCode cc) {
    return CustomTile(
      leading: db2.getIconImage(
        cc.borderedIcon,
        width: 56,
        aspectRatio: 132 / 144,
      ),
      title: AutoSizeText(cc.lName.l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!Language.isJP) AutoSizeText(cc.name, maxLines: 1),
          Text('No.${cc.collectionNo}'),
        ],
      ),
      trailing: IconButton(
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () => _onTapCard(cc, true),
      ),
      selected: SplitRoute.isSplit(context) && selected == cc,
      onTap: () => _onTapCard(cc),
    );
  }

  @override
  Widget gridItemBuilder(CommandCode cc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: GestureDetector(
        child: db2.getIconImage(cc.borderedIcon),
        onTap: () => _onTapCard(cc),
      ),
    );
  }

  @override
  String getSummary(CommandCode cc) {
    return options?.getSummary(cc) ?? '';
  }

  @override
  bool filter(CommandCode ccc) {
    if (!filterData.rarity.matchOne(ccc.rarity)) {
      return false;
    }
    return true;
  }

  void _onTapCard(CommandCode cc, [bool forcePush = false]) {
    if (widget.onSelected != null && !forcePush) {
      widget.onSelected!(cc);
    } else {
      router.push(
        url: cc.route,
        child: CmdCodeDetailPage(
          cc: cc,
          onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
        ),
        detail: true,
        popDetail: true,
      );
      selected = cc;
    }
    setState(() {});
  }
}
