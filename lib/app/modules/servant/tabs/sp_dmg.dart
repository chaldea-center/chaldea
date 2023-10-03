import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/trait/trait.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/builders.dart';
import '../../common/misc.dart';

enum _SEScope {
  buff,
  td,
  ce,
  cc;

  String get shownName {
    switch (this) {
      case buff:
        return 'Buff';
      case td:
        return S.current.np_short;
      case ce:
        return S.current.craft_essence_short;
      case cc:
        return S.current.command_code_short;
    }
  }
}

class _GroupData {
  final List<int> traits;
  final bool useAnd;
  final int? rarity;
  final Map<_SEScope, Set<GameCardMixin>> cards = {};

  _GroupData({
    required this.traits,
    required this.useAnd,
    required this.rarity,
  });
}

class SvtSpDmgTab extends StatefulWidget {
  final Servant svt;
  const SvtSpDmgTab({super.key, required this.svt});

  @override
  State<SvtSpDmgTab> createState() => _SvtSpDmgTabState();
}

class _SvtSpDmgTabState extends State<SvtSpDmgTab> with SingleTickerProviderStateMixin {
  bool hasSpDmg = false;
  @override
  void initState() {
    super.initState();
    hasSpDmg = [
      ...widget.svt.skills,
      ...widget.svt.classPassive,
      ...widget.svt.extraPassiveNonEvent,
      ...widget.svt.noblePhantasms
    ].any((skill) => skill.functions.any((func) =>
        (const [BuffType.upDamage, BuffType.upDamageIndividuality, BuffType.upDamageIndividualityActiveonly]
                .contains(func.buff?.type) &&
            func.buff?.ckOpIndv.isNotEmpty == true) ||
        const [FuncType.damageNpIndividual, FuncType.damageNpIndividualSum, FuncType.damageNpStateIndividualFix]
            .contains(func.funcType)));
  }

  @override
  Widget build(BuildContext context) {
    if (!hasSpDmg) {
      return SpDmgIndivTab(
        svtIndivs: widget.svt.traitsAll.toList(),
        svtRarity: widget.svt.rarity,
      );
    }
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: SizedBox(
                      height: 36,
                      child: TabBar(
                        tabs: ["vs. Others", "vs. this"]
                            .map((e) => Tab(child: Text(e, style: Theme.of(context).textTheme.bodyMedium)))
                            .toList(),
                      ))),
            ],
          ),
          Expanded(
            child: TabBarView(children: [
              SpDmgSelfTab(svt: widget.svt),
              SpDmgIndivTab(
                svtIndivs: widget.svt.traitsAll.toList(),
                svtRarity: widget.svt.rarity,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class SpDmgSelfTab extends StatelessWidget {
  final Servant svt;
  const SpDmgSelfTab({super.key, required this.svt});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      for (final skill in [...svt.skills, ...svt.classPassive, ...svt.extraPassiveNonEvent, ...svt.noblePhantasms])
        ...checkSkills(context, skill),
    ]);
  }

  List<Widget> checkSkills(BuildContext context, SkillOrTd skill) {
    List<Widget> parts = [];
    for (final func in skill.functions) {
      List<NiceTrait> traits = [];
      bool useAnd = false;
      final buff = func.buff;
      if (buff != null &&
          const [BuffType.upDamage, BuffType.upDamageIndividuality, BuffType.upDamageIndividualityActiveonly]
              .contains(buff.type) &&
          buff.ckOpIndv.isNotEmpty) {
        traits = buff.ckOpIndv;
        useAnd = buff.script?.checkIndvTypeAnd == true;
      } else if (const [FuncType.damageNpIndividual, FuncType.damageNpStateIndividualFix].contains(func.funcType)) {
        final target = func.svals.firstOrNull?.Target;
        if (target != null) traits = [NiceTrait(id: target)];
        useAnd = false;
      } else if (const [FuncType.damageNpIndividualSum].contains(func.funcType)) {
        final targetList = func.svals.firstOrNull?.TargetList;
        if (targetList != null && targetList.isNotEmpty) traits = targetList.map((e) => NiceTrait(id: e)).toList();
        useAnd = false;
      }
      if (traits.isNotEmpty) {
        parts.add(const Divider(indent: 16, endIndent: 16));
        parts.add(FuncDescriptor(func: func));
        if (useAnd) {
          parts.add(ListTile(
            dense: true,
            selected: true,
            title: Text(traits.map((e) => e.shownName()).join(" & ")),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () {
              router.pushPage(TraitDetailPage.ids(ids: traits.map((e) => e.signedId).toList()));
            },
          ));
        } else {
          for (final trait in traits) {
            parts.add(ListTile(
              dense: true,
              selected: true,
              title: Text(trait.shownName()),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: trait.routeTo,
            ));
          }
        }
      }
    }
    if (parts.isNotEmpty) {
      return [
        Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                leading: skill is BaseTd
                    ? CommandCardWidget(card: skill.svt.card, width: 32)
                    : db.getIconImage(skill.icon, width: 28),
                title: Text(skill.lName.l),
                onTap: skill.routeTo,
              ),
              ...parts,
            ],
          ),
        )
      ];
    }
    return [];
  }
}

class SpDmgIndivTab extends StatefulWidget {
  final List<int> svtIndivs;
  final int? svtRarity;
  const SpDmgIndivTab({super.key, required this.svtIndivs, this.svtRarity});

  @override
  State<SpDmgIndivTab> createState() => _SpDmgIndivTabState();
}

class _SpDmgIndivTabState extends State<SpDmgIndivTab> {
  final type = FilterGroupData<_SEScope>();

  final data = <String, _GroupData>{};

  @override
  void initState() {
    super.initState();
    initData();
  }

  Set<GameCardMixin> getGroup(Iterable<int> traits, bool useAnd, int? rarity, _SEScope scope) {
    final ids = traits.toList();
    ids.toList();
    String key = [ids.join(useAnd ? '&' : '|'), rarity].join('+');
    return data
        .putIfAbsent(key, () => _GroupData(traits: ids, useAnd: useAnd, rarity: rarity))
        .cards
        .putIfAbsent(scope, () => {});
  }

  void initData() {
    data.clear();
    for (final card in db.gameData.servantsById.values) {
      checkBuffType(_SEScope.buff, card,
          [...card.skills, ...card.classPassive, ...card.extraPassiveNonEvent, ...card.noblePhantasms]);
      checkTdSE(_SEScope.td, card, card.noblePhantasms);
    }
    for (final card in db.gameData.craftEssencesById.values) {
      checkBuffType(_SEScope.ce, card, card.skills);
    }
    for (final card in db.gameData.commandCodesById.values) {
      checkBuffType(_SEScope.cc, card, card.skills);
    }
  }

  void checkBuffType(_SEScope scope, GameCardMixin card, List<SkillOrTd> skills) {
    for (final skill in skills) {
      for (final func in skill.functions) {
        if (func.buffs.isEmpty) continue;
        final buff = func.buffs.first;
        if (![
          BuffType.upDamage,
          // BuffType.upDamageIndividuality,
          // BuffType.upDamageIndividualityActiveonly,
        ].contains(buff.type)) {
          continue;
        }
        if (buff.ckOpIndv.isEmpty) continue;
        if (buff.script?.checkIndvTypeAnd == true) {
          if (buff.ckOpIndv.every((e) => widget.svtIndivs.contains(e.signedId))) {
            getGroup(buff.ckOpIndv.map((e) => e.signedId), true, null, scope).add(card);
          }
        } else {
          for (final trait in buff.ckOpIndv) {
            if (widget.svtIndivs.contains(trait.signedId)) {
              getGroup([trait.signedId], false, null, scope).add(card);
            }
          }
        }
      }
    }
  }

  void checkTdSE(_SEScope scope, GameCardMixin card, List<SkillOrTd> tds) {
    for (final td in tds) {
      for (final func in td.functions) {
        final vals = func.svals.getOrNull(0);
        if (vals == null) continue;
        switch (func.funcType) {
          case FuncType.damageNpIndividual:
          case FuncType.damageNpStateIndividualFix:
            if (vals.Target != null && widget.svtIndivs.contains(vals.Target)) {
              getGroup([vals.Target!], false, null, scope).add(card);
            }
            break;
          case FuncType.damageNpIndividualSum:
            if (vals.TargetList != null) {
              for (final trait in vals.TargetList!) {
                if (widget.svtIndivs.contains(trait)) {
                  getGroup([trait], false, null, scope).add(card);
                }
              }
            }
            break;
          case FuncType.damageNpRare:
            if (widget.svtRarity != null && vals.TargetRarityList?.contains(widget.svtRarity) == true) {
              getGroup([], false, widget.svtRarity!, scope).add(card);
            }
            break;
          case FuncType.damageNpStateIndividual:
          case FuncType.damageNpAndCheckIndividuality:
            // not used
            break;
          default:
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: buildBody()),
        kDefaultDivider,
        SafeArea(
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              FilterGroup(
                options: _SEScope.values,
                values: type,
                combined: true,
                onFilterChanged: (optionData, lastChanged) {
                  setState(() {});
                },
                optionBuilder: (v) => Text(v.shownName),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    final scopes = type.options.isEmpty ? _SEScope.values.toList() : type.options.toList();
    scopes.sort2((e) => e.index);
    List<Widget> children = [];
    for (final group in data.values) {
      final cards = <GameCardMixin>{for (final scope in scopes) ...?group.cards[scope]}.toList();
      if (cards.isEmpty) continue;
      children.add(Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(TextSpan(
                children: [
                  ...SharedBuilder.traitSpans(
                    context: context,
                    traits: group.traits.map((e) => NiceTrait(id: e)).toList(),
                    useAndJoin: group.useAnd,
                  ),
                  if (group.rarity != null) TextSpan(text: '${S.current.rarity} $kStarChar2${group.rarity}')
                ],
              )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 2,
                runSpacing: 4,
                children: [
                  for (final card in cards) card.iconBuilder(context: context, width: 48),
                ],
              )
            ],
          ),
        ),
      ));
    }
    return ListView(children: children);
  }
}

class SpDmgIndivPage extends StatelessWidget {
  final Widget? title;
  final List<int> svtIndivs;
  const SpDmgIndivPage({super.key, this.title, required this.svtIndivs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title ?? Text(S.current.super_effective_damage)),
      body: SpDmgIndivTab(svtIndivs: svtIndivs),
    );
  }
}
