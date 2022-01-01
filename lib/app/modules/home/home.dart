import 'package:flutter/material.dart';

import '../../app.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chaldea')),
      body: GridView.extent(
        maxCrossAxisExtent: 72,
        children: [
          IconButton(
            onPressed: () {
              router.push(url: '/servants', detail: false);
            },
            icon: const Icon(Icons.people_alt_outlined),
          ),
        ],
      ),
    );
  }
}
