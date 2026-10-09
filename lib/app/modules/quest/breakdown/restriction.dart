import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/descriptors/descriptor_base.dart';
import 'package:chaldea/app/descriptors/multi_entry.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class QuestRestrictionDescriptor extends StatelessWidget with DescriptorBase {
  final QuestPhaseRestriction restriction;
  final bool showReleaseHint;
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;
  @override
  final InlineSpan? leading;
  @override
  final EdgeInsetsGeometry? padding;

  const QuestRestrictionDescriptor({
    super.key,
    required this.restriction,
    this.showReleaseHint = true,
    this.style,
    this.textScaleFactor,
    this.leading,
    this.padding,
  });

  @override
  List<int> get targetIds => restriction.restriction.targetVals;
  @override
  bool? get useAnd => false;
  @override
  String? get unknownMsg => null;

  @override
  List<InlineSpan> traits(BuildContext context, {List<int>? overrideIds}) =>
      emptyHint(MultiDescriptor.traits(context, overrideIds ?? targetIds, useAnd: useAnd, addSvtId: false));

  String? get fallbackMessage {
    final re = restriction.restriction;
    final unparsed = switch (re.type) {
      RestrictionType.none || RestrictionType.fixedMyGrandSvt || RestrictionType.myGrandSvtPositionMain => true,
      RestrictionType.rarity ||
      RestrictionType.totalCost ||
      RestrictionType.lv ||
      RestrictionType.svtNum ||
      RestrictionType.mySvtNum => _comparison(re.rangeType, re.targetVals) == null,
      _ => false,
    };
    if (!unparsed) return null;
    for (final message in [restriction.dialogMessage, restriction.noticeMessage, restriction.title, re.name]) {
      if (_messageKey(message).isNotEmpty && _messageKey(message) != '0') return message.trim();
    }
    return null;
  }

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    final re = restriction.restriction;
    final vals = re.targetVals;
    final vals2 = re.targetVals2;
    var valsUsed = true;
    var vals2Used = false;
    List<InlineSpan> spans;
    switch (re.type) {
      case RestrictionType.individuality:
        spans = rich(
          re.rangeType == RestrictionRangeType.equal
              ? _l(
                  jp: '${_position(vals2)}編成可能な特性: ',
                  cn: '${_position(vals2)}仅可编入具有以下特性的从者：',
                  tw: '${_position(vals2)}僅可編入具有以下特性的從者：',
                  na: 'Only Servants ${_position(vals2)}with these traits: ',
                )
              : re.rangeType == RestrictionRangeType.notEqual
              ? _l(
                  jp: '${_position(vals2)}編成不可の特性: ',
                  cn: '${_position(vals2)}不可编入具有以下特性的从者：',
                  tw: '${_position(vals2)}不可編入具有以下特性的從者：',
                  na: 'Cannot use Servants ${_position(vals2)}with these traits: ',
                )
              : _l(
                  jp: '${_position(vals2)}編成特性制限: ',
                  cn: '${vals2.isEmpty ? '' : '${_position(vals2)}的'}编队特性限制：',
                  tw: '${vals2.isEmpty ? '' : '${_position(vals2)}的'}編隊特性限制：',
                  na: 'Formation trait restriction${vals2.isEmpty ? '' : ' ${_position(vals2).trim()}'}: ',
                ),
          traits(context),
        );
        vals2Used = true;
        break;
      case RestrictionType.rarity:
      case RestrictionType.totalCost:
      case RestrictionType.lv:
      case RestrictionType.svtNum:
      case RestrictionType.mySvtNum:
        final label = switch (re.type) {
          RestrictionType.rarity => S.current.filter_sort_rarity,
          RestrictionType.totalCost => S.current.cost,
          RestrictionType.lv => S.current.level,
          RestrictionType.mySvtNum => _l(jp: '自前サーヴァント数', cn: '自有从者数量', tw: '自有從者數量', na: 'Owned Servant count'),
          _ => _l(jp: 'サーヴァント数', cn: '从者数量', tw: '從者數量', na: 'Servant count'),
        };
        final comparison = _comparison(re.rangeType, vals);
        spans = text('$label${comparison == null ? '' : ' $comparison'}');
        valsUsed = comparison != null;
        if (comparison == null) {
          spans.add(TextSpan(text: ' (rangeType=${re.rangeType.name})'));
        }
        break;
      case RestrictionType.supportOnly:
        spans = text(_l(jp: 'サポートのみ出撃', cn: '仅支援从者出击', tw: '僅支援從者出擊', na: 'Deploy support Servants only'));
        valsUsed = false;
        break;
      case RestrictionType.uniqueSvtOnly:
        spans = text(
          _l(jp: '同一サーヴァントの複数編成不可', cn: '不可重复编入同一从者', tw: '不可重複編入同一從者', na: 'Cannot use duplicate Servants'),
        );
        valsUsed = false;
        break;
      case RestrictionType.fixedSupportPosition:
        spans = text(
          _l(
            jp: '${_slots(vals)}にサポートを編成',
            cn: '支援从者必须编入${_slots(vals)}',
            tw: '支援從者必須編入${_slots(vals)}',
            na: 'Support must occupy ${_slots(vals)}',
          ),
        );
        break;
      case RestrictionType.fixedMySvtIndividualityPositionMain:
        spans = rich(
          _l(
            jp: '${_position(vals2, frontline: true)}自前のサーヴァントを編成: ',
            cn: '必须${_position(vals2, frontline: true)}编入自有从者：',
            tw: '必須${_position(vals2, frontline: true)}編入自有從者：',
            na: 'Include owned Servants ${_position(vals2, frontline: true)}with traits: ',
          ),
          MultiDescriptor.traits(context, vals, useAnd: true, addSvtId: false),
        );
        vals2Used = true;
        break;
      case RestrictionType.fixedMySvtIndividualitySingle:
        spans = rich(
          _l(jp: '自前の編成可能なサーヴァント: ', cn: '自有从者仅可编入：', tw: '自有從者僅可編入：', na: 'Only these owned Servants may be used: '),
          traits(context),
        );
        // TODO_local: Decode vals2=[1] for fixedMySvtIndividualitySingle (5000102, 94155622).
        break;
      case RestrictionType.mySvtOrNpc:
        assert(vals2.length <= 1, 'Unexpected mySvtOrNpc positions: $vals2');
        spans = rich(
          _l(
            jp: '${_position(vals2)}自前またはNPCのサーヴァントを編成: ',
            cn: '${_position(vals2)}编入自有或NPC从者：',
            tw: '${_position(vals2)}編入自有或NPC從者：',
            na: 'Use an owned or NPC Servant ${_position(vals2)}with traits: ',
          ),
          traits(context),
        );
        if (vals2.length > 1) {
          spans.add(
            TextSpan(
              text: _l(jp: '（推定）', cn: '（推测）', tw: '（推測）', na: ' (inferred)'),
            ),
          );
        }
        vals2Used = true;
        break;
      case RestrictionType.mySvtOrSupport:
        spans = rich(
          _l(
            jp: '${_position(vals2)}自前の',
            cn: '${_position(vals2)}编入自有从者：',
            tw: '${_position(vals2)}編入自有從者：',
            na: 'Use an owned Servant ${_position(vals2)}with traits: ',
          ),
          traits(context),
          _l(jp: '、またはサポートを編成', cn: '，或支援从者', tw: '，或支援從者', na: ', or a support Servant'),
        );
        vals2Used = true;
        break;
      case RestrictionType.fixedSvtIndividualityPositionMain:
        spans = rich(
          re.rangeType == RestrictionRangeType.notEqual
              ? _l(
                  jp: '${S.current.team_starting_member}に編成不可: ',
                  cn: '不可编入${S.current.team_starting_member}：',
                  tw: '不可編入${S.current.team_starting_member}：',
                  na: 'Cannot include in the ${S.current.team_starting_member}: ',
                )
              : _l(
                  jp: '${S.current.team_starting_member}に編成必須: ',
                  cn: '必须编入${S.current.team_starting_member}：',
                  tw: '必須編入${S.current.team_starting_member}：',
                  na: 'Must include in the ${S.current.team_starting_member}: ',
                ),
          traits(context),
        );
        break;
      case RestrictionType.uniqueIndividuality:
        spans = rich(
          _l(
            jp: '以下の特性のサーヴァントは複数編成不可: ',
            cn: '不可重复编入具有以下特性的从者：',
            tw: '不可重複編入具有以下特性的從者：',
            na: 'Cannot use duplicates with these traits: ',
          ),
          traits(context),
        );
        break;
      case RestrictionType.alloutBattleUniqueSvt:
        spans = rich(
          _l(jp: 'サーヴァントは', cn: '在', tw: '在', na: 'Each Servant may deploy only once within '),
          vals.isEmpty ? text(S.current.event) : MultiDescriptor.events(context, [vals.first]),
          _l(
            jp: '${vals.length >= 2 ? 'のグループ${vals[1]}' : ''}で一度のみ出撃可能',
            cn: '${vals.length >= 2 ? '的第${vals[1]}组' : ''}内，每名从者仅可出击一次',
            tw: '${vals.length >= 2 ? '的第${vals[1]}組' : ''}內，每名從者僅可出擊一次',
            na: vals.length >= 2 ? ' (group ${vals[1]})' : '',
          ),
        );
        valsUsed = vals.length <= 2;
        break;
      case RestrictionType.dataLostBattleUniqueSvt:
        spans = text(
          _l(
            jp: 'DATA LOSTしたサーヴァントは編成不可',
            cn: 'DATA LOST的从者不可编入',
            tw: 'DATA LOST的從者不可編入',
            na: 'Cannot use DATA LOST Servants',
          ),
        );
        // TODO_local: Decode vals=[1] for dataLostBattleUniqueSvt (3001198).
        valsUsed = false;
        break;
      case RestrictionType.myGrandSvt:
      case RestrictionType.myGrandSvtOrSupportGrandSvt:
        // TODO_local: Decode vals2 for myGrandSvt (94150500=[2], 94158300/94161201=[1]).
        final count = re.type == RestrictionType.myGrandSvtOrSupportGrandSvt && vals2.length == 1 ? vals2.single : null;
        spans = text(
          re.type == RestrictionType.myGrandSvt
              ? _l(jp: '自前のグランドサーヴァントを編成', cn: '必须编入自有冠位从者', tw: '必須編入自有冠位從者', na: 'Include an owned Grand Servant')
              : _l(
                  jp: '自前またはサポートのグランドサーヴァントを${count == null ? '' : '$count騎'}編成',
                  cn: '必须编入${count == null ? '' : '$count骑'}自有或支援冠位从者',
                  tw: '必須編入${count == null ? '' : '$count騎'}自有或支援冠位從者',
                  na: count == null
                      ? 'Include an owned or support Grand Servant'
                      : 'Include $count owned or support Grand ${count == 1 ? 'Servant' : 'Servants'}',
                ),
        );
        if (vals.isNotEmpty && !(vals.length == 1 && vals.single == 0)) {
          spans.add(
            TextSpan(
              text: re.rangeType == RestrictionRangeType.notEqual
                  ? _l(jp: '（除外特性: ', cn: '（排除特性：', tw: '（排除特性：', na: ' (excluding traits: ')
                  : _l(jp: '（特性: ', cn: '（特性：', tw: '（特性：', na: ' (traits: '),
            ),
          );
          spans.addAll(traits(context));
          spans.add(const TextSpan(text: ')'));
        }
        vals2Used = re.type == RestrictionType.myGrandSvtOrSupportGrandSvt && vals2.length <= 1;
        break;
      case RestrictionType.activeGrandBoard:
        spans = text(
          _l(
            jp: 'グランドサーヴァントは${_slots(vals)}のみ編成可能',
            cn: '冠位从者仅可编入${_slots(vals)}',
            tw: '冠位從者僅可編入${_slots(vals)}',
            na: 'Grand Servants may only occupy ${_slots(vals)}',
          ),
        );
        break;
      case RestrictionType.fixedCostume:
        spans = rich(
          _l(jp: '', cn: '固定', tw: '固定', na: 'Fix the ${S.current.costume} of '),
          traits(context),
          _l(jp: 'の${S.current.costume}を固定', cn: '的${S.current.costume}', tw: '的${S.current.costume}', na: ''),
        );
        break;
      case RestrictionType.none:
      case RestrictionType.fixedMyGrandSvt:
      case RestrictionType.myGrandSvtPositionMain:
        spans = text('${S.current.quest_restriction}: ${re.type.name} (rangeType=${re.rangeType.name})');
        valsUsed = false;
        break;
    }
    final original = fallbackMessage;
    if (original != null) {
      spans = text(original);
      valsUsed = true;
      vals2Used = true;
    }
    if (!valsUsed && vals.isNotEmpty) spans.add(TextSpan(text: ' (vals=${vals.join('/')})'));
    if (!vals2Used && vals2.isNotEmpty) {
      // Preserve unparsed vals2; see the unresolved examples documented above.
      spans.add(TextSpan(text: ' (vals2=${vals2.join('/')})'));
    }
    if (showReleaseHint && (restriction.script?.releaseConditions?.isNotEmpty ?? false)) {
      spans.add(
        TextSpan(
          text: _l(jp: '（開放条件あり）', cn: '（有开放条件）', tw: '（有開放條件）', na: ' (has release conditions)'),
        ),
      );
    }
    return spans;
  }

  String _position(List<int> positions, {bool frontline = false}) {
    if (positions.isEmpty && !frontline) return '';
    final allFrontline =
        frontline && (positions.isEmpty || positions.toSet().length == 3 && positions.toSet().containsAll([1, 2, 3]));
    final location = allFrontline
        ? S.current.team_starting_member
        : frontline
        ? _l(
            jp: '${S.current.team_starting_member}の${_slots(positions)}',
            cn: '${S.current.team_starting_member}${_slots(positions)}',
            tw: '${S.current.team_starting_member}${_slots(positions)}',
            na: '${_slots(positions)} of the ${S.current.team_starting_member}',
          )
        : _slots(positions);
    return _l(jp: '$locationに', cn: '在$location', tw: '在$location', na: 'in ${allFrontline ? 'the ' : ''}$location ');
  }

  String _slots(List<int> positions) {
    final slots = positions.join('/');
    return _l(
      jp: '$slots番目',
      cn: '第$slots号位',
      tw: '第$slots號位',
      na: '${positions.length > 1 ? 'slots' : 'slot'} $slots',
    );
  }

  String? _comparison(RestrictionRangeType range, List<int> vals) {
    if (range == RestrictionRangeType.between) {
      return vals.length == 2 ? '${vals[0]} ~ ${vals[1]}' : null;
    }
    if (vals.length != 1) return null;
    final op = switch (range) {
      RestrictionRangeType.equal => '=',
      RestrictionRangeType.notEqual => '≠',
      RestrictionRangeType.above => '≥',
      RestrictionRangeType.below => '≤',
      _ => null,
    };
    return op == null ? null : '$op${vals.single}';
  }
}

class QuestRestrictionPage extends StatelessWidget {
  final List<QuestPhaseRestriction> restrictions;
  final String questName;
  const QuestRestrictionPage({super.key, required this.restrictions, required this.questName});

  static List<(String, String)> messageRows(QuestPhaseRestriction restriction, {String? fallbackMessage}) {
    final groups = <String, (List<String>, String)>{};
    final fallbackKey = fallbackMessage == null ? null : _messageKey(fallbackMessage);
    for (final (label, message) in [
      (_l(jp: 'タイトル', cn: '标题', tw: '標題', na: 'Title'), restriction.title),
      (S.current.name, restriction.restriction.name),
      (_l(jp: 'お知らせ', cn: '通知', tw: '通知', na: 'Notice'), restriction.noticeMessage),
      (_l(jp: 'ダイアログ', cn: '提示', tw: '提示', na: 'Dialog'), restriction.dialogMessage),
    ]) {
      final key = _messageKey(message);
      if (key.isEmpty || key == '0' || key == fallbackKey) continue;
      final group = groups.putIfAbsent(key, () => ([], message.trim().replaceAll(_messageWhitespace, ' ')));
      group.$1.add(label);
    }
    return [for (final (labels, message) in groups.values) (labels.join(' / '), message)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('[${S.current.quest_restriction}] $questName')),
      body: InheritSelectionArea(
        child: SafeArea(
          top: false,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: restrictions.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) => _buildRestriction(context, restrictions[index], index),
          ),
        ),
      ),
    );
  }

  Widget _buildRestriction(BuildContext context, QuestPhaseRestriction restriction, int index) {
    final releases = restriction.script?.releaseConditions ?? const <CommonRelease>[];
    final groups = <int, List<CommonRelease>>{};
    for (final release in releases) {
      groups.putIfAbsent(release.condGroup, () => []).add(release);
    }
    final descriptor = QuestRestrictionDescriptor(
      restriction: restriction,
      showReleaseHint: false,
      leading: TextSpan(text: '${index + 1}. '),
      style: Theme.of(context).textTheme.bodyMedium,
    );
    final messages = messageRows(restriction, fallbackMessage: descriptor.fallbackMessage);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        descriptor,
        if (groups.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(S.current.effective_condition, style: Theme.of(context).textTheme.labelMedium),
                if (groups.length > 1)
                  Text(S.current.common_release_group_hint, style: Theme.of(context).textTheme.bodySmall),
                for (final groupId in groups.keys.toList()..sort())
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (groups.length > 1)
                          Text(
                            '${_l(jp: 'グループ', cn: '组', tw: '組', na: 'Group')} $groupId',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        for (final release in groups[groupId]!)
                          CondTargetValueDescriptor.commonRelease(
                            commonRelease: release,
                            leading: const TextSpan(text: '• '),
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        for (final (label, message) in messages)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, top: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '[$label] ',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  TextSpan(text: message),
                ],
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

final _messageWhitespace = RegExp(r'[\s\u3000]+');
String _messageKey(String message) => message.replaceAll(_messageWhitespace, '');

String _l({required String jp, required String cn, required String tw, required String na}) =>
    M.of(jp: jp, cn: cn, tw: tw, na: na, k: na);
