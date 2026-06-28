import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chaldea/widgets/modern/action_row.dart';
import 'package:chaldea/widgets/theme.dart';

void main() {
  Future<void> pumpRow(WidgetTester tester, ActionRow row) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: row),
      ),
    );
  }

  testWidgets('renders leading, title, subtitle, chevron by default', (tester) async {
    await pumpRow(
      tester,
      const ActionRow(
        leading: Icon(Icons.settings),
        title: 'Settings',
        subtitle: 'Configure',
      ),
    );
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Configure'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('hides chevron when showChevron=false', (tester) async {
    await pumpRow(
      tester,
      const ActionRow(title: 'T', showChevron: false),
    );
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('danger variant colors title with error', (tester) async {
    await pumpRow(
      tester,
      const ActionRow(title: 'Delete', variant: ActionRowVariant.danger),
    );
    final titleWidget = tester.widget<Text>(find.text('Delete'));
    expect(titleWidget.style?.color, AppTheme.light().colorScheme.error);
  });

  testWidgets('onTap invokes callback', (tester) async {
    var tapped = 0;
    await pumpRow(
      tester,
      ActionRow(title: 'T', onTap: () => tapped++),
    );
    await tester.tap(find.byType(ActionRow));
    expect(tapped, 1);
  });
}
