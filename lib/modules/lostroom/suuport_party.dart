import 'package:chaldea/components/components.dart';

class SupportPartyPage extends StatefulWidget {
  const SupportPartyPage({Key? key}) : super(key: key);

  @override
  _SupportPartyPageState createState() => _SupportPartyPageState();
}

class _SupportPartyPageState extends State<SupportPartyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.support_party),
      ),
      body: ListView(
        children: [
          SizedBox(height: 200, child: partyCanvas),
        ],
      ),
    );
  }

  Widget get partyCanvas {
    return Container();
  }
}
