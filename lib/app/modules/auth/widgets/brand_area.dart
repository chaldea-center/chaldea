// BrandArea: login page brand header — circular app icon + "Chaldea"
// wordmark + "FGO Game Helper" tagline. Per design.md D7, uses the project's
// existing app_icon_logo.png asset in place of the design's text "C" badge.

import 'package:flutter/material.dart';

class BrandArea extends StatelessWidget {
  const BrandArea({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        ClipOval(
          child: Image.asset('res/img/launcher_icon/app_icon_logo.png', width: 72, height: 72, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
        Text(
          'Chaldea',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
        const SizedBox(height: 4),
        Text('FGO Game Helper', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
