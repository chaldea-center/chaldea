import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_list_page.dart';
import 'package:chaldea/modules/craft/craft_list_page.dart';
import 'package:chaldea/modules/event/events_page.dart';
import 'package:chaldea/modules/extras/cv_illustrator_list.dart';
import 'package:chaldea/modules/extras/exp_card_cost_page.dart';
import 'package:chaldea/modules/extras/issues_page.dart';
import 'package:chaldea/modules/extras/mystic_code_page.dart';
import 'package:chaldea/modules/ffo/ffo_page.dart';
import 'package:chaldea/modules/free_quest_calculator/free_calculator_page.dart';
import 'package:chaldea/modules/home/subpage/edit_gallery_page.dart';
import 'package:chaldea/modules/import_data/home_import_page.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/master_mission/master_mission_page.dart';
import 'package:chaldea/modules/servant/costume_list_page.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:chaldea/modules/statistics/game_statistics_page.dart';
import 'package:chaldea/modules/summon/summon_list_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'gallery_item.dart';

class GridGallery extends StatefulWidget {
  final double? maxWidth;

  const GridGallery({Key? key, this.maxWidth}) : super(key: key);

  @override
  _GridGalleryState createState() => _GridGalleryState();
}

class _GridGalleryState extends State<GridGallery> {
  @override
  Widget build(BuildContext context) {
    int crossCount;
    if (widget.maxWidth != null &&
        widget.maxWidth! > 0 &&
        widget.maxWidth != double.infinity) {
      crossCount = widget.maxWidth! ~/ 75;
      crossCount = fixValidRange(crossCount, 2, 8);
    } else {
      crossCount = 4;
    }

    Widget grid = GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: crossCount,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: 1,
      children: _getShownGalleries(context),
    );
    if (db.gameData.version.length < 2) {
      grid = GestureDetector(
        onTap: () {
          SimpleCancelOkDialog(
            title: Text('Gamedata Error'),
            content: Text(S.current.reload_default_gamedata),
            onTapOk: () async {
              await db.loadZipAssets(kDatasetAssetKey);
              db.loadGameData();
            },
          ).showDialog(context);
        },
        child: AbsorbPointer(
          child: Opacity(
            opacity: 0.5,
            child: grid,
          ),
        ),
      );
    }
    return grid;
  }

  List<Widget> _getShownGalleries(BuildContext context) {
    List<Widget> _galleryItems = [];
    kAllGalleryItems.forEach((name, item) {
      if (db.userData.galleries[name] == false &&
          !GalleryItem.persistentPages.contains(name)) {
        return;
      }
      _galleryItems.add(InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: item.child == null
                    ? Icon(item.icon, size: 40, color: _iconColor)
                    : item.child,
              ),
            ),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.topCenter,
                child: AutoSizeText(
                  item.title,
                  style: TextStyle(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                  maxFontSize: 14,
                ),
              ),
            )
          ],
        ),
        onTap: () {
          if (item.builder != null) {
            SplitRoute.push(
              context: context,
              builder: item.builder!,
              detail: item.isDetail,
              popDetail: true,
            ).then((value) => db.saveUserData());
          }
        },
      ));
    });
    return _galleryItems;
  }

  Color? get _iconColor {
    return Utils.isDarkMode(context)
        ? Theme.of(context).colorScheme.secondaryVariant
        : Theme.of(context).colorScheme.secondary;
  }

  Widget faIcon(IconData icon) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: FaIcon(
        icon,
        size: 36,
        color: _iconColor,
      ),
    );
  }

  Map<String, GalleryItem> get kAllGalleryItems {
    return {
      GalleryItem.servant: GalleryItem(
        name: GalleryItem.servant,
        title: S.current.servant_title,
        // icon: Icons.people,
        child: faIcon(FontAwesomeIcons.users),
        builder: (context, _) => ServantListPage(),
      ),
      GalleryItem.craft_essence: GalleryItem(
        name: GalleryItem.craft_essence,
        title: S.current.craft_essence,
        // icon: Icons.extension,
        child: faIcon(FontAwesomeIcons.streetView),
        builder: (context, _) => CraftListPage(),
      ),
      GalleryItem.cmd_code: GalleryItem(
        name: GalleryItem.cmd_code,
        title: S.current.command_code,
        // icon: Icons.stars,
        child: faIcon(FontAwesomeIcons.expand),
        builder: (context, _) => CmdCodeListPage(),
      ),
      GalleryItem.item: GalleryItem(
        name: GalleryItem.item,
        title: S.current.item_title,
        icon: Icons.category,
        // child: faIcon(FontAwesomeIcons.cubes),
        builder: (context, _) => ItemListPage(),
      ),
      GalleryItem.event: GalleryItem(
        name: GalleryItem.event,
        title: S.current.event_title,
        icon: Icons.flag,
        builder: (context, _) => EventListPage(),
      ),
      GalleryItem.plan: GalleryItem(
        name: GalleryItem.plan,
        title: S.current.plan_title,
        icon: Icons.article_outlined,
        builder: (context, _) => ServantListPage(planMode: true),
        isDetail: false,
      ),
      GalleryItem.free_calculator: GalleryItem(
        name: GalleryItem.free_calculator,
        title: S.current.free_quest_calculator_short,
        // icon: Icons.pin_drop,
        child: faIcon(FontAwesomeIcons.mapMarked),
        builder: (context, _) => FreeQuestCalculatorPage(),
        isDetail: true,
      ),
      GalleryItem.master_mission: GalleryItem(
        name: GalleryItem.master_mission,
        title: S.current.master_mission,
        child: faIcon(FontAwesomeIcons.tasks),
        builder: (context, _) => MasterMissionPage(),
        isDetail: true,
      ),
      GalleryItem.mystic_code: GalleryItem(
        name: GalleryItem.mystic_code,
        title: S.current.mystic_code,
        child: faIcon(FontAwesomeIcons.diagnoses),
        builder: (context, _) => MysticCodePage(),
        isDetail: true,
      ),
      GalleryItem.costume: GalleryItem(
        name: GalleryItem.costume,
        title: S.current.costume,
        child: faIcon(FontAwesomeIcons.tshirt),
        builder: (context, _) => CostumeListPage(),
        isDetail: false,
      ),
      // GalleryItem.calculator: GalleryItem(
      //   name: GalleryItem.calculator,
      //   title: S.current.calculator,
      //   icon: Icons.keyboard,
      //   builder: (context, _) => DamageCalcPage(),
      //   isDetail: true,
      // ),
      GalleryItem.gacha: GalleryItem(
        name: GalleryItem.gacha,
        title: S.current.summon_title,
        child: faIcon(FontAwesomeIcons.dice),
        builder: (context, _) => SummonListPage(),
        isDetail: false,
      ),
      GalleryItem.ffo: GalleryItem(
        name: GalleryItem.ffo,
        title: 'Freedom Order',
        child: faIcon(FontAwesomeIcons.layerGroup),
        builder: (context, _) => FreedomOrderPage(),
        isDetail: true,
      ),
      GalleryItem.cv_list: GalleryItem(
        name: GalleryItem.cv_list,
        title: S.current.info_cv,
        icon: Icons.keyboard_voice,
        builder: (context, _) => CvListPage(),
        isDetail: true,
      ),
      GalleryItem.illustrator_list: GalleryItem(
        name: GalleryItem.illustrator_list,
        title: S.current.illustrator,
        child: faIcon(FontAwesomeIcons.paintBrush),
        builder: (context, _) => IllustratorListPage(),
        isDetail: true,
      ),
      // if (kDebugMode_)
      //   GalleryItem.ap_cal: GalleryItem(
      //     name: GalleryItem.ap_cal,
      //     title: S.current.ap_calc_title,
      //     icon: Icons.directions_run,
      //     builder: (context, _) => APCalcPage(),
      //     isDetail: true,
      //   ),
      GalleryItem.exp_card: GalleryItem(
        name: GalleryItem.exp_card,
        title: S.current.exp_card_title,
        // icon: Icons.rice_bowl,
        child: faIcon(FontAwesomeIcons.breadSlice),
        builder: (context, _) => ExpCardCostPage(),
        isDetail: true,
      ),
      GalleryItem.statistics: GalleryItem(
        name: GalleryItem.statistics,
        title: S.current.statistics_title,
        icon: Icons.analytics,
        builder: (context, _) => GameStatisticsPage(),
        isDetail: true,
      ),
      GalleryItem.import_data: GalleryItem(
        name: GalleryItem.import_data,
        title: S.current.import_data,
        icon: Icons.cloud_download,
        builder: (context, _) => ImportPageHome(),
        isDetail: false,
      ),
      GalleryItem.issues: GalleryItem(
        name: GalleryItem.issues,
        title: 'FAQ',
        icon: Icons.report_problem,
        builder: (context, _) => IssuesPage(),
        isDetail: true,
      ),
      GalleryItem.more: GalleryItem(
        name: GalleryItem.more,
        title: S.current.more,
        icon: Icons.add,
        builder: (context, _) => EditGalleryPage(galleries: kAllGalleryItems),
        isDetail: true,
      ),
    };
  }
}
