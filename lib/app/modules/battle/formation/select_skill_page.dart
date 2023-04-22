import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/skill/skill_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SkillSelectPage extends StatefulWidget {
  final SkillType? skillType;
  final ValueChanged<BaseSkill> onSelected;
  const SkillSelectPage({super.key, required this.skillType, required this.onSelected});

  @override
  State<SkillSelectPage> createState() => _SkillSelectPageState();
}

class _EffectData {
  BaseFunction func;
  int turn = -1;
  int count = -1;
  int rate = 5000;

  int value = 0;
  bool enabled = false; // for no value
  bool hasValue = true;

  FuncTargetType target = FuncTargetType.self;

  _EffectData(this.func);
  final controller = TextEditingController();

  static const usedTargetTypes = <FuncTargetType>[
    FuncTargetType.self,
    FuncTargetType.ptOne,
    FuncTargetType.ptAll,
    FuncTargetType.ptFull,
    FuncTargetType.enemy,
    FuncTargetType.enemyAll,
  ];
}

class _SkillSelectPageState extends State<SkillSelectPage> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);
  late final _skillIdController = TextEditingController();

  final List<_EffectData> _effects = [];

  @override
  void initState() {
    super.initState();

    BaseFunction? _addState(int funcId, int buffId) {
      final buff = db.gameData.baseBuffs[buffId];
      if (buff == null) return null;
      return BaseFunction.create(
        funcId: funcId,
        funcType: FuncType.addStateShort,
        funcTargetType: FuncTargetType.self,
        funcPopupText: buff.name,
        funcPopupIcon: buff.icon,
        buffs: [buff],
      );
    }

    final funcList = <BaseFunction?>[
      const BaseFunction.create(
        funcId: -460,
        funcType: FuncType.gainNp,
        funcTargetType: FuncTargetType.self,
        funcPopupText: 'NP増加',
      ),
      _addState(-1077, 129), // upDamage
      _addState(-146, 126), // upAtk
      _addState(-247, 138), // upNpDamage
      _addState(-753, 227), // upChargeTd
      _addState(-100, 100), // upQuick
      _addState(-109, 101), // upArts
      _addState(-118, 102), // upBuster
      // _addState(funcId, buffId),// upExtra
      _addState(-336, 140), // upDropNp
      _addState(-199, 142), // upCriticaldamage
      _addState(-288, 154), // breakAvoidance
      _addState(-510, 189), // pierceInvincible
    ];
    for (final func in funcList) {
      if (func == null) continue;
      final effect = _EffectData(func);
      if ([BuffType.breakAvoidance, BuffType.pierceInvincible].contains(func.buff?.type)) {
        effect.hasValue = false;
      }
      _effects.add(effect);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _skillIdController.dispose();
    for (final effect in _effects) {
      effect.controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = S.current.select_skill;
    if (widget.skillType != null) {
      title += '(${widget.skillType!.shortName})';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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

  Widget get fromDBTab {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextFormField(
            controller: _skillIdController,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              hintText: '969756 ${S.current.logic_type_or} **/JP/skill/969756'.breakWord,
              labelText: 'skillId ${S.current.logic_type_or} chaldea/AADB skill url',
              hintStyle: const TextStyle(overflow: TextOverflow.visible),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ),
        Center(
          child: ElevatedButton(
              onPressed: () async {
                final result = Atlas.resolveRegionInt(_skillIdController.text.trim());
                final region = result.item1;
                final skillId = result.item2;

                if (skillId == null) {
                  EasyLoading.showError(S.current.invalid_input);
                  return;
                }
                await loadSkill(null, skillId, region);
              },
              child: Text(S.current.search)),
        ),
        const Divider(),
        ListTile(
          title: const Text('Skill List'),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            router.pushPage(SkillListPage(
              onSelected: (skill, skillId) => loadSkill(skill, skillId, Region.jp),
            ));
          },
        ),
      ],
    );
  }

  Future<void> loadSkill(BaseSkill? skill, int? skillId, Region region) async {
    if (skill == null && skillId != null && skillId > 0) {
      EasyLoading.show();
      skill = await AtlasApi.skill(skillId);
      EasyLoading.dismiss();
      if (skill == null) {
        EasyLoading.showError(S.current.not_found);
      }
    }
    if (skill != null) {
      skill = BaseSkill.fromJson(skill.toJson());
      if (widget.skillType != null) skill.type = widget.skillType!;
      widget.onSelected(skill);
      if (mounted) Navigator.pop(context);
    }
    if (mounted) setState(() {});
  }

  late final BaseSkill _customSkill = BaseSkill.create(
    id: -(100000000 + DateTime.now().timestamp % 100000000),
    name: '',
    type: widget.skillType ?? SkillType.active,
    functions: [],
  );

  Widget get customSkillTab {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              ListTile(dense: true, title: const Text('ID'), trailing: Text(_customSkill.id.toString())),
              ListTile(
                dense: true,
                title: const Text('Name'),
                trailing: SizedBox(
                  width: 120,
                  child: TextFormField(
                    initialValue: _customSkill.name,
                    decoration: const InputDecoration(isDense: true),
                    textAlign: TextAlign.center,
                    onChanged: (s) {
                      if (s.trim().isNotEmpty) _customSkill.name = s.trim();
                    },
                  ),
                ),
              ),
              for (final effect in _effects) buildFunc(effect),
            ],
          ),
        ),
        kDefaultDivider,
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
              child: FilledButton(
                onPressed: createCustomSkill,
                child: Text(S.current.add),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildFunc(_EffectData effect) {
    final func = effect.func;
    int? percentBase = func.buff?.percentBase ?? kFuncValPercentType[func.funcType];
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          leading: func.funcPopupIcon == null ? null : db.getIconImage(func.funcPopupIcon, width: 24),
          title: Text(func.lPopupText.l),
          horizontalTitleGap: 8,
          subtitle: Text(<String>[
            if (effect.count > 0) Transl.special.funcValCountTimes(effect.count),
            if (effect.turn > 0) Transl.special.funcValTurns(effect.turn),
            Transl.funcTargetType(effect.target).l,
          ].join(' ')),
          trailing: !effect.hasValue
              ? Checkbox(
                  value: effect.enabled,
                  onChanged: (v) {
                    setState(() {
                      if (v != null) effect.enabled = v;
                    });
                  },
                )
              : SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: effect.controller,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIcon: percentBase == null ? null : Text('%', style: Theme.of(context).textTheme.bodySmall),
                      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    textAlign: TextAlign.end,
                    onChanged: (s) {
                      s = s.trim();
                      double? v = s.isEmpty ? 0 : double.tryParse(s);
                      if (v == null) return;
                      if (percentBase != null) {
                        v *= percentBase;
                      }
                      effect.value = v.toInt();
                      setState(() {});
                    },
                  ),
                ),
        );
      },
      contentBuilder: (context) {
        List<Widget> children = [
          ListTile(
            dense: true,
            title: Text(S.current.target),
            trailing: DropdownButton<FuncTargetType>(
              isDense: true,
              value: effect.target,
              items: [
                for (final type in _EffectData.usedTargetTypes)
                  DropdownMenuItem(
                    value: type,
                    child: Text(
                      Transl.funcTargetType(type).l,
                      textScaleFactor: 0.8,
                    ),
                  )
              ],
              onChanged: (v) {
                setState(() {
                  if (v != null) effect.target = v;
                });
              },
            ),
          ),
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              if (func.buffs.isNotEmpty)
                TextButton(
                  onPressed: () {
                    InputCancelOkDialog(
                      title: S.current.counts,
                      text: effect.count.toString(),
                      validate: (s) => int.tryParse(s) != null,
                      onSubmit: (s) {
                        effect.count = int.parse(s);
                        if (effect.count <= 0) effect.count = -1;
                        if (mounted) setState(() {});
                      },
                    ).showDialog(context);
                  },
                  child: Text(Transl.special.funcValCountTimes(effect.count <= 0 ? '∞' : effect.count)),
                ),
              if (func.buffs.isNotEmpty)
                TextButton(
                  onPressed: () {
                    InputCancelOkDialog(
                      title: S.current.battle_turn,
                      text: effect.turn.toString(),
                      validate: (s) => int.tryParse(s) != null,
                      onSubmit: (s) {
                        effect.turn = int.parse(s);
                        if (effect.turn <= 0) effect.turn = -1;
                        if (mounted) setState(() {});
                      },
                    ).showDialog(context);
                  },
                  child: Text(Transl.special.funcValTurns(effect.turn <= 0 ? '∞' : effect.turn)),
                ),
              TextButton(
                onPressed: () {
                  InputCancelOkDialog(
                    title: 'Rate',
                    text: (effect.rate / 10).toString(),
                    validate: (s) {
                      final v = double.tryParse(s);
                      return v != null && v > 0;
                    },
                    onSubmit: (s) {
                      effect.rate = (double.parse(s) * 10).toInt();
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                },
                child: Text('${effect.rate.format(percent: true, base: 10)} Rate'),
              ),
            ],
          )
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }

  void createCustomSkill() {
    if (widget.skillType != null) {
      _customSkill.type = widget.skillType!;
    }
    _customSkill.functions.clear();
    for (final effct in _effects) {
      Map<String, dynamic> vals = {
        'Rate': effct.rate,
        if (effct.hasValue) 'Value': effct.value,
        if (effct.func.buffs.isNotEmpty) 'Turn': effct.turn,
        if (effct.func.buffs.isNotEmpty) 'Count': effct.count,
      };

      if (effct.hasValue) {
        if (effct.value == 0) continue;
      } else {
        if (!effct.enabled) continue;
      }
      final data = effct.func.toJson();
      data['funcTargetType'] = effct.target.name;
      data['svals'] = [vals];
      _customSkill.functions.add(NiceFunction.fromJson(data));
    }
    if (_customSkill.functions.isEmpty) {
      EasyLoading.showError(S.current.empty_hint);
      return;
    }
    if (_customSkill.name.isEmpty) {
      _customSkill.name = '${S.current.general_custom} ${_customSkill.id}';
    }
    loadSkill(_customSkill, null, Region.jp);
  }
}
