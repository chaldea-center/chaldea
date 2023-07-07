import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventHeelPortraitPage extends StatefulWidget {
  final Event event;
  const EventHeelPortraitPage({super.key, required this.event});

  @override
  State<EventHeelPortraitPage> createState() => _EventHeelPortraitPageState();
}

class _EventHeelPortraitPageState extends State<EventHeelPortraitPage> {
  late final controller = ScrollController();
  final svtClass = FilterRadioData<SvtClass>();
  final rarity = FilterRadioData<int>();

  bool filter(HeelPortrait heel) {
    final svt = db.gameData.servantsById[heel.id];
    if (svtClass.options.isNotEmpty) {
      if (!SvtClassX.match(svt?.className ?? SvtClass.none, svtClass.radioValue!)) {
        return false;
      }
    }
    if (!rarity.matchOne(svt?.rarity ?? 0)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final heelPortraits = widget.event.heelPortraits.where(filter).toList();
    heelPortraits.sort2((e) => e.id);
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverList.list(children: [
          const SizedBox(height: 8),
          Center(
            child: FilterGroup<SvtClass>(
              combined: true,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              options: SvtClassX.regularAllWithBeast,
              values: svtClass,
              optionBuilder: (v) => db.getIconImage(v.icon(3), width: 24, height: 24, padding: const EdgeInsets.all(2)),
              onFilterChanged: (_, __) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: FilterGroup<int>(
              combined: true,
              padding: EdgeInsets.zero,
              options: const [5, 4, 3, 2, 1, 0],
              values: rarity,
              onFilterChanged: (_, __) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 8),
        ]),
        SliverGrid.extent(
          maxCrossAxisExtent: 100,
          childAspectRatio: 2 / 3,
          children: [
            for (final heel in heelPortraits) itemBuilder(context, heel),
          ],
        ),
      ],
    );
  }

  Widget itemBuilder(BuildContext context, HeelPortrait heel) {
    String name = heel.name;
    if (name.isEmpty) {
      name = db.gameData.servantsById[heel.id]?.zeroLimitName ?? heel.id.toString();
    }

    Widget title = Text.rich(
      SharedBuilder.textButtonSpan(
        context: context,
        text: Transl.svtNames(name).l,
        onTap: () {
          router.push(url: Routes.servantI(heel.id));
        },
      ),
      textScaleFactor: 0.8,
      textAlign: TextAlign.center,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: CachedImage(
            imageUrl: heel.image,
            showSaveOnLongPress: true,
            cachedOption: CachedImageOption(
              errorWidget: (context, url, error) => const CachedImage(
                  imageUrl: "https://static.atlasacademy.io/JP/EventUI/Prefabs/80432/portrait_unknown.png"),
            ),
          ),
        ),
        Expanded(flex: 3, child: title),
      ],
    );
  }
}
