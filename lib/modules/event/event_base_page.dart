import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventBasePage {
  List<Widget> buildHeaders({
    required BuildContext context,
    required EventBase event,
  }) {
    List<Widget> children = [];
    List<String> banners =
        [event.bannerUrlJp, event.bannerUrl].whereType<String>().toList();
    if (banners.isNotEmpty) {
      children.add(CarouselSlider(
        items: banners
            .map((e) => GestureDetector(
                  onTap: () => jumpToExternalLinkAlert(
                    url: WikiUtil.mcFullLink(event.indexKey),
                    name: 'Mooncell',
                  ),
                  child: CachedImage(
                    imageUrl: event.lBannerUrl,
                    isMCFile: true,
                    placeholder: (_, __) => AspectRatio(aspectRatio: 8 / 3),
                  ),
                ))
            .toList(),
        options: CarouselOptions(
          aspectRatio: 8 / 3,
          viewportFraction: 1.0,
          autoPlay: true,
          enableInfiniteScroll: false,
          autoPlayInterval: const Duration(seconds: 6),
        ),
      ));
    }
    children.add(CustomTable(children: [
      CustomTableRow(children: [
        TableCellData(
          text: event.localizedName,
          textAlign: TextAlign.center,
          fontSize: 12,
          color: TableCellData.resolveHeaderColor(context),
        )
      ]),
      if (!Language.isJP && event.nameJp != null)
        CustomTableRow(children: [
          TableCellData(
            text: event.nameJp!,
            textAlign: TextAlign.center,
            fontSize: 12,
            color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
          )
        ]),
      CustomTableRow(children: [
        TableCellData(
          text: 'JP: ${event.startTimeJp ?? '?'} ~ ${event.endTimeJp ?? '?'}',
          maxLines: 1,
          fontSize: 14,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(16, 4, 4, 4),
        )
      ]),
      if (event.startTimeCn != null && event.endTimeCn != null)
        CustomTableRow(children: [
          TableCellData(
            text: 'CN: ${event.startTimeCn ?? '?'} ~ ${event.endTimeCn ?? '?'}',
            maxLines: 1,
            fontSize: 14,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(16, 4, 4, 4),
          )
        ]),
    ]));
    children.add(SizedBox(height: 8));
    return children;
  }

  List<Widget> buildSummons({
    required BuildContext context,
    required List<Summon> summons,
  }) {
    if (summons.isEmpty) return [];
    return [
      ListTile(title: Center(child: Text(S.current.summon))),
      TileGroup(
        children: summons
            .map((e) => ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.dice,
                  color: Colors.blue,
                ),
                title: Text(e.localizedName, style: TextStyle(fontSize: 14)),
                horizontalTitleGap: 0,
                onTap: () {
                  SplitRoute.push(context, SummonDetailPage(summon: e));
                }))
            .toList(),
      ),
    ];
  }
}
