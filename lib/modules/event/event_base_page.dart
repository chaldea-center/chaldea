import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'quest_list_page.dart';

class EventBasePage {
  List<Widget> buildHeaders({
    required BuildContext context,
    required EventBase event,
  }) {
    List<Widget> children = [];
    children.add(GestureDetector(
      onTap: () => jumpToExternalLinkAlert(
        url: WikiUtil.mcFullLink(event.indexKey),
        name: 'Mooncell',
      ),
      child: CarouselUtil.limitHeightWidget(
          context: context, imageUrls: [event.bannerUrlJp, event.bannerUrl]),
    ));
    children.add(CustomTable(children: [
      CustomTableRow(children: [
        TableCellData(
          text: event.localizedName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
          color: TableCellData.resolveHeaderColor(context),
        )
      ]),
      if (!Language.isJP && event.nameJp != null)
        CustomTableRow(children: [
          TableCellData(
            text: event.nameJp!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
          )
        ]),
      CustomTableRow(children: [
        TableCellData(
          text: 'JP: ${event.startTimeJp ?? '?'} ~ ${event.endTimeJp ?? '?'}',
          maxLines: 1,
          style: const TextStyle(fontSize: 14),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        )
      ]),
      if (event.startTimeCn != null && event.endTimeCn != null)
        CustomTableRow(children: [
          TableCellData(
            text: 'CN: ${event.startTimeCn ?? '?'} ~ ${event.endTimeCn ?? '?'}',
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          )
        ]),
    ]));
    children.add(const SizedBox(height: 8));
    return children;
  }

  List<Widget> buildSummons({
    required BuildContext context,
    required List<Summon> summons,
  }) {
    if (summons.isEmpty) return [];
    return [
      blockHeader(S.current.summon),
      TileGroup(
        children: summons
            .map((e) => ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.dice,
                  size: 20,
                  color: Colors.blue,
                ),
                title: Text(e.lName, style: const TextStyle(fontSize: 14)),
                horizontalTitleGap: 0,
                onTap: () {
                  SplitRoute.push(context, SummonDetailPage(summon: e));
                }))
            .toList(),
      ),
    ];
  }

  static Widget buildSpecialRewards(
      BuildContext context, EventBase event, Widget tile) {
    final svt = db.gameData.servants[event.welfareServant];
    final items = <Widget>[
      if (event.grail > 0)
        Item.iconBuilder(
            context: context,
            itemKey: Items.grail,
            text: event.grail.toString(),
            width: 32),
      if (event.crystal > 0)
        Item.iconBuilder(
            context: context,
            itemKey: Items.crystal,
            text: event.crystal.toString(),
            width: 32),
      if (event.grail2crystal > 0)
        Item.iconBuilder(
            context: context,
            itemKey: Items.grail2crystal,
            text: event.grail2crystal.toString(),
            width: 32),
      if (event.rarePrism > 0)
        Item.iconBuilder(
            context: context,
            itemKey: Items.rarePri,
            text: event.rarePrism.toString(),
            width: 32),
      if (event.foukun4 > 0) ...[
        Item.iconBuilder(
            context: context,
            itemKey: Items.fou4Hp,
            text: event.foukun4.toString(),
            width: 32),
        Item.iconBuilder(
            context: context,
            itemKey: Items.fou4Atk,
            text: event.foukun4.toString(),
            width: 32),
      ],
    ];
    if (svt == null && items.isEmpty) return Container();
    Widget rewards = Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      children: items,
    );
    if (svt != null) {
      rewards = Row(
        children: [
          Expanded(child: rewards),
          svt.iconBuilder(context: context, width: 32),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tile,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 24, 4),
          child: rewards,
        ),
      ],
    );
  }

  Widget blockHeader(String header) {
    return ListTile(
      title: Text(
        header,
        textScaleFactor: 0.95,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    );
  }

  List<Widget> buildQuests({
    required BuildContext context,
    required EventBase event,
  }) {
    if (event is LimitEvent) {
      if (event.mainQuests.isEmpty && event.freeQuests.isEmpty) {
        return [];
      }
    }
    return [
      blockHeader(S.current.quest),
      TileGroup(
        children: [
          ListTile(
            title: Text(
                LocalizedText.of(chs: '主线关卡', jpn: 'シナリオ', eng: 'Main Quests', kor: '메인 퀘스트')),
            onTap: () {
              SplitRoute.push(
                context,
                QuestListPage(
                  title: event.localizedName,
                  quests: event.mainQuests,
                  showChapter: true,
                ),
              );
            },
          ),
          ListTile(
            title: Text(S.current.free_quest),
            onTap: () {
              List<Quest> quests = [];
              if (event is MainRecord) {
                quests = db.gameData.freeQuests.values
                    .where((quest) => event.isSameEvent(quest.chapter))
                    .toList();
              } else if (event is LimitEvent) {
                quests = event.freeQuests;
              }
              SplitRoute.push(
                context,
                QuestListPage(
                  title: event.localizedName,
                  quests: quests,
                  showChapter: false,
                ),
              );
            },
          ),
        ],
      )
    ];
  }
}
