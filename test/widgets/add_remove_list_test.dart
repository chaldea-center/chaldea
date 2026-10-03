import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:chaldea/widgets/add_remove_list.dart';

void main() {
  testWidgets('combines title and subtitle in one tile and supports add and remove', (tester) async {
    var added = false;
    int? removed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddRemoveList<int>(
            title: 'Servants',
            subtitle: '1 excluded · long press to remove',
            items: const [42],
            addTooltip: 'Add servant',
            onAdd: () => added = true,
            onRemove: (value) => removed = value,
            itemBuilder: (context, value, remove) => GestureDetector(onLongPress: remove, child: Text('Card $value')),
          ),
        ),
      ),
    );

    final titleTile = find.ancestor(of: find.text('Servants'), matching: find.byType(ListTile));
    expect(titleTile, findsOneWidget);
    expect(find.descendant(of: titleTile, matching: find.text('1 excluded · long press to remove')), findsOneWidget);
    expect(find.text('Card 42'), findsOneWidget);

    await tester.tap(find.byTooltip('Add servant'));
    expect(added, isTrue);
    await tester.longPress(find.text('Card 42'));
    expect(removed, 42);
  });
}
