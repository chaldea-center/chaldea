import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';

class SummonListPage extends StatefulWidget {
  @override
  _SummonListPageState createState() => _SummonListPageState();
}

class _SummonListPageState extends State<SummonListPage> {
  late ScrollController _scrollController;
  late List<Summon> summons;
  bool showOutdated = false;
  bool favorite = false;
  bool reversed = false;
  List<Summon> _shownSummons = [];

  Set<String> get plans => db.curUser.plannedSummons;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    summons = db.gameData.summons.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    _shownSummons = summons.where((e) {
      if (plans.contains(e.indexKey)) return true;
      if (!favorite) {
        return showOutdated || !e.isOutdated();
      } else {
        return false;
      }
    }).toList();
    if (reversed) {
      _shownSummons = _shownSummons.reversed.toList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).summon_title),
        leading: MasterBackButton(),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(db.userData.showSummonBanner
                ? Icons.image_outlined
                : Icons.image_not_supported_outlined),
            tooltip: 'Banner',
            onPressed: () {
              setState(() {
                db.userData.showSummonBanner = !db.userData.showSummonBanner;
              });
            },
          ),
          IconButton(
            icon: Icon(showOutdated ? Icons.timer_off : Icons.timer),
            tooltip: 'Outdated',
            onPressed: () {
              setState(() {
                showOutdated = !showOutdated;
              });
            },
          ),
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
          IconButton(
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_outline),
            tooltip: S.current.favorite,
            onPressed: () {
              setState(() {
                favorite = !favorite;
              });
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          itemBuilder: (context, index) => getSummonTile(_shownSummons[index]),
          separatorBuilder: (context, index) => kDefaultDivider,
          itemCount: _shownSummons.length,
        ),
      ),
    );
  }

  Widget getSummonTile(Summon summon) {
    Widget title;
    Widget? subtitle;
    if (db.userData.showSummonBanner) {
      title = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 108),
        child: CachedImage(
          imageUrl: db.curUser.server == GameServer.cn
              ? summon.bannerUrl ?? summon.bannerUrlJp
              : summon.bannerUrlJp ?? summon.bannerUrl,
          placeholder: (ctx, url) => Text(summon.localizedName),
          errorWidget: (ctx, url, error) => Text(summon.localizedName),
        ),
      );
    } else {
      title = AutoSizeText(
        summon.localizedName,
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
      subtitle = Text(subtitleText);
    }
    return ListTile(
      title: title,
      subtitle: subtitle,
      contentPadding: db.userData.showSummonBanner
          ? EdgeInsets.only(right: 8)
          : EdgeInsets.only(left: 16, right: 8),
      minVerticalPadding: db.userData.showSummonBanner ? 0 : null,
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
          context: context,
          popDetail: true,
          builder: (context, _) => SummonDetailPage(
            summon: summon,
            summonList: _shownSummons,
          ),
        );
      },
    );
  }
}
