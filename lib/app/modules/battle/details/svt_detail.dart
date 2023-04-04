import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../enemy/quest_enemy.dart';

class BattleSvtDetail extends StatefulWidget {
  final BattleServantData svt;
  final BattleData? battleData;
  const BattleSvtDetail({super.key, required this.svt, required this.battleData});

  @override
  State<BattleSvtDetail> createState() => _BattleSvtDetailState();
}

class _BattleSvtDetailState extends State<BattleSvtDetail> with SingleTickerProviderStateMixin {
  static int tabIndex = 0;
  late final TabController _tabController;

  BattleServantData get svt => widget.svt;
  BattleData? get battleData => widget.battleData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: tabIndex.clamp(0, 1));
    _tabController.addListener(() {
      tabIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) => [_sliverBuilder(context)]),
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: TabBarView(
            controller: _tabController,
            children: [buffTab, infoTab],
          ),
        ),
      ),
    );
  }

  Widget _sliverBuilder(BuildContext context) {
    final icon = svt.niceEnemy?.icon ?? svt.niceSvt?.ascendIcon(svt.limitCount);
    return SliverAppBar(
      title: AutoSizeText(svt.lBattleName, maxLines: 1),
      actions: [
        _popupButton,
      ],
      pinned: true,
      expandedHeight: 150,
      toolbarHeight: AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.grey,
                // child: const SizedBox.expand(),
              ),
            ),
            if (icon != null)
              Positioned.fill(
                child: CachedImage(
                  imageUrl: icon,
                  placeholder: (context, url) => const SizedBox(),
                  cachedOption: const CachedImageOption(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment(0.0, 0.0),
                  ),
                ),
              ),
            if (icon != null)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    color: Colors.grey[800]?.withOpacity(Theme.of(context).isDarkMode ? 0.75 : 0.65),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight - 16),
              child: SafeArea(child: header),
            ),
          ],
        ),
      ),
      bottom: tabBar,
    );
  }

  Widget get header {
    return CustomTile(
      leading: svt.niceEnemy?.iconBuilder(
            context: context,
            width: 72,
          ) ??
          svt.niceSvt?.iconBuilder(
            context: context,
            width: 72,
            overrideIcon: svt.niceSvt?.ascendIcon(svt.limitCount, true),
          ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No.${svt.niceEnemy?.shownId ?? svt.niceSvt?.shownId ?? svt.svtId}'
            '  ${Transl.svtClassId(svt.svtClass.id).l}'
            '\nATK ${svt.atk}  HP ${svt.hp}'
            '\nPosition ${svt.index + 1}',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: 4),
        ],
      ),
      titlePadding: const EdgeInsetsDirectional.only(start: 16),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () {
        if (svt.isEnemy) {
          svt.niceEnemy?.routeTo();
        } else if (svt.isPlayer) {
          svt.niceSvt?.routeTo();
        }
      },
    );
  }

  PreferredSizeWidget get tabBar {
    return FixedHeight.tabBar(Align(
      alignment: AlignmentDirectional.centerStart,
      child: TabBar(
        controller: _tabController,
        // labelColor: Theme.of(context).colorScheme.secondary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        // unselectedLabelColor: Colors.grey,
        tabs: [const Tab(text: 'Buff'), Tab(text: S.current.card_info)],
        indicatorColor: Theme.of(context).isDarkMode ? null : Colors.white.withAlpha(210),
      ),
    ));
  }

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          const PopupMenuItem(enabled: false, child: Text('Nothing')),
        ];
      },
    );
  }

  Widget get infoTab {
    List<Widget> shiftNpcs = [];
    const curEnemyStyle = TextStyle(decoration: TextDecoration.underline);
    if (svt.isEnemy && svt.shiftNpcIds.isNotEmpty) {
      final enemy = svt.niceEnemy?.deck == DeckType.enemy ? svt.niceEnemy : null;
      shiftNpcs.add(Text('Init HP ${enemy?.hp ?? "???"}', style: enemy == null ? null : curEnemyStyle));
    }
    for (final npcId in svt.shiftNpcIds) {
      final enemy = battleData?.enemyDecks[DeckType.shift]?.firstWhereOrNull((e) => e.npcId == npcId);
      if (enemy == null) {
        shiftNpcs.add(Text('NPC $npcId'));
      } else {
        shiftNpcs.add(Text.rich(
          SharedBuilder.textButtonSpan(
            context: context,
            text: '$npcId: HP ${enemy.hp}',
            onTap: () {
              router.pushPage(QuestEnemyDetail(enemy: enemy));
            },
          ),
          style: enemy == svt.niceEnemy ? curEnemyStyle : null,
        ));
      }
    }
    shiftNpcs = divideList(shiftNpcs, const Text(' → '));
    List<Widget> children = [
      CustomTable(children: [
        if (shiftNpcs.isNotEmpty) ...[
          CustomTableRow.fromTexts(texts: const ['Shift'], isHeader: true),
          CustomTableRow.fromChildren(children: [
            Wrap(
              alignment: WrapAlignment.center,
              children: shiftNpcs,
            )
          ])
        ],
        CustomTableRow.fromTexts(
          texts: [
            S.current.info_alignment,
            S.current.info_death_rate,
            S.current.info_critical_rate,
          ],
          isHeader: true,
        ),
        CustomTableRow.fromTexts(
          texts: [
            Transl.svtAttribute(svt.attribute).l,
            _dscPercent(svt.deathRate, 10),
            svt.isEnemy ? _dscPercent(svt.niceEnemy!.criticalRate, 10) : svt.niceSvt!.starAbsorb.toString(),
          ],
        ),
        if (svt.isEnemy) ...[
          CustomTableRow.fromTexts(
            texts: [
              S.current.np_gain_mod,
              S.current.def_np_gain_mod,
              S.current.crit_star_mod,
            ],
            isHeader: true,
          ),
          CustomTableRow.fromTexts(
            texts: [
              _dscPercent(svt.enemyTdRate, 10),
              _dscPercent(svt.enemyTdAttackRate, 10),
              _dscPercent(svt.enemyStarRate, 10),
            ],
          ),
        ],
        CustomTableRow.fromTexts(
          texts: [S.current.trait],
          isHeader: true,
        ),
        CustomTableRow.fromChildren(
            children: [SharedBuilder.traitList(context: context, traits: svt.getBasicSvtTraits()..sort2((e) => e.id))]),
      ])
    ];

    children.add(DividerWithTitle(title: S.current.noble_phantasm, indent: 16, padding: const EdgeInsets.only(top: 8)));
    final td = battleData == null ? svt.td : svt.getCurrentNP(battleData!);
    children.add(SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          leading: td == null
              ? db.getIconImage(Atlas.common.emptySkillIcon, width: 32, aspectRatio: 1)
              : CommandCardWidget(card: td.card, width: 38),
          title: Text("${S.current.noble_phantasm} Lv.${td == null ? '-' : svt.tdLv}"),
          subtitle: Text(svt.td?.nameWithRank ?? "NONE"),
        );
      },
      contentBuilder: (context) {
        if (td == null) return const Center(child: Text('\nNONE\n'));
        return TdDescriptor(td: td, showEnemy: svt.isEnemy, level: svt.tdLv);
      },
    ));
    children.add(DividerWithTitle(title: S.current.active_skill, indent: 16));
    for (final skillNum in kActiveSkillNums) {
      final skill = svt.skillInfoList.getOrNull(skillNum - 1);
      final baseSkill = skill?.proximateSkill;
      children.add(SimpleAccordion(
        headerBuilder: (context, _) {
          return ListTile(
            dense: true,
            leading: SizedBox(
              width: 40,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: db.getIconImage(
                    baseSkill?.icon ?? Atlas.common.emptySkillIcon,
                    width: 32,
                    aspectRatio: 1,
                  ),
                ),
              ),
            ),
            title: Text("${S.current.skill} $skillNum  Lv.${baseSkill == null ? '-' : skill?.skillLv}"),
            subtitle: Text(skill?.lName ?? "NONE"),
          );
        },
        contentBuilder: (context) {
          if (baseSkill == null) return const Center(child: Text('\nNONE\n'));
          return SkillDescriptor(skill: baseSkill, showEnemy: svt.isEnemy, level: skill?.skillLv);
        },
      ));
    }
    return ListView(children: children);
  }

  Widget get buffTab {
    List<Widget> children = [];

    children.add(const SHeader('Active Buffs'));
    for (final buff in svt.battleBuff.activeList) {
      children.add(buildBuff(buff));
    }
    children.add(const SHeader('Passive Buffs'));
    for (final buff in svt.battleBuff.passiveList) {
      children.add(buildBuff(buff));
    }
    // children.add(const SHeader('Command Code Buffs'));
    // for (final buff in svt.battleBuff.commandCodeList) {
    //   children.add(buildBuff(buff));
    // }

    return ListView(children: children);
  }

  Widget buildBuff(BuffData buff) {
    final valueSpans = <InlineSpan>[
      if (buff.count >= 0) TextSpan(text: Transl.special.funcValCountTimes(buff.count)),
      if (buff.turn >= 0) TextSpan(text: Transl.special.funcValTurns(buff.turn)),
      // else S.current.battle_buff_permanent,
      if (buff.param != 0 && !kBuffValueTriggerTypes.containsKey(buff.buff.type))
        TextSpan(
          text: Buff.formatRate(buff.buff.type, buff.param),
          style: ((kBuffActionPercentTypes[buff.buff.buffAction] ?? kBuffTypePercentType[buff.buff.type]) == null)
              ? const TextStyle(fontStyle: FontStyle.italic)
              : null,
        ),
    ];
    if (valueSpans.isEmpty) valueSpans.add(const TextSpan(text: ' - '));
    return ListTile(
      dense: true,
      horizontalTitleGap: 4,
      leading: Container(
        decoration: buff.irremovable
            ? BoxDecoration(
                border: Border.all(color: Theme.of(context).hintColor),
                borderRadius: BorderRadius.circular(2),
              )
            : const BoxDecoration(),
        padding: const EdgeInsets.all(1),
        child: db.getIconImage(buff.buff.icon, width: 24, aspectRatio: 1),
      ),
      title: Text(buff.buff.name.isEmpty
          ? FuncDescriptor.buildBasicFuncText(NiceFunction(
              funcId: 0,
              funcType: FuncType.addState,
              funcTargetType: FuncTargetType.self,
              funcTargetTeam: FuncApplyTarget.playerAndEnemy,
              buffs: [buff.buff],
              svals: [DataVals(buff.vals.toJson(sort: false)..['Value'] = buff.param)],
            )).toString()
          : buff.buff.lName.l),
      subtitle: Text(buff.buff.lDetail.l),
      trailing: InkWell(
        onTap: () {
          Map<String, dynamic> vals = buff.vals.toJson(sort: false);
          if (vals['Value'] != buff.param) {
            vals = {
              'param': buff.param,
              ...vals,
            };
          }
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              return Theme(
                data: ThemeData.light(),
                child: SimpleCancelOkDialog(
                  title: const Text('Data Vals'),
                  content: JsonViewer(vals, defaultOpen: true),
                  scrollable: true,
                  hideCancel: true,
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 12.0, 24.0),
                ),
              );
            },
          );
        },
        child: Text.rich(
          TextSpan(children: divideList(valueSpans, const TextSpan(text: '\n'))),
          textAlign: TextAlign.end,
          textScaleFactor: 0.9,
        ),
      ),
      onTap: () {
        buff.buff.routeTo();
      },
    );
  }
}

String _dscPercent(int v, int base) {
  return '${(v / base).toString().replaceFirst(RegExp(r'\.0+$'), '')}%';
}
