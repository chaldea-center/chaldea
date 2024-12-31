import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../servant/filter.dart';

class SelectUserSvtCollectionPage extends StatefulWidget {
  final FakerRuntime runtime;
  final String? Function(UserServantCollectionEntity collection)? getStatus;
  final ValueChanged<UserServantCollectionEntity>? onSelected;
  const SelectUserSvtCollectionPage({super.key, required this.runtime, this.getStatus, this.onSelected});

  @override
  State<SelectUserSvtCollectionPage> createState() => _SelectUserSvtCollectionPageState();
}

class _SelectUserSvtCollectionPageState extends State<SelectUserSvtCollectionPage> {
  late final runtime = widget.runtime;
  late final mstData = runtime.mstData;

  static SvtFilterData filterData = SvtFilterData();

  bool filter(UserServantCollectionEntity collection) {
    final svt = db.gameData.servantsById[collection.svtId];
    if (!collection.isOwned || svt == null || svt.collectionNo <= 0) return false;
    if (!ServantFilterPage.filter(filterData, svt)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final collections = mstData.userSvtCollection.where(filter).toList();
    collections.sort((a, b) =>
        SvtFilterData.compareId(a.svtId, b.svtId, keys: filterData.sortKeys, reversed: filterData.sortReversed));
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User Svt Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => ServantFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
                planMode: false,
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 64,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 132 / 144,
        ),
        itemBuilder: (context, index) {
          final collection = collections[index];
          final svt = db.gameData.servantsById[collection.svtId];
          final status = widget.getStatus?.call(collection);
          Widget child;
          if (svt == null) {
            child = Text(['${collection.svtId}', if (status != null) status].join('\n'));
          } else {
            child = svt.iconBuilder(
              context: context,
              text: status,
              jumpToDetail: false,
            );
          }
          child = GestureDetector(
            child: child,
            onTap: () {
              Navigator.pop(context);
              widget.onSelected?.call(collection);
            },
            onLongPress: () {
              router.push(url: Routes.servantI(collection.svtId));
            },
          );
          return child;
        },
        itemCount: collections.length,
      ),
    );
  }
}
