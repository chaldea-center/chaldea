// ModernScaffold: thin wrapper over Scaffold that reads colors from
// ModernThemeData and offers two body modes:
//  - `children:` — laid out in a ListView (lazy rendering, proper width
//    constraints). Use this for typical form/list pages.
//  - `body:` — a single widget placed as-is. Use this when the page needs
//    its own scroll controller or a Column with Expanded children.

import 'package:flutter/material.dart';

import 'modern_theme.dart';

class ModernScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final List<Widget>? children;
  final Widget? body;
  final EdgeInsets padding;

  const ModernScaffold({
    super.key,
    this.appBar,
    this.children,
    this.body,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : assert(children != null || body != null, 'Either children or body must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = ModernThemeData.of(context);
    final Widget content;
    if (body != null) {
      content = Padding(padding: padding, child: body!);
    } else {
      content = ListView(
        padding: padding.copyWith(top: 16, bottom: 24),
        children: children!,
      );
    }
    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: appBar,
      // When appBar is present, Scaffold positions body below it (top is
      // already safe). When absent, let SafeArea handle the top inset too.
      body: SafeArea(
        top: appBar == null,
        child: content,
      ),
    );
  }
}
