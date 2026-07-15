import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/widgets/modern/input.dart';
import 'package:chaldea/widgets/theme.dart';

void main() {
  Future<void> pumpInput(WidgetTester tester, FormInput input) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: input),
      ),
    );
  }

  testWidgets('renders label above field', (tester) async {
    await pumpInput(tester, FormInput(label: 'Username', validator: (_) => null));
    expect(find.text('Username'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('passes controller to TextFormField', (tester) async {
    final controller = TextEditingController(text: 'hello');
    await pumpInput(tester, FormInput(controller: controller, validator: (_) => null));
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller, same(controller));
  });

  testWidgets('obscureText passes through', (tester) async {
    await pumpInput(tester, FormInput(label: 'Password', obscure: true, validator: (_) => null));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
  });

  testWidgets('error hidden before blur in onBlur mode', (tester) async {
    final controller = TextEditingController(text: 'bad');
    await pumpInput(
      tester,
      FormInput(
        controller: controller,
        validator: (v) => v == 'bad' ? 'Invalid input' : null,
        errorDisplayMode: ErrorDisplayMode.onBlur,
      ),
    );
    expect(find.text('Invalid input'), findsNothing);
  });

  testWidgets('error displays after blur in onBlur mode', (tester) async {
    final controller = TextEditingController(text: 'bad');
    final focusNode = FocusNode();
    await pumpInput(
      tester,
      FormInput(
        controller: controller,
        focusNode: focusNode,
        validator: (v) => v == 'bad' ? 'Invalid input' : null,
        errorDisplayMode: ErrorDisplayMode.onBlur,
      ),
    );
    // Focus then blur to trigger touched state
    focusNode.requestFocus();
    await tester.pump();
    focusNode.unfocus();
    await tester.pump();
    expect(find.text('Invalid input'), findsOneWidget);
  });

  testWidgets('error displays when forceShowError is true', (tester) async {
    final controller = TextEditingController(text: 'bad');
    await pumpInput(
      tester,
      FormInput(
        controller: controller,
        validator: (v) => v == 'bad' ? 'Invalid input' : null,
        errorDisplayMode: ErrorDisplayMode.onSubmit,
        forceShowError: true,
      ),
    );
    expect(find.text('Invalid input'), findsOneWidget);
  });

  testWidgets('error updates on change after blur', (tester) async {
    final controller = TextEditingController(text: 'bad');
    final focusNode = FocusNode();
    await pumpInput(
      tester,
      FormInput(
        controller: controller,
        focusNode: focusNode,
        validator: (v) => v == 'bad' ? 'Invalid input' : null,
        errorDisplayMode: ErrorDisplayMode.onBlur,
      ),
    );
    // Blur to mark touched
    focusNode.requestFocus();
    await tester.pump();
    focusNode.unfocus();
    await tester.pump();
    expect(find.text('Invalid input'), findsOneWidget);
    // Change to valid value — error should clear
    controller.text = 'good';
    await tester.pump();
    expect(find.text('Invalid input'), findsNothing);
  });
}
