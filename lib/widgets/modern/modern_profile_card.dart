// ModernProfileCard: simplified gradient-header card showing a title (e.g.
// username) and an optional subtitle (e.g. uid). Avatar circle removed —
// the profile page has no avatar feature. Gradient and foreground colors
// come from ModernThemeData so they can be restyled via ThemeData.

import 'package:flutter/material.dart';

import 'modern_theme.dart';

class ModernProfileCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ModernProfileCard({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = ModernThemeData.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.profileGradientStart, theme.profileGradientEnd],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.profileForeground,
                      ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.profileForeground.withAlpha(200),
                        ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
