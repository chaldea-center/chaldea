//@dart=2.12
import 'dart:math';

import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';

class APCalcPage extends StatefulWidget {
  @override
  _APCalcPageState createState() => _APCalcPageState();
}

class _APCalcPageState extends State<APCalcPage> {
  late TextEditingController _curCtrl, _maxCtrl;
  String? endTime;
  bool showExtraHint = Random().nextDouble() > 0.5;

  @override
  void initState() {
    super.initState();
    _curCtrl = TextEditingController(text: '0');
    _maxCtrl = TextEditingController(text: '142');
  }

  @override
  void dispose() {
    _curCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _buildRow(S.of(context).cur_ap, _curCtrl),
      _buildRow(S.of(context).max_ap, _maxCtrl),
      ListTile(
        title: ElevatedButton(
          onPressed: calcTime,
          child: Text(S.of(context).calculate),
        ),
      ),
      ListTile(
        title: Center(
          child: Text(
            (endTime ?? '-').toString(),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    ];
    return AutoUnfocusBuilder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).ap_overflow_time),
          leading: BackButton(),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (_, i) => children[i],
                separatorBuilder: (_, i) => kDefaultDivider,
                itemCount: children.length,
              ),
            ),
            if (showExtraHint)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    S.of(context).ap_calc_page_joke,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String text, TextEditingController controller) {
    return ListTile(
      title: Text(text + ': '),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                FocusScope.of(context).unfocus();
                controller.text =
                    ((int.tryParse(controller.text) ?? 0) - 1).toString();
                calcTime();
              }),
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              maxLength: 5,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 5),
              ),
              onChanged: (s) {
                calcTime();
              },
            ),
          ),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                FocusScope.of(context).unfocus();
                controller.text =
                    ((int.tryParse(controller.text) ?? 0) + 1).toString();
                calcTime();
              })
        ],
      ),
    );
  }

  void calcTime() {
    int cur = int.tryParse(_curCtrl.text) ?? 0;
    int maxVal = int.tryParse(_maxCtrl.text) ?? 0;
    final duration = Duration(minutes: (maxVal - cur) * 5);
    final now = DateTime.now();
    final end = now.add(duration);
    String day;
    switch (end.day - now.day) {
      case 0:
        day = 'Today';
        break;
      case 1:
        day = 'Tomorrow';
        break;
      default:
        day = '${end.month}-${end.day}';
    }
    endTime = '$day ${DateFormat('HH:mm').format(end)}';
    setState(() {});
  }
}
