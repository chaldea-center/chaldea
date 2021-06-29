import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_detail_page.dart';
import 'package:chaldea/modules/craft/craft_detail_page.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

const String _unknownCreator = '---';

class CvListPage extends StatefulWidget {
  @override
  _CvListPageState createState() => _CvListPageState();
}

class _CvListPageState extends State<CvListPage> {
  late ScrollController _scrollController;
  Map<String, List<Servant>> cvMap = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (var svt in db.gameData.servants.values) {
      List<String> cvs = svt.info.lCV;
      if (cvs.isEmpty) cvs = svt.info.cv;
      if (cvs.isEmpty) {
        cvMap.putIfAbsent(_unknownCreator, () => []).add(svt);
      }
      for (var cv in cvs) {
        cvMap.putIfAbsent(cv, () => []).add(svt);
      }
    }
    cvMap = sortDict<String, List<Servant>>(
      cvMap,
      compare: (a, b) =>
          Utils.toAlphabet(a.key).compareTo(Utils.toAlphabet(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = cvMap.keys.toList();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.current.info_cv),
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) => cvDetail(names[index]),
          separatorBuilder: (context, _) => kDefaultDivider,
          itemCount: names.length,
        ),
      ),
    );
  }

  Widget cvDetail(String cv) {
    final svts = cvMap[cv]!;
    // if (svts.length == 1) {
    //   return ListTile(
    //     title: Text(cv),
    //     trailing: _cardIcon(context, svts.first),
    //   );
    // }
    List<Widget> children = [];
    for (var svt in svts) {
      children.add(_cardIcon(context, svt));
    }
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          title: Text(cv),
          trailing: Text(svts.length.toString()),
        );
      },
      contentBuilder: (context) => _gridView(context, svts),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}

class IllustratorListPage extends StatefulWidget {
  @override
  _IllustratorListPageState createState() => _IllustratorListPageState();
}

class _IllustratorListPageState extends State<IllustratorListPage> {
  late ScrollController _scrollController;
  Map<String, List<Servant>> svtMap = {};
  Map<String, List<CraftEssence>> craftMap = {};
  Map<String, List<CommandCode>> codeMap = {};
  List<String> illustrators = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    db.gameData.servants.values.forEach((svt) {
      svtMap.putIfAbsent(svt.info.lIllustrator, () => []).add(svt);
    });
    db.gameData.crafts.values.forEach((craft) {
      String illus = craft.lIllustrators;
      if (illus.isEmpty) illus = craft.illustrators.join(', ');
      if (illus.isEmpty) illus = _unknownCreator;
      craftMap.putIfAbsent(illus, () => []).add(craft);
    });
    db.gameData.cmdCodes.values.forEach((code) {
      String illus = code.lIllustrators;
      if (illus.isEmpty) illus = code.illustrators.join(', ');
      if (illus.isEmpty) illus = _unknownCreator;
      codeMap.putIfAbsent(illus, () => []).add(code);
    });

    illustrators
      ..addAll(svtMap.keys)
      ..addAll(craftMap.keys)
      ..addAll(codeMap.keys);
    illustrators = illustrators.toSet().toList();
    illustrators
        .sort((a, b) => Utils.toAlphabet(a).compareTo(Utils.toAlphabet(b)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.current.illustrator),
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) {
            return _detail(illustrators[index]);
          },
          separatorBuilder: (context, _) => kDefaultDivider,
          itemCount: illustrators.length,
        ),
      ),
    );
  }

  Widget _detail(String name) {
    int count = (svtMap[name]?.length ?? 0) +
        (craftMap[name]?.length ?? 0) +
        (codeMap[name]?.length ?? 0);
    return SimpleAccordion(
      disableAnimation: true,
      headerBuilder: (context, _) => ListTile(
        title: Text(name),
        trailing: Text(count.toString()),
      ),
      contentBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svtMap.containsKey(name)) _gridView(context, svtMap[name]!),
            if (craftMap.containsKey(name)) _gridView(context, craftMap[name]!),
            if (codeMap.containsKey(name)) _gridView(context, codeMap[name]!),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}

Widget _cardIcon<T>(BuildContext context, T card) {
  String icon;
  Widget Function(BuildContext, SplitLayout) builder;
  if (card is Servant) {
    icon = card.icon;
    builder = (context, _) => ServantDetailPage(card);
  } else if (card is CraftEssence) {
    icon = card.icon;
    builder = (context, _) => CraftDetailPage(ce: card);
  } else if (card is CommandCode) {
    icon = card.icon;
    builder = (context, _) => CmdCodeDetailPage(code: card);
  } else {
    throw ArgumentError.value(card.runtimeType, 'card', 'Unknown type');
  }
  return InkWell(
    onTap: () {
      SplitRoute.push(
        context: context,
        builder: builder,
        detail: true,
      );
    },
    child: Padding(
      padding: EdgeInsets.all(2),
      child: db.getIconImage(icon, width: 132 / 2.5, height: 144 / 2.5),
    ),
  );
}

Widget _gridView<T>(BuildContext context, List<T> cards) {
  return LayoutBuilder(builder: (context, constraints) {
    int count = constraints.maxWidth ~/ 54;
    return GridView.count(
      childAspectRatio: 132 / 144,
      crossAxisCount: count,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: cards.map((e) => _cardIcon(context, e)).toList(),
    );
  });
}
