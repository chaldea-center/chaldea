import 'package:flutter/material.dart';

class ServantPage extends StatefulWidget {
  final int? id;

  const ServantPage({Key? key, required this.id}) : super(key: key);

  @override
  _ServantPageState createState() => _ServantPageState();
}

class _ServantPageState extends State<ServantPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Servant ${widget.id}')),
    );
  }
}
