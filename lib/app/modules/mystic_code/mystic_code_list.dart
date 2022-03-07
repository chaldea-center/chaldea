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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'mystic_code.dart';

class MysticCodeListPage extends StatefulWidget {
  final void Function(MysticCode)? onSelected;

  MysticCodeListPage({Key? key, this.onSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MysticCodeListPageState();
}

class MysticCodeListPageState extends State<MysticCodeListPage>
    with SearchableListState<MysticCode, MysticCodeListPage> {
  @override
  Iterable<MysticCode> get wholeData => db2.gameData.mysticCodes.values;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => a.id.compareTo(b.id));
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(S.current.mystic_code, maxLines: 1),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            onPressed: () =>
                setState(() => db2.curUser.isGirl = !db2.curUser.isGirl),
            icon: FaIcon(
              db2.curUser.isGirl
                  ? FontAwesomeIcons.venus
                  : FontAwesomeIcons.mars,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(MysticCode mc) {
    return CustomTile(
      leading: db2.getIconImage(
        mc.icon,
        width: 56,
        aspectRatio: 132 / 144,
      ),
      title: AutoSizeText(mc.lName.l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!Language.isJP) AutoSizeText(mc.name, maxLines: 1),
          Text('No.${mc.id}'),
        ],
      ),
      trailing: IconButton(
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () => _onTapCard(mc, true),
      ),
      selected: SplitRoute.isSplit(context) && selected == mc,
      onTap: () => _onTapCard(mc),
    );
  }

  @override
  Widget gridItemBuilder(MysticCode mc) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: GestureDetector(
        child: db2.getIconImage(mc.borderedIcon),
        onTap: () => _onTapCard(mc),
      ),
    );
  }

  @override
  String getSummary(MysticCode mc) {
    return options?.getSummary(mc) ?? '';
  }

  @override
  bool filter(MysticCode mc) => true;

  void _onTapCard(MysticCode mc, [bool forcePush = false]) {
    if (widget.onSelected != null && !forcePush) {
      widget.onSelected!(mc);
    } else {
      router.push(
        url: mc.route,
        child: MysticCodePage(id: mc.id),
        detail: true,
        popDetail: true,
      );
      selected = mc;
    }
    setState(() {});
  }
}
