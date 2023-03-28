import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../skill/skill_list.dart';

class AddExtraPassivePage extends StatefulWidget {
  final PlayerSvtData svtData;
  const AddExtraPassivePage({super.key, required this.svtData});

  @override
  State<AddExtraPassivePage> createState() => _AddExtraPassivePageState();
}

class _AddExtraPassivePageState extends State<AddExtraPassivePage> with SingleTickerProviderStateMixin {
  PlayerSvtData get svtData => widget.svtData;

  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.add_skill),
        bottom: FixedHeight.tabBar(TabBar(controller: _tabController, tabs: [
          const Tab(text: 'ID'),
          Tab(text: S.current.general_custom),
        ])),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [fromDBTab, customSkillTab],
      ),
    );
  }

  Widget get fromSvtTab {
    final skills = svtData.svt?.extraPassive ?? [];
    List<Widget> children = [];
    for (final skill in skills) {
      final hasAdded = svtData.extraPassives.any((s) => s.id == skill.id);
      children.add(Row(
        children: [
          Expanded(
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsetsDirectional.only(start: 16),
              leading: db.getIconImage(skill.icon ?? Atlas.common.emptySkillIcon, width: 32, aspectRatio: 1),
              title: Text(
                skill.lName.l,
                style: hasAdded ? TextStyle(color: Theme.of(context).disabledColor) : null,
              ),
              subtitle:
                  Text(skill.lDetail ?? '???', textScaleFactor: 0.85, maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () {
                skill.routeTo();
              },
            ),
          ),
          IconButton(
            onPressed: hasAdded
                ? null
                : () {
                    svtData.addCustomPassive(skill, skill.maxLv);
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.add),
            color: Theme.of(context).colorScheme.secondary,
            tooltip: S.current.add,
          ),
        ],
      ));
    }
    return ListView(children: children);
  }

  Widget get fromDBTab {
    return ListView(
      children: [
        ListTile(
          title: const Text('Skill List'),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            router.pushPage(SkillListPage(
              onSelected: (skill, skillId) async {
                if (skill == null && skillId != null && skillId > 0) {
                  EasyLoading.show();
                  skill = await AtlasApi.skill(skillId);
                  EasyLoading.dismiss();
                  if (skill == null) {
                    EasyLoading.showError(S.current.not_found);
                  }
                }
                if (skill != null) {
                  svtData.addCustomPassive(skill, skill.maxLv);
                  if (mounted) Navigator.pop(context);
                }
              },
            ));
          },
        ),
        const SFooter('Input skillId in search box to fetch skill which is not saved in local'),
      ],
    );
  }

  final BaseSkill _customSkill = BaseSkill.create(
    id: 100000000 + DateTime.now().timestamp % 100000000,
    name: '${S.current.general_custom} ${S.current.skill}',
    type: SkillType.passive,
    functions: [],
  );

  Widget get customSkillTab {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        ListTile(title: const Text('ID'), trailing: Text(_customSkill.id.toString())),
        ListTile(
          title: const Text('Name'),
          trailing: SizedBox(
            width: 180,
            child: TextFormField(
              initialValue: _customSkill.name,
              decoration: const InputDecoration(isDense: true),
              textAlign: TextAlign.center,
              onChanged: (s) {
                if (s.isNotEmpty) _customSkill.name = s;
              },
            ),
          ),
        ),
        const ListTile(
          title: Text('TODO'),
        ),
      ],
    );
  }

  final Map<NiceFunction, TextEditingController> _controllers = {};

  Widget buildEffect(_EffectType type, NiceFunction func, String name, int base, bool isPercent) {
    final controller = _controllers.putIfAbsent(func, () => TextEditingController(text: '0'));
    return ListTile(
      leading: db.getIconImage(func.buff?.icon, width: 24),
      title: Text(name),
      subtitle: Text(type.name),
      trailing: Wrap(
        children: [
          TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {},
          ),
          SizedBox(
            width: 20,
            child: Text(isPercent ? '%' : ''),
          )
        ],
      ),
    );
  }

  int? convertValue(_EffectType type, String s) {
    switch (type) {
      case _EffectType.gainNp:
      case _EffectType.upDamage:
      case _EffectType.upAtk:
      case _EffectType.upNpDamage:
      case _EffectType.upChargeTd:
      case _EffectType.upQuick:
      case _EffectType.upArts:
      case _EffectType.upBuster:
      case _EffectType.upExtra:
      case _EffectType.upDropNp:
      case _EffectType.upCritical:
        return ((double.tryParse(s) ?? 0) * 10).toInt();
      case _EffectType.breakAvoidance:
      case _EffectType.pierceInvincible:
        return null;
    }
  }
}

enum _EffectType {
  gainNp,
  upDamage,
  upAtk,
  upNpDamage,
  upChargeTd,
  upQuick,
  upArts,
  upBuster,
  upExtra,
  upDropNp,
  upCritical,
  breakAvoidance,
  pierceInvincible,
  ;
}
