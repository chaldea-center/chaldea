import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventMuralPage extends HookWidget {
  final Event event;
  const EventMuralPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final murals = event.murals.toList();
    if (murals.isEmpty) return const SizedBox();
    murals.sort2((e) => e.id);
    // const bg = "https://static.atlasacademy.io/JP/EventUI/Prefabs/80442/img_pic_bg.png";
    // return DecoratedBox(
    //   decoration: const BoxDecoration(
    //     image: DecorationImage(
    //       image: CachedNetworkImageProvider(bg),
    //       fit: BoxFit.fill,
    //     ),
    //   ),
    //   child:
    // );
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => itemBuilder(context, murals[index]),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemCount: murals.length,
    );
  }

  Widget itemBuilder(BuildContext context, EventMural mural) {
    return SimpleAccordion(
      headerTileColor: Colors.transparent,
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final img in mural.images)
                CachedImage(
                  imageUrl: img,
                  showSaveOnLongPress: true,
                  height: 48,
                  placeholder: (_, _) => const SizedBox.shrink(),
                ),
            ],
          ),
          subtitle: Text(mural.message),
        );
      },
      contentBuilder: (context) {
        final child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mural.condQuestId != 0)
              CondTargetValueDescriptor(
                condType: CondType.questClearPhase,
                target: mural.condQuestId,
                value: mural.condQuestPhase,
                textScaleFactor: 0.9,
              ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [for (final img in mural.images) CachedImage(imageUrl: img, showSaveOnLongPress: true)],
            ),
          ],
        );
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: child);
      },
    );
  }
}
