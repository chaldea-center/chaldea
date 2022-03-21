import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CvListPage extends StatefulWidget {
  CvListPage({Key? key}) : super(key: key);

  @override
  _CvListPageState createState() => _CvListPageState();
}

class _CvListPageState extends State<CvListPage>
    with SearchableListState<String, CvListPage> {
  @override
  Iterable<String> get wholeData => cvs;

  Map<String, List<Servant>> cvMap = {};
  List<String> cvs = [];

  bool _initiated = false;

  void _parse() async {
    cvMap.clear();
    cvs.clear();
    for (var svt in db2.gameData.servants.values) {
      List<String> _cvs = svt.profile.cv.split(RegExp(r'[&＆\s]+'));
      _cvs.add(svt.profile.cv);
      for (var cv in _cvs.toSet()) {
        cvMap.putIfAbsent(Transl.cvNames(cv.trim()).l, () => []).add(svt);
      }
      await null;
    }
    cvs = cvMap.keys.toList();
    cvs.sort((a, b) =>
        SearchUtil.getSortAlphabet(a).compareTo(SearchUtil.getSortAlphabet(b)));

    if (mounted) {
      setState(() {
        _initiated = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _parse();
    // options = _CVOptions(onChanged: null, state: this);
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: null);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: Text(S.current.info_cv),
        bottom: showSearchBar ? searchBar : null,
        // actions: [searchIcon],
      ),
    );
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    if (shownList.isEmpty && !_initiated) {
      return const Center(child: CircularProgressIndicator());
    }
    return super.buildScrollable(useGrid: useGrid);
  }

  @override
  String getSummary(String cv) {
    return options?.getSummary(cv) ?? '';
  }

  @override
  bool filter(String cv) => true;

  @override
  Widget listItemBuilder(String cv) {
    final svts = cvMap[cv]!;
    List<Widget> children = [];
    for (var svt in svts) {
      children.add(svt.iconBuilder(context: context));
    }
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          title: Text(cv.isEmpty ? '?' : Transl.cvNames(cv.trim()).l),
          trailing: Text(svts.length.toString()),
        );
      },
      contentBuilder: (context) => GridView.extent(
        maxCrossAxisExtent: 60,
        childAspectRatio: 132 / 144,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 8),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: children,
      ),
    );
  }

  @override
  Widget gridItemBuilder(String cv) =>
      throw UnimplementedError('GridView not designed');
}
