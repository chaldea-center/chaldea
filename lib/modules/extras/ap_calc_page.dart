import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class APCalcPage extends StatefulWidget {
  @override
  _APCalcPageState createState() => _APCalcPageState();
}

class _APCalcPageState extends State<APCalcPage> {
  TextEditingController _curCtrl, _maxCtrl;
  String endTime;

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
      _buildRow('Cur AP', _curCtrl),
      _buildRow('Max AP', _maxCtrl),
      ListTile(
        title: RaisedButton(
          onPressed: calcTime,
          child: Text('Calculate'),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
        ),
      ),
      ListTile(
        title: Text('AP full at'),
        trailing: Text(endTime.toString()),
      ),
    ];
    return AutoUnfocusBuilder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('AP Calculator'),
          leading: BackButton(),
        ),
        body: ListView.separated(
          itemBuilder: (_, i) => children[i],
          separatorBuilder: (_, i) => Divider(height: 1),
          itemCount: children.length,
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
                controller.text = ((int.tryParse(controller.text) ?? 0) - 1).toString();
                calcTime();
              }),
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              maxLength: 4,
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
                controller.text = ((int.tryParse(controller.text) ?? 0) + 1).toString();
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
