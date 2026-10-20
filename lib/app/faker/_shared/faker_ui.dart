import 'package:material_ui/material_ui.dart';

/// Bottom action bar shared by faker pages.
///
/// Each entry of [groups] becomes one centered row, stacked top-down, so callers
/// list secondary tools first and the primary action last to keep it nearest the
/// thumb. Empty groups are skipped, and [message] renders above all rows.
class FakerActionBar extends StatelessWidget {
  final List<List<Widget>> groups;

  /// Transient line above the rows, e.g. the progress toast.
  final Widget? message;

  const FakerActionBar({super.key, required this.groups, this.message});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?message,
          for (final btns in groups)
            if (btns.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: btns,
                ),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Merges one row metric onto every faker list tile so switch, checkbox and
/// plain tiles share a single height across all faker pages.
class FakerTileTheme extends StatelessWidget {
  final Widget child;

  const FakerTileTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListTileTheme.merge(
      dense: true,
      minLeadingWidth: 24,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}
