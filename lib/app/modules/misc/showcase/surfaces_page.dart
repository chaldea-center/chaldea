import 'package:flutter/material.dart';

import 'package:chaldea/widgets/theme.dart';

class SurfacesPage extends StatelessWidget {
  const SurfacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surfaces & Layout')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          final lightCol = Expanded(
            child: Theme(
              data: AppTheme.light(),
              child: const _SurfacesContent(modeLabel: 'Light'),
            ),
          );
          final darkCol = Expanded(
            child: Theme(
              data: AppTheme.dark(),
              child: const _SurfacesContent(modeLabel: 'Dark'),
            ),
          );
          return SingleChildScrollView(
            child: isWide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [lightCol, darkCol])
                : Column(
                    children: [
                      SizedBox(height: 600, child: lightCol),
                      const Divider(thickness: 2),
                      SizedBox(height: 600, child: darkCol),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _SurfacesContent extends StatelessWidget {
  final String modeLabel;
  const _SurfacesContent({required this.modeLabel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(modeLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // Elevated Card
          Card(
            color: cs.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Elevated Card', style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    'surfaceContainerLowest bg + outlineVariant border',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filled Card
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filled Card', style: Theme.of(context).textTheme.titleMedium),
                  Text('surfaceContainerHighest bg', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Outlined Card
          Card(
            color: cs.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outlined Card', style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    'surface bg + outlineVariant border (from cardTheme)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // SearchBar placeholder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: AppShape.full),
            child: Row(
              children: [
                Icon(Icons.search, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Text('Search...', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAB
          Align(
            alignment: Alignment.centerLeft,
            child: FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('FAB'),
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Divider', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.outline)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),

          // Badge
          Badge(
            backgroundColor: cs.error,
            textColor: cs.onError,
            label: const Text('3'),
            child: const Icon(Icons.notifications, size: 32),
          ),

          const SizedBox(height: 24),

          // BottomNav (static demo)
          Container(
            decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: AppShape.medium),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, Icons.home_outlined, 'Home', selected: true),
                _navItem(context, Icons.search_outlined, 'Search'),
                _navItem(context, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, {bool selected = false}) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}
