import 'package:chaldea/components/components.dart';
import 'package:chaldea/models/models.dart';

abstract class DescriptorBase {
  Widget buildRegion(BuildContext context) {
    return MappingBase<WidgetBuilder>(
      jp: buildJP,
      cn: buildCN,
      tw: buildTW,
      na: buildNA,
      kr: buildKR,
    ).l!(context);
  }

  Widget buildJP(BuildContext context);

  Widget buildCN(BuildContext context);

  Widget buildTW(BuildContext context);

  Widget buildNA(BuildContext context);

  Widget buildKR(BuildContext context);

  RichText combineToRich(
    BuildContext context,
    String? text1, [
    List<Widget>? children2,
    String? text3,
    List<Widget>? children4,
    String? text5,
  ]) {
    return RichText(
      text: TextSpan(
        text: text1,
        style: Theme.of(context).textTheme.bodyText2,
        children: [
          if (children2 != null)
            for (final child in children2) WidgetSpan(child: child),
          if (text3 != null) TextSpan(text: text3),
          if (children4 != null)
            for (final child in children4) WidgetSpan(child: child),
          if (text5 != null) TextSpan(text: text5),
        ],
      ),
    );
  }
}
