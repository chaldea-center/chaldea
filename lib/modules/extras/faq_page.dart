import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/feedback_page.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

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
              future: MarkdownHelpPage.loadHelpAsset(
                  asset: 'FAQ.md', lapse: kSplitRouteDuration),
              builder: (context, snapshot) {
                return snapshot.data == null
                    ? Center(child: CircularProgressIndicator())
                    : MyMarkdownWidget(
                        data: snapshot.data ?? '', selectable: true);
              },
            ),
          ),
          kDefaultDivider,
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  SplitRoute.push(context, FeedbackPage());
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
