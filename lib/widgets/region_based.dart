import 'package:flutter/material.dart';

import '../app/modules/common/builders.dart';
import '../models/models.dart';
import 'widget_builders.dart';

mixin RegionBasedState<V, T extends StatefulWidget> on State<T> {
  Region? region;
  V? data;

  Future<void> onRegionChanged(dynamic newRegion) {
    setState(() {
      if (newRegion is Region) {
        region = newRegion;
      } else {
        region = null;
      }
    });
    return doFetchData();
  }

  Widget dropdownRegion({bool shownNone = false}) {
    return DropdownButton<Region?>(
      value: region,
      // hint: Text('Region'),
      items: [
        if (shownNone)
          const DropdownMenuItem(
            value: null,
            child: Text('Inherit'),
          ),
        for (final region in Region.values)
          DropdownMenuItem(
            value: region,
            child: Text(region.localName),
          ),
      ],
      icon: Icon(
        Icons.arrow_drop_down,
        color: SharedBuilder.appBarForeground(context),
      ),
      selectedItemBuilder: (context) {
        final style = TextStyle(color: SharedBuilder.appBarForeground(context));
        return [
          DropdownMenuItem(
            value: null,
            child: Text('Inherit', style: style),
          ),
          for (final region in Region.values)
            DropdownMenuItem(
              child: Text(region.localName, style: style),
            )
        ];
      },
      onChanged: onRegionChanged,
      underline: const SizedBox(),
    );
  }

  bool _loading = false;
  Future<V?> fetchData(Region? r);
  Future<void> doFetchData() async {
    _loading = true;
    data = null;
    if (mounted) setState(() {});
    try {
      data = await fetchData(region);
    } finally {
      _loading = false;
      if (mounted) setState(() {});
    }
  }

  Widget buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (data == null) {
      return Center(child: RefreshButton(onPressed: doFetchData));
    }
    return buildContent(context, data as V);
  }

  Widget buildContent(BuildContext context, V data);
}
