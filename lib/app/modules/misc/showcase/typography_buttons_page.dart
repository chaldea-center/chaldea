import 'package:flutter/material.dart';

import 'package:chaldea/widgets/theme.dart';

class TypographyButtonsPage extends StatelessWidget {
  const TypographyButtonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typography & Buttons')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          final lightCol = Expanded(
            child: Theme(
              data: AppTheme.light(),
              child: const _TypographyButtonsContent(modeLabel: 'Light'),
            ),
          );
          final darkCol = Expanded(
            child: Theme(
              data: AppTheme.dark(),
              child: const _TypographyButtonsContent(modeLabel: 'Dark'),
            ),
          );
          return SingleChildScrollView(
            child: isWide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [lightCol, darkCol])
                : Column(
                    children: [
                      SizedBox(height: 800, child: lightCol),
                      const Divider(thickness: 2),
                      SizedBox(height: 800, child: darkCol),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _TypographyButtonsContent extends StatelessWidget {
  final String modeLabel;
  const _TypographyButtonsContent({required this.modeLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = AppTheme.ofExtra(context).accent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(modeLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          // === MD3 Type Scale ===
          _sectionLabel(context, 'Type Scale'),
          Text('Display Large', style: theme.textTheme.displayLarge),
          Text('Display Medium', style: theme.textTheme.displayMedium),
          Text('Display Small', style: theme.textTheme.displaySmall),
          Text('Headline Large', style: theme.textTheme.headlineLarge),
          Text('Headline Medium', style: theme.textTheme.headlineMedium),
          Text('Headline Small', style: theme.textTheme.headlineSmall),
          Text('Title Large', style: theme.textTheme.titleLarge),
          Text('Title Medium', style: theme.textTheme.titleMedium),
          Text('Title Small', style: theme.textTheme.titleSmall),
          Text('Body Large', style: theme.textTheme.bodyLarge),
          Text('Body Medium', style: theme.textTheme.bodyMedium),
          Text('Body Small', style: theme.textTheme.bodySmall),
          Text('Label Large', style: theme.textTheme.labelLarge),
          Text('Label Medium', style: theme.textTheme.labelMedium),
          Text('Label Small', style: theme.textTheme.labelSmall),
          const SizedBox(height: 24),

          // === Text Color Variants ===
          _sectionLabel(context, 'Text Colors'),
          Text('onSurface (default)', style: theme.textTheme.bodyLarge),
          Text('onSurfaceVariant', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          Text('outline', style: theme.textTheme.bodyLarge?.copyWith(color: cs.outline)),
          Text('primary', style: theme.textTheme.bodyLarge?.copyWith(color: cs.primary)),
          Text('error', style: theme.textTheme.bodyLarge?.copyWith(color: cs.error)),
          Text('accent (Lv6/Lv10 highlight)', style: theme.textTheme.bodyLarge?.copyWith(color: accent)),
          const SizedBox(height: 24),

          // === Buttons ===
          _sectionLabel(context, 'Buttons'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              TextButton(onPressed: () {}, child: const Text('Text')),
              IconButton(onPressed: () {}, icon: const Icon(Icons.star)),
            ],
          ),
          const SizedBox(height: 16),

          // Disabled states
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: null, child: const Text('Filled (disabled)')),
              OutlinedButton(onPressed: null, child: const Text('Outlined (disabled)')),
              ElevatedButton(onPressed: null, child: const Text('Elevated (disabled)')),
              TextButton(onPressed: null, child: const Text('Text (disabled)')),
            ],
          ),
          const SizedBox(height: 24),

          // === TextField States ===
          _sectionLabel(context, 'TextField States'),
          const TextField(
            decoration: InputDecoration(labelText: 'Enabled', hintText: 'Type here...'),
          ),
          const SizedBox(height: 12),
          const TextField(
            autofocus: false,
            decoration: InputDecoration(labelText: 'Focused (simulate)', hintText: 'Type here...'),
          ),
          const SizedBox(height: 12),
          const TextField(
            enabled: false,
            decoration: InputDecoration(labelText: 'Disabled', hintText: 'Cannot edit'),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(labelText: 'Error', errorText: 'Error message', hintText: 'Type here...'),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
