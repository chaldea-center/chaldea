// ActionRow: a thin wrapper around InfoRow that defaults showChevron to
// true (action rows usually navigate) and maps ActionRowVariant.danger to
// InfoRow's danger flag for destructive actions like "Delete account".

import 'package:flutter/material.dart';

import 'info_row.dart';

enum ActionRowVariant { normal, danger }

class ActionRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final ActionRowVariant variant;
  final bool showChevron;
  final VoidCallback? onTap;

  const ActionRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.variant = ActionRowVariant.normal,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InfoRow(
      leading: leading,
      title: title,
      subtitle: subtitle,
      showChevron: showChevron,
      danger: variant == ActionRowVariant.danger,
      onTap: onTap,
    );
  }
}
