import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class PlayerSvtDefaultLvEditPage extends StatefulWidget {
  const PlayerSvtDefaultLvEditPage({super.key});

  @override
  State<PlayerSvtDefaultLvEditPage> createState() => _PlayerSvtDefaultLvEditPageState();
}

class _PlayerSvtDefaultLvEditPageState extends State<PlayerSvtDefaultLvEditPage> {
  PlayerSvtDefaultData get defaultLvs => db.settings.battleSim.defaultLvs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.default_lvs)),
      body: ListView(
        children: [
          CheckboxListTile(
            dense: true,
            title: Text('Lv. @${S.current.max_limit_break}'),
            value: defaultLvs.useMaxLv,
            onChanged: (v) {
              setState(() {
                if (v != null) defaultLvs.useMaxLv = v;
              });
            },
          ),
          disable(
            disabled: defaultLvs.useMaxLv,
            child: SliderWithPrefix(
              label: 'Level',
              min: 1,
              max: 120,
              value: defaultLvs.lv,
              valueText: defaultLvs.lv.toString(),
              onChange: (v) {
                setState(() {
                  defaultLvs.lv = v.toInt();
                });
              },
            ),
          ),
          SliderWithPrefix(
            label: S.current.ascension_short,
            min: 0,
            max: 4,
            value: defaultLvs.limitCount,
            valueText: defaultLvs.limitCount.toString(),
            onChange: (v) {
              setState(() {
                defaultLvs.limitCount = v.toInt();
              });
            },
          ),
          const Divider(height: 16),
          CheckboxListTile(
            dense: true,
            title: Text('${S.current.np_short} Lv: ${S.current.general_default}'),
            subtitle: Text('0-3$kStarChar+${S.current.event}: Lv.5, 4$kStarChar: Lv.2, 5$kStarChar: Lv.1'),
            value: defaultLvs.useDefaultTdLv,
            onChanged: (v) {
              setState(() {
                if (v != null) defaultLvs.useDefaultTdLv = v;
              });
            },
          ),
          disable(
            disabled: defaultLvs.useDefaultTdLv,
            child: SliderWithPrefix(
              label: '${S.current.np_short} Lv',
              min: 1,
              max: 5,
              value: defaultLvs.tdLv,
              valueText: defaultLvs.tdLv.toString(),
              onChange: (v) {
                setState(() {
                  defaultLvs.tdLv = v.toInt();
                });
              },
            ),
          ),
          const Divider(height: 16),
          SliderWithPrefix(
            label: S.current.active_skill_short,
            min: 1,
            max: 10,
            value: defaultLvs.activeSkillLv,
            valueText: defaultLvs.activeSkillLv.toString(),
            onChange: (v) {
              setState(() {
                defaultLvs.activeSkillLv = v.toInt();
              });
            },
          ),
          const Divider(height: 16),
          for (int index = 0; index < defaultLvs.appendLvs.length; index++)
            SliderWithPrefix(
              label: '${S.current.append_skill_short}${index + 1}',
              min: 0,
              max: 10,
              value: defaultLvs.appendLvs[index],
              valueText: defaultLvs.appendLvs[index].toString(),
              onChange: (v) {
                setState(() {
                  defaultLvs.appendLvs[index] = v.toInt();
                });
              },
            ),
          const Divider(height: 16),
          SFooter(S.current.default_lvs_hint)
        ],
      ),
    );
  }

  Widget disable({required bool disabled, required Widget child}) {
    if (!disabled) return child;
    return Opacity(opacity: 0.5, child: AbsorbPointer(child: child));
  }
}
