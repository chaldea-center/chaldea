import 'package:flutter/material.dart';

import 'elements/gallery_item.dart';
import 'elements/grid_gallery.dart';

class LostRoomPage extends StatefulWidget {
  const LostRoomPage({super.key});

  @override
  State<LostRoomPage> createState() => _LostRoomPageState();
}

class _LostRoomPageState extends State<LostRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LOSTROOM')),
      body: LayoutBuilder(
        builder: (context, constrains) => SingleChildScrollView(
          child: GridGallery(
            items: GalleryItem.lostRoomItems,
            maxWidth: constrains.maxWidth,
          ),
        ),
      ),
    );
  }
}
