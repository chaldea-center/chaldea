import 'dart:math' show max, min;

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';

class CreateRecipePage extends StatefulWidget {
  final FakerRuntime runtime;
  const CreateRecipePage({super.key, required this.runtime});

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage>
    with SingleTickerProviderStateMixin, FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  late final stat = runtime.agentData.recipeStat;
  Event? event;
  List<EventRecipe> recipes = [];
  Map<int, int> giftToItem = {};

  @override
  void initState() {
    super.initState();

    event = runtime.gameData.timerData.events.values.firstWhereOrNull(
      (e) => e.recipes.isNotEmpty && isTimeOpen(e.startedAt, e.shopClosedAt, null),
    );
    recipes = event?.recipes ?? [];
    recipes.sort2((e) => e.id);

    for (final recipe in recipes) {
      for (final recipeGift in recipe.recipeGifts) {
        for (final gift in recipeGift.gifts) {
          if (giftToItem.containsKey(gift.id) && gift.objectId != giftToItem[gift.id]) {
            EasyLoading.showError('conflict gift item: gift id ${gift.id}');
            assert(false, 'conflict gift ${gift.id}: ${giftToItem[gift.id]} != ${gift.objectId}');
          }
          giftToItem[gift.id] = gift.objectId;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemIds = {
      for (final recipe in recipes)
        for (final consume in recipe.consumes) consume.objectId,
    }.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.event_recipe),
        actions: [
          IconButton(onPressed: event?.routeTo, icon: Icon(Icons.flag), tooltip: S.current.event),
          runtime.buildMenuButton(context),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final recipe in recipes) ...[buildRecipe(recipe), const Divider()],
                Center(
                  child: Padding(padding: .symmetric(vertical: 16), child: Text(S.current.statistics_title)),
                ),
                const Divider(indent: 16, endIndent: 16),
                ...buildStat(),
                ?buildEventPoint(),
              ],
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: OverflowBar(
              spacing: 4,
              children: [
                for (final itemId in itemIds)
                  Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: itemId,
                    width: 40,
                    text: mstData.getItemOrSvtNum(itemId).format(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRecipe(EventRecipe recipe) {
    return ListTile(
      leading: GameCardMixin.cardIconBuilder(
        context: context,
        icon: recipe.icon,
        height: 48,
        text: stat.recipeCreateNums[recipe.id]?.format(),
      ),
      title: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: [
          for (final recipeGift in recipe.recipeGifts)
            for (final gift in recipeGift.gifts)
              Container(
                decoration: recipeGift.isRateUp
                    ? BoxDecoration(
                        border: .all(color: Colors.red),
                        borderRadius: .circular(4),
                      )
                    : const BoxDecoration(),
                padding: .all(1),
                child: gift.iconBuilder(
                  context: context,
                  width: 32,
                  showOne: false,
                  text: [
                    mstData.getItemOrSvtNum(gift.objectId).format(),
                    if (mstData.isCurPlanUser) (db.itemCenter.itemLeft[gift.objectId] ?? 0).format(),
                  ].join('\n'),
                ),
              ),
        ],
      ),
      subtitle: Row(
        crossAxisAlignment: .center,
        children: [
          for (final consume in recipe.consumes)
            switch (consume.type) {
              .ap => Text(' AP ${consume.num} '),
              .item => Item.iconBuilder(
                context: context,
                item: null,
                itemId: consume.objectId,
                width: 28,
                text: [
                  if (consume.num != 1) '×${consume.num.format()}',
                  mstData.getItemOrSvtNum(consume.objectId).format(),
                ].join('\n'),
                icon: db.gameData.items[consume.objectId]?.icon,
              ),
            },
          Spacer(),
          Text('   MAX ${getMaxDrawNumOne(recipe, 999999)}'),
        ],
      ),
      trailing: IconButton(
        onPressed: getMaxDrawNumOne(recipe) > 0 ? () => onTapDraw(recipe) : null,
        icon: Icon(Icons.currency_exchange),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  List<Widget> buildStat() {
    final giftIds = <int>{...giftToItem.keys, ...stat.giftCounts.keys}.toList();
    giftIds.sort2((e) => db.gameData.items[giftToItem[e]]?.priority ?? e * 1000);
    return [
      ListTile(
        title: Wrap(
          children: [
            for (final recipe in recipes)
              GameCardMixin.cardIconBuilder(
                context: context,
                icon: recipe.icon,
                width: 48,
                height: 48,
                text: (stat.recipeCreateNums[recipe.id] ?? 0).format(),
              ),
          ],
        ),
      ),
      const Divider(indent: 16, endIndent: 16),
      ListTile(
        title: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: giftIds.map((giftId) {
            final itemId = giftToItem[giftId];
            final count = stat.giftCounts[giftId] ?? 0;
            if (itemId == null) {
              return Text('Gift $giftId×$count');
            }
            return Item.iconBuilder(
              context: context,
              width: 32,
              item: null,
              itemId: itemId,
              text: count.format(),
              //
            );
          }).toList(),
        ),
      ),
    ];
  }

  Widget? buildEventPoint() {
    final pointRewards = event?.pointRewards ?? [];
    Map<int, int> maxGroupPoints = {};
    for (final reward in pointRewards) {
      maxGroupPoints[reward.groupId] = max(maxGroupPoints[reward.groupId] ?? 0, reward.point);
    }
    final userEventPoints = {
      for (final userEventPoint in mstData.userEventPoint)
        if (userEventPoint.eventId == event?.id) userEventPoint.groupId: userEventPoint,
    };
    List<Widget> children = [];
    String fmtPoint(int? v) => v?.formatSep() ?? '?';
    for (final groupId in <int>{...maxGroupPoints.keys, ...userEventPoints.keys}) {
      final maxPoint = maxGroupPoints[groupId];
      final userPointValue = userEventPoints[groupId]?.value;
      children.add(
        ListTile(
          title: Text(S.current.event_point),
          subtitle: Text('Group $groupId'),
          trailing: Text(
            [
              '${fmtPoint(userPointValue)}/${fmtPoint(maxPoint)}',
              if (userPointValue != null && maxPoint != null) (userPointValue / maxPoint).format(percent: true),
            ].join('\n'),
            textAlign: .end,
          ),
        ),
      );
    }
    if (children.isEmpty) return null;
    return Column(
      mainAxisSize: .min,
      children: [
        DividerWithTitle(indent: 16, title: S.current.event_point),
        ...children,
      ],
    );
  }

  int getMaxDrawNumOne(EventRecipe recipe, [int? defaultMaxNum]) {
    int maxDrawNum = defaultMaxNum ?? recipe.maxNum;
    for (final consume in recipe.consumes) {
      switch (consume.type) {
        case CommonConsumeType.item:
          maxDrawNum = min(maxDrawNum, mstData.getItemOrSvtNum(consume.objectId) ~/ consume.num);
        case CommonConsumeType.ap:
          maxDrawNum = min(maxDrawNum, mstData.user?.calCurAp() ?? 0);
      }
    }
    return max(0, maxDrawNum);
  }

  Future<void> onTapDraw(EventRecipe recipe) async {
    final maxDrawNum = getMaxDrawNumOne(recipe);
    if (!mounted) return;
    await InputCancelOkDialog.number(
      title: 'Draw Num',
      initValue: maxDrawNum,
      validate: (v) => v > 0 && v <= maxDrawNum,
      onSubmit: (v) {
        showEasyLoading(() => runtime.runTask(() => startDraw(recipe, v)));
      },
    ).showDialog(context);
  }

  Future<void> startDraw(EventRecipe recipe, int createNum) async {
    final resp = await runtime.agent.eventCreateRecipe(recipeId: recipe.id, createNum: createNum);
    try {
      final success = resp.data.getResponseNull('event_create_recipe')?.success;
      if (success == null) return;
      final giftIds = MstValues.toIntList(success['recipeGiftIds']);
      stat.recipeCreateNums.addNum(recipe.id, createNum);
      for (final giftId in giftIds) {
        stat.giftCounts.addNum(giftId, 1);
      }
    } catch (e, s) {
      logger.e('parse recipe resp failed', e, s);
      EasyLoading.showError(e.toString());
    }
  }
}
