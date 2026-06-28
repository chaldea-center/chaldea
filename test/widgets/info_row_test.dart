import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/widgets/modern/info_row.dart';
import 'package:chaldea/widgets/theme.dart';

void main() {
  Future<void> pumpRow(WidgetTester tester, InfoRow row) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: row),
      ),
    );
  }

  testWidgets('renders leading, title, value', (tester) async {
    await pumpRow(tester, const InfoRow(leading: Icon(Icons.person), title: 'Username', value: 'alice'));
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
  });

  testWidgets('renders subtitle when provided', (tester) async {
    await pumpRow(tester, const InfoRow(title: 'T', subtitle: 'sub text'));
    expect(find.text('T'), findsOneWidget);
    expect(find.text('sub text'), findsOneWidget);
  });

  testWidgets('shows chevron when showChevron=true', (tester) async {
    await pumpRow(tester, const InfoRow(title: 'T', showChevron: true));
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('hides chevron by default', (tester) async {
    await pumpRow(tester, const InfoRow(title: 'T'));
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('onTap invokes callback', (tester) async {
    var tapped = 0;
    await pumpRow(tester, InfoRow(title: 'T', onTap: () => tapped++));
    await tester.tap(find.byType(InfoRow));
    expect(tapped, 1);
  });

  testWidgets('prominence.title makes title large + subtitle small (default)', (tester) async {
    await pumpRow(tester, const InfoRow(title: 'TitleText', subtitle: 'SubText'));
    final titleWidget = tester.widget<Text>(find.text('TitleText'));
    final subWidget = tester.widget<Text>(find.text('SubText'));
    expect(titleWidget.style?.fontSize, greaterThan(subWidget.style!.fontSize!));
    expect(titleWidget.style?.fontWeight, FontWeight.w400);
  });

  testWidgets('prominence.subtitle inverts title/subtitle sizing', (tester) async {
    await pumpRow(tester, const InfoRow(title: 'Label', subtitle: 'ValueBig', prominence: InfoRowProminence.subtitle));
    final titleWidget = tester.widget<Text>(find.text('Label'));
    final subWidget = tester.widget<Text>(find.text('ValueBig'));
    expect(subWidget.style?.fontSize, greaterThan(titleWidget.style!.fontSize!));
    expect(subWidget.style?.fontWeight, FontWeight.w400);
  });
}
