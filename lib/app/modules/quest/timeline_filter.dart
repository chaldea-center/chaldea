import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

enum TimelineSortType {
  questOpenTime,
  apCampaignTime,
}

enum TimelineQuestType {
  skillRankUp,
  tdRankUp,
  interlude,
  ;

  String get shownName {
    switch (this) {
      case TimelineQuestType.skillRankUp:
        return S.current.skill_rankup;
      case TimelineQuestType.tdRankUp:
        return S.current.td_rankup;
      case TimelineQuestType.interlude:
        return S.current.interlude;
    }
  }
}

class SvtQuestTimelineFilterData {
  Region region = Region.jp;
  bool reversed = true;
  bool showOutdated = false;
  FavoriteState favorite = FavoriteState.all;
  final sortType =
      FilterRadioData<TimelineSortType>.nonnull(TimelineSortType.questOpenTime);
  final questType = FilterGroupData<TimelineQuestType>();

  void reset() {
    for (final v in <FilterGroupData>[sortType, questType]) {
      v.reset();
    }
  }

  bool get useApCampaign =>
      sortType.radioValue == TimelineSortType.apCampaignTime;
}

class SvtQuestTimelineFilter extends FilterPage<SvtQuestTimelineFilterData> {
  const SvtQuestTimelineFilter({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _SvtQuestTimelineFilterState createState() => _SvtQuestTimelineFilterState();
}

class _SvtQuestTimelineFilterState extends FilterPageState<
    SvtQuestTimelineFilterData, SvtQuestTimelineFilter> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter_sort, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: null, children: [
        SwitchListTile.adaptive(
          value: filterData.showOutdated,
          title: Text(S.current.show_outdated),
          onChanged: (v) {
            filterData.showOutdated = v;
            update();
          },
        ),
        FilterGroup<FavoriteState>(
          title: Text(S.current.favorite),
          options: FavoriteState.values,
          values: FilterRadioData.nonnull(filterData.favorite),
          combined: true,
          optionBuilder: (v) {
            return Text.rich(TextSpan(children: [
              CenterWidgetSpan(child: Icon(v.icon, size: 16)),
              TextSpan(text: v.shownName),
            ]));
          },
          onFilterChanged: (v, _) {
            filterData.favorite = v.radioValue!;
            update();
          },
        ),
        FilterGroup<TimelineQuestType>(
          title: Text(S.current.general_type, style: textStyle),
          options: TimelineQuestType.values,
          values: filterData.questType,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (v, _) {
            update();
          },
        ),
        FilterGroup<TimelineSortType>(
          title: Text(S.current.sort_order, style: textStyle),
          options: TimelineSortType.values,
          combined: true,
          values: filterData.sortType,
          optionBuilder: (v) {
            switch (v) {
              case TimelineSortType.questOpenTime:
                return Text(S.current.quest_timeline_sort_quest_open);
              case TimelineSortType.apCampaignTime:
                return Text(S.current.quest_timeline_sort_campaign_open);
            }
          },
          onFilterChanged: (v, _) {
            // filterData.region=Region.jp;
            update();
          },
        ),
      ]),
    );
  }
}
