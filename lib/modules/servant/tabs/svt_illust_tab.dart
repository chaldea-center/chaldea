import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtIllustTab extends SvtTabBaseWidget {
  const SvtIllustTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtIllustTabState createState() => _SvtIllustTabState();
}

class _SvtIllustTabState extends SvtTabBaseState<SvtIllustTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: svt.info.illustrations.length, vsync: this);
  }

  Widget placeholder(BuildContext context, String? url) {
    return db.getIconImage(svt.cardBackFace);
  }

  String _localize(String s) {
    return s.replaceFirstMapped(RegExp(r'第(.)阶段'), (match) {
      final n = match.group(1);
      return LocalizedText(chs: '第$n阶段', jpn: '第$n段階 ', eng: 'Stage $n')
          .localized;
    }).replaceFirst(
      '愚人节',
      const LocalizedText(chs: '愚人节', jpn: 'エイプリルフール', eng: "April Fools' Day")
          .localized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = svt.info.illustrations.values.toList();
    return Column(
      children: <Widget>[
        SizedBox(
          height: 36,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: svt.info.illustrations.keys
                .map((e) => getTab(_localize(e)))
                .toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(svt.info.illustrations.length, (index) {
              return GestureDetector(
                onTap: () async {
                  var newIndex = await FullscreenImageViewer.show(
                    context: context,
                    urls: imageUrls,
                    placeholder: placeholder,
                    initialPage: index,
                  );
                  if (newIndex != null && newIndex is int) {
                    _tabController.animateTo(newIndex);
                  }
                },
                child: CachedImage(
                  imageUrl: imageUrls[index],
                  placeholder: placeholder,
                  showSaveOnLongPress: true,
                ),
              );
            }),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
