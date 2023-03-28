import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/builders.dart';
import '../home/subpage/feedback_page.dart';

class BattleHomePage extends StatelessWidget {
  BattleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        toolbarHeight: kToolbarHeight,
        title: const Text('Laplace'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Center(
            child: Text('Testing/测试中...'),
          ),
          const SizedBox(height: 8),
          TileGroup(
            footerWidget: SFooter.rich(TextSpan(children: [
              const TextSpan(text: 'Bug? '),
              SharedBuilder.textButtonSpan(
                context: context,
                text: S.current.about_feedback,
                onTap: () => router.pushPage(FeedbackPage()),
              ),
              const TextSpan(text: '!'),
            ])),
            children: [
              ListTile(
                leading: const Icon(Icons.calculate),
                title: Text(S.current.battle_simulation),
                // horizontalTitleGap: 0,
                onTap: () {
                  router.push(url: Routes.laplace);
                },
              ),
              const ListTile(
                enabled: false,
                leading: Icon(Icons.snowing),
                title: Text('· · ·'),
              )
            ],
          )
        ],
      ),
    );
  }
}
