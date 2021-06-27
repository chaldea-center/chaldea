import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/servant/costume_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../servant_detail_page.dart';
import 'leveling_cost_page.dart';
import 'svt_tab_base.dart';

class SvtPlanTab extends SvtTabBaseWidget {
  SvtPlanTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  State<StatefulWidget> createState() =>
      _SvtPlanTabState(parent: parent, svt: svt, status: status);
}

class _SvtPlanTabState extends SvtTabBaseState<SvtPlanTab> {
  /// in edit mode, change skill lv_a to lv_b and take out the items
  bool enhanceMode = false;

  ServantPlan enhancePlan = ServantPlan();

  ServantPlan get plan => db.curUser.svtPlanOf(svt.no);

  _SvtPlanTabState(
      {ServantDetailPageState? parent, Servant? svt, ServantStatus? status})
      : super(parent: parent, svt: svt, status: status);

  void ensureTargetLarger(ServantPlan cur, ServantPlan target) {
    target.validate(cur);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool sliderMode = widget.parent?.svtPlanSliderMode.get() ?? false;
    return db.streamBuilder((context) {
      if (svt.lActiveSkills.isEmpty) {
        return Center(child: Text('${svt.info.localizedName} has no skills'));
      }
      status.validate();
      final curVal = status.curVal;
      final targetVal = enhanceMode ? enhancePlan : plan;
      targetVal.validate(curVal);
      // ascension part
      List<Widget> children = [];
      if (svt.no != 1) {
        children.add(TileGroup(
          header: S.of(context).ascension_up,
          children: <Widget>[
            buildPlanRow(
              useSlider: sliderMode,
              leading: Container(
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
        final activeSkill = svt.lActiveSkills[index];
        int? _state;
        if (Servant.unavailable.contains(svt.no)) {
          _state = 0;
        } else {
          _state = status.skillIndex.getOrNull(index) ??
              (Language.isCN ? activeSkill.cnState : null);
        }
        _state ??= activeSkill.skills.length - 1;
        Skill skill = activeSkill.skills[_state];
        String shownName =
            Language.isCN ? skill.name : (skill.nameJp ?? skill.name);
        if (index >= 3) {
          skillWidgets.add(buildPlanRow(
              start: 0, minVal: 0, maxVal: 0, onValueChanged: (_, __) {}));
        } else {
          skillWidgets.add(buildPlanRow(
            useSlider: sliderMode,
            leading: db.getIconImage(skill.icon, width: 33),
            title: '$shownName ${skill.rank}',
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
              curLv: curVal.skills[index],
              targetLv: targetVal.skills[index],
            ),
          ));
        }
      }
      children.add(
          TileGroup(header: S.of(context).skill_up, children: skillWidgets));

      // dress part
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
              SplitRoute.push(
                context: context,
                builder: (context, _) => CostumeDetailPage(costume: costume),
              );
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
      if (dressWidgets.length > 0) {
        children.add(TileGroup(
            header: S.of(context).costume_unlock, children: dressWidgets));
      }
      children.add(TileGroup(
        children: <Widget>[
          buildPlanRow(
            useSlider: sliderMode,
            leading: db.getIconImage('宝具强化', width: 33),
            title: S.of(context).nobel_phantasm_level,
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
          if (svt.no != 1)
            buildPlanRow(
              useSlider: sliderMode,
              leading: Item.iconBuilder(
                  context: context, itemKey: Items.grail, width: 33),
              title: S.of(context).grail_up,
              start: curVal.grail,
              end: targetVal.grail,
              minVal: 0,
              maxVal: svt.getMaxGrailCount(),
              labelFormatter: (v) => svt.getGrailLv(v).toString(),
              trailingLabelFormatter: (a, b) =>
                  '${svt.getGrailLv(a)}->${svt.getGrailLv(b!).toString().padRight(3)}',
              onValueChanged: (_start, _end) {
                status.favorite = true;
                curVal.grail = _start;
                targetVal.grail = _end;
                updateState();
              },
              detailPageBuilder: null,
            ),
          buildPlanRow(
            useSlider: sliderMode,
            leading: Item.iconBuilder(
                context: context, itemKey: Items.fou4Hp, width: 33),
            title: Item.localizedNameOf(Items.fou4Hp),
            start: curVal.fouHp,
            end: targetVal.fouHp,
            minVal: 0,
            maxVal: 50,
            labelFormatter: (v) => (v * 20).toString(),
            trailingLabelFormatter: (a, b) =>
                '${curVal.shownFouHp}->${targetVal.shownFouHp}',
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
            leading: Item.iconBuilder(
                context: context, itemKey: Items.fou4Atk, width: 33),
            title: Item.localizedNameOf(Items.fou4Atk),
            start: curVal.fouAtk,
            end: targetVal.fouAtk,
            minVal: 0,
            maxVal: 50,
            labelFormatter: (v) => (v * 20).toString(),
            trailingLabelFormatter: (a, b) =>
                '${curVal.shownFouAtk}->${targetVal.shownFouAtk}',
            onValueChanged: (_start, _end) {
              status.favorite = true;
              curVal.fouAtk = _start;
              targetVal.fouAtk = _end;
              updateState();
            },
            detailPageBuilder: null,
          ),
        ],
      ));

      return Column(
        children: <Widget>[
          Expanded(child: ListView(children: children)),
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
    String labelFormatter(int v)?,
    String trailingLabelFormatter(int a, int? b)?,
    required void onValueChanged(int start, int end),
    bool useSlider = false,
    WidgetBuilder? detailPageBuilder,
  }) {
    assert(minVal <= start && start <= maxVal);
    if (end != null) {
      assert(start <= end && end <= maxVal);
    }
    if (labelFormatter == null) {
      labelFormatter = (v) => v.toString();
    }
    if (trailingLabelFormatter == null) {
      trailingLabelFormatter = (a, b) {
        String s = labelFormatter!(a).padLeft(2);
        if (b != null) s += '->' + labelFormatter(b).padRight(2);
        return s;
      };
    }
    Widget trailingIcon = IconButton(
      icon: Icon(Icons.info_outline,
          color: detailPageBuilder == null ? Colors.grey : Colors.blueAccent),
      onPressed: detailPageBuilder == null
          ? null
          : () => showDialog(context: context, builder: detailPageBuilder),
    );
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
        contentPadding: EdgeInsets.fromLTRB(16, 0, 0, 0),
        titlePadding: EdgeInsets.zero,
        leading: leading,
        title: title == null
            ? null
            : Padding(
                padding: EdgeInsets.only(left: 6, top: 4),
                child: AutoSizeText(title, maxLines: 1),
              ),
        subtitle: SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            rangeValueIndicatorShape: PaddleRangeSliderValueIndicatorShape(),
            rangeTickMarkShape:
                RoundRangeSliderTickMarkShape(tickMarkRadius: 1.2),
            tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 1.2),
            activeTickMarkColor: Colors.grey[200],
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Container(height: 23, child: slider),
        ),
        trailing: Text(trailingLabelFormatter(start, end),
            style: TextStyle(fontFamily: kMonoFont)),
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
        selector = RangeSelector<int>(
          start: start,
          end: end,
          startEnabled: !enhanceMode,
          startItems:
              List.generate(maxVal - minVal + 1, (index) => minVal + index),
          endItems:
              List.generate(maxVal - minVal + 1, (index) => minVal + index),
          itemBuilder: (context, v) => Text(labelFormatter!(v)),
          onChanged: onValueChanged,
        );
      }
      return CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 0, 0, 0),
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

  Widget buildButtonBar(ServantPlan targetPlan) {
    final curVal = status.curVal;
    List<Widget> buttons = [];
    // 强化 or 取消
    buttons.add(
      ElevatedButton(
        onPressed: () => setState(() {
          // reset enhance plan every time enter the enhance mode
          enhancePlan = ServantPlan.from(curVal);
          enhanceMode = !enhanceMode;
        }),
        child: Text(enhanceMode ? S.of(context).cancel : S.of(context).enhance),
      ),
    );

    // 确定
    if (enhanceMode) {
      buttons.add(ElevatedButton(
        onPressed: _onEnhance,
        child: Text(S.of(context).ok),
      ));
    }

    // Lv.x or ≠
    bool skillLvEqual =
        Set.from((enhanceMode ? targetPlan : curVal).skills).length == 1;
    buttons.add(DropdownButton(
      value:
          skillLvEqual ? (enhanceMode ? targetPlan : curVal).skills[0] : null,
      hint: Text('Lv. ≠'),
      items: List.generate(10,
          (i) => DropdownMenuItem(value: i + 1, child: Text('Lv. ${i + 1}'))),
      onChanged: _onAllSkillLv,
    ));

    // max ↑
    buttons.add(IconButton(
      icon: Icon(Icons.vertical_align_top),
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
        Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 4), child: Text('9')),
        IconButton(
          icon: Icon(Icons.trending_up),
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
        Padding(padding: EdgeInsets.fromLTRB(0, 0, 4, 4), child: Text('10')),
        IconButton(
          icon: Icon(Icons.trending_up),
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
          fit: BoxFit.contain,
          child: ButtonBar(children: buttons),
        ),
      ),
    );
  }

  void updateState() {
    db.itemStat.updateSvtItems(lapse: Duration(seconds: 1));
    if (widget.parent != null)
      widget.parent?.setState(() {});
    else
      setState(() {});
  }

  void _onEnhance() {
    final enhanceItems = Item.sortMapById(svt.getAllCost(
      cur: status.curVal..favorite = true,
      target: enhancePlan,
    ));
    List<Widget> children = [];
    enhanceItems.forEach((itemKey, number) {
      children.add(ImageWithText(
        onTap: () => SplitRoute.push(
          context: context,
          builder: (context, _) => ItemDetailPage(itemKey: itemKey),
        ),
        image: db.getIconImage(itemKey),
        text: formatNumber(number, compact: true),
        padding: EdgeInsets.only(right: 3),
      ));
    });
    bool hasItem = sum(enhanceItems.values) > 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).enhance_warning),
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        content: Container(
          width: defaultDialogWidth(context),
          child: hasItem
              ? buildResponsiveGridWrap(
                  context: context,
                  children: children,
                  responsive: true,
                  crossCount: 5,
                )
              : ListTile(title: Text('Nothing')),
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
