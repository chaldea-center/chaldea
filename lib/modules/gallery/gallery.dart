import 'package:chaldea/modules/gallery/detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'blank_page.dart';
import 'package:chaldea/components/detail_route.dart';
import 'package:chaldea/components/master_detail_utils.dart';

class Gallery extends StatefulWidget {
  @override
  GalleryState createState() => GalleryState();
}

class GalleryState extends State<Gallery> {
  final items = List<String>.generate(10, (i) => "Item $i");
  String selectedItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: kTabletMasterContainerRatio,
          child: Material(
              elevation: 4,
              child: Scaffold(
                  appBar: AppBar(
                    title: Text('Master'),
                  ),
                  body: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            selected: items[index] == selectedItem,
                            title: Text(items[index]),
                            onTap: () {
                              setState(() {
                                selectedItem = items[index];

                                // To remove the previously selected detail page
                                while (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }

                                Navigator.of(context)
                                    .push(DetailRoute(builder: (context) {
                                  return DetailPage(item: selectedItem);
                                }));
                              });
                            });
                      }))),
        ),
        isTablet(context)
            ? Flexible(
                flex: 100 - kTabletMasterContainerRatio, child: BlankPage())
            : Container()
      ],
    );
  }
}
