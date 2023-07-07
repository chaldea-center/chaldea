import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/bgm/bgm.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/audio.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventRewardScenePage extends StatefulWidget {
  final Event event;
  const EventRewardScenePage({super.key, required this.event});

  @override
  State<EventRewardScenePage> createState() => _EventRewardScenePageState();
}

class _EventRewardScenePageState extends State<EventRewardScenePage> {
  final scrollController = ScrollController();
  final player = MyAudioPlayer<String>();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    final scenes = widget.event.rewardScenes.toList();
    scenes.sort2((e) => e.slot);
    return ListView.separated(
      controller: scrollController,
      itemBuilder: (context, index) => itemBuilder(context, scenes[index]),
      separatorBuilder: (_, __) => const SizedBox(),
      itemCount: scenes.length,
    );
  }

  Widget itemBuilder(BuildContext context, EventRewardScene scene) {
    return TileGroup(
      headerWidget: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text.rich(TextSpan(text: 'Slot ${scene.slot} ', children: [
          CenterWidgetSpan(
            child: db.getIconImage(
              Theme.of(context).isDarkMode ? scene.tabOnImage : scene.tabOffImage,
              height: 20,
            ),
          )
        ])),
      ),
      children: [
        if (scene.image != null)
          ListTile(
            title: const Text('Logo'),
            trailing: db.getIconImage(scene.image),
            onTap: () => FullscreenImageViewer.show(context: context, urls: [scene.image]),
          ),
        ListTile(
          title: Text(S.current.background),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: db.getIconImage(scene.bg),
          ),
          onTap: () => FullscreenImageViewer.show(context: context, urls: [scene.bg]),
        ),
        if (scene.bgm.id != 0) getBgm(scene.bgm),
        if (scene.afterBgm.id != 0 && scene.afterBgm.id != scene.bgm.id) getBgm(scene.afterBgm),
        if (scene.guides.isNotEmpty) ...const [
          Divider(),
          SHeader('Guide'),
        ],
        for (final guide in scene.guides) getGuide(guide),
      ],
    );
  }

  Widget getBgm(BgmEntity bgm) {
    return ListTile(
      dense: true,
      title: bgm.tooltip.split('\n').length > 1 ? null : Text(S.current.bgm),
      subtitle: Text(bgm.tooltip),
      trailing: SoundPlayButton(url: bgm.audioAsset, player: player),
      onTap: () {
        router.push(url: bgm.route, child: BgmDetailPage(bgm: bgm));
      },
    );
  }

  Widget getGuide(EventRewardSceneGuide guide) {
    final svtId = db.gameData.storyCharaFigures[guide.imageId] ?? guide.imageId;
    String name = guide.displayName ?? db.gameData.servantsById[svtId]?.lName.jp ?? guide.imageId.toString();
    return ListTile(
      title: Text(Transl.svtNames(name).l),
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      trailing: SizedBox(
        width: 100,
        child: CachedImage(
          imageUrl: guide.image,
          cachedOption: const CachedImageOption(
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
      onTap: () => FullscreenImageViewer.show(context: context, urls: [guide.image]),
    );
  }
}
