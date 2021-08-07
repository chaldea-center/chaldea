import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import 'craft_detail_page.dart';
import 'craft_filter_page.dart';

class CraftListPage extends StatefulWidget {
  CraftListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CraftListPageState();
}

class CraftListPageState
    extends SearchableListState<CraftEssence, CraftListPage> {
  @override
  Iterable<CraftEssence> get wholeData => db.gameData.crafts.values;

  //temp, calculate once build() called.
  int __binAtkHpType = 0;

  CraftFilterData get filterData => db.userData.craftFilter;

  void initState() {
    super.initState();
    if (db.appSetting.autoResetFilter) {
      filterData.reset();
    }
    options = _CraftSearchOptions(onChanged: (_) => safeSetState());
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => CraftEssence.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: MasterBackButton(),
        title: AutoSizeText(S.current.craft_essence,
            maxLines: 1, overflow: TextOverflow.fade),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CraftFilterPage(
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
  Widget listItemBuilder(CraftEssence ce) {
    String additionalText = '';
    switch (filterData.sortKeys.first) {
      case CraftCompare.atk:
        additionalText = '  ATK ${ce.atkMax}';
        break;
      case CraftCompare.hp:
        additionalText = '  HP ${ce.hpMax}';
        break;
      default:
        break;
    }
    return CustomTile(
      leading: db.getIconImage(ce.icon, width: 56),
      title: AutoSizeText(ce.lName, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!Language.isJP) AutoSizeText(ce.nameJp, maxLines: 1),
          Text('No.${ce.no.toString().padRight(4)}  $additionalText'),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      selected: SplitRoute.isSplit(context) && selected == ce,
      onTap: () {
        SplitRoute.push(
          context,
          CraftDetailPage(
            ce: ce,
            onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
          ),
          popDetail: true,
        );
        setState(() {
          selected = ce;
        });
      },
    );
  }

  @override
  Widget gridItemBuilder(CraftEssence ce) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: GestureDetector(
        child: db.getIconImage(ce.icon),
        onTap: () {
          SplitRoute.push(
            context,
            CraftDetailPage(
              ce: ce,
              onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
            ),
            popDetail: true,
          );
          setState(() {
            selected = ce;
          });
        },
      ),
    );
  }

  @override
  void filterShownList({Comparator<CraftEssence>? compare}) {
    __binAtkHpType = 0;
    for (int i = 0; i < CraftFilterData.atkHpTypeData.length; i++) {
      if (filterData.atkHpType.options[CraftFilterData.atkHpTypeData[i]] ==
          true) {
        __binAtkHpType += 1 << i;
      }
    }
    super.filterShownList(compare: compare);
  }

  @override
  String getSummary(CraftEssence ce) {
    return options!.getSummary(ce);
  }

  @override
  bool filter(CraftEssence ce) {
    if (!filterData.rarity.singleValueFilter(ce.rarity.toString())) {
      return false;
    }

    if (!filterData.category.singleValueFilter(ce.category,
        defaultCompare: (o, v) => v?.contains(o) ?? false)) {
      return false;
    }
    if (__binAtkHpType > 0 &&
        ((1 << ((ce.hpMax > 0 ? 1 : 0) + (ce.atkMax > 0 ? 2 : 0))) &
                __binAtkHpType) ==
            0) {
      return false;
    }
    if (!filterData.status
        .singleValueFilter((db.curUser.crafts[ce.no] ?? 0).toString())) {
      return false;
    }
    return true;
  }
}

class _CraftSearchOptions with SearchOptionsMixin<CraftEssence> {
  bool basic;

  bool skill;
  bool description;
  ValueChanged? onChanged;

  _CraftSearchOptions({
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
  String getSummary(CraftEssence ce) {
    StringBuffer buffer = StringBuffer();
    if (basic) {
      buffer.write(getCache(
        ce,
        'basic',
        () => [
          ce.no.toString(),
          ce.mcLink,
          ...Utils.getSearchAlphabets(ce.name, ce.nameJp, ce.nameEn),
          ...Utils.getSearchAlphabetsForList(ce.illustrators,
              [ce.illustratorsJp ?? ''], [ce.illustratorsEn ?? '']),
          ...Utils.getSearchAlphabetsForList(ce.characters),
        ],
      ));
    }
    if (skill) {
      buffer.write(getCache(
        ce,
        'skill',
        () => [
          ...Utils.getSearchAlphabets(ce.skill, null, ce.skillEn),
          ...Utils.getSearchAlphabets(ce.skillMax, null, ce.skillMaxEn),
          ...Utils.getSearchAlphabetsForList(ce.eventSkills),
        ],
      ));
    }
    if (description) {
      buffer.write(getCache(
        ce,
        'description',
        () => Utils.getSearchAlphabets(
            ce.description, ce.descriptionJp, ce.descriptionEn),
      ));
    }
    return buffer.toString();
  }
}
