import 'package:flutter/material.dart';

import 'package:chaldea/modules/gallery/gallery.dart';
import 'package:chaldea/modules/gallery/blank_page.dart';
import 'package:chaldea/components/master_detail_utils.dart';

class ChaldeaContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChaldeaContainerState();
}

//372 633 1281. 261 648 909
class _ChaldeaContainerState extends State<ChaldeaContainer> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chaldea",
      home: Gallery(),
    );
  }
}
