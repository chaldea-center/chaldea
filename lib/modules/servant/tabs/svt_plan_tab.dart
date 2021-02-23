//@dart=2.9
import 'dart:math' show max, min;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';

import '../servant_detail_page.dart';
import 'leveling_cost_page.dart';
import 'svt_tab_base.dart';

class SvtPlanTab extends SvtTabBaseWidget {
  SvtPlanTab(
      {Key key,
      ServantDetailPageState parent,
      Servant svt,
      ServantStatus status})
      : super(key: key, parent: parent, svt: svt, status: status);

  @override
  State<StatefulWidget> createState() =>
      _SvtPlanTabState(parent: parent, svt: svt, status: status);
}

class _SvtPlanTabState extends SvtTabBaseState<SvtPlanTab> {
  /// in edit mode, change skill lv_a to lv_b and take out the items
  bool enhanceMode = false;
  ServantPlan enhancePlan;

  ServantPlan get plan => db.curUser.svtPlanOf(svt.no);

  _SvtPlanTabState(
      {ServantDetailPageState parent, Servant svt, ServantStatus status})
      : super(parent: parent, svt: svt, status: status);

  /// valid range include start and end
  int _ensureInRange(int v, int start, int end) {
    v = v ?? start;
    if (v < start) return start;
    if (v > end) return end;
    return v;
  }

  void ensureTargetLarger(ServantPlan cur, ServantPlan target) {
    // first ensure valid too
    cur.ascension = _ensureInRange(cur.ascension, 0, 4);
    target.ascension = max(target.ascension, cur.ascension);
    for (var i = 0; i < cur.skills.length; i++) {
      cur.skills[i] = _ensureInRange(cur.skills[i], 1, 10);
      target.skills[i] = max(target.skills[i], cur.skills[i]);
    }
    target.fixDressLength(cur.dress.length, 0);
    for (var i = 0; i < cur.dress.length; i++) {
      cur.dress[i] = _ensureInRange(cur.dress[i], 0, 1);
      target.dress[i] = max(target.dress[i] ?? 0, cur.dress[i]);
    }
    cur.grail = _ensureInRange(cur.grail, 0, 10);
    target.grail = max(target.grail, cur.grail);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.activeSkills == null) {
      return Center(child: Text('Nothing'));
    }
    status.validate();
    final curVal = status.curVal;
    final targetVal = enhanceMode ? enhancePlan : plan;
    ensureTargetLarger(curVal, targetVal);
    // ascension part
    List<Widget> children = [];
    if (svt.no != 1) {
      children.add(TileGroup(
        header: S.of(context).ascension_up,
        children: <Widget>[
          buildPlanRow(
            title: S.of(context).ascension_up,
            start: curVal.ascension,
            end: targetVal.ascension,
            minVal: 0,
            maxVal: 4,
            onValueChanged: (_start, _end) {
              curVal
                ..ascension = _start
                ..favorite = true;
              targetVal
                ..ascension = _end
                ..favorite = true;
              db.userData.broadcastUserUpdate();
              db.itemStat.updateSvtItems();
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
    for (int index = 0; index < svt.activeSkills.length; index++) {
      final activeSkill = svt.activeSkills[index];
      Skill skill =
          activeSkill.skills[status.skillIndex[index] ?? activeSkill.cnState];
      String shownName =
          Language.isCN ? skill.name : (skill.nameJp ?? skill.name);
      skillWidgets.add(buildPlanRow(
        leading: db.getIconImage(skill.icon, width: 33),
        title: '$shownName ${skill.rank}',
        start: curVal.skills[index],
        end: targetVal.skills[index],
        minVal: 1,
        maxVal: 10,
        onValueChanged: (_start, _end) {
          curVal
            ..skills[index] = _start
            ..favorite = true;
          targetVal
            ..skills[index] = _end
            ..favorite = true;
          db.userData.broadcastUserUpdate();
          db.itemStat.updateSvtItems();
        },
        detailPageBuilder: (context) => LevelingCostPage(
          costList: svt.itemCost.skill,
          title: '${S.current.skill} ${index + 1} - ${skill.localizedName}',
          curLv: curVal.skills[index],
          targetLv: targetVal.skills[index],
        ),
      ));
    }
    children
        .add(TileGroup(header: S.of(context).skill_up, children: skillWidgets));

    // dress part
    List<Widget> dressWidgets = [];
    curVal.fixDressLength(svt.itemCost.dress.length, 0);
    targetVal.fixDressLength(svt.itemCost.dress.length, 0);
    for (int index = 0; index < svt.itemCost.dress.length; index++) {
      final dressNameCn = svt.itemCost.dressName[index];
      final dressNameJp = svt.itemCost.dressNameJp[index];
      dressWidgets.add(buildPlanRow(
        leading: db.getIconImage('灵衣开放权', width: 33),
        title: Language.isCN ? dressNameCn : dressNameJp,
        subtitle: Language.isCN ? dressNameJp : dressNameCn,
        start: curVal.dress[index],
        end: targetVal.dress[index],
        minVal: 0,
        maxVal: 1,
        onValueChanged: (_start, _end) {
          curVal
            ..dress[index] = _start
            ..favorite = true;
          targetVal
            ..dress[index] = _end
            ..favorite = true;
          db.userData.broadcastUserUpdate();
          db.itemStat.updateSvtItems();
        },
        detailPageBuilder: (context) => LevelingCostPage(
          costList: [svt.itemCost.dress[index]],
          title: '${S.current.dress_up} - ${svt.itemCost.dressName[index]}',
        ),
      ));
    }
    if (dressWidgets.length > 0) {
      children.add(
          TileGroup(header: S.of(context).dress_up, children: dressWidgets));
    }

    children.add(TileGroup(
      children: <Widget>[
        buildPlanRow(
          leading: db.getIconImage('宝具强化', width: 33),
          title: S.of(context).nobel_phantasm_level,
          start: status.npLv,
          minVal: 1,
          maxVal: 5,
          onValueChanged: (_value, _) {
            status.npLv = _value;
            curVal.favorite = true;
            plan.favorite = true;
            db.userData.broadcastUserUpdate();
          },
          detailPageBuilder: null,
        ),
        if (svt.no != 1)
          buildPlanRow(
            leading: db.getIconImage(Item.grail, width: 33),
            title: S.of(context).grail_up,
            start: curVal.grail,
            end: targetVal.grail,
            minVal: 0,
            maxVal: [10, 10, 10, 9, 7, 5][svt.info.rarity],
            itemBuilder: (v) => Text(svt.getGrailLv(v).toString()),
            onValueChanged: (_start, _end) {
              curVal
                ..grail = _start
                ..favorite = true;
              targetVal
                ..grail = _end
                ..favorite = true;
              db.userData.broadcastUserUpdate();
              db.itemStat.updateSvtItems();
            },
            detailPageBuilder: null,
          )
      ],
    ));

    return Column(
      children: <Widget>[
        Expanded(child: ListView(children: children)),
        buildButtonBar(targetVal),
      ],
    );
  }

  Widget buildPlanRow({
    Widget leading,
    String title,
    String subtitle,
    int start,
    int end,
    int minVal,
    int maxVal,
    Widget itemBuilder(int v),
    void Function(int, int) onValueChanged,
    WidgetBuilder detailPageBuilder,
  }) {
    assert(start != null && minVal <= start && start <= maxVal);
    if (end != null) {
      assert(start <= end && end <= maxVal);
    }
    if (itemBuilder == null) {
      itemBuilder = (v) => Text(v.toString());
    }
    Widget selector;
    if (end == null) {
      selector = DropdownButton(
        value: start,
        items: List.generate(
          maxVal - minVal + 1,
          (index) => DropdownMenuItem(
            value: minVal + index,
            child: itemBuilder(minVal + index),
          ),
        ),
        // disable at enhance mode
        onChanged: enhanceMode ? null : (v) => onValueChanged(v, -1),
      );
    } else {
      selector = RangeSelector<int>(
        start: start,
        end: end,
        startEnabled: !enhanceMode,
        startItems:
            List.generate(maxVal - minVal + 1, (index) => minVal + index),
        endItems: List.generate(maxVal - minVal + 1, (index) => minVal + index),
        itemBuilder: (context, v) => itemBuilder(v),
        onChanged: onValueChanged,
      );
    }
    return CustomTile(
      contentPadding: EdgeInsets.fromLTRB(16, 4, 0, 4),
      leading: leading,
      title: title == null ? null : AutoSizeText(title, maxLines: 1),
      subtitle: subtitle == null
          ? null
          : AutoSizeText(subtitle, maxLines: 1, minFontSize: 10),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          selector,
          IconButton(
            icon: Icon(Icons.info_outline,
                color: detailPageBuilder == null
                    ? Colors.grey
                    : Colors.blueAccent),
            onPressed: detailPageBuilder == null
                ? null
                : () =>
                    showDialog(context: context, builder: detailPageBuilder),
          )
        ],
      ),
    );
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
        style: ElevatedButton.styleFrom(
            primary:
                enhanceMode ? Colors.grey : Theme.of(context).primaryColor),
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
            curVal.favorite = true;
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
            curVal.favorite = true;
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
    State state; // = widget.parent ?? this;
    if (widget.parent != null)
      state = widget.parent;
    else
      state = this;
    state.setState(() {});
    if (!enhanceMode) {
      db.userData.broadcastUserUpdate();
      db.itemStat.updateSvtItems();
    }
  }

  void _onEnhance() {
    final enhanceItems = Item.sortMapById(svt.getAllCost(
      cur: status.curVal..favorite = true,
      target: enhancePlan..favorite = true,
    ));
    List<Widget> children = [];
    enhanceItems.forEach((itemKey, number) {
      children.add(ImageWithText(
        onTap: () => SplitRoute.push(
            context: context, builder: (context, _) => ItemDetailPage(itemKey)),
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
                  context: context, children: children, responsive: false)
              : Text('Nothing'),
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

  void _onAllSkillLv(int lv) {
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
