import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class HideSvtPlanDetailSettingPage extends StatefulWidget {
  const HideSvtPlanDetailSettingPage({super.key});

  @override
  State<HideSvtPlanDetailSettingPage> createState() => _HideSvtPlanDetailSettingPageState();
}

class _HideSvtPlanDetailSettingPageState extends State<HideSvtPlanDetailSettingPage> {
  List<SvtPlanDetail> get settings => db.settings.display.hideSvtPlanDetails;

  // also check it in validate()
  final persists = [SvtPlanDetail.activeSkill, SvtPlanDetail.appendSkill];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.hide_svt_plan_details)),
      body: ListView(
        children: [
          for (final value in SvtPlanDetail.values) _buildOption(value),
          SafeArea(child: SFooter(S.current.hide_svt_plan_details_hint))
        ],
      ),
    );
  }

  Widget _buildOption(SvtPlanDetail option) {
    bool enabled = !persists.contains(option);
    bool checked = !(enabled && settings.contains(option));
    return CheckboxListTile(
      value: checked,
      title: Text(_getName(option)),
      onChanged: enabled
          ? (v) {
              if (v != null) {
                if (v) {
                  settings.remove(option);
                } else {
                  settings.add(option);
                }
              }
              setState(() {});
            }
          : null,
    );
  }

  String _getName(SvtPlanDetail value) {
    return {
          SvtPlanDetail.ascension: S.current.ascension_up,
          SvtPlanDetail.activeSkill: S.current.active_skill,
          SvtPlanDetail.appendSkill: S.current.append_skill,
          SvtPlanDetail.costume: S.current.costume,
          SvtPlanDetail.grail: S.current.grail_up,
          SvtPlanDetail.noblePhantasm: S.current.noble_phantasm_level,
          SvtPlanDetail.fou4: '${kStarChar}4 ${S.current.foukun}',
          SvtPlanDetail.fou3: '${kStarChar}3 ${S.current.foukun}',
          SvtPlanDetail.bondLimit: S.current.bond_limit,
          SvtPlanDetail.commandCode: S.current.command_code,
        }[value] ??
        value.name;
  }
}
