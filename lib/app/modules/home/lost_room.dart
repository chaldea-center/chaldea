import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'elements/grid_gallery.dart';

class LostRoomPage extends StatefulWidget {
  const LostRoomPage({super.key});

  @override
  State<LostRoomPage> createState() => _LostRoomPageState();
}

class _LostRoomPageState extends State<LostRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LOSTROOM')),
      body: LayoutBuilder(
        builder: (context, constrains) => ListView(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
              child: CachedImage(
                imageUrl:
                    'https://anime.fate-go.jp/mllr/assets/img/kv/logo.png',
                placeholder: (_, __) => Container(),
              ),
            ),
            kDefaultDivider,
            GridGallery(
              isHome: false,
              maxWidth: constrains.maxWidth,
            ),
          ],
        ),
      ),
    );
  }
}
