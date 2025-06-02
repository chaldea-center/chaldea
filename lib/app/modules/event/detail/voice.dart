import 'package:chaldea/app/modules/servant/tabs/voice_tab.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/audio.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventVoicePage extends StatefulWidget {
  final Event event;
  const EventVoicePage({super.key, required this.event});

  @override
  State<EventVoicePage> createState() => _EventVoicePageState();
}

class _EventVoicePageState extends State<EventVoicePage> {
  final scrollController = ScrollController();
  final player = MyAudioPlayer<VoiceLine>();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    final voiceGroups = widget.event.voices.toList();
    return ListView.separated(
      controller: scrollController,
      itemBuilder: (context, index) => itemBuilder(context, voiceGroups[index]),
      separatorBuilder: (_, _) => const SizedBox(),
      itemCount: voiceGroups.length,
    );
  }

  Widget itemBuilder(BuildContext context, VoiceGroup group) {
    return VoiceGroupAccordion(group: group, player: player, event: widget.event);
  }

  Widget getGuide(EventRewardSceneGuide guide) {
    String name = guide.displayName ?? db.gameData.servantsById[guide.imageId]?.lName.jp ?? guide.imageId.toString();
    return ListTile(
      title: Text(Transl.svtNames(name).l),
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      trailing: SizedBox(
        width: 100,
        child: CachedImage(
          imageUrl: guide.image,
          cachedOption: const CachedImageOption(alignment: Alignment.topCenter, fit: BoxFit.fitWidth),
        ),
      ),
      onTap: () => FullscreenImageViewer.show(context: context, urls: [guide.image]),
    );
  }
}
