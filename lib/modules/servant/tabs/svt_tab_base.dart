import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';

abstract class SvtTabBaseWidget extends StatefulWidget {
  final ServantDetailPageState? parent;
  final Servant? svt;
  final ServantStatus? status;

  const SvtTabBaseWidget({Key? key, this.parent, this.svt, this.status})
      : assert(parent != null || svt != null),
        super(key: key);
}

abstract class SvtTabBaseState<T extends SvtTabBaseWidget> extends State<T> {
  Servant get svt => (widget.svt ?? widget.parent?.svt)!;
  ServantStatus? _fallbackStatus;

  ServantStatus get status {
    if (widget.status != null || widget.parent?.status != null) {
      return (widget.status ?? widget.parent?.status)!;
    }
    return _fallbackStatus ??= ServantStatus();
  }

  Widget getTab(String label) {
    return Tab(
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }
}
