import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/widgets/modern/section_card.dart';
import 'package:chaldea/widgets/theme.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, SectionCard card) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: card),
      ),
    );
  }

  testWidgets('renders title when provided', (tester) async {
    await pumpCard(tester, const SectionCard(title: 'Account Info', children: [Text('row1')]));
    expect(find.text('Account Info'), findsOneWidget);
    expect(find.text('row1'), findsOneWidget);
  });

  testWidgets('omits title when null', (tester) async {
    await pumpCard(tester, const SectionCard(children: [Text('only row')]));
    expect(find.byType(Text), findsOneWidget);
    expect(find.text('only row'), findsOneWidget);
  });

  testWidgets('divided=true inserts Divider between children', (tester) async {
    await pumpCard(tester, const SectionCard(divided: true, children: [Text('a'), Text('b'), Text('c')]));
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('divided=false inserts no dividers', (tester) async {
    await pumpCard(tester, const SectionCard(divided: false, children: [Text('a'), Text('b')]));
    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('renders inside a Card', (tester) async {
    await pumpCard(tester, const SectionCard(children: [Text('x')]));
    expect(find.byType(Card), findsOneWidget);
  });
}
