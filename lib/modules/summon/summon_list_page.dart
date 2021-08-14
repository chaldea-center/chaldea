import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';

class SummonListPage extends StatefulWidget {
  @override
  _SummonListPageState createState() => _SummonListPageState();
}

class _SummonListPageState extends SearchableListState<Summon, SummonListPage> {
  bool showOutdated = false;
  bool favorite = false;
  bool reversed = false;

  @override
  Iterable<Summon> get wholeData => db.gameData.summons.values;
  @override
  List<Summon> shownList = [];

  Set<String> get plans => db.curUser.plannedSummons;

  @override
  Widget build(BuildContext context) {
    filterShownList();
    if (reversed) {
      shownList = shownList.reversed.toList();
    }
    shownList.sort((a, b) {
      if (a.isStory && !b.isStory) return -1;
      if (b.isStory && !a.isStory) return 1;
      return 0;
    });
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: Text(S.of(context).summon_title),
        leading: MasterBackButton(),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            icon: Icon(
                reversed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
            tooltip: 'Reversed',
            onPressed: () {
              setState(() {
                reversed = !reversed;
              });
            },
          ),
          searchIcon,
          IconButton(
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_outline),
            tooltip: S.current.favorite,
            onPressed: () {
              setState(() {
                favorite = !favorite;
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(db.appSetting.showSummonBanner
                    ? LocalizedText.of(
                        chs: '显示标题', jpn: 'タイトルを表示', eng: 'Show Title')
                    : LocalizedText.of(
                        chs: '显示封面', jpn: '画像を表示', eng: 'Show Banner')),
                onTap: () {
                  setState(() {
                    db.appSetting.showSummonBanner =
                        !db.appSetting.showSummonBanner;
                  });
                },
              ),
              PopupMenuItem(
                child: Text(showOutdated
                    ? S.current.hide_outdated
                    : S.current.show_outdated),
                onTap: () {
                  setState(() {
                    showOutdated = !showOutdated;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(Summon summon) {
    Widget title;
    Widget? subtitle;
    if (db.appSetting.showSummonBanner) {
      title = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 108),
        child: CachedImage(
          imageUrl: db.curUser.server == GameServer.cn
              ? summon.bannerUrl ?? summon.bannerUrlJp
              : summon.bannerUrlJp ?? summon.bannerUrl,
          placeholder: (ctx, url) => Text(summon.lName),
          cachedOption: CachedImageOption(
              errorWidget: (ctx, url, error) => Text(summon.lName)),
        ),
      );
    } else {
      title = AutoSizeText(
        summon.lName,
        maxLines: 2,
        maxFontSize: 14,
        style: TextStyle(color: summon.isOutdated() ? Colors.grey : null),
      );
      String? subtitleText;
      if (db.curUser.server == GameServer.cn) {
        subtitleText = summon.startTimeCn?.split(' ').first;
        if (subtitleText != null) {
          subtitleText = 'CN ' + subtitleText;
        }
      }
      if (subtitleText == null) {
        subtitleText = 'JP ' + (summon.startTimeJp?.split(' ').first ?? '???');
      }
      if (!summon.isStory) subtitle = Text(subtitleText);
    }
    return ListTile(
      title: title,
      subtitle: subtitle,
      contentPadding: db.appSetting.showSummonBanner
          ? EdgeInsets.only(right: 8)
          : EdgeInsets.only(left: 16, right: 8),
      minVerticalPadding: db.appSetting.showSummonBanner ? 0 : null,
      trailing: db.streamBuilder(
        (context) {
          final planned = db.curUser.plannedSummons.contains(summon.indexKey);
          return IconButton(
            icon: Icon(
              planned ? Icons.favorite : Icons.favorite_outline,
              color: planned ? Colors.redAccent : null,
            ),
            onPressed: () {
              if (planned) {
                db.curUser.plannedSummons.remove(summon.indexKey);
              } else {
                db.curUser.plannedSummons.add(summon.indexKey);
              }
              db.notifyDbUpdate();
            },
          );
        },
      ),
      onTap: () {
        SplitRoute.push(
          context,
          SummonDetailPage(summon: summon, summonList: shownList),
          popDetail: true,
        );
      },
    );
  }

  @override
  Widget gridItemBuilder(Summon datum) {
    throw UnimplementedError('GridView not designed');
  }

  @override
  String getSummary(Summon summon) {
    return Utils.getSearchAlphabets(summon.name, summon.nameJp, summon.nameEn)
        .join('\t');
  }

  @override
  bool filter(Summon summon) {
    if (plans.contains(summon.indexKey)) return true;
    if (!favorite) {
      return showOutdated || summon.isStory || !summon.isOutdated();
    } else {
      // won't reach here
      return false;
    }
  }
}
