import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/searchable_list_state.dart';
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
        title: AutoSizeText(S.current.class_score, maxLines: 1),
        bottom: showSearchBar ? searchBar : null,
      ),
    );
  }

  @override
  Widget listItemBuilder(ClassBoard board) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          db.getIconImage(
            "https://static.atlasacademy.io/file/aa-fgo-extract-jp/ClassBoard/UI/DownloadClassBoardUIAtlas/DownloadClassBoardUIAtlas1/btn_class.png",
            width: 40,
            aspectRatio: 1,
          ),
          db.getIconImage(
            board.uiIcon,
            width: 40 * 120 / 128,
            aspectRatio: 1,
          ),
        ],
      ),
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
