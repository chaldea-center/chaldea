import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../command_code/cmd_code_list.dart';
import '../../item/item.dart';
import 'leveling_cost_page.dart';

class SvtPlanTab extends StatefulWidget {
  final Servant svt;

  const SvtPlanTab({super.key, required this.svt});

  @override
  State<StatefulWidget> createState() => _SvtPlanTabState();
}

class _SvtPlanTabState extends State<SvtPlanTab> {
  /// in edit mode, change skill lv_a to lv_b and take out the items
  bool enhanceMode = false;
  late TextEditingController _coinEditController;
  SvtPlan enhancePlan = SvtPlan.empty();

  Servant get svt => widget.svt;

  SvtPlan get plan => db.curUser.svtPlanOf(svt.collectionNo);

  SvtStatus get status => db.curUser.svtStatusOf(svt.collectionNo);

  @override
  void initState() {
    super.initState();
    _coinEditController = TextEditingController(text: db.curUser.items[svt.coin?.item.id]?.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _coinEditController.dispose();
  }

  bool showDetail(SvtPlanDetail detail) {
    return !db.settings.display.hideSvtPlanDetails.contains(detail);
  }

  @override
  Widget build(BuildContext context) {
    final sliderMode = db.settings.display.svtPlanInputMode == SvtPlanInputMode.slider;
    if (svt.skills.isEmpty) {
      return Center(child: Text('${svt.lName.l} has no skills'));
    }
    status.validate();
    final curVal = status.cur;
    final targetVal = enhanceMode ? enhancePlan : plan;
    targetVal.validate(curVal);
    // ascension part
    List<Widget> children = [];
    if (svt.collectionNo > 0) {
      children.add(TileGroup(
        header: kLaplaceName,
        children: [
          CheckboxListTile(
            dense: true,
            title: Text(S.current.pin_to_top),
            value: db.curUser.battleSim.pingedSvts.contains(svt.collectionNo),
            onChanged: (v) {
              setState(() {
                db.curUser.battleSim.pingedSvts.toggle(svt.collectionNo);
              });
            },
          ),
        ],
      ));
    }
    if (showDetail(SvtPlanDetail.ascension)) {
      children.add(TileGroup(
        header: S.current.ascension_up,
        children: <Widget>[
          buildPlanRow(
            useSlider: sliderMode,
            leading: const SizedBox(
              width: 33,
              height: 33,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.seedling,
                  size: 28,
                  color: Colors.lightGreen,
                ),
              ),
            ),
            title: S.current.ascension_up,
            start: curVal.ascension,
            end: targetVal.ascension,
            minVal: 0,
            maxVal: 4,
            onValueChanged: (_start, _end) {
              status.cur.favorite = plan.favorite = true;
              curVal.ascension = _start;
              targetVal.ascension = _end;
              updateState();
            },
            detailPageBuilder: (context) => LevelingCostPage(
              costList: svt.ascensionMaterials,
              title: S.current.ascension_up,
              curLv: curVal.ascension,
              targetLv: targetVal.ascension,
            ),
          )
        ],
      ));
    }

    //skill part
    if (showDetail(SvtPlanDetail.activeSkill)) {
      List<Widget> skillWidgets = [];
      for (final skillNum in kActiveSkillNums) {
        final index = skillNum - 1;
        final skills = svt.groupedActiveSkills[skillNum] ?? [];
        if (skills.isEmpty) continue;
        final skill = svt.getDefaultSkill(skills, db.curUser.region) ?? skills.last;
        skillWidgets.add(buildPlanRow(
          useSlider: sliderMode,
          leading: db.getIconImage(skill.icon, width: 33, onTap: skill.routeTo),
          title: Transl.skillNames(skill.name).l,
          start: curVal.skills[index],
          end: targetVal.skills[index],
          minVal: 1,
          maxVal: 10,
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.skills[index] = _start;
            targetVal.skills[index] = _end;
            updateState();
          },
          detailPageBuilder: (context) => LevelingCostPage(
            costList: svt.skillMaterials,
            title: '${S.current.skill} $skillNum - ${Transl.skillNames(skill.name).l}',
            curLv: curVal.skills[index],
            targetLv: targetVal.skills[index],
          ),
        ));
      }
      children.add(TileGroup(header: S.current.skill_up, children: skillWidgets));
    }

    // append skill
    if (showDetail(SvtPlanDetail.appendSkill)) {
      List<Widget> appendSkillWidgets = [];
      for (int index = 0; index < 3; index++) {
        final skill = svt.appendPassive.getOrNull(index)?.skill;
        if (skill == null) continue;
        appendSkillWidgets.add(buildPlanRow(
          useSlider: sliderMode,
          leading: db.getIconImage(skill.icon, width: 33, onTap: skill.routeTo),
          title: Transl.skillNames(skill.name).l,
          start: curVal.appendSkills[index],
          end: targetVal.appendSkills[index],
          minVal: 0,
          maxVal: 10,
          labelFormatter: (v) => v == 0 ? '-' : v.toString(),
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.appendSkills[index] = _start;
            targetVal.appendSkills[index] = _end;
            updateState();
          },
          detailPageBuilder: (context) => LevelingCostPage(
            costList: {
              if (svt.icon != null)
                0: LvlUpMaterial(
                  items: [ItemAmount(amount: 120, item: svt.coin!.item)],
                  qp: 0,
                ),
              ...svt.appendSkillMaterials,
            },
            title: '${S.current.append_skill} ${index + 1} - ${Transl.skillNames(skill.name).l}',
            curLv: curVal.appendSkills[index],
            targetLv: targetVal.appendSkills[index],
          ),
        ));
      }
      children.add(TileGroup(
        header: S.current.append_skill,
        children: appendSkillWidgets,
      ));
    }

    // costume part
    if (showDetail(SvtPlanDetail.costume)) {
      List<Widget> dressWidgets = [];
      for (final costume in svt.profile.costume.values) {
        dressWidgets.add(buildPlanRow(
          useSlider: false,
          leading: InkWell(
            child: db.getIconImage(
              svt.extraAssets.faces.costume?[costume.battleCharaId] ?? Atlas.assetItem(Items.costumeIconId),
              aspectRatio: 132 / 144,
              width: 33,
              placeholder: (ctx) => db.getIconImage(Atlas.assetItem(Items.costumeIconId)),
            ),
            onTap: () {
              router.push(url: Routes.costumeI(costume.costumeCollectionNo));
            },
          ),
          title: costume.lName.l,
          subtitle: Transl.isJP ? null : costume.name,
          start: curVal.costumes[costume.battleCharaId] ?? 0,
          end: targetVal.costumes[costume.battleCharaId] ?? 0,
          minVal: 0,
          maxVal: 1,
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.costumes[costume.battleCharaId] = _start;
            targetVal.costumes[costume.battleCharaId] = _end;
            updateState();
          },
          detailPageBuilder: (context) => LevelingCostPage(
            costList: svt.costumeMaterials[costume.battleCharaId] == null
                ? {}
                : {0: svt.costumeMaterials[costume.battleCharaId]!},
            title: '${S.current.costume_unlock} - ${costume.lName.l}',
          ),
        ));
      }
      if (dressWidgets.isNotEmpty) {
        children.add(TileGroup(header: S.current.costume_unlock, children: dressWidgets));
      }
    }
    final extraParts1 = [
      if (showDetail(SvtPlanDetail.coin) && svt.coin != null)
        ListTile(
          dense: true,
          horizontalTitleGap: 3,
          leading: InkWell(
            child: Item.iconBuilder(
              context: context,
              item: svt.coin!.item,
              width: 33,
            ),
          ),
          title: Text(S.current.servant_coin),
          subtitle: Text('${S.current.coin_summon_num}: ${svt.coin?.summonNum}'),
          trailing: db.onUserData((context, snapshot) => TextButton(
                onPressed: () {
                  InputCancelOkDialog(
                    title: S.current.servant_coin,
                    text: db.curUser.items[svt.coin?.item.id]?.toString(),
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    validate: (s) => int.tryParse(s) != null,
                    onSubmit: (s) {
                      int? coin = int.tryParse(s);
                      final coinId = svt.coin?.item.id;
                      if (coin != null && coinId != null) {
                        db.curUser.items[coinId] = coin;
                        updateState();
                      }
                    },
                  ).showDialog(context);
                },
                child: Text(
                  '${(db.curUser.items[svt.coin?.item.id] ?? 0)}',
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              )),
        ),
      if (showDetail(SvtPlanDetail.grail))
        buildPlanRow(
          useSlider: sliderMode,
          leading: Item.iconBuilder(context: context, item: null, itemId: Items.grailId, width: 33),
          title: S.current.grail_up,
          start: curVal.grail,
          end: targetVal.grail,
          minVal: 0,
          maxVal: Maths.max(db.gameData.constData.svtGrailCost[svt.rarity]!.keys, 0),
          labelFormatter: (v) => svt.grailedLv(v).toString(),
          trailingLabelFormatter: (a, b) => '${svt.grailedLv(a)}→'
                  '${svt.grailedLv(b!)}'
              .padLeft(7),
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.grail = _start;
            targetVal.grail = _end;
            updateState();
          },
          detailPageBuilder: (context) => LevelingCostPage(
            title: S.current.grail_up,
            costList: svt.grailUpMaterials,
            curLv: curVal.grail,
            targetLv: targetVal.grail,
            levelFormatter: (v) => svt.grailedLv(v).toString(),
          ),
        ),
      if (showDetail(SvtPlanDetail.noblePhantasm))
        buildPlanRow(
          useSlider: sliderMode,
          leading: db.getIconImage(Atlas.assetItem(Items.npRankUpIconId), width: 33),
          title: S.current.noble_phantasm_level,
          start: curVal.npLv,
          end: targetVal.npLv,
          minVal: 0,
          maxVal: 5,
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.npLv = _start;
            targetVal.npLv = _end;
            updateState();
          },
          detailPageBuilder: (context) => const SimpleCancelOkDialog(title: Text('Not Used yet')),
        ),
    ];
    if (extraParts1.isNotEmpty) {
      children.add(TileGroup(children: extraParts1));
    }

    // Extra part2: grail/fou-kun
    final extraParts2 = <Widget>[
      if (showDetail(SvtPlanDetail.fou4))
        buildPlanRow(
          useSlider: sliderMode,
          leading: Item.iconBuilder(context: context, item: null, itemId: Items.hpFou4, width: 33),
          title: '${kStarChar}4 HP ${S.current.foukun}',
          start: curVal.fouHp,
          end: targetVal.fouHp,
          minVal: 0,
          maxVal: 50,
          labelFormatter: (v) => (v * 20).toString(),
          trailingLabelFormatter: (a, b) => '${curVal.fouHp * 20}→${targetVal.fouHp * 20}',
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.fouHp = _start;
            targetVal.fouHp = _end;
            updateState();
          },
          detailPageBuilder: null,
        ),
      if (showDetail(SvtPlanDetail.fou4))
        buildPlanRow(
          useSlider: sliderMode,
          leading: Item.iconBuilder(context: context, item: null, itemId: Items.atkFou4, width: 33),
          title: '${kStarChar}4 ATK ${S.current.foukun}',
          start: curVal.fouAtk,
          end: targetVal.fouAtk,
          minVal: 0,
          maxVal: 50,
          labelFormatter: (v) => (v * 20).toString(),
          trailingLabelFormatter: (a, b) => '${curVal.fouAtk * 20}→${targetVal.fouAtk * 20}',
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.fouAtk = _start;
            targetVal.fouAtk = _end;
            updateState();
          },
          detailPageBuilder: null,
        ),
      if (showDetail(SvtPlanDetail.fou3))
        buildPlanRow(
          useSlider: sliderMode,
          leading: Item.iconBuilder(context: context, item: null, itemId: Items.hpFou3, width: 33),
          title: '${kStarChar}3 HP ${S.current.foukun}',
          start: curVal.fouHp3,
          end: targetVal.fouHp3,
          minVal: 0,
          maxVal: 20,
          labelFormatter: (v) => (v * 50).toString(),
          trailingLabelFormatter: (a, b) => '${curVal.fouHp3 * 50}→${targetVal.fouHp3 * 50}',
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.fouHp3 = _start;
            targetVal.fouHp3 = _end;
            updateState();
          },
          detailPageBuilder: null,
        ),
      if (showDetail(SvtPlanDetail.fou3))
        buildPlanRow(
          useSlider: sliderMode,
          leading: Item.iconBuilder(context: context, item: null, itemId: Items.atkFou3, width: 33),
          title: '${kStarChar}3 ATK ${S.current.foukun}',
          start: curVal.fouAtk3,
          end: targetVal.fouAtk3,
          minVal: 0,
          maxVal: 20,
          labelFormatter: (v) => (v * 50).toString(),
          trailingLabelFormatter: (a, b) => '${curVal.fouAtk3 * 50}→${targetVal.fouHp3 * 50}',
          onValueChanged: (_start, _end) {
            status.cur.favorite = true;
            curVal.fouAtk3 = _start;
            targetVal.fouAtk3 = _end;
            updateState();
          },
          detailPageBuilder: null,
        ),
      if (showDetail(SvtPlanDetail.bondLimit))
        buildPlanRow(
          useSlider: sliderMode,
          leading: db.getIconImage(
            "https://static.atlasacademy.io/JP/Terminal/Info/CommonUIAtlas/img_bond_category.png",
            width: 33,
          ),
          title: S.current.game_kizuna,
          start: status.bond,
          minVal: 0,
          maxVal: 15,
          onValueChanged: (_start, _) {
            status.favorite = true;
            status.bond = _start;
            curVal.bondLimit = curVal.bondLimit.clamp(_start, 15);
            targetVal.bondLimit = targetVal.bondLimit.clamp(curVal.bondLimit, 15);
            updateState();
          },
          detailPageBuilder: (context) => SimpleCancelOkDialog(
            title: Text('${S.current.bond} (${S.current.current_})'),
            hideCancel: true,
          ),
        ),
    ];
    if (extraParts2.isNotEmpty) {
      children.add(TileGroup(
        header: S.current.event_item_extra,
        children: extraParts2,
      ));
    }
    if (showDetail(SvtPlanDetail.commandCode)) {
      children.add(_buildCmdCodePlanner());
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.only(bottom: 16),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        ),
        buildButtonBar(targetVal),
      ],
    );
  }

  Widget buildPlanRow({
    Widget? leading,
    String? title,
    Widget? titleWidget,
    String? subtitle,
    required int start,
    int? end,
    required int minVal,
    required int maxVal,
    int? divisions,
    String Function(int v)? labelFormatter,
    String Function(int a, int? b)? trailingLabelFormatter,
    required void Function(int start, int end) onValueChanged,
    bool useSlider = false,
    WidgetBuilder? detailPageBuilder,
  }) {
    assert(minVal <= start && start <= maxVal);
    start = start.clamp(minVal, maxVal);
    if (end != null) {
      assert(start <= end && end <= maxVal);
      end = end.clamp(start, maxVal);
    }
    labelFormatter ??= (v) => v.toString();
    trailingLabelFormatter ??= (a, b) {
      String s = labelFormatter!(a).padLeft(2);
      if (b != null) s += '→${labelFormatter(b).padRight(2)}';
      return s;
    };
    if (title != null) {
      titleWidget ??= AutoSizeText(title, maxLines: 1);
    }

    Widget trailingIcon;
    if (detailPageBuilder != null) {
      trailingIcon = IconButton(
        icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
        onPressed: () => showDialog(
          context: context,
          builder: detailPageBuilder,
          useRootNavigator: false,
        ),
      );
    } else {
      trailingIcon = const SizedBox(width: 16);
    }
    if (useSlider) {
      Widget slider;
      if (end == null) {
        slider = Slider(
          min: minVal.toDouble(),
          max: maxVal.toDouble(),
          divisions: divisions ?? (maxVal - minVal).round(),
          value: start.toDouble(),
          label: labelFormatter(start),
          onChanged: enhanceMode
              ? null
              : (v) {
                  onValueChanged(v.round(), -1);
                },
        );
      } else {
        slider = RangeSlider(
          min: minVal.toDouble(),
          max: maxVal.toDouble(),
          divisions: divisions ?? (maxVal - minVal).round(),
          values: RangeValues(start.toDouble(), end.toDouble()),
          labels: RangeLabels(labelFormatter(start), labelFormatter(end)),
          onChanged: (v) {
            // enhance mode: don't modify start
            if (v.start.round() != start || v.end.round() != end) {
              onValueChanged(enhanceMode ? start : v.start.round(), v.end.round());
            }
          },
        );
      }
      return CustomTile(
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        titlePadding: EdgeInsets.zero,
        leading: leading,
        title: titleWidget == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: 6, top: 4),
                child: titleWidget,
              ),
        subtitle: SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
            rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 1.2),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.2),
            activeTickMarkColor: Colors.grey[200],
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: SizedBox(height: 23, child: slider),
        ),
        trailing: Text(trailingLabelFormatter(start, end), style: kMonoStyle),
        trailingIcon: trailingIcon,
      );
    } else {
      Widget selector;
      if (end == null) {
        selector = DropdownButton<int>(
          value: start,
          items: List.generate(
            maxVal - minVal + 1,
            (index) => DropdownMenuItem(
              value: minVal + index,
              child: Text(labelFormatter!(minVal + index), textScaler: const TextScaler.linear(0.9)),
            ),
          ),
          // disable at enhance mode
          onChanged: enhanceMode
              ? null
              : (v) {
                  if (v != null) onValueChanged(v, -1);
                },
        );
      } else {
        final items =
            List.generate((maxVal - minVal) ~/ (divisions ?? 1) + 1, (index) => minVal + index * (divisions ?? 1));
        selector = RangeSelector<int>(
          start: start,
          end: end,
          startEnabled: !enhanceMode,
          startItems: items,
          endItems: items,
          itemBuilder: (context, v) => Text(labelFormatter!(v), textScaler: const TextScaler.linear(0.9)),
          onChanged: (_start, _end) {
            onValueChanged(enhanceMode ? start : _start, _end);
          },
        );
      }
      return CustomTile(
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
        leading: leading,
        title: titleWidget,
        subtitle: subtitle == null ? null : AutoSizeText(subtitle, maxLines: 1, minFontSize: 10),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[selector, trailingIcon],
        ),
      );
    }
  }

  Widget _buildCmdCodePlanner() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SHeader('${S.current.command_code}/${S.current.beast_footprint}'),
        Material(
          color: Theme.of(context).cardColor,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(56),
              1: FixedColumnWidth(28),
              2: FixedColumnWidth(36),
              // 3: cc skill
              4: FixedColumnWidth(32)
            },
            border: TableBorder.all(color: const Color.fromRGBO(162, 169, 177, 1), width: 0.25),
            children: List.generate(svt.cards.length, (index) {
              final code = db.gameData.commandCodes[status.getCmdCode(index)];
              final footprint = status.cmdCardStrengthen?.getOrNull(index) ?? 0;
              Widget footWidget = GameCardMixin.cardIconBuilder(
                context: context,
                icon: Atlas.assetItem(ItemIconId.beastFootprint),
                aspectRatio: 1,
                width: 32,
                padding: const EdgeInsets.all(2),
                text: footprint > 0 ? (footprint * 20).toString() : null,
              );
              if (footprint <= 0) {
                footWidget = Opacity(opacity: 0.6, child: footWidget);
              }
              footWidget = InkWell(
                onTap: () {
                  Picker(
                    title: Text(S.current.beast_footprint),
                    itemExtent: 36,
                    height: min(250, MediaQuery.of(context).size.height - 220),
                    hideHeader: true,
                    cancelText: S.current.cancel,
                    confirmText: S.current.confirm,
                    backgroundColor: null,
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    adapter: NumberPickerAdapter(
                      data: [
                        NumberPickerColumn(
                          items: List.generate(26, (i) => i),
                          initValue: footprint,
                          onFormatValue: (v) {
                            return (v * 20).toString();
                          },
                        ),
                      ],
                    ),
                    onConfirm: (picker, values) {
                      final v = picker.getSelectedValues()[0] as int;
                      status.setCmdCard(index, v);
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                },
                child: footWidget,
              );
              return TableRow(children: [
                Center(
                  child: CommandCardWidget(card: svt.cards[index], width: 48),
                ),
                Center(child: footWidget),
                InkWell(
                  onTap: () {
                    router.pushBuilder(
                      builder: (context) => CmdCodeListPage(
                        onSelected: (selectedCode) {
                          status.setCmdCode(index, selectedCode.collectionNo);
                          if (mounted) setState(() {});
                        },
                      ),
                      detail: false,
                    );
                  },
                  child: db.getIconImage(code?.icon ?? Atlas.common.emptySkillIcon,
                      height: 36, aspectRatio: 1, padding: const EdgeInsets.all(4)),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: code?.routeTo,
                    child: Text(
                      code?.skills.getOrNull(0)?.lDetail ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      status.setCmdCode(index, null);
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  tooltip: S.current.remove,
                )
              ]);
            }),
          ),
        ),
      ],
    );
  }

  bool get useActiveSkill => db.runtimeData.svtPlanTabButtonBarUseActive;
  set useActiveSkill(bool v) => db.runtimeData.svtPlanTabButtonBarUseActive = v;

  Widget buildButtonBar(SvtPlan targetPlan) {
    final curVal = status.cur;
    List<Widget> buttons = [];
    // 强化 or 取消
    if (enhanceMode) {
      buttons.add(TextButton(
        onPressed: () {
          setState(() {
            enhanceMode = !enhanceMode;
          });
        },
        child: Text(S.current.cancel),
      ));
    } else {
      buttons.add(TextButton(
        onPressed: () {
          final Map<int, int> items = Item.sortMapByPriority(db.itemCenter.calcOneSvt(svt, status.cur, plan).all);
          _showItemsDialog(
            title: S.current.demands,
            items: items,
            hideCancel: true,
            showSubOwned: true,
          );
        },
        child: Text(S.current.demands),
      ));
      buttons.add(ElevatedButton(
        onPressed: () {
          setState(() {
            // reset enhance plan every time enter the enhance mode
            enhancePlan = SvtPlan.fromJson(curVal.toJson());
            enhanceMode = !enhanceMode;
          });
        },
        child: Text(S.current.enhance),
      ));
    }

    // 确定
    if (enhanceMode) {
      buttons.add(ElevatedButton(
        onPressed: _onEnhance,
        child: Text(S.current.ok),
      ));
    }

    buttons.add(const SizedBox(
      height: 28,
      child: VerticalDivider(
        width: 8,
        thickness: 1,
      ),
    ));
    buttons.add(DropdownButton<bool>(
      value: useActiveSkill,
      underline: const SizedBox(),
      items: [
        DropdownMenuItem(
          value: true,
          child: Text('${S.current.active_skill_short}:'),
        ),
        DropdownMenuItem(
          value: false,
          child: Text('${S.current.append_skill_short}:'),
        ),
      ],
      onChanged: (v) {
        setState(() {
          if (v != null) useActiveSkill = v;
        });
      },
    ));

    // Lv.x or ≠
    final _rightPlan = enhanceMode ? targetPlan : plan;
    final skillsLeft = curVal.getSkills(useActiveSkill);
    buttons.add(DropdownButton<int>(
      value: skillsLeft.toSet().length == 1 ? skillsLeft.first : null,
      items: [
        const DropdownMenuItem(value: -1, child: Text('x+1')),
        for (int index = useActiveSkill ? 1 : 0; index <= 10; index++)
          DropdownMenuItem(
            value: index,
            child: Text('Lv.$index'),
          )
      ],
      hint: const Text('Lv.≠'),
      onChanged: enhanceMode
          ? null
          : (v) {
              if (v == -1) {
                for (int i = 0; i < skillsLeft.length; i++) {
                  skillsLeft[i] += 1;
                }
              } else if (v != null) {
                skillsLeft.fillRange(0, skillsLeft.length, v);
              }
              curVal.favorite = true;
              curVal.validate(null, svt);
              _rightPlan.validate(curVal, svt);
              updateState();
            },
    ));
    buttons.add(const Text(' → '));

    final skillsRight = _rightPlan.getSkills(useActiveSkill);
    buttons.add(DropdownButton<int>(
      value: skillsRight.toSet().length == 1 ? skillsRight.first : null,
      items: [
        const DropdownMenuItem(value: -1, child: Text('x+1')),
        for (int index = useActiveSkill ? 1 : 0; index <= 10; index++)
          DropdownMenuItem(
            value: index,
            child: Text('Lv.$index'),
          )
      ],
      hint: const Text('Lv.≠'),
      onChanged: (v) {
        if (v == -1) {
          for (int i = 0; i < skillsRight.length; i++) {
            skillsRight[i] += 1;
          }
        } else if (v != null) {
          skillsRight.fillRange(0, skillsRight.length, v);
        }
        curVal.favorite = true;
        _rightPlan.validate(curVal, svt);
        updateState();
      },
    ));

    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context, width: 0.5))),
      child: SafeArea(
        child: Align(
          alignment: Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ButtonBar(
              buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
              children: buttons,
            ),
          ),
        ),
      ),
    );
  }

  void updateState() {
    EasyDebounce.debounce(
      'svt_plan_changed',
      const Duration(milliseconds: 500),
      () {
        svt.updateStat();
      },
    );
    if (mounted) setState(() {});
  }

  void _onEnhance() {
    status.cur.favorite = true;
    final Map<int, int> enhanceItems =
        Item.sortMapByPriority(db.itemCenter.calcOneSvt(svt, status.cur, enhancePlan).all);

    _showItemsDialog(
      title: S.current.enhance_warning,
      items: enhanceItems,
      hideCancel: false,
      showSubOwned: true,
      onConfirm: () {
        Maths.sumDict([db.curUser.items, Maths.multiplyDict(enhanceItems, -1)], inPlace: true);
        status.cur = SvtPlan.fromJson(enhancePlan.toJson());
        enhanceMode = !enhanceMode;
        updateState();
      },
    );
  }

  void _showItemsDialog({
    required String title,
    required Map<int, int> items,
    required bool hideCancel,
    VoidCallback? onConfirm,
    bool showSubOwned = false,
  }) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => ValueStatefulBuilder<bool>(
        initValue: false,
        builder: (context, value) {
          Map<int, int> shownItems = Map.of(items);
          if (value.value) {
            for (final itemId in shownItems.keys.toList()) {
              shownItems.addNum(itemId, -max(0, db.curUser.items[itemId] ?? 0));
            }
            shownItems.removeWhere((key, value) => value <= 0);
          }
          return SimpleCancelOkDialog(
            title: Text(title),
            hideCancel: hideCancel,
            onTapOk: onConfirm,
            content: shownItems.isEmpty
                ? const Text('Nothing')
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: [
                        for (final entry in shownItems.entries)
                          Item.iconBuilder(
                            context: context,
                            item: db.gameData.items[entry.key],
                            icon: Item.getIcon(entry.key),
                            text: entry.value.format(),
                            width: 48,
                            onTap: () {
                              router.pushPage(ItemDetailPage(itemId: entry.key));
                            },
                          ),
                      ],
                    ),
                  ),
            actions: [
              if (showSubOwned)
                TextButton(
                  onPressed: () {
                    value.value = !value.value;
                  },
                  child: Text(
                    S.current.item_stat_sub_owned,
                    style: TextStyle(
                      color: value.value ? Theme.of(context).disabledColor : null,
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
