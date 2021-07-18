import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/feedback_page.dart';

class IssuesPage extends StatefulWidget {
  const IssuesPage({Key? key}) : super(key: key);

  @override
  _IssuesPageState createState() => _IssuesPageState();
}

class _IssuesPageState extends State<IssuesPage> {
  String? data;

  @override
  void initState() {
    super.initState();
    MarkdownHelpPage.loadHelpAsset(asset: 'common_issues.md').then((value) {
      data = value;
      if (mounted) setState(() {});
    }).catchError((e, s) {});
  }

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
            child: data == null
                ? Center(child: CircularProgressIndicator())
                : MyMarkdownWidget(data: data, selectable: true),
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
