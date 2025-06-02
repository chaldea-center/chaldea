import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/skill/skill_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../../packages/logger.dart';

class SkillSelectPage extends StatefulWidget {
  final SkillType? skillType;
  final ValueChanged<BaseSkill> onSelected;
  const SkillSelectPage({super.key, required this.skillType, required this.onSelected});

  @override
  State<SkillSelectPage> createState() => _SkillSelectPageState();
}

class _SkillSelectPageState extends State<SkillSelectPage> {
  late final _skillIdController = TextEditingController();

  final CustomSkillData skillData = CustomSkillData();

  @override
  void initState() {
    super.initState();
    skillData.getSkillId();
    skillData.effects.addAll(CustomFuncData.allTypes);
    if (widget.skillType != null) skillData.skillType = widget.skillType!;
  }

  @override
  void dispose() {
    super.dispose();
    _skillIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = S.current.select_skill;
    if (widget.skillType != null) {
      title += '(${widget.skillType!.shortName})';
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const DividerWithTitle(title: '1', height: 16),
                TileGroup(
                  children: [
                    ListTile(
                      tileColor: Theme.of(context).cardColor,
                      title: Text(S.current.skill_list),
                      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                      onTap: () {
                        router.pushPage(
                          SkillListPage(onSelected: (skill, skillId) => loadSkill(skill, skillId, Region.jp)),
                        );
                      },
                    ),
                  ],
                ),
                const DividerWithTitle(title: '2', height: 16),
                Material(
                  color: Theme.of(context).cardColor,
                  child: Padding(
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
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    const SizedBox(width: kMinInteractiveDimension),
                    FilledButton(
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
                      child: Text(S.current.atlas_load),
                    ),
                    SizedBox(width: kMinInteractiveDimension, child: ChaldeaUrl.laplaceHelpBtn('faq#atlas-db-url')),
                  ],
                ),
                const DividerWithTitle(title: '3', height: 16),
                ListTile(
                  title: Text('${S.current.general_import} JSON'),
                  trailing: const Icon(Icons.file_open),
                  tileColor: Theme.of(context).cardColor,
                  onTap: () async {
                    try {
                      final result = await FilePickerU.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                        clearCache: true,
                      );
                      final bytes = result?.files.firstOrNull?.bytes;
                      if (bytes == null) return;
                      final skill = NiceSkill.fromJson(Map.from(jsonDecode(utf8.decode(bytes))));
                      if (skill.id > 0) skill.id = -skill.id;
                      if (skill.functions.isEmpty) {
                        EasyLoading.showError('Empty skill effect!');
                        return;
                      }
                      await loadSkill(skill, null, Region.jp);
                    } catch (e, s) {
                      logger.i('load custom json skill failed', e, s);
                      EasyLoading.showError(e.toString());
                      return;
                    }
                  },
                ),
                DividerWithTitle(title: '4 - ${S.current.general_custom}', height: 16),
                Material(
                  color: Theme.of(context).cardColor,
                  child: CustomSkillForm(skillData: skillData),
                ),
              ],
            ),
          ),
          const Divider(height: 8),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Center(
                child: FilledButton(onPressed: createCustomSkill, child: Text(S.current.create_custom_skill)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadSkill(BaseSkill? skill, int? skillId, Region region) async {
    if (skill == null && skillId != null && skillId > 0) {
      EasyLoading.show();
      if (region == Region.jp) {
        skill = db.gameData.baseSkills[skillId];
      }
      skill ??= await AtlasApi.skill(skillId, region: region);
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

  void createCustomSkill() {
    final skill = skillData.buildSkill();
    if (skill == null) {
      EasyLoading.showError(S.current.empty_hint);
      return;
    }
    if (skill.name.isEmpty) {
      skill.name = '${S.current.general_custom} ${skill.id}';
    }
    loadSkill(skill, null, Region.jp);
  }
}

class CustomSkillForm extends StatefulWidget {
  final CustomSkillData skillData;
  final bool showInfo;
  final bool valueOnly;
  final bool showTargetSelf;
  final VoidCallback? onChanged;

  const CustomSkillForm({
    super.key,
    required this.skillData,
    this.valueOnly = false,
    this.showInfo = true,
    this.showTargetSelf = true,
    this.onChanged,
  });

  @override
  State<CustomSkillForm> createState() => _CustomSkillFormState();
}

class _CustomSkillFormState extends State<CustomSkillForm> {
  CustomSkillData get skill => widget.skillData;

  final Map<CustomFuncData, TextEditingController> _controllers = {};
  final usedTargetTypes = const <FuncTargetType>[
    FuncTargetType.self,
    FuncTargetType.ptOne,
    FuncTargetType.ptAll,
    FuncTargetType.ptFull,
    FuncTargetType.enemy,
    FuncTargetType.enemyAll,
    FuncTargetType.enemyFull,
  ];

  @override
  void dispose() {
    super.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
  }

  TextEditingController getController(CustomFuncData effect) {
    final controller = _controllers[effect];
    if (controller == null) {
      String text = effect.getValueText(false);
      if (text == '0') text = '';
      return _controllers[effect] = TextEditingController(text: text);
    }
    final curVal = effect.parseValue(controller.text);
    if (curVal != null && curVal != effect.value) {
      controller.text = effect.getValueText(false);
    }
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showInfo) ...[
          ListTile(dense: true, title: const Text('ID'), trailing: Text(skill.skillId.toString())),
          ListTile(
            dense: true,
            title: Text(S.current.name),
            trailing: SizedBox(
              width: 120,
              child: TextFormField(
                initialValue: skill.name,
                decoration: const InputDecoration(isDense: true),
                textAlign: TextAlign.center,
                onChanged: (s) {
                  if (s.trim().isNotEmpty) skill.name = s.trim();
                },
              ),
            ),
          ),
          ListTile(
            dense: true,
            title: Text(S.current.general_type),
            trailing: FilterGroup<SkillType>(
              combined: true,
              padding: EdgeInsets.zero,
              options: SkillType.values,
              values: FilterRadioData.nonnull(skill.skillType),
              optionBuilder: (v) => Text(v.shortName),
              onFilterChanged: (value, _) {
                skill.skillType = value.radioValue!;
                setState(() {});
                widget.onChanged?.call();
              },
            ),
          ),
          ListTile(
            dense: true,
            title: const Text('CD'),
            trailing: SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: skill.cd.toString(),
                decoration: InputDecoration(
                  isDense: true,
                  suffixIcon: Text(S.current.battle_turn, style: Theme.of(context).textTheme.bodySmall),
                  suffixIconConstraints: const BoxConstraints(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                onChanged: (s) {
                  int? v = int.tryParse(s);
                  if (v == null || v < 0) return;
                  skill.cd = v;
                  setState(() {});
                  widget.onChanged?.call();
                },
              ),
            ),
          ),
        ],
        for (final effect in skill.effects) buildFunc(effect),
      ],
    );
  }

  Widget buildFunc(CustomFuncData effect) {
    final func = effect.baseFunc;
    if (func == null) return ListTile(dense: true, title: Text('Invalid Func ${effect.funcId}'));

    final int? percentBase = effect.percentBase;
    List<String> subtitles = [
      if (skill.hasTurnCount) ...[
        if (effect.count > 0) Transl.special.funcValCountTimes(effect.count),
        if (effect.turn > 0) Transl.special.funcValTurns(effect.turn),
      ],
      if (widget.showTargetSelf || effect.target != FuncTargetType.self) Transl.funcTargetType(effect.target).l,
    ];
    final header = ListTile(
      dense: true,
      contentPadding: widget.valueOnly ? null : const EdgeInsetsDirectional.only(start: 16),
      leading: effect.icon == null ? null : db.getIconImage(effect.icon, width: 24),
      title: Text(effect.popupText),
      horizontalTitleGap: 8,
      subtitle: subtitles.isEmpty ? null : Text(subtitles.join(' ')),
      trailing: !effect.useValue
          ? Checkbox(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: effect.enabled,
              onChanged: (v) {
                setState(() {
                  if (v != null) effect.enabled = v;
                });
                widget.onChanged?.call();
              },
            )
          : SizedBox(
              width: 80,
              child: TextFormField(
                controller: getController(effect),
                decoration: InputDecoration(
                  isDense: true,
                  suffixIcon: percentBase == null ? null : Text('%', style: Theme.of(context).textTheme.bodySmall),
                  suffixIconConstraints: const BoxConstraints(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                textAlign: TextAlign.end,
                onChanged: (s) {
                  final v = effect.parseValue(s);
                  if (v == null) return;
                  effect.value = v;
                  setState(() {});
                  widget.onChanged?.call();
                },
              ),
            ),
    );
    if (widget.valueOnly) return header;
    return SimpleAccordion(
      headerBuilder: (context, _) => header,
      contentBuilder: (context) {
        List<Widget> children = [
          ListTile(
            dense: true,
            title: Text(S.current.target),
            trailing: DropdownButton<FuncTargetType>(
              isDense: true,
              value: effect.target,
              items: [
                for (final type in usedTargetTypes)
                  DropdownMenuItem(
                    value: type,
                    child: Text(Transl.funcTargetType(type).l, textScaler: const TextScaler.linear(0.8)),
                  ),
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
          ),
        ];

        return Column(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }
}
