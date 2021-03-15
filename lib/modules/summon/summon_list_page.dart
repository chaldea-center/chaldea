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
  bool showImage = false;
  bool showOutdated = false;
  bool favorite = false;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).summon_title),
        leading: MasterBackButton(),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(showOutdated ? Icons.timer_off : Icons.timer),
            onPressed: () {
              setState(() {
                showOutdated = !showOutdated;
              });
            },
          ),
          IconButton(
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_outline),
            onPressed: () {
              setState(() {
                favorite = !favorite;
              });
            },
          ),
          // IconButton(
          //   icon: Icon(showImage
          //       ? Icons.image_outlined
          //       : Icons.image_not_supported_outlined),
          //   onPressed: () {
          //     setState(() {
          //       showImage = !showImage;
          //     });
          //   },
          // ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: AutoSizeText(
            summon.localizedName,
            maxLines: 2,
            maxFontSize: 16,
            style: TextStyle(color: summon.isOutdated() ? Colors.grey : null),
          ),
          trailing: db.streamBuilder(
            (context) {
              final planned =
                  db.curUser.plannedSummons.contains(summon.indexKey);
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
        ),
        if (showImage)
          CachedImage(
            imageUrl: summon.bannerUrl ?? summon.bannerUrlJp,
            isMCFile: true,
            connectivity: db.connectivity,
            placeholder: (context, _) => Container(),
          ),
      ],
    );
  }
}
