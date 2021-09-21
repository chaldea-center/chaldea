import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:flutter/services.dart';

class BondFarmingPage extends StatefulWidget {
  const BondFarmingPage({Key? key}) : super(key: key);

  @override
  _BondFarmingPageState createState() => _BondFarmingPageState();
}

class _BondFarmingPageState extends State<BondFarmingPage> {
  Servant? svt;
  int point = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bond Farming')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ListTile(
            leading:
                svt?.iconBuilder(context: context) ?? db.getIconImage(null),
            title: Text(svt == null ? 'Select' : 'No.${svt!.no}-${svt!.lName}'),
            trailing: IconButton(
              onPressed: () {
                SplitRoute.push(context, ServantListPage(
                  onSelected: (v) {
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        svt = v;
                      });
                    }
                  },
                ));
              },
              icon: const Icon(Icons.change_circle),
              tooltip: 'Change',
            ),
          ),
          ListTile(
            title: const Text('Current Bond Point(BP)'),
            trailing: SizedBox(
              width: 120,
              child: TextField(
                onChanged: (s) {
                  point = int.tryParse(s) ?? point;
                  setState(() {});
                },
                textAlign: TextAlign.end,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ),
          const ListTile(
            title: Text('BP +50'),
          ),
          const ListTile(
            title: Text('BP +15%'),
          ),
          const ListTile(
            title: Text('BP +10%'),
          ),
          const ListTile(
            title: Text('BP +5%'),
          ),
        ],
      ),
    );
  }
}
