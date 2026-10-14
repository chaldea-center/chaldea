import 'package:material_ui/material_ui.dart';

class MiniBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;

  const MiniBadge({super.key, required this.label, this.color, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = color ?? cs.primary;
    final bg = backgroundColor ?? fg.withAlpha(30);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg, height: 1.2),
      ),
    );
  }
}
