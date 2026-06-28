// ModernAppBar: 56px app bar with optional back button. Uses Material (not
// Container) for the background so IconButton's hover/splash ink paints ON
// TOP of the bar color — fixing the original bug where the hover circle was
// hidden behind the Container decoration. Colors and height come from
// ModernThemeData.

import 'package:flutter/material.dart';

import 'modern_theme.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const ModernAppBar({super.key, required this.title, this.showBack = true, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = ModernThemeData.of(context);
    return Material(
      color: theme.appBarBackground,
      child: SizedBox(
        height: theme.appBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: NavigationToolbar(
            leading: showBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: theme.appBarForeground,
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  )
                : null,
            middle: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.appBarForeground,
                  ),
            ),
            trailing: actions == null ? null : Row(mainAxisSize: MainAxisSize.min, children: actions!),
          ),
        ),
      ),
    );
  }
}
