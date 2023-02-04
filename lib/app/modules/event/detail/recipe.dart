import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventRecipePage extends HookWidget {
  final Event event;
  const EventRecipePage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return db.onUserData(
      (context, snapshot) => ListView.separated(
        itemBuilder: (context, index) =>
            itemBuilder(context, event.recipes[index]),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: event.recipes.length,
      ),
    );
  }

  Widget itemBuilder(BuildContext context, EventRecipe recipe) {
    return SimpleAccordion(
      headerBuilder: (context, _) {
        final recipeGifts = List.of(recipe.recipeGifts);
        recipeGifts.sort2((e) => e.displayOrder);
        return ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          leading: db.getIconImage(recipe.icon, width: 36),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(Transl.misc2('RecipeName', recipe.name))),
              for (final consume in recipe.consumes) ...[
                Item.iconBuilder(
                  context: context,
                  item: db.gameData.items[consume.objectId],
                  width: 24,
                  icon: db.gameData.items[consume.objectId]?.icon,
                ),
                Text(consume.num.format(), textScaleFactor: 0.9),
              ],
            ],
          ),
          subtitle: Wrap(
            spacing: 2,
            runSpacing: 2,
            alignment: WrapAlignment.start,
            children: [
              for (final recipeGift in recipeGifts)
                for (final gift in recipeGift.gifts)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: recipeGift.topIconId == 1
                            ? Colors.red
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: gift.iconBuilder(
                        context: context,
                        width: 32,
                        showOne: false,
                      ),
                    ),
                  )
            ],
          ),
        );
      },
      contentBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const SizedBox(),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Rate Up: '),
                    for (final recipeGift in recipe.recipeGifts)
                      if (recipeGift.topIconId == 1)
                        for (final gift in recipeGift.gifts)
                          CenterWidgetSpan(
                            child: gift.iconBuilder(
                                context: context, width: 28, showOne: false),
                          ),
                    const TextSpan(text: '\nCost: '),
                    for (final consume in recipe.consumes) ...[
                      CenterWidgetSpan(
                        child: Item.iconBuilder(
                          context: context,
                          item: null,
                          itemId: consume.objectId,
                          width: 28,
                          // text: consume.num.format(),
                        ),
                      ),
                      TextSpan(text: '×${consume.num.format()} '),
                    ],
                    TextSpan(text: '\n${S.current.event_point}: '),
                    CenterWidgetSpan(
                      child: Item.iconBuilder(
                        context: context,
                        item: recipe.eventPointItem,
                        width: 28,
                      ),
                    ),
                    TextSpan(text: '×${recipe.eventPointNum}'),
                    TextSpan(
                        text:
                            '\n${S.current.treasure_box_max_draw_once}: ${recipe.maxNum}'),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
