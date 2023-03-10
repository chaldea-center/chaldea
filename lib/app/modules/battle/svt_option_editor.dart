import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
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
    topListChildren.add(CustomTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      titlePadding: EdgeInsets.zero,
      leading: const Text('Lv'),
      title: Slider(
        min: 1,
        max: 120,
        divisions: 119,
        value: playerSvtData.lv.toDouble(),
        label: playerSvtData.lv.toString(),
        onChanged: (v) {
          playerSvtData.lv = v.round();
          _updateState();
        },
      ),
      trailing: SizedBox(width: 30, child: Text(playerSvtData.lv.toString())),
    ));
    topListChildren.add(CustomTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      titlePadding: EdgeInsets.zero,
      leading: const Text('ATK Fou'),
      title: Slider(
        min: 0,
        max: 200,
        divisions: 200,
        value: playerSvtData.atkFou / 10,
        onChanged: (v) {
          final int fou = v.round() * 10;
          if (fou > 1000 && fou % 20 == 10) {
            playerSvtData.atkFou = fou - 10;
          } else {
            playerSvtData.atkFou = fou;
          }
          _updateState();
        },
      ),
      trailing: SizedBox(width: 40, child: Text(playerSvtData.atkFou.toString())),
    ));
    topListChildren.add(CustomTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      titlePadding: EdgeInsets.zero,
      leading: const Text('HP Fou'),
      title: Slider(
        min: 0,
        max: 200,
        divisions: 200,
        value: playerSvtData.hpFou / 10,
        onChanged: (v) {
          final int fou = v.round() * 10;
          if (fou > 1000 && fou % 20 == 10) {
            playerSvtData.hpFou = fou - 10;
          } else {
            playerSvtData.hpFou = fou;
          }
          _updateState();
        },
      ),
      trailing: SizedBox(width: 40, child: Text(playerSvtData.hpFou.toString())),
    ));

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
    final ascensionText = faces.ascension != null && faces.ascension!.containsKey(playerSvtData.ascension)
        ? '${S.current.ascension} ${playerSvtData.ascension}'
        : faces.costume != null && faces.costume!.containsKey(playerSvtData.ascension)
            ? svt.profile.costume[playerSvtData.ascension]?.lName.l ?? '${S.current.costume} ${playerSvtData.ascension}'
            : 'Unknown Ascension';

    return CustomTile(
      leading: playerSvtData.svt!.iconBuilder(
        context: context,
        height: 72,
        jumpToDetail: true,
        overrideIcon: ServantSelector.getSvtAscensionBorderedIconUrl(playerSvtData.svt!, playerSvtData.ascension),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(svt.lName.l),
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
                        playerSvtData.ascension = ascension;
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
                    title: Text(S.current.svt_ascension_icon),
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

  void _updateState() {
    if (mounted) {
      setState(() {});
      onChange();
    }
  }
}
