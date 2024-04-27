import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class TransformSvtProfileTabber extends StatelessWidget {
  final Servant svt;
  final Widget Function(BuildContext context, Servant svt) builder;
  const TransformSvtProfileTabber({super.key, required this.svt, required this.builder});

  @override
  Widget build(BuildContext context) {
    final List<Servant> transformVariants = [svt];
    for (final skill in [...svt.skills, ...svt.noblePhantasms]) {
      for (final func in skill.filteredFunction(showPlayer: true, showEnemy: true, includeTrigger: true)) {
        if (func is! NiceFunction) continue;
        if (func.funcType == FuncType.transformServant) {
          final transformSvt = db.gameData.servantsById[func.svals.firstOrNull?.Value];
          if (transformSvt != null && transformVariants.every((e) => e.id != transformSvt.id)) {
            transformVariants.add(transformSvt);
          }
        }
      }
    }
    if (transformVariants.length <= 1) return builder(context, svt);

    return DefaultTabController(
      length: transformVariants.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TabBar(
                    isScrollable: true,
                    tabs: [
                      for (final e in transformVariants) buildHeader(context, e),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final e in transformVariants) builder(context, e),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget buildHeader(BuildContext context, Servant svt) {
    String name = svt == this.svt ? svt.lName.l : '${svt.lName.l}(${svt.id})';
    return Tab(
      child: Text.rich(
        TextSpan(children: [
          CenterWidgetSpan(child: svt.iconBuilder(context: context, width: 24)),
          TextSpan(text: ' $name'),
        ]),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

// mixin TransformSvtProfileTabber<T extends StatefulWidget> on State<T> {
//   Servant get baseSvt;

//   late final List<Servant> transformVariants = [baseSvt];

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (transformVariants.length <= 1) return buildContent(context, baseSvt);
//     return DefaultTabController(
//       length: transformVariants.length,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               Expanded(
//                 child: SizedBox(
//                   height: 36,
//                   child: TabBar(
//                     isScrollable: true,
//                     tabs: [
//                       for (final e in transformVariants) buildHeader(context, e),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 for (final e in transformVariants) buildContent(context, e),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget buildHeader(BuildContext context, Servant svt) {
//     String name = svt == baseSvt ? svt.lName.l : '${svt.lName.l}(${svt.id})';
//     return Tab(
//       child: Text.rich(
//         TextSpan(children: [
//           CenterWidgetSpan(child: svt.iconBuilder(context: context, width: 24)),
//           TextSpan(text: ' $name'),
//         ]),
//         style: Theme.of(context).textTheme.bodyMedium,
//       ),
//     );
//   }

//   Widget buildContent(BuildContext context, Servant svt);
// }
