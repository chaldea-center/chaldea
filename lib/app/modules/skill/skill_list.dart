import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_page_base.dart';
import 'skill_filter.dart';

class SkillListPage extends StatefulWidget {
  final void Function(BaseSkill? skill, int? skillId)? onSelected;
  const SkillListPage({super.key, this.onSelected});

  @override
  _SkillListPageState createState() => _SkillListPageState();
}

class _SkillListPageState extends State<SkillListPage> with SearchableListState<BaseSkill?, SkillListPage> {
  final filterData = SkillFilterData();

  int? get _searchSkillId {
    final _id = int.tryParse(searchEditingController.text);
    if (_id != null && _id >= 0 && !db.gameData.baseSkills.containsKey(_id)) {
      return _id;
    }
    return null;
  }

  @override
  Iterable<BaseSkill?> get wholeData {
    int? _id = _searchSkillId;
    return [
      if (_id != null) null,
      ...db.gameData.baseSkills.values,
    ];
  }

  @override
  bool get prototypeExtent => true;

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => (a?.id ?? 0) - (b?.id ?? 0));
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.skill),
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => SkillFilter(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  bool filter(BaseSkill? skill) {
    if (skill == null) return true;
    if (!filterData.type.matchOne(skill.type)) {
      return false;
    }
    if (!filterData.funcTargetType.matchAny(skill.functions.map((e) => e.funcTargetType))) {
      return false;
    }
    if (!filterData.funcType.matchAny(skill.functions.map((e) => e.funcType))) {
      return false;
    }
    if (!filterData.buffType
        .matchAny(skill.functions.where((e) => e.buffs.isNotEmpty).map((e) => e.buffs.first.type))) {
      return false;
    }

    return true;
  }

  @override
  Iterable<String?> getSummary(BaseSkill? skill) sync* {
    if (skill == null) {
      yield _searchSkillId?.toString();
      return;
    }
    yield skill.id.toString();
    yield* SearchUtil.getSkillKeys(skill);
  }

  @override
  Widget listItemBuilder(BaseSkill? skill) {
    return ListTile(
      dense: true,
      leading: skill?.icon == null ? const SizedBox(height: 28, width: 28) : db.getIconImage(skill?.icon, height: 28),
      horizontalTitleGap: 8,
      title: Text.rich(
        TextSpan(
          text: skill?.lName.l ?? "Skill $_searchSkillId",
          children: [
            if (skill != null)
              TextSpan(text: '\n${skill.id} ${skill.type.name}', style: Theme.of(context).textTheme.bodySmall)
          ],
        ),
      ),
      onTap: () {
        if (widget.onSelected != null) {
          Navigator.pop(context, skill);
          widget.onSelected!(skill, _searchSkillId);
          return;
        }
        final id = skill?.id ?? _searchSkillId;
        if (id != null) router.popDetailAndPush(context: context, url: Routes.skillI(id));
      },
    );
  }

  @override
  Widget gridItemBuilder(BaseSkill? skill) => throw UnimplementedError('GridView not designed');
}
