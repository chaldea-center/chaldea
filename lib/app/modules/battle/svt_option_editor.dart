import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/servant/tabs/td_tab.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/widgets/widgets.dart';

import 'battle_simulation.dart';

class ServantOptionEditPage extends StatefulWidget {
  final PlayerSvtData playerSvtData;
  final VoidCallback onChange;

  ServantOptionEditPage({super.key, required this.playerSvtData, required this.onChange});

  @override
  State<ServantOptionEditPage> createState() => _ServantOptionEditPageState();
}

class _ServantOptionEditPageState extends State<ServantOptionEditPage> {
  PlayerSvtData get playerSvtData => widget.playerSvtData;

  Servant get svt => playerSvtData.svt!;

  VoidCallback get onChange => widget.onChange;

  @override
  Widget build(final BuildContext context) {
    final List<Widget> topListChildren = [];
    topListChildren.add(_header(context));
    topListChildren.add(_buildSlider(
      leadingText: 'Lv',
      min: 1,
      max: 120,
      value: playerSvtData.lv,
      label: playerSvtData.lv.toString(),
      onChange: (v) {
        playerSvtData.lv = v.round();
        _updateState();
      },
    ));
    topListChildren.add(_buildSlider(
      leadingText: 'ATK Fou',
      min: 0,
      max: 200,
      value: playerSvtData.atkFou ~/ 10,
      label: playerSvtData.atkFou.toString(),
      onChange: (v) {
        final int fou = v.round() * 10;
        if (fou > 1000 && fou % 20 == 10) {
          playerSvtData.atkFou = fou - 10;
        } else {
          playerSvtData.atkFou = fou;
        }
        _updateState();
      },
    ));
    topListChildren.add(_buildSlider(
      leadingText: 'HP Fou',
      min: 0,
      max: 200,
      value: playerSvtData.hpFou ~/ 10,
      label: playerSvtData.hpFou.toString(),
      onChange: (v) {
        final int fou = v.round() * 10;
        if (fou > 1000 && fou % 20 == 10) {
          playerSvtData.hpFou = fou - 10;
        } else {
          playerSvtData.hpFou = fou;
        }
        _updateState();
      },
    ));
    topListChildren.add(_buildNPSection());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AutoSizeText('Edit Servant Option', maxLines: 1),
        centerTitle: false,
      ),
      body: ListView(
        children: divideTiles(
          topListChildren,
          divider: const Divider(height: 8, thickness: 2),
        ),
      ),
    );
  }

  Widget _header(final BuildContext context) {
    final faces = svt.extraAssets.faces;
    final ascensionText = svt.profile.costume.containsKey(playerSvtData.asensionPhase)
        ? svt.profile.costume[playerSvtData.asensionPhase]!.lName.l
        : '${S.current.ascension} ${playerSvtData.asensionPhase == 0 ? 1 : playerSvtData.asensionPhase}';
    return CustomTile(
      leading: playerSvtData.svt!.iconBuilder(
        context: context,
        height: 72,
        jumpToDetail: true,
        overrideIcon: ServantSelector.getSvtAscensionBorderedIconUrl(playerSvtData.svt!, playerSvtData.asensionPhase),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Transl.svtNames(ServantSelector.getSvtName(svt, playerSvtData.asensionPhase)).l),
          Text(
            'No.${svt.collectionNo > 0 ? svt.collectionNo : svt.id}'
            '  ${Transl.svtClassId(svt.classId).l}',
          ),
          TextButton(
            child: Text(ascensionText),
            onPressed: () async {
              await null;
              if (!mounted) return;
              await showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  final List<Widget> children = [];
                  void _addOne(final int ascension, final String name, final String? icon) {
                    if (icon == null) return;
                    final borderedIcon = svt.bordered(icon);
                    children.add(ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: db.getIconImage(
                        borderedIcon,
                        width: 36,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      title: Text(name),
                      onTap: () {
                        final ascensionPhase = ascension == 1 ? 0 : ascension;
                        final List<NiceTd> previousShownTds = ServantSelector.getShownTds(svt, playerSvtData.asensionPhase);
                        final List<NiceTd> shownTds = ServantSelector.getShownTds(svt, ascensionPhase);
                        playerSvtData.asensionPhase = ascensionPhase;
                        if (previousShownTds.length != shownTds.length) {
                          playerSvtData.npStrengthenLv = svt.groupedNoblePhantasms.first.indexOf(shownTds.last) + 1;
                          logger.d('Capping npStrengthenLv: ${playerSvtData.npStrengthenLv}');
                        }
                        Navigator.pop(context);
                      },
                    ));
                  }

                  if (faces.ascension != null) {
                    faces.ascension!.forEach((key, value) {
                      _addOne(key, '${S.current.ascension} $key', value);
                    });
                  }
                  if (faces.costume != null) {
                    faces.costume!.forEach((key, value) {
                      _addOne(
                        key,
                        svt.profile.costume[key]?.lName.l ?? '${S.current.costume} $key',
                        value,
                      );
                    });
                  }

                  return SimpleCancelOkDialog(
                    title: const Text('Change Ascension'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: children,
                      ),
                    ),
                    hideOk: true,
                  );
                },
              );
              _updateState();
            },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildNPSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSlider(
          leadingText: 'NP Lv',
          min: 1,
          max: 5,
          value: playerSvtData.npLv,
          label: playerSvtData.npLv.toString(),
          onChange: (v) {
            playerSvtData.npLv = v.round();
            _updateState();
          },
        ),
        _buildTdDescriptor(),
      ],
    );
  }

  Widget _buildTdDescriptor() {
    final int ascension = playerSvtData.asensionPhase;
    final List<NiceTd> shownTds = ServantSelector.getShownTds(svt, ascension);
    final ascensionOverride = svt.ascensionAdd.overWriteTDName.all.containsKey(ascension)
        ? OverrideTDData(
            tdName: svt.ascensionAdd.overWriteTDName.all[ascension],
            tdRuby: svt.ascensionAdd.overWriteTDRuby.all[ascension],
            tdFileName: svt.ascensionAdd.overWriteTDFileName.all[ascension],
            tdRank: svt.ascensionAdd.overWriteTDRank.all[ascension],
            tdTypeText: svt.ascensionAdd.overWriteTDTypeText.all[ascension],
          )
        : null;
    ascensionOverride?.keys.add(ascension);

    if (shownTds.length == 1 && shownTds.first.condQuestId <= 0) {
      return TdDescriptor(
        td: shownTds.first,
        showEnemy: !svt.isUserSvt,
        level: playerSvtData.npLv,
        overrideData: ascensionOverride,
      );
    }

    final td = svt.groupedNoblePhantasms.first[playerSvtData.npStrengthenLv - 1];

    final toggle = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: FilterGroup<NiceTd>(
            shrinkWrap: true,
            combined: true,
            options: shownTds,
            optionBuilder: (selectedTd) {
              String name = ascensionOverride?.tdName ?? selectedTd.name;
              name = Transl.tdNames(name).l;
              final rank = ascensionOverride?.tdRank ?? selectedTd.rank;
              if (!['なし', '无', 'None', '無', '없음'].contains(rank)) {
                name = '$name $rank';
              }
              if (name.trim().isEmpty) name = '???';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(name),
              );
            },
            values: FilterRadioData.nonnull(td),
            onFilterChanged: (v, _) {
              playerSvtData.npStrengthenLv = svt.groupedNoblePhantasms.first.indexOf(v.radioValue!) + 1;
              logger.d('Changing npStrengthenLv: ${playerSvtData.npStrengthenLv}');
              _updateState();
            },
          ),
        ),
        if (td.condQuestId > 0 || ascensionOverride != null)
          IconButton(
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 24,
            ),
            onPressed: () => showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) => SvtTdTab.releaseCondition(svt, td, ascensionOverride),
            ),
            icon: const Icon(Icons.info_outline),
            color: Theme.of(context).hintColor,
            tooltip: S.current.open_condition,
          ),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        toggle,
        TdDescriptor(
          td: td,
          showEnemy: !svt.isUserSvt,
          level: playerSvtData.npLv,
          overrideData: ascensionOverride,
        ),
      ],
    );
  }

  Widget _buildSlider({
    required final String leadingText,
    required final int min,
    required final int max,
    required final int value,
    required final String label,
    required final ValueChanged<double> onChange,
  }) {
    return CustomTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      titlePadding: EdgeInsets.zero,
      leading: SizedBox(width: 65, child: Text(leadingText)),
      title: Slider(
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: max - min,
        value: value.toDouble(),
        label: label,
        onChanged: (v) {
          onChange(v);
        },
      ),
      trailing: SizedBox(width: 40, child: Text(label)),
    );
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
      onChange();
    }
  }
}
