import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/trait/trait_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class TraitEditPage extends StatefulWidget {
  final List<NiceTrait> traits;
  final ValueChanged<List<NiceTrait>> onChanged;

  const TraitEditPage({super.key, required this.traits, required this.onChanged});

  @override
  State<TraitEditPage> createState() => _TraitEditPageState();
}

class _TraitEditPageState extends State<TraitEditPage> {
  late final traits = widget.traits.toList()..sort2((e) => e.id);
  bool hasEdit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('[${S.current.edit}] ${S.current.trait}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: traits.length,
              itemBuilder: itemBuilder,
              separatorBuilder: (context, index) => kDefaultDivider,
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: OverflowBar(
              alignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    router.pushPage(
                      TraitListPage(
                        onSelected: (value) {
                          if (value != 0) {
                            hasEdit = true;
                            traits.removeWhere((e) => e.id == value);
                            traits.add(NiceTrait(id: value));
                            traits.sort2((e) => e.id);
                          }
                          if (mounted) setState(() {});
                        },
                      ),
                    );
                  },
                  child: Text(S.current.add),
                ),
                FilledButton(
                  onPressed:
                      hasEdit
                          ? () {
                            widget.onChanged(traits);
                            Navigator.pop(context);
                          }
                          : null,
                  child: Text(S.current.confirm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    final trait = traits[index];
    return ListTile(
      dense: true,
      title: Text(Transl.trait(trait.id).l),
      subtitle: Text(trait.signedId.toString()),
      trailing: IconButton(
        onPressed: () {
          setState(() {
            hasEdit = true;
            traits.remove(trait);
          });
        },
        icon: const Icon(Icons.clear),
        tooltip: S.current.remove,
        color: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }
}
