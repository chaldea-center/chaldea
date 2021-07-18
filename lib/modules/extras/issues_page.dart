import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/feedback_page.dart';

class IssuesPage extends StatelessWidget {
  const IssuesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        titleSpacing: 0,
        title: Text('FAQ'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String?>(
              future: MarkdownHelpPage.loadHelpAsset(asset: 'common_issues.md'),
              builder: (context, snapshot) {
                return MyMarkdownWidget(
                  data: snapshot.data ?? '',
                  selectable: true,
                );
              },
            ),
          ),
          kDefaultDivider,
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  SplitRoute.push(
                    context: context,
                    builder: (ctx, _) => FeedbackPage(),
                  );
                },
                child: Text(S.current.about_feedback),
              )
            ],
          ),
        ],
      ),
    );
  }
}
