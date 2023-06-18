import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../packages/language.dart';
import '../home/elements/random_image.dart';
import '../home/subpage/feedback_page.dart';

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
        const SizedBox(height: 8),
        const Center(
          child: Text('Testing/测试中...'),
        ),
        const SizedBox(height: 8),
        TileGroup(
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
              title: Text(S.current.manage_uploaded_teams),
              onTap: () {
                router.push(url: Routes.laplaceManageTeam);
              },
            ),
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
