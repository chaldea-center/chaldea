import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../home/subpage/feedback_page.dart';

class FAQPage extends StatelessWidget {
  FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('FAQ'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String?>(
              future: MarkdownHelpPage.loadHelpAsset(
                  asset: 'FAQ.md', lapse: kSplitRouteDuration),
              builder: (context, snapshot) {
                return snapshot.data == null
                    ? const Center(child: CircularProgressIndicator())
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
