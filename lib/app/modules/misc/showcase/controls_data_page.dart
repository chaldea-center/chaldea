import 'package:flutter/material.dart';

import 'package:chaldea/widgets/theme.dart';

class ControlsDataPage extends StatelessWidget {
  const ControlsDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controls & Data')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          final lightCol = Expanded(
            child: Theme(data: AppTheme.light(), child: const _ControlsDataContent(modeLabel: 'Light')),
          );
          final darkCol = Expanded(
            child: Theme(data: AppTheme.dark(), child: const _ControlsDataContent(modeLabel: 'Dark')),
          );
          return SingleChildScrollView(
            child: isWide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [lightCol, darkCol])
                : Column(children: [
                    SizedBox(height: 1000, child: lightCol),
                    const Divider(thickness: 2),
                    SizedBox(height: 1000, child: darkCol),
                  ]),
          );
        },
      ),
    );
  }
}

class _ControlsDataContent extends StatefulWidget {
  final String modeLabel;
  const _ControlsDataContent({required this.modeLabel});

  @override
  State<_ControlsDataContent> createState() => _ControlsDataContentState();
}

class _ControlsDataContentState extends State<_ControlsDataContent> {
  bool _checkbox = true;
  bool _switch = true;
  int _radio = 0;
  double _slider = 0.5;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.modeLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          _sectionLabel(context, 'Checkbox / Radio / Switch'),
          CheckboxListTile(
            value: _checkbox,
            onChanged: (v) => setState(() => _checkbox = v ?? false),
            title: const Text('Checkbox'),
          ),
          RadioListTile<int>(
            value: 0,
            groupValue: _radio,
            onChanged: (v) => setState(() => _radio = v ?? 0),
            title: const Text('Radio 0'),
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: _radio,
            onChanged: (v) => setState(() => _radio = v ?? 1),
            title: const Text('Radio 1'),
          ),
          SwitchListTile(
            value: _switch,
            onChanged: (v) => setState(() => _switch = v),
            title: const Text('Switch'),
          ),
          const SizedBox(height: 16),

          _sectionLabel(context, 'Slider'),
          Slider(
            value: _slider,
            onChanged: (v) => setState(() => _slider = v),
          ),
          const SizedBox(height: 16),

          _sectionLabel(context, 'Progress'),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),

          _sectionLabel(context, 'TabBar'),
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: const [Tab(text: 'A'), Tab(text: 'B'), Tab(text: 'C')],
                  onTap: (i) => setState(() => _tabIndex = i),
                ),
                SizedBox(
                  height: 80,
                  child: TabBarView(
                    children: [
                      Center(child: Text('Tab A content (index $_tabIndex)')),
                      Center(child: Text('Tab B content')),
                      Center(child: Text('Tab C content')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _sectionLabel(context, 'Chips'),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(label: const Text('Filter'), selected: true, onSelected: (_) {}),
              ActionChip(label: const Text('Action'), onPressed: () {}),
              InputChip(label: const Text('Input'), onDeleted: () {}),
              const Chip(label: Text('Assist')),
            ],
          ),
          const SizedBox(height: 16),

          _sectionLabel(context, 'DataTable'),
          DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Value')),
            ],
            rows: const [
              DataRow(cells: [DataCell(Text('Alpha')), DataCell(Text('1'))]),
              DataRow(cells: [DataCell(Text('Beta')), DataCell(Text('2'))]),
              DataRow(cells: [DataCell(Text('Gamma')), DataCell(Text('3'))]),
            ],
          ),
          const SizedBox(height: 16),

          _sectionLabel(context, 'Dialog / Snackbar / BottomSheet'),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Dialog'),
                    content: const Text('Dialog content'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                  ),
                ),
                child: const Text('Dialog'),
              ),
              OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Snackbar content')),
                ),
                child: const Text('Snackbar'),
              ),
              OutlinedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => const SizedBox(height: 200, child: Center(child: Text('BottomSheet'))),
                ),
                child: const Text('BottomSheet'),
              ),
            ],
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
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
