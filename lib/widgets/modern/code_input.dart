// CodeInput: N-cell OTP input. Auto-advances on input, retreats on
// backspace, and distributes pasted digits across cells. Exposes the
// concatenated value via [onChanged].

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const CodeInput({super.key, this.length = 6, this.onChanged, this.autofocus = true});

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<String> _values;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode(onKeyEvent: _onKey));
    _values = List.generate(widget.length, (_) => '');
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _focusNodes.first.requestFocus() : null);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _concat() => _values.join();

  void _notify() => widget.onChanged?.call(_concat());

  void _onChanged(int index, String value) {
    // Handle paste: if the user pastes a multi-char string into one cell,
    // distribute the digits across all cells starting from `index`.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^\d]'), '');
      for (var i = 0; i < digits.length && (index + i) < widget.length; i++) {
        _values[index + i] = digits[i];
        _controllers[index + i].text = digits[i];
      }
      final lastFilled = (index + digits.length - 1).clamp(0, widget.length - 1);
      final nextEmpty = _values.indexWhere((v) => v.isEmpty);
      final target = nextEmpty == -1 ? lastFilled : nextEmpty.clamp(0, widget.length - 1);
      _focusNodes[target].requestFocus();
      _notify();
      return;
    }
    _values[index] = value;
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _notify();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final index = _focusNodes.indexOf(node);
    if (index < 0) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_values[index].isEmpty && index > 0) {
        _values[index - 1] = '';
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        _notify();
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // Input fill/border colors come from ThemeData (inputDecorationTheme +
    // colorScheme) since AppThemeData no longer carries input fields.
    final themeData = Theme.of(context);
    final cs = themeData.colorScheme;
    return Row(
      spacing: 8,
      children: [
        for (var i = 0; i < widget.length; i++)
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: themeData.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: themeData.inputDecorationTheme.fillColor ?? cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: cs.primary, width: 1.5),
                  ),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            ),
          ),
      ],
    );
  }
}
