import 'package:flutter/material.dart';

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
            isHome: false,
            maxWidth: constrains.maxWidth,
          ),
        ),
      ),
    );
  }
}
