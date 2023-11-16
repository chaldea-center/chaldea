import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../packages/language.dart';
import '../home/elements/random_image.dart';
import '../home/subpage/feedback_page.dart';
import 'teams/favorite_teams_page.dart';
import 'teams/teams_query_page.dart';

class BattleHomePage extends StatelessWidget {
  BattleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget body = getBody(context);
    if (!db.gameData.isValid) {
      body = GestureDetector(
        onTap: () {
          SimpleCancelOkDialog(
            title: Text(S.current.warning),
            content: Text(S.current.game_data_not_found),
            hideCancel: true,
          ).showDialog(context);
        },
        child: AbsorbPointer(
          child: Opacity(
            opacity: 0.5,
            child: body,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        toolbarHeight: kToolbarHeight,
        title: const Text('Laplace'),
      ),
      body: body,
    );
  }

  Widget getBody(BuildContext context) {
    return ListView(
      children: [
        TileGroup(
          header: "事象記録電脳魔・ラプラス",
          children: [
            ListTile(
              leading: const Icon(Icons.calculate),
              title: Text(S.current.battle_simulation),
              subtitle: const Text('3T Simulator'),
              // horizontalTitleGap: 0,
              onTap: () {
                router.push(url: Routes.laplace);
              },
            ),
            ListTile(
              leading: const Icon(Icons.radar),
              title: Text(S.current.np_damage),
              // horizontalTitleGap: 0,
              onTap: () {
                router.push(url: Routes.laplaceNpDmg);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: Text(S.current.laplace_my_teams),
              onTap: () {
                router.push(url: Routes.laplaceManageTeam);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(S.current.favorite_teams),
              onTap: () {
                router.push(child: const FavoriteTeamsPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.numbers),
              title: Text("${S.current.team} ID"),
              onTap: () {
                InputCancelOkDialog(
                  title: '${S.current.team} ID',
                  validate: (s) => (int.tryParse(s) ?? 0) > 0,
                  keyboardType: TextInputType.number,
                  onSubmit: (s) {
                    final id = int.tryParse(s);
                    if (id == null || id <= 0) return;
                    router.push(
                      url: Routes.laplaceManageTeam,
                      child: TeamsQueryPage(mode: TeamQueryMode.id, teamIds: [id]),
                    );
                  },
                ).showDialog(context);
              },
            ),
            if (AppInfo.isDebugDevice || db.settings.secrets.user?.isAdmin == true)
              ListTile(
                leading: const Icon(Icons.groups),
                title: const Text("???'s Teams"),
                onTap: () {
                  InputCancelOkDialog(
                    title: 'User ID or name',
                    validate: (s) => s.trim().isNotEmpty,
                    onSubmit: (value) {
                      router.push(
                        url: Routes.laplaceManageTeam,
                        child: TeamsQueryPage(mode: TeamQueryMode.user, userId: value),
                      );
                    },
                  ).showDialog(context);
                },
              ),
          ],
        ),
        TileGroup(
          header: "(O_O)?",
          children: [
            ListTile(
              title: Text(Language.isZH ? '常见问题/FAQ' : S.current.faq),
              leading: const Icon(Icons.question_answer),
              onTap: () {
                launch(ChaldeaUrl.laplace('faq'));
              },
            ),
            ListTile(
              title: const Text('Bugs'),
              leading: const Icon(Icons.bug_report),
              onTap: () {
                launch(ChaldeaUrl.laplace('bugs'));
              },
            ),
            ListTile(
              title: Text(S.current.about_feedback),
              leading: const Icon(Icons.message),
              onTap: () {
                router.pushPage(FeedbackPage());
              },
            ),
          ],
        ),
        const RandomImageSurprise(),
      ],
    );
  }
}
