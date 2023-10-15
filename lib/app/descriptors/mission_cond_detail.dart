import 'package:chaldea/app/modules/master_mission/solver/scheme.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'descriptor_base.dart';
import 'multi_entry.dart';

class MissionCondDetailDescriptor extends HookWidget with DescriptorBase {
  final int? targetNum;
  final EventMissionConditionDetail detail;
  final bool? _useAnd;
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;
  @override
  final InlineSpan? leading;
  final int? eventId;
  @override
  final String? unknownMsg;

  MissionCondDetailDescriptor({
    super.key,
    required this.targetNum,
    required this.detail,
    this.style,
    this.textScaleFactor,
    this.leading,
    bool? useAnd,
    this.eventId,
    this.unknownMsg,
  }) : _useAnd = useAnd;

  @override
  bool? get useAnd {
    if (_useAnd != null) return _useAnd;
    final type = CustomMission.kDetailCondMapping[detail.missionCondType];
    switch (type) {
      case CustomMissionType.trait:
        // https://github.com/atlasacademy/apps/commit/5f989cd9979a3f6313cc3e7eb349f7487bf607a7
        if (detail.missionCondType == DetailCondType.enemyIndividualityKillNum.id) {
          return false;
        } else if (detail.missionCondType == DetailCondType.defeatEnemyIndividuality.id) {
          return true;
        }
        return true;
      case CustomMissionType.questTrait:
        return false;
      case CustomMissionType.quest:
      case CustomMissionType.enemy:
      case CustomMissionType.servantClass:
      case CustomMissionType.enemyClass:
      case CustomMissionType.enemyNotServantClass:
        return false;
      case null:
        return null;
    }
  }

  @override
  List<int> get targetIds => detail.targetIds;

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    String targetNum = this.targetNum?.toString() ?? 'x';
    final condType = DetailCondType.parseId(detail.missionCondType);
    switch (condType) {
      case DetailCondType.questClearIndividuality:
        return localized(
          jp: () => rich(context, null, traits(context), 'フィールドのクエストを$targetNum回クリアせよ'),
          cn: () => rich(context, '通关$targetNum次场地为', traits(context), '的关卡'),
          tw: () => rich(context, '通關$targetNum次場地為', traits(context)),
          na: () => rich(context, 'Clear $targetNum quests with fields ', traits(context)),
          kr: () => rich(context, null, traits(context), '필드의 프리 퀘스트를 $targetNum회 클리어'),
        );
      case DetailCondType.questClearOnce: // once?
      case DetailCondType.questClearNum1:
      case DetailCondType.questClearNum2:
      case DetailCondType.questClearNumIncludingGrailFront:
        if (targetIds.length == 1 && targetIds.first == 0) {
          return localized(
            jp: () => text('いずれかのクエストを$targetNum回クリアせよ'),
            cn: () => text('通关$targetNum次任意关卡'),
            tw: () => text('通關$targetNum次任意關卡'),
            na: () => text('Complete any quest $targetNum times'),
            kr: () => text('퀘스트를 $targetNum회 클리어'),
          );
        } else {
          return localized(
            jp: () => rich(context, '以下のクエストを$targetNum回クリアせよ', quests(context)),
            cn: () => rich(context, '通关$targetNum次以下关卡', quests(context)),
            tw: () => rich(context, '通關$targetNum次以下關卡', quests(context)),
            na: () => rich(context, '$targetNum runs of quests ', quests(context)),
            kr: () => rich(context, '아래의 퀘스트를 $targetNum회 클리어', quests(context)),
          );
        }
      case DetailCondType.questTypeClear:
        final types = targetIds.map((e) => kQuestTypeIds[e]?.shownName ?? 'Unknown QuestType $e').join('/');
        return localized(
          jp: null,
          cn: () => text('通关$targetNum次类型为[$types]的关卡'),
          tw: () => text('通關$targetNum次類型為[$types]的關卡'),
          na: () => text('Clear $targetNum times of [$types] quests'),
          kr: null,
        );
      case DetailCondType.warMainQuestClear:
        return localized(
          jp: null,
          cn: () => rich(context, '通关$targetNum次以下章节的主线关卡: ', wars(context)),
          tw: () => rich(context, '通關$targetNum次以下章節的主線關卡: ', wars(context)),
          na: () => rich(context, 'Clear $targetNum times main quests from ', wars(context)),
          kr: null,
        );
      case DetailCondType.enemyKillNum:
      case DetailCondType.targetQuestEnemyKillNum:
        return localized(
          jp: () => rich(context, null, servants(context), 'の敵を$targetNum体倒せ'),
          cn: () => rich(context, '击败$targetNum个敌人:', servants(context)),
          tw: () => rich(context, '擊敗$targetNum個敵人:', servants(context)),
          na: () => rich(context, 'Defeat $targetNum from enemies ', servants(context)),
          kr: () => rich(context, null, servants(context), '계열의 적을 $targetNum마리 처치'),
        );
      case DetailCondType.defeatEnemyIndividuality:
      case DetailCondType.enemyIndividualityKillNum:
      case DetailCondType.targetQuestEnemyIndividualityKillNum:
        return localized(
          jp: () => rich(context, null, traits(context), '特性を持つ敵を$targetNum体倒せ'),
          cn: () => rich(context, '击败$targetNum个持有', traits(context), '特性的敌人'),
          tw: () => rich(context, '擊敗$targetNum個持有', traits(context), '特性的敵人'),
          na: () => rich(context, 'Defeat $targetNum enemies with traits ', traits(context)),
          kr: () => rich(context, null, traits(context), '속성을 가진 적을 $targetNum마리 처치'),
        );
      case DetailCondType.defeatServantClass:
        return localized(
          jp: () => rich(context, null, svtClasses(context), 'クラスのサーヴァントを$targetNum骑倒せ'),
          cn: () => rich(context, '击败$targetNum骑', svtClasses(context), '职阶中任意一种从者'),
          tw: () => rich(context, '擊敗$targetNum騎', svtClasses(context), '職階中任意一種從者'),
          na: () => rich(context, 'Defeat $targetNum servants with class ', svtClasses(context)),
          kr: () => rich(context, null, svtClasses(context), '클래스의 서번트를 $targetNum기 처치'),
        );
      case DetailCondType.defeatEnemyClass:
        return localized(
          jp: () => rich(context, null, svtClasses(context), 'クラスの敵を$targetNum骑倒せ'),
          cn: () => rich(context, '击败$targetNum骑', svtClasses(context), '职阶中任意一种敌人'),
          tw: () => rich(context, '擊敗$targetNum騎', svtClasses(context), '職階中任意一種敵人'),
          na: () => rich(context, 'Defeat $targetNum enemies with class ', svtClasses(context)),
          kr: () => rich(context, null, svtClasses(context), '클래스의 적을 $targetNum마리 처치'),
        );
      case DetailCondType.defeatEnemyNotServantClass:
        return localized(
          jp: () => rich(context, null, svtClasses(context), 'クラスの敵を$targetNum骑倒せ(サーヴァント及び一部ボスなどは除く)'),
          cn: () => rich(context, '击败$targetNum骑', svtClasses(context), '职阶中任意一种敌人(从者及部分首领级敌方除外)'),
          tw: () => rich(context, '擊敗$targetNum騎', svtClasses(context), '職階中任意一種敵人(從者及部分首領級敵方除外)'),
          na: () => rich(context, 'Defeat $targetNum enemies with class ', svtClasses(context),
              ' (excluding Servants and certain bosses)'),
          kr: () => rich(context, null, svtClasses(context), '클래스의 적을 $targetNum마리 처치 (서번트 및 일부 보스 등은 제외)'),
        );
      case DetailCondType.battleSvtClassInDeck:
        return localized(
          jp: () => rich(context, null, svtClasses(context), 'クラスのサーヴァントを1騎以上編成して、いずれかのクエストを$targetNum回クリアせよ'),
          cn: () => rich(context, '在队伍中编入至少1骑以上', svtClasses(context), '职阶从者，并完成任意关卡$targetNum次'),
          tw: () => rich(context, '在隊伍中編入至少1騎以上', svtClasses(context), '職階從者，並完成任意關卡$targetNum次'),
          na: () => rich(context, 'Put one or more servants with class', svtClasses(context),
              ' in your Party and complete any quest $targetNum times'),
          kr: () => rich(context, null, svtClasses(context), '클래스의 서번트를 1기 이상 편성해서 전투 진행을 $targetNum회 완료'),
        );
      case DetailCondType.itemGetBattle:
      case DetailCondType.itemGetTotal:
      case DetailCondType.targetQuestItemGetTotal:
        return localized(
          jp: () => rich(context, '戦利品で', items(context), 'を$targetNum個集めろ'),
          cn: () => rich(context, '通过战利品获得$targetNum个道具', items(context)),
          tw: () => rich(context, '通過戰利品獲得$targetNum個道具', items(context)),
          na: () => rich(context, 'Obtain $targetNum ', items(context), ' as battle drop'),
          kr: () => rich(context, '전리품으로 ', items(context), ' 중 하나를 $targetNum개 획득'),
        );
      case DetailCondType.battleSvtIndividualityInDeck:
        return localized(
          jp: () => rich(context, null, traits(context), '属性を持つサーヴァントを1騎以上編成して、いずれかのクエストを$targetNum回クリアせよ'),
          cn: () => rich(context, '在队伍内编入至少1骑以上持有', traits(context), '属性的从者，并完成任意关卡$targetNum次'),
          tw: () => rich(context, '在隊伍內編入至少1騎以上持有', traits(context), '屬性的從者，並完成任意關卡$targetNum次'),
          na: () => rich(context, 'Put servants with traits', traits(context),
              ' in your Party and complete Quests $targetNum times'),
          kr: () => rich(context, null, traits(context), '특성을 가진 서번트를 1기 이상 편성해서 전투 진행을 $targetNum회 완료'),
        );
      case DetailCondType.battleSvtIdInDeck1:
      case DetailCondType.battleSvtIdInDeck2:
        return localized(
          jp: () => rich(context, null, servants(context), 'のサーヴァントを1騎以上編成して、いずれかのクエストを$targetNum回クリアせよ'),
          cn: () => rich(context, '在队伍内编入至少1骑以上', servants(context), '从者，并完成任意关卡$targetNum次'),
          tw: () => rich(context, '在隊伍內編入至少1騎以上', servants(context), '從者，並完成任意關卡$targetNum次'),
          na: () =>
              rich(context, 'Put servants ', servants(context), ' in your Party and complete Quests $targetNum times'),
          kr: () => rich(context, null, servants(context), '를 1기 이상 편성해서 전투 진행을 $targetNum회 완료'),
        );
      case DetailCondType.battleSvtIdInFrontDeck:
        return localized(
          jp: () => rich(context, null, servants(context), 'をスタメンにして、いずれかのクエストを$targetNum回クリアせよ'),
          cn: () => rich(context, '在队伍内编入', servants(context), '从者作为首发队员，并完成任意关卡$targetNum次'),
          tw: () => rich(context, '在隊伍內編入', servants(context), '從者作為首發隊員，並完成任意關卡$targetNum次'),
          na: () => rich(
              context, 'Put servants ', servants(context), ' in Starting Member and complete Quests $targetNum times'),
          kr: null,
        );
      case DetailCondType.svtGetBattle:
        return localized(
          jp: () => text('戦利品で種火を$targetNum個集めろ'),
          cn: () => text('获取$targetNum个种火作为战利品'),
          tw: () => text('獲取$targetNum個種火作為戰利品'),
          na: () => text('Acquire $targetNum embers through battle'),
          kr: () => text('전리품으로 종화를 $targetNum개 획득'),
        );
      case DetailCondType.friendPointSummon:
        return localized(
          jp: () => text('フレンドポイント召喚を$targetNum回実行せよ'),
          cn: () => text('完成$targetNum次友情点召唤'),
          tw: () => text('完成$targetNum次友情點數召喚'),
          na: () => text('Perform $targetNum Friend Point Summons'),
          kr: () => text('친구 포인트 소환을 $targetNum회 실행'),
        );
      case DetailCondType.questChallengeNum:
        return localized(
          jp: () => rich(context, '以下のクエストを$targetNum回挑戦せよ', quests(context)),
          cn: () => rich(context, '挑战$targetNum次以下关卡', quests(context)),
          tw: () => rich(context, '挑戰$targetNum次以下關卡', quests(context)),
          na: () => rich(context, 'Challenge $targetNum runs of quests ', quests(context)),
          kr: null,
        );
      case DetailCondType.svtFriendshipGet:
        return localized(
          jp: () => text('絆を$targetNum獲得せよ'),
          cn: () => text('获取$targetNum牵绊'),
          tw: () => text('獲取$targetNum羈絆'),
          na: () => text('Obtain $targetNum Bond Points'),
          kr: null,
        );
      case DetailCondType.moreFriendFollower:
        return localized(
          jp: () => text('フレンド・フォローを$targetNum人増やせ'),
          cn: () => text('添加$targetNum个好友或关注对象'),
          tw: () => text('增加$targetNum個好友或關注對象'),
          na: () => text('Add $targetNum more Friends/Followers'),
          kr: null,
        );
      case DetailCondType.boardGameDiceUse:
        return localized(
          jp: () => rich(context, 'ガッポリーで', items(context), 'を累計$targetNum回使用せよ'),
          cn: () => rich(context, '在堆金大亨中累计使用$targetNum次', items(context)),
          tw: () => rich(context, '在BIG富翁中累計使用$targetNum次', items(context)),
          na: () => rich(context, 'Use ', items(context), ' $targetNum times at Culdpoly'),
          kr: null,
        );
      case DetailCondType.boardGameSquareAdvanced:
        return localized(
          jp: () => text('ガッポリーで合計$targetNumマス進め'),
          cn: () => text('在堆金大亨中总计前进$targetNum格'),
          tw: () => text('在BIG富翁中總計前進$targetNum格'),
          na: () => text('Proceed $targetNum spaces in Culdpoly'),
          kr: () => text('갓폴리에서 합계 $targetNum칸 진행'),
        );
      case DetailCondType.exchangeSvtQuestClear:
        return localized(
          jp: () => text('交換したサーヴァントを編成して、いずれかのクエストを$targetNum回クリアせよ'),
          cn: () => text('在队伍中编入兑换的从者，并完成任意关卡$targetNum次'),
          tw: null,
          na: () => text('Put the exchanged servant in your Party and complete any quest $targetNum times'),
          kr: null,
        );
      case DetailCondType.exchangeSvtTdPlay:
        return localized(
          jp: () => text('交換したサーヴァントの宝具を$targetNum回使用せよ'),
          cn: () => text('使用$targetNum次兑换的从者的宝具'),
          tw: null,
          na: () => text('Use the exchanged servant\'s Noble Phantasm $targetNum times'),
          kr: null,
        );
      case DetailCondType.exchangeSvtVoicePlay:
        return localized(
          jp: () => text('交換したサーヴァントのボイスをマイルームで$targetNum回再生せよ'),
          cn: () => text('在个人空间播放$targetNum次兑换的从者的语音'),
          tw: null,
          na: () => text('Play the exchanged servant\'s voice $targetNum times in My Room'),
          kr: null,
        );
      // unused
      case DetailCondType.battleSvtInDeck:
      case DetailCondType.battleSvtEquipInDeck:
      case null:
        break;
    }
    if (unknownMsg != null) return text(unknownMsg!);
    return localized(
      jp: () => text('不明な条件(${detail.missionCondType}): $targetIds, $targetNum'),
      cn: () => text('未知条件(${detail.missionCondType}): $targetIds, $targetNum'),
      tw: () => text('未知條件(${detail.missionCondType}): $targetIds, $targetNum'),
      na: () => text('Unknown CondDetail(${detail.missionCondType}): $targetIds, $targetNum'),
      kr: () => text('알 수 없는 조건(${detail.missionCondType}): $targetIds, $targetNum'),
    );
  }

  @override
  List<InlineSpan> localized({
    required List<InlineSpan> Function()? jp,
    required List<InlineSpan> Function()? cn,
    required List<InlineSpan> Function()? tw,
    required List<InlineSpan> Function()? na,
    required List<InlineSpan> Function()? kr,
  }) {
    final spans = super.localized(jp: jp, cn: cn, tw: tw, na: na, kr: kr);
    final questTraits = detail.targetQuestIndividualities.map((e) => e.signedId).toList();
    final eventIds = List<int>.of(detail.targetEventIds ?? []);
    final context = useContext();
    List<InlineSpan> extraSpans = [];
    if (questTraits.isNotEmpty) {
      extraSpans.addAll(super.localized(
        jp: () => rich(context, '(クエスト特性: ', MultiDescriptor.traits(context, questTraits), ')'),
        cn: () => rich(null, '(所需关卡特性: ', MultiDescriptor.traits(context, questTraits), ')'),
        tw: () => rich(null, '(所需關卡特性: ', MultiDescriptor.traits(context, questTraits), ')'),
        na: () => rich(null, '(Required Quest Trait: ', MultiDescriptor.traits(context, questTraits), ')'),
        kr: null,
      ));
    }
    if (eventIds.isNotEmpty) {
      if (eventIds.length == 1 && eventIds.first == 0) {
        extraSpans.add(TextSpan(text: '(${S.current.main_story})'));
      } else if (eventIds.length == 1 && eventIds.first == eventId) {
        // don't show event info inside event page
      } else {
        extraSpans.addAll(super.localized(
          jp: () => rich(context, '(イベント: ', MultiDescriptor.events(context, eventIds), ')'),
          cn: () => rich(null, '(活动: ', MultiDescriptor.events(context, eventIds), ')'),
          tw: () => rich(null, '(活動: ', MultiDescriptor.events(context, eventIds), ')'),
          na: () => rich(null, '(Event: ', MultiDescriptor.events(context, eventIds), ')'),
          kr: null,
        ));
      }
    }
    if (extraSpans.isNotEmpty) {
      spans.add(TextSpan(children: extraSpans, style: const TextStyle(fontSize: 14)));
    }
    return spans;
  }
}
