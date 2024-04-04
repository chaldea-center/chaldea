import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/searchable_list_state.dart';
import 'board_cost.dart';
import 'class_board.dart';

class ClassBoardListPage extends StatefulWidget {
  final void Function(ClassBoard)? onSelected;

  ClassBoardListPage({super.key, this.onSelected});

  @override
  State<StatefulWidget> createState() => ClassBoardListPageState();
}

class ClassBoardListPageState extends State<ClassBoardListPage>
    with SearchableListState<ClassBoard, ClassBoardListPage> {
  @override
  Iterable<ClassBoard> get wholeData => db.gameData.classBoards.values;

  @override
  final bool prototypeExtent = true;

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => a.id.compareTo(b.id));
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(S.current.class_board, maxLines: 1),
        bottom: showSearchBar ? searchBar : null,
        actions: [
          InkWell(
            onTap: () {
              router.pushPage(const ClassBoardItemCostPage());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(minWidth: 56),
              child: Center(child: Text(S.current.statistics_title)),
            ),
            // icon: const Icon(Icons.analytics),
            // tooltip: S.current.statistics_title,
          )
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(ClassBoard board) {
    return ListTile(
      leading: db.getIconImage(board.btnIcon, width: 40, aspectRatio: 1),
      title: AutoSizeText(board.dispName, maxLines: 1),
      subtitle: Text('No.${board.id}'),
      trailing: IconButton(
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () => _onTapCard(board, true),
      ),
      selected: SplitRoute.isSplit(context) && selected == board,
      onTap: () => _onTapCard(board),
    );
  }

  @override
  Widget gridItemBuilder(ClassBoard board) => throw UnimplementedError("GridView is not allowed");

  @override
  bool filter(ClassBoard board) => true;

  void _onTapCard(ClassBoard board, [bool forcePush = false]) {
    if (widget.onSelected != null && !forcePush) {
      Navigator.pop(context);
      widget.onSelected!(board);
    } else {
      router.popDetailAndPush(
        context: context,
        url: board.route,
        child: ClassBoardDetailPage(board: board),
        detail: true,
      );
      selected = board;
    }
    setState(() {});
  }
}
