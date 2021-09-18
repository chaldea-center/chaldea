import 'package:chaldea/components/components.dart';

class IllustSelectPage extends StatelessWidget {
  final Servant svt;

  const IllustSelectPage({Key? key, required this.svt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final illustrations = [
      ...svt.info.illustrations.values,
      for (final icons in svt.icons) ...icons.valueList,
      for (final sprites in svt.sprites) ...sprites.valueList,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Illustration'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2,
        children: illustrations
            .map((name) => Padding(
                  padding: const EdgeInsets.all(4),
                  child: CachedImage(
                    imageUrl: name,
                    onTap: () {
                      Navigator.pop(context, name);
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }
}
