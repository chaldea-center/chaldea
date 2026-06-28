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
    await pumpInput(tester, const FormInput(label: 'Username'));
    expect(find.text('Username'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('passes controller and validator to TextFormField', (tester) async {
    final controller = TextEditingController(text: 'hello');
    String? validatedValue;
    await pumpInput(
      tester,
      FormInput(
        controller: controller,
        validator: (v) {
          validatedValue = v;
          return null;
        },
      ),
    );
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller, same(controller));
    field.validator?.call('test');
    expect(validatedValue, 'test');
  });

  testWidgets('obscureText passes through', (tester) async {
    await pumpInput(tester, const FormInput(label: 'Password', obscure: true));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
  });

  testWidgets('errorText displays when set', (tester) async {
    await pumpInput(tester, const FormInput(label: 'Email', errorText: 'Invalid email'));
    expect(find.text('Invalid email'), findsOneWidget);
  });
}
