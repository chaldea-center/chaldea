import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import 'cmd_code_detail_page.dart';
import 'cmd_code_filter_page.dart';

class CmdCodeListPage extends StatefulWidget {
  final void Function(CommandCode)? onSelected;

  CmdCodeListPage({Key? key, this.onSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CmdCodeListPageState();
}

class CmdCodeListPageState
    extends SearchableListState<CommandCode, CmdCodeListPage> {
  @override
  Iterable<CommandCode> get wholeData => db.gameData.cmdCodes.values;

  CmdCodeFilterData get filterData => db.userData.cmdCodeFilter;

  @override
  void initState() {
    super.initState();
    if (db.appSetting.autoResetFilter) {
      filterData.reset();
    }
    options = _CmdCodeSearchOptions(onChanged: (_) => safeSetState());
  }

  void _onTapCard(CommandCode code, [bool forcePush = false]) {
    if (widget.onSelected != null && !forcePush) {
      widget.onSelected!(code);
    } else {
      SplitRoute.push(
        context,
        CmdCodeDetailPage(
          code: code,
          onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
        ),
        popDetail: true,
      );
      selected = code;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => CommandCode.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.command_code),
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
          searchIcon,
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(CommandCode code) {
    return CustomTile(
      leading: db.getIconImage(code.icon, width: 56),
      title: AutoSizeText(code.lName, maxLines: 1, overflow: TextOverflow.fade),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!Language.isJP) AutoSizeText(code.nameJp, maxLines: 1),
          Text('No.${code.no}')
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.keyboard_arrow_right),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () {
          _onTapCard(code, true);
        },
      ),
      selected: SplitRoute.isSplit(context) && selected == code,
      onTap: () => _onTapCard(code),
    );
  }

  @override
  Widget gridItemBuilder(CommandCode code) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        child: db.getIconImage(code.icon),
        onTap: () => _onTapCard(code),
      ),
    );
  }

  @override
  String getSummary(CommandCode code) {
    return options!.getSummary(code);
  }

  @override
  bool filter(CommandCode code) {
    if (!filterData.rarity.singleValueFilter(code.rarity.toString())) {
      return false;
    }
    if (!filterData.category.singleValueFilter(code.category,
        defaultCompare: (o, v) => v?.contains(o))) {
      return false;
    }
    if (code.niceSkills
        .every((skill) => !skill.testFunctions(filterData.effects))) {
      return false;
    }
    return true;
  }
}

class _CmdCodeSearchOptions with SearchOptionsMixin<CommandCode> {
  bool basic;
  bool skill;
  bool description;
  @override
  ValueChanged? onChanged;

  _CmdCodeSearchOptions({
    this.basic = true,
    this.skill = true,
    this.description = false,
    this.onChanged,
  });

  @override
  Widget builder(BuildContext context, StateSetter setState) {
    return Wrap(
      children: [
        CheckboxWithLabel(
          value: basic,
          label: Text(S.current.search_option_basic),
          onChanged: (v) {
            basic = v ?? basic;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: skill,
          label: Text(S.current.skill),
          onChanged: (v) {
            skill = v ?? skill;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: description,
          label: Text(S.current.card_description),
          onChanged: (v) {
            description = v ?? description;
            setState(() {});
            updateParent();
          },
        ),
      ],
    );
  }

  @override
  String getSummary(CommandCode code) {
    StringBuffer buffer = StringBuffer();
    if (basic) {
      buffer.write(getCache(
        code,
        'basic',
        () => [
          code.no.toString(),
          code.gameId.toString(),
          code.mcLink,
          ...Utils.getSearchAlphabets(code.name, code.nameJp, code.nameEn),
          ...Utils.getSearchAlphabetsForList(code.illustrators,
              [code.illustratorsJp ?? ''], [code.illustratorsEn ?? '']),
          ...Utils.getSearchAlphabetsForList(code.characters),
        ],
      ));
    }
    if (skill) {
      buffer.write(getCache(
        code,
        'skill',
        () => [
          code.skill,
          code.skillEn,
        ],
      ));
    }
    if (description) {
      buffer.write(getCache(
        code,
        'description',
        () => Utils.getSearchAlphabets(
          code.description,
          code.descriptionJp,
          code.descriptionEn,
        ),
      ));
    }
    return buffer.toString();
  }
}
