import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtSpriteTab extends SvtTabBaseWidget {
  const SvtSpriteTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtSvtSpriteTabTabState createState() => _SvtSvtSpriteTabTabState();
}

class _SvtSvtSpriteTabTabState extends SvtTabBaseState<SvtSpriteTab>
    with SingleTickerProviderStateMixin {
  final Map<int, ScrollController> _horizontalControllers = {};

  ScrollController getScrollController(int index) {
    return _horizontalControllers[index] ??= ScrollController();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _horizontalControllers.forEach((key, value) => value.dispose());
  }

  Widget placeholder(BuildContext context, String? url) {
    return Container();
  }

  String _localize(String s) {
    // icon1, icon2, iconCostume
    // sprite ...
    if (s == 'iconCostume') {
      return LocalizedText.of(
          chs: '灵衣图标', jpn: '霊衣アイコン', eng: 'Costume Icons', kor: '영의 아이콘');
    }
    if (s == 'spriteCostume') {
      return LocalizedText.of(
          chs: '灵衣模型', jpn: '霊衣モデル', eng: 'Costume Sprites', kor: '영의 스프라이트');
    }
    return s.replaceFirstMapped(RegExp(r'(icon|sprite)(\d)'), (match) {
      String suffix = match.group(2).toString();
      if (suffix == '1') suffix = '';
      if (match.group(1) == 'icon') return S.current.icons + ' $suffix';
      if (match.group(1) == 'sprite') return S.current.sprites + ' $suffix';
      return match.group(0).toString();
    }).trim();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.addAll(_rows(svt.icons, 150));
    children.addAll(_rows(svt.sprites, 250));
    return ListView(children: children);
  }

  List<Widget> _rows(List<KeyValueListEntry> entries, double height) {
    List<Widget> children = [];
    for (final KeyValueListEntry entry in entries) {
      // print(entry.key);
      List<String> urls = entry.valueList.whereType<String>().toList();
      if (urls.isEmpty) continue;
      children.add(TileGroup(
        header: _localize(entry.key ?? '-'),
        children: [
          SizedBox(
            height: height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final url in urls)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    child: CachedImage(
                      imageUrl: url,
                      // height: height,
                      showSaveOnLongPress: true,
                      placeholder: placeholder,
                      onTap: () {
                        FullscreenImageViewer.show(
                          context: context,
                          urls: urls,
                          placeholder: placeholder,
                          initialPage: urls.indexOf(url),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ));
    }
    return children;
  }
}
