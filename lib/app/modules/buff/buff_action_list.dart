import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/widgets.dart';

class BuffActionListPage extends StatefulWidget {
  const BuffActionListPage({super.key});

  @override
  _BuffActionListPageState createState() => _BuffActionListPageState();
}

class _BuffActionListPageState extends State<BuffActionListPage>
    with SearchableListState<BuffAction, BuffActionListPage> {
  static final deprecatedMap = {
    for (final entry in BuffActionConverter.deprecatedTypes.entries) entry.value: entry.key,
  };

  final Map<BuffAction, ({Set<String> plus, Set<String> minus})> _buffIcons = {};

  @override
  Iterable<BuffAction> wholeData = BuffAction.values.where((e) => e.value > 0);

  @override
  bool prototypeExtent = false;

  @override
  void initState() {
    super.initState();
    for (final buff in db.gameData.baseBuffs.values) {
      final icon = buff.icon;
      if (icon == null) continue;
      for (final action in buff.buffActions) {
        final icons = _buffIcons[action] ??= (plus: <String>{}, minus: <String>{});
        final actionInfo = db.gameData.constData.buffActions[action];
        if (actionInfo != null && actionInfo.minusTypes.contains(buff.type)) {
          icons.minus.add(icon);
        } else {
          icons.plus.add(icon);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => a.value - b.value);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(leading: const MasterBackButton(), title: const Text("Buff Actions"), bottom: searchBar),
    );
  }

  @override
  bool filter(BuffAction? buffAction) => true;

  @override
  Iterable<String?> getSummary(BuffAction buffAction) sync* {
    yield buffAction.value.toString();
    yield buffAction.name.toString();
    yield deprecatedMap[buffAction];
  }

  @override
  Widget listItemBuilder(BuffAction buffAction) {
    final icons = _buffIcons[buffAction];
    final shownIcons = <String>{...?icons?.plus.take(3), ...?icons?.minus.take(3)};
    return ListTile(
      // dense: true,
      title: Text("${buffAction.value} - ${buffAction.name}"),
      subtitle:
          shownIcons.isEmpty
              ? null
              : Wrap(
                spacing: 2,
                children: [for (final icon in shownIcons) db.getIconImage(icon, width: 18, height: 18)],
              ),
      onTap: () {
        router.popDetailAndPush(context: context, url: Routes.buffActionI(buffAction));
      },
    );
  }

  @override
  Widget gridItemBuilder(BuffAction buffAction) => throw UnimplementedError('GridView not designed');
}
