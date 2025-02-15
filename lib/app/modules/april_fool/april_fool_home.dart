import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/material.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../ffo/ffo.dart';
import 'pages/af23_grail_league.dart';
import 'pages/af24_dream_striker.dart';

class AprilFoolHome extends StatelessWidget {
  const AprilFoolHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.april_fool)),
      body: ListView(
        children: [
          // https://fategrandorder.fandom.com/wiki/Fate/Dream_Striker_Release_Campaign
          buildOne(
            context: context,
            title: "Fate/Dream Striker",
            subtitle: "JP 2024",
            icon: "https://static.wikia.nocookie.net/fategrandorder/images/c/c2/FDS-app-icon.png",
            page: const FateDreamStriker(),
          ),
          // https://fategrandorder.fandom.com/wiki/Fate/Grail_League_Release_Campaign#Servants
          buildOne(
            context: context,
            title: "Fate/Grail League",
            subtitle: "JP 2023",
            icon: "https://static.wikia.nocookie.net/fategrandorder/images/c/c0/FGL-app-icon.png",
            page: const FateGrailLeague(),
          ),
          // https://fategrandorder.fandom.com/wiki/Fate/Pixel_Wars_Release_Campaign
          // buildOne(
          //   context: context,
          //   title: "Fate/Pixel Wars",
          //   subtitle: "JP 2022",
          //   icon: "https://static.wikia.nocookie.net/fategrandorder/images/8/82/FatePixelWarsIcon.png",
          //   page: page,
          // ),
          // https://fategrandorder.fandom.com/wiki/Fate/Freedom_Order_Release_Campaign
          buildOne(
            context: context,
            title: "Fate/Freedom Order",
            subtitle: "JP 2021",
            icon: "https://static.wikia.nocookie.net/fategrandorder/images/d/d0/FateFreedomOrder1.png",
            page: FreedomOrderPage(),
          ),
        ],
      ),
    );
  }

  Widget buildOne({
    required BuildContext context,
    required String title,
    required String? subtitle,
    required String icon,
    required Widget? page,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      leading: db.getIconImage(icon, width: 40, height: 40),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      enabled: page != null,
      onTap:
          page == null
              ? null
              : () {
                router.pushPage(page);
              },
    );
  }
}
