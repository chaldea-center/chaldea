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
import 'craft.dart';
import 'filter.dart';

class CraftListPage extends StatefulWidget {
  CraftListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CraftListPageState();
}

class CraftListPageState extends State<CraftListPage>
    with SearchableListState<CraftEssence, CraftListPage> {
  @override
  Iterable<CraftEssence> get wholeData => db2.gameData.craftEssences.values;

  CraftFilterData get filterData => db2.settings.craftFilterData;

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
      compare: (a, b) => CraftFilterData.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(S.current.craft_essence,
            maxLines: 1, overflow: TextOverflow.fade),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt),
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
          // searchIcon,
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
      leading: db2.getIconImage(
        ce.borderedIcon,
        width: 56,
        aspectRatio: 132 / 144,
      ),
      title: AutoSizeText(ce.lName.l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!Language.isJP) AutoSizeText(ce.name, maxLines: 1),
          Text('No.${ce.collectionNo}$additionalText'),
        ],
      ),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      selected: SplitRoute.isSplit(context) && selected == ce,
      onTap: () {
        setState(() {
          selected = ce;
        });
        router.push(
          url: ce.route,
          child: CraftDetailPage(
            ce: ce,
            onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
          ),
          detail: true,
          popDetail: true,
        );
        // SplitRoute.push(
        //   context,
        //   CraftDetailPage(
        //     ce: ce,
        //     onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
        //   ),
        // );
      },
    );
  }

  @override
  Widget gridItemBuilder(CraftEssence ce) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: GestureDetector(
        child: db2.getIconImage(ce.extraAssets.faces.equip?[0]),
        onTap: () {
          setState(() {
            selected = ce;
          });
          SplitRoute.push(
            context,
            CraftDetailPage(
              ce: ce,
              onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
            ),
            popDetail: true,
          );
        },
      ),
    );
  }

  @override
  String getSummary(CraftEssence ce) {
    return options?.getSummary(ce) ?? '';
  }

  @override
  bool filter(CraftEssence ce) {
    if (!filterData.rarity.matchOne(ce.rarity)) {
      return false;
    }
    if (!filterData.obtain.matchOne(ce.extra.obtain)) {
      return false;
    }
    if (!filterData.atkType.matchOne(ce.atkType)) {
      return false;
    }
    if (!filterData.status.matchOne(
        db2.curUser.craftEssences[ce.collectionNo] ?? CraftStatus.notMet)) {
      return false;
    }
    //
    // if (ce.niceSkills
    //     .every((skill) => !skill.testFunctions(filterData.effects))) {
    //   return false;
    // }
    return true;
  }
}

// class _CraftSearchOptions with SearchOptionsMixin<CraftEssence> {
//   bool basic;
//
//   bool skill;
//   bool description;
//   @override
//   ValueChanged? onChanged;
//
//   _CraftSearchOptions({
//     this.basic = true,
//     this.skill = true,
//     this.description = false,
//     this.onChanged,
//   });
//
//   @override
//   Widget builder(BuildContext context, StateSetter setState) {
//     return Wrap(
//       children: [
//         CheckboxWithLabel(
//           value: basic,
//           label: Text(S.current.search_option_basic),
//           onChanged: (v) {
//             basic = v ?? basic;
//             setState(() {});
//             updateParent();
//           },
//         ),
//         CheckboxWithLabel(
//           value: skill,
//           label: Text(S.current.skill),
//           onChanged: (v) {
//             skill = v ?? skill;
//             setState(() {});
//             updateParent();
//           },
//         ),
//         CheckboxWithLabel(
//           value: description,
//           label: Text(S.current.card_description),
//           onChanged: (v) {
//             description = v ?? description;
//             setState(() {});
//             updateParent();
//           },
//         ),
//       ],
//     );
//   }
//
//   @override
//   String getSummary(CraftEssence ce) {
//     StringBuffer buffer = StringBuffer();
//     if (basic) {
//       buffer.write(getCache(
//         ce,
//         'basic',
//         () => [
//           ce.no.toString(),
//           ce.gameId.toString(),
//           ce.mcLink,
//           ...Utils.getSearchAlphabets(ce.name, ce.nameJp, ce.nameEn),
//           ...Utils.getSearchAlphabetsForList(ce.illustrators,
//               [ce.illustratorsJp ?? ''], [ce.illustratorsEn ?? '']),
//           ...Utils.getSearchAlphabetsForList(ce.characters),
//         ],
//       ));
//     }
//     if (skill) {
//       buffer.write(getCache(
//         ce,
//         'skill',
//         () => [
//           ...Utils.getSearchAlphabets(ce.skill, null, ce.skillEn),
//           ...Utils.getSearchAlphabets(ce.skillMax, null, ce.skillMaxEn),
//           ...Utils.getSearchAlphabetsForList(ce.eventSkills),
//         ],
//       ));
//     }
//     if (description) {
//       buffer.write(getCache(
//         ce,
//         'description',
//         () => Utils.getSearchAlphabets(
//             ce.description, ce.descriptionJp, ce.descriptionEn),
//       ));
//     }
//     return buffer.toString();
//   }
// }
