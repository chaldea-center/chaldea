// import 'package:flutter/material.dart';
// import 'package:chaldea/models/models.dart';

// import '../servant.dart';

// abstract class SvtTabBaseWidget extends StatefulWidget {
//   final ServantDetailPageState? parent;
//   final Servant? svt;
//   final SvtStatus? status;

//   const SvtTabBaseWidget({Key? key, this.parent, this.svt, this.status})
//       : assert(parent != null || svt != null),
//         super(key: key);
// }

// mixin SvtTabBase {
//   Servant get svt;

//   SvtStatus get status {
//     return db2.curUser.svtStatusOf(no)
//   }

//   Widget getTab(String label) {
//     return Tab(
//       child: Text(
//         label,
//         style: Theme.of(context).textTheme.bodyText2,
//       ),
//     );
//   }
// }
