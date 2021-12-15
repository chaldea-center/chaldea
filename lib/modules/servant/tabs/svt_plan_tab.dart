import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_list_page.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/servant/costume_detail_page.dart';
import 'package:chaldea/modules/shared/common_builders.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../servant_detail_page.dart';
import 'leveling_cost_page.dart';
import 'svt_tab_base.dart';

class SvtPlanTab extends SvtTabBaseWidget {
  const SvtPlanTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  State<StatefulWidget> createState() => _SvtPlanTabState();
}

class _SvtPlanTabState extends SvtTabBaseState<SvtPlanTab> {
  /// in edit mode, change skill lv_a to lv_b and take out the items
  bool enhanceMode = false;

  late TextEditingController _coinEditController;

  ServantPlan enhancePlan = ServantPlan();

  ServantPlan get plan => db.curUser.svtPlanOf(svt.no);

  @override
  void initState() {
    super.initState();
    _coinEditController = TextEditingController(text: status.coin.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _coinEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sliderMode = db.appSetting.svtPlanSliderMode;
    return db.streamBuilder((context) {
      if (svt.lActiveSkills.isEmpty) {
        return Center(child: Text('${svt.info.localizedName} has no skills'));
      }
      status.validate(svt);
      final curVal = status.curVal;
      final targetVal = enhanceMode ? enhancePlan : plan;
      targetVal.validate(curVal, svt.info.rarity);
      // ascension part
      List<Widget> children = [];
      if (svt.no != 1) {
        children.add(TileGroup(
          header: S.of(context).ascension_up,
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
              title: S.of(context).ascension_up,
              start: curVal.ascension,
              end: targetVal.ascension,
              minVal: 0,
              maxVal: 4,
              onValueChanged: (_start, _end) {
                status.favorite = true;
                curVal.ascension = _start;
                targetVal.ascension = _end;
                updateState();
              },
              detailPageBuilder: (context) => LevelingCostPage(
                costList: svt.itemCost.ascension,
                title: S.of(context).ascension_up,
                curLv: curVal.ascension,
                targetLv: targetVal.ascension,
              ),
            )
          ],
        ));
      }

      //skill part
      List<Widget> skillWidgets = [];
      for (int index = 0; index < svt.lActiveSkills.length; index++) {
        if (index >= 3) continue;
        final activeSkill = svt.lActiveSkills[index];
        int? _state;
        if (!svt.isAvailable) {
          _state = 0;
        } else {
          _state = status.skillIndex.getOrNull(index);
        }
        Skill? skill = activeSkill.ofIndex(_state);
        if (skill == null) continue;
        String shownName = skill.localizedName;
        if (skill.rank?.isNotEmpty == true) {
          shownName += ' ${skill.rank}';
        }
        if (index >= 3) {
          skillWidgets.add(buildPlanRow(
              start: 0, minVal: 0, maxVal: 0, onValueChanged: (_, __) {}));
        } else {
          skillWidgets.add(buildPlanRow(
            useSlider: sliderMode,
            leading: db.getIconImage(skill.icon, width: 33),
            title: shownName,
            start: curVal.skills[index],
            end: targetVal.skills[index],
            minVal: 1,
            maxVal: 10,
            onValueChanged: (_start, _end) {
              status.favorite = true;
              curVal.skills[index] = _start;
              targetVal.skills[index] = _end;
              updateState();
            },
            detailPageBuilder: (context) => LevelingCostPage(
              costList: svt.itemCost.skill,
              title: '${S.current.skill} ${index + 1} - ${skill.localizedName}',
              curLv: curVal.skills[index] - 1,
              targetLv: targetVal.skills[index] - 1,
              levelFormatter: (v) => 'Lv.${v + 1}',
            ),
          ));
        }
      }
      children
          .add(TileGroup(header: S.current.skill_up, children: skillWidgets));

      // costume part
      List<Widget> dressWidgets = [];
      curVal.fixDressLength(svt.costumeNos.length, 0);
      targetVal.fixDressLength(svt.costumeNos.length, 0);
      for (int index = 0; index < svt.costumeNos.length; index++) {
        final costume = db.gameData.costumes[svt.costumeNos[index]];
        if (costume == null) continue;
        dressWidgets.add(buildPlanRow(
          useSlider: false,
          // leading: db.getIconImage('灵衣开放权', width: 33),
          leading: GestureDetector(
            child: db.getIconImage(costume.icon,
                aspectRatio: 132 / 144,
                width: 33,
                placeholder: (ctx) => db.getIconImage('灵衣开放权')),
            onTap: () {
              SplitRoute.push(context, CostumeDetailPage(costume: costume));
            },
          ),
          title: costume.lName,
          subtitle: Language.isJP ? null : costume.nameJp,
          start: curVal.dress[index],
          end: targetVal.dress[index],
          minVal: 0,
          maxVal: 1,
          onValueChanged: (_start, _end) {
            status.favorite = true;
            curVal.dress[index] = _start;
            targetVal.dress[index] = _end;
            updateState();
          },
          detailPageBuilder: (context) => LevelingCostPage(
            costList: [costume.itemCost],
            title: '${S.current.costume_unlock} - ${costume.lName}',
          ),
        ));
      }
      if (dressWidgets.isNotEmpty) {
        children.add(TileGroup(
            header: S.of(context).costume_unlock, children: dressWidgets));
      }

      // append skill
      List<Widget> appendSkillWidgets = [];
      for (int index = 0; index < svt.appendSkills.length; index++) {
        final skill = svt.appendSkills[index];
        appendSkillWidgets.add(buildPlanRow(
          useSlider: sliderMode,
          leading: db.getIconImage(skill.icon, width: 33),
          title: skill.localizedName,
          start: curVal.appendSkills[index],
          end: targetVal.appendSkills[index],
          minVal: 0,
          maxVal: 10,
          labelFormatter: (v) => v == 0 ? '-' : v.toString(),
          onValueChanged: (_start, _end) {
            status.favorite = true;
            curVal.appendSkills[index] = _start;
            targetVal.appendSkills[index] = _end;
            updateState();
          },
          detailPageBuilder: (context) => LevelingCostPage(
            costList: svt.itemCost.appendSkillWithCoin,
            title:
                '${S.current.append_skill} ${index + 1} - ${skill.localizedName}',
            curLv: curVal.appendSkills[index],
            targetLv: targetVal.appendSkills[index],
          ),
        ));
      }
      children.add(TileGroup(
        header: S.current.append_skill,
        children: appendSkillWidgets,
      ));
      children.add(TileGroup(
        children: [
          ListTile(
            horizontalTitleGap: 3,
            leading: InkWell(
              child: Item.iconBuilder(
                context: context,
                itemKey: svt.svtCoinIcon!,
                jumpToDetail: false,
                width: 33,
              ),
              onTap: () {
                SplitRoute.push(
                    context, ItemDetailPage(itemKey: Items.servantCoin));
              },
            ),
            title: Text(S.current.servant_coin),
            subtitle: Text(
                LocalizedText.of(chs: '召唤', jpn: 'ガチャ', eng: 'Summon', kor: '가챠') +
                    ': ${svt.coinSummonNum}'),
            trailing: SizedBox(
              width: 60,
              child: TextField(
                controller: _coinEditController,
                buildCounter: (context,
                        {required int currentLength,
                        required int? maxLength,
                        required bool isFocused}) =>
                    null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                maxLines: 1,
                maxLength: 4,
                onChanged: (v) {
                  int? coin = int.tryParse(v);
                  if (coin != null) {
                    status.coin = coin;
                    updateState();
                  }
                },
              ),
            ),
          ),
          if (svt.no != 1)
            buildPlanRow(
              useSlider: sliderMode,
              leading: Item.iconBuilder(
                  context: context, itemKey: Items.grail, width: 33),
              title: S.of(context).grail_up,
              start: curVal.grail,
              end: targetVal.grail,
              minVal: 0,
              maxVal: Grail.maxGrailCount(svt.info.rarity),
              labelFormatter: (v) =>
                  Grail.grailToLvMax(svt.info.rarity, v).toString(),
              trailingLabelFormatter: (a, b) =>
                  '${Grail.grailToLvMax(svt.info.rarity, a)}→'
                          '${Grail.grailToLvMax(svt.info.rarity, b!)}'
                      .padLeft(7),
              onValueChanged: (_start, _end) {
                status.favorite = true;
                curVal.grail = _start;
                targetVal.grail = _end;
                updateState();
              },
              detailPageBuilder: (context) => LevelingCostPage(
                title: S.current.grail_up,
                costList: Grail.itemCost(svt.info.rarity),
                curLv: curVal.grail,
                targetLv: targetVal.grail,
                levelFormatter: (v) =>
                    'Lv.${Grail.grailToLvMax(svt.info.rarity, v)}',
              ),
            ),
        ],
      ));

      // Extra part: np/grail/fou-kun
      children.add(TileGroup(
        header: S.current.event_item_extra,
        children: <Widget>[
          buildPlanRow(
            useSlider: sliderMode,
            leading: db.getIconImage('宝具强化', width: 33),
            title: S.of(context).noble_phantasm_level,
            start: status.npLv,
            minVal: 1,
            maxVal: 5,
            trailingLabelFormatter: (a, b) => '   $a   ',
            onValueChanged: (_value, _) {
              status.npLv = _value;
              status.favorite = true;
              db.notifyDbUpdate();
            },
            detailPageBuilder: null,
          ),
          buildPlanRow(
            useSlider: sliderMode,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Item.iconBuilder(
                    context: context, itemKey: Items.fou3Hp, width: 33),
                const SizedBox(width: 4),
                Item.iconBuilder(
                    context: context, itemKey: Items.fou4Hp, width: 33)
              ],
            ),
            title: LocalizedText.of(chs: 'HP芙芙', jpn: 'HPフォウ', eng: 'HP Fou', kor: 'HP 포우'),
            start: curVal.fouHp,
            end: targetVal.fouHp,
            minVal: -20,
            maxVal: 50,
            labelFormatter: (v) => Item.fouValToShown(v).toString(),
            trailingLabelFormatter: (a, b) =>
                '${curVal.shownFouHp}→${targetVal.shownFouHp}',
            onValueChanged: (_start, _end) {
              status.favorite = true;
              curVal.fouHp = _start;
              targetVal.fouHp = _end;
              updateState();
            },
            detailPageBuilder: null,
          ),
          buildPlanRow(
            useSlider: sliderMode,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Item.iconBuilder(
                    context: context, itemKey: Items.fou3Atk, width: 33),
                const SizedBox(width: 4),
                Item.iconBuilder(
                    context: context, itemKey: Items.fou4Atk, width: 33)
              ],
            ),
            title:
                LocalizedText.of(chs: 'ATK芙芙', jpn: 'ATKフォウ', eng: 'ATK Fou', kor: 'ATK 포우'),
            start: curVal.fouAtk,
            end: targetVal.fouAtk,
            minVal: -20,
            maxVal: 50,
            labelFormatter: (v) => Item.fouValToShown(v).toString(),
            trailingLabelFormatter: (a, b) =>
                '${curVal.shownFouAtk}→${targetVal.shownFouAtk}',
            onValueChanged: (_start, _end) {
              status.favorite = true;
              curVal.fouAtk = _start;
              targetVal.fouAtk = _end;
              updateState();
            },
            detailPageBuilder: null,
          ),
          buildPlanRow(
            useSlider: sliderMode,
            leading: Item.iconBuilder(
                context: context, itemKey: Items.chaldeaLantern, width: 33),
            title: S.current.game_kizuna,
            start: curVal.bondLimit,
            end: targetVal.bondLimit,
            minVal: 5,
            maxVal: 15,
            // labelFormatter: (v) => v == 15 ? '15' : '$v',
            // trailingLabelFormatter: (a, b) => '$a → $b',
            onValueChanged: (_start, _end) {
              status.favorite = true;
              curVal.bondLimit = _start;
              targetVal.bondLimit = _end;
              updateState();
            },
            detailPageBuilder: (context) => SimpleCancelOkDialog(
              title: Text(S.current.game_kizuna),
              hideCancel: true,
              content: Text(LocalizedText.of(
                chs: '数值为当前的羁绊上限，用于计算梦火消耗',
                jpn: '値は、カルデアの夢火の消費量を計算するために使用される、ボンドの現在の上限です。',
                eng:
                    'The value is the current bond limit, used for calculation of Chaldea Lantern',
                kor: '이 값은 칼데아의 몽화 소비량을 계산하기 위해 사용되는 포인트의 현재 상한입니다. '
              )),
            ),
          ),
        ],
      ));

      children.add(_buildCmdCodePlanner());

      return Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: children,
            ),
          ),
          buildButtonBar(targetVal),
        ],
      );
    });
  }

  Widget buildPlanRow({
    Widget? leading,
    String? title,
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
    if (end != null) {
      assert(start <= end && end <= maxVal);
    }
    labelFormatter ??= (v) => v.toString();
    trailingLabelFormatter ??= (a, b) {
      String s = labelFormatter!(a).padLeft(2);
      if (b != null) s += '→' + labelFormatter(b).padRight(2);
      return s;
    };
    Widget trailingIcon;
    if (detailPageBuilder != null) {
      trailingIcon = IconButton(
        icon: Icon(Icons.info_outline,
            color: Theme.of(context).colorScheme.secondary),
        onPressed: () =>
            showDialog(context: context, builder: detailPageBuilder),
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
          onChanged: (v) {
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
            onValueChanged(v.start.round(), v.end.round());
          },
        );
      }
      return CustomTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        titlePadding: EdgeInsets.zero,
        leading: leading,
        title: title == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 6, top: 4),
                child: AutoSizeText(title, maxLines: 1),
              ),
        subtitle: SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            rangeValueIndicatorShape:
                const PaddleRangeSliderValueIndicatorShape(),
            rangeTickMarkShape:
                const RoundRangeSliderTickMarkShape(tickMarkRadius: 1.2),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.2),
            activeTickMarkColor: Colors.grey[200],
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            rangeThumbShape:
                const RoundRangeSliderThumbShape(enabledThumbRadius: 6),
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
              child: Text(labelFormatter!(minVal + index)),
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
        // TODO: add divisions
        final items = List.generate((maxVal - minVal) ~/ (divisions ?? 1) + 1,
            (index) => minVal + index * (divisions ?? 1));
        selector = RangeSelector<int>(
          start: start,
          end: end,
          startEnabled: !enhanceMode,
          startItems: items,
          endItems: items,
          itemBuilder: (context, v) => Text(labelFormatter!(v)),
          onChanged: onValueChanged,
        );
      }
      return CustomTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        leading: leading,
        title: title == null ? null : AutoSizeText(title, maxLines: 1),
        subtitle: subtitle == null
            ? null
            : AutoSizeText(subtitle, maxLines: 1, minFontSize: 10),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[selector, trailingIcon],
        ),
      );
    }
  }

  Widget _buildCmdCodePlanner() {
    status.equipCmdCodes.length = svt.info.cards.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SHeader(S.current.command_code),
        Material(
          color: Theme.of(context).cardColor,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: List.generate(svt.info.cards.length, (index) {
              final code = db.gameData.cmdCodes[status.equipCmdCodes[index]];
              return TableRow(children: [
                db.getIconImage(svt.info.cards[index],
                    height: 48, padding: const EdgeInsets.all(4)),
                InkWell(
                  onTap: () async {
                    await SplitRoute.push(
                      context,
                      CmdCodeListPage(
                        onSelected: (selectedCode) {
                          status.equipCmdCodes[index] = selectedCode.no;
                          Navigator.of(context).pop();
                        },
                      ),
                      detail: false,
                      popDetail: false,
                    );
                    if (mounted) setState(() {});
                  },
                  child: db.getIconImage(code?.icon ?? '未知技能',
                      height: 48,
                      aspectRatio: 132 / 144,
                      padding: const EdgeInsets.all(4)),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    code?.lSkill ?? '',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      status.equipCmdCodes[index] = null;
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  tooltip: 'Remove',
                )
              ]);
            }),
            columnWidths: const {
              0: FixedColumnWidth(56),
              1: FixedColumnWidth(56),
              // 2:
              3: FixedColumnWidth(32)
            },
            border: TableBorder.all(
                color: const Color.fromRGBO(162, 169, 177, 1), width: 0.25),
          ),
        ),
      ],
    );
  }

  Widget buildButtonBar(ServantPlan targetPlan) {
    final curVal = status.curVal;
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
      buttons.add(IconButton(
        onPressed: () {
          final items =
              Item.sortMapById(svt.getAllCost(status: status, target: plan));
          SimpleCancelOkDialog(
            title: Text(S.current.item_total_demand),
            hideCancel: true,
            content: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final entry in items.entries)
                  Item.iconBuilder(
                    context: context,
                    itemKey: entry.key,
                    text: formatNumber(entry.value, compact: true),
                    width: 36,
                  ),
              ],
            ),
          ).showDialog(context);
        },
        icon: const Icon(Icons.info_outline),
        tooltip: S.current.item_total_demand,
      ));
      buttons.add(ElevatedButton(
        onPressed: () {
          setState(() {
            // reset enhance plan every time enter the enhance mode
            enhancePlan = ServantPlan.from(curVal);
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
        child: Text(S.of(context).ok),
      ));
    }

    buttons.add(const SizedBox(width: 8));

    // Lv.x or ≠
    bool skillLvEqual =
        Set.from((enhanceMode ? targetPlan : curVal).skills).length == 1;
    buttons.add(DropdownButton(
      value:
          skillLvEqual ? (enhanceMode ? targetPlan : curVal).skills[0] : null,
      hint: const Text('Lv. ≠'),
      items: List.generate(10,
          (i) => DropdownMenuItem(value: i + 1, child: Text('Lv. ${i + 1}'))),
      onChanged: _onAllSkillLv,
    ));

    // max ↑
    buttons.add(IconButton(
      icon: const Icon(Icons.vertical_align_top),
      tooltip: S.of(context).skilled_max10,
      onPressed: enhanceMode
          ? null
          : () {
              curVal.setMax(skill: 10);
              targetPlan.setMax(skill: 10);
              updateState();
            },
    ));

    // 999
    buttons.add(Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 8, 4), child: Text('9')),
        IconButton(
          icon: const Icon(Icons.trending_up),
          tooltip: S.of(context).plan_max9,
          onPressed: () {
            status.favorite = true;
            targetPlan.setMax(skill: 9);
            for (int i = 0; i < 3; i++) {
              if (enhanceMode) {
                // cur cannot change in enhance mode, change target to ensure target>cur
                targetPlan.skills[i] =
                    max(curVal.skills[i], targetPlan.skills[i]);
              } else {
                // change cur to ensure cur<=target
                curVal.skills[i] = min(curVal.skills[i], 9);
              }
            }
            updateState();
          },
        ),
      ],
    ));

    // 310
    buttons.add(Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 4, 4), child: Text('10')),
        IconButton(
          icon: const Icon(Icons.trending_up),
          tooltip: S.of(context).plan_max10,
          onPressed: () {
            status.favorite = true;
            targetPlan.setMax(skill: 10);
            updateState();
          },
        ),
      ],
    ));
    return Container(
      decoration: BoxDecoration(
          border: Border(top: Divider.createBorderSide(context, width: 0.5))),
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ButtonBar(
            children: buttons,
            buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
          ),
        ),
      ),
    );
  }

  void updateState() {
    db.itemStat.updateSvtItems(lapse: const Duration(seconds: 2));
    if (widget.parent != null) {
      widget.parent?.setState(() {});
    } else {
      setState(() {});
    }
  }

  void _onEnhance() {
    status.curVal.favorite = true;
    final enhanceItems = Item.sortMapById(svt.getAllCost(
      status: status,
      target: enhancePlan,
    ));
    List<Widget> children = [];
    enhanceItems.forEach((itemKey, number) {
      children.add(ImageWithText(
        onTap: () => SplitRoute.push(
          context,
          ItemDetailPage(itemKey: itemKey),
        ),
        image: db.getIconImage(itemKey),
        text: formatNumber(number, compact: true),
        padding: const EdgeInsets.only(right: 3),
      ));
    });
    bool hasItem = sum(enhanceItems.values) > 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).enhance_warning),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        content: SizedBox(
          width: defaultDialogWidth(context),
          child: hasItem
              ? buildGridIcons(
                  context: context,
                  children: children,
                  crossCount: 5,
                )
              : const ListTile(title: Text('Nothing')),
        ),
        actions: [
          TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text(S.of(context).confirm),
            onPressed: () {
              if (hasItem) {
                sumDict([db.curUser.items, multiplyDict(enhanceItems, -1)],
                    inPlace: true);
                status.curVal.copyFrom(enhancePlan);
                enhanceMode = !enhanceMode;
                updateState();
              }
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }

  void _onAllSkillLv(int? lv) {
    if (lv == null) return;
    final cur = status.curVal, target = enhanceMode ? enhancePlan : plan;
    cur.favorite = target.favorite = true;
    if (enhanceMode) {
      for (var i = 0; i < 3; i++) {
        // don't downgrade skill when enhancement
        target.skills[i] = max(lv, cur.skills[i]);
      }
    } else {
      cur.ascension = 4;
      for (var i = 0; i < 3; i++) {
        cur.skills[i] = lv;
        target.skills[i] = max(lv, target.skills[i]);
      }
    }
    updateState();
  }
}
