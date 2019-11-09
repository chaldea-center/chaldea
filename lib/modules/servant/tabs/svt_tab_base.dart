import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';

abstract class SvtTabBaseWidget extends StatefulWidget {
  final ServantDetailPageState parent;
  final Servant svt;
  final ServantPlan plan;

  SvtTabBaseWidget({Key key, this.parent, this.svt, this.plan})
      : super(key: key);
}

abstract class SvtTabBaseState<T extends SvtTabBaseWidget> extends State<T> {
  Servant svt;
  ServantPlan plan;

  SvtTabBaseState(
      {ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : assert(parent?.svt != null || svt != null) {
    this.svt = svt ?? parent?.svt;
    this.plan = plan ?? parent?.plan ?? ServantPlan();
  }
}
