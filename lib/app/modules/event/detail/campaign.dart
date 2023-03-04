import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/quest/quest_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventCampaignDetailPage extends StatelessWidget {
  final Event event;
  const EventCampaignDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (event.campaignQuests.isNotEmpty) {
      if (event.campaignQuests.any((q) => q.questId == 0)) {
        children.add(const ListTile(title: Text('All Quests')));
      } else {
        Map<QuestType?, int> counts = {};
        final questIds = event.campaignQuests.map((e) => e.questId).toList();
        for (final questId in questIds) {
          final quest = db.gameData.quests[questId];
          counts.addNum(quest?.type, 1);
        }
        children.add(ListTile(
          dense: true,
          title: const Text('Target Quests'),
          subtitle: Text(counts.entries.map((e) => '${e.value} ${getQuestTypeName(e.key)}').join(', ')),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            router.pushPage(QuestListPage.ids(ids: questIds));
          },
        ));
      }
    }
    final campaigns = event.campaigns.toList();
    campaigns.sort2((e) => e.idx * 100 + e.target.index);
    for (int index = 0; index < campaigns.length; index++) {
      children.addAll(itemBuilder(context, campaigns[index], index));
    }
    return TileGroup(header: S.current.event_campaign, children: children);
  }

  List<Widget> itemBuilder(BuildContext context, EventCampaign campaign, int index) {
    List<Widget> children = [
      const SizedBox(height: 8),
      Row(
        children: [
          const Expanded(child: Divider(indent: 16, endIndent: 8, thickness: 1, height: 16)),
          Text(
            '${S.current.event_campaign} ${index + 1}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Expanded(child: Divider(indent: 8, endIndent: 16, thickness: 1, height: 16)),
        ],
      ),
      ListTile(
        title: Text(S.current.general_type),
        trailing: Text(Transl.enums(campaign.target, (enums) => enums.combineAdjustTarget).l),
        dense: true,
      ),
      ListTile(
        title: const Text("Value"),
        trailing: fmtValue(context, campaign),
        dense: true,
      ),
      ListTile(
        title: const Text("Calc Type"),
        trailing: Text(campaign.calcType.name),
        dense: true,
      ),
    ];
    if (campaign.warIds.isNotEmpty) {
      children.add(const SHeader('Related Wars'));
      for (final warId in campaign.warIds) {
        final war = db.gameData.wars[warId];
        children.add(ListTile(
          title: Text(war?.lName.l ?? 'War $warId'),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            router.push(url: Routes.warI(warId));
          },
        ));
      }
    }
    bool targetSame =
        campaign.target == CombineAdjustTarget.questAp && campaign.targetIds.length == event.campaignQuests.length;
    if (targetSame) {
      targetSame =
          (campaign.targetIds..sort()).join() == (event.campaignQuests.map((e) => e.questId).toList()..sort()).join();
    }

    if (campaign.targetIds.isNotEmpty && !targetSame) {
      children.add(SHeader('${campaign.targetIds.length} targets'));
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: [for (final id in campaign.targetIds) getTarget(context, campaign, id)],
        ),
      ));
    }

    return children;
  }

  String getCalcType(EventCombineCalc calcType) {
    switch (calcType) {
      case EventCombineCalc.addition:
        return '+';
      case EventCombineCalc.multiplication:
        return '×';
      case EventCombineCalc.fixedValue:
        return '=';
    }
  }

  Widget fmtValue(BuildContext context, EventCampaign campaign) {
    if (campaign.target == CombineAdjustTarget.questUseContinueItem) {
      final item = db.gameData.items[campaign.value];
      return InkWell(
        onTap: () {
          router.push(url: Routes.itemI(campaign.value));
        },
        child: Text.rich(TextSpan(
          children: [
            if (item != null)
              CenterWidgetSpan(
                child: Item.iconBuilder(context: context, item: item, width: 36),
              ),
            TextSpan(text: ' ${Item.getName(campaign.value)}')
          ],
        )),
      );
    }
    int? percentBase;

    switch (campaign.target) {
      // case CombineAdjustTarget.none:
      // minus types
      case CombineAdjustTarget.combineQp:
      case CombineAdjustTarget.questAp:
      case CombineAdjustTarget.svtequipCombineQp:
      case CombineAdjustTarget.questApFirstTime:
        percentBase = 10;
        break;
      // bonus types
      case CombineAdjustTarget.combineExp:
      case CombineAdjustTarget.largeSuccess:
      case CombineAdjustTarget.superSuccess:
      case CombineAdjustTarget.svtequipLargeSuccess:
      case CombineAdjustTarget.svtequipSuperSuccess:
      case CombineAdjustTarget.questFp:
      case CombineAdjustTarget.exchangeSvtCombineExp:
      case CombineAdjustTarget.questUseFriendshipUpItem:
      case CombineAdjustTarget.questFriendship:
        percentBase = 10;
        break;
      // case CombineAdjustTarget.activeSkill:
      // case CombineAdjustTarget.limitQp:
      // case CombineAdjustTarget.limitItem:
      // case CombineAdjustTarget.skillQp:
      // case CombineAdjustTarget.skillItem:
      // case CombineAdjustTarget.treasureDeviceQp:
      // case CombineAdjustTarget.treasureDeviceItem:
      // case CombineAdjustTarget.questExp:
      // case CombineAdjustTarget.questQp:
      // case CombineAdjustTarget.questDrop:
      // case CombineAdjustTarget.svtequipCombineExp:
      // case CombineAdjustTarget.questEventPoint:
      // case CombineAdjustTarget.enemySvtClassPickUp:
      // case CombineAdjustTarget.eventEachDropNum:
      // case CombineAdjustTarget.eventEachDropRate:
      // case CombineAdjustTarget.dailyDropUp:
      case CombineAdjustTarget.friendPointGachaFreeDrawNum:
        break;
      default:
        break;
    }
    if (campaign.calcType == EventCombineCalc.fixedValue) {
      percentBase = null; // not absolutely
    }
    return Text([
      getCalcType(campaign.calcType),
      percentBase == null
          ? campaign.value.toString()
          : campaign.value.format(
              percent: true,
              base: percentBase.toDouble(),
            )
    ].join());
  }

  Widget getTarget(BuildContext context, EventCampaign campaign, int id) {
    final entity = db.gameData.servantsById[id];
    if (entity != null) return entity.iconBuilder(context: context, width: 48);
    final item = db.gameData.items[id];
    if (item != null && campaign.target == CombineAdjustTarget.questUseFriendshipUpItem) {
      return Item.iconBuilder(context: context, item: item, width: 48);
    }
    return Text(id.toString());
  }

  String getQuestTypeName(QuestType? type) {
    switch (type) {
      case QuestType.main:
        return S.current.main_quest;
      case QuestType.free:
        return S.current.free_quest;
      case QuestType.friendship:
        return S.current.interlude;
      case QuestType.event:
        return S.current.event;
      case QuestType.heroballad:
      case QuestType.warBoard:
        return S.current.war_board;
      case null:
        return 'Unknown';
    }
  }
}
