import 'package:flutter/material.dart';

class ServantListPage extends StatefulWidget {
  ServantListPage({Key? key}) : super(key: key);

  @override
  _ServantListPageState createState() => _ServantListPageState();
}

class _ServantListPageState extends State<ServantListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servant List')),
    );
  }
}
