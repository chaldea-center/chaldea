// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/wiki_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MappingData _$MappingDataFromJson(Map json) => MappingData(
      itemNames: (json['item_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      mcNames: (json['mc_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      costumeNames: (json['costume_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      cvNames: (json['cv_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      illustratorNames: (json['illustrator_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      ccNames: (json['cc_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      svtNames: (json['svt_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      ceNames: (json['ce_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      eventNames: (json['event_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      warNames: (json['war_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      questNames: (json['quest_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      spotNames: (json['spot_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      entityNames: (json['entity_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdTypes: (json['td_types'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      bgmNames: (json['bgm_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      summonNames: (json['summon_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      charaNames: (json['chara_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      buffNames: (json['buff_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      buffDetail: (json['buff_detail'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      funcPopuptext: (json['func_popuptext'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      skillNames: (json['skill_names'] as Map?)?.map(
        (k, e) => MapEntry(k as String,
            MappingBase<String>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      skillDetail: (json['skill_detail'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdNames: (json['td_names'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdRuby: (json['td_ruby'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdDetail: (json['td_detail'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      trait: (json['trait'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      svtClass: (json['svt_class'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      mcDetail: (json['mc_detail'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      costumeDetail: (json['costume_detail'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      skillState: (json['skill_state'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                MappingDict<int>.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdState: (json['td_state'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                MappingDict<int>.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      svtRelease: json['svt_release'] == null
          ? null
          : MappingList<int>.fromJson(
              Map<String, dynamic>.from(json['svt_release'] as Map)),
      ceRelease: json['ce_release'] == null
          ? null
          : MappingList<int>.fromJson(
              Map<String, dynamic>.from(json['ce_release'] as Map)),
      ccRelease: json['cc_release'] == null
          ? null
          : MappingList<int>.fromJson(
              Map<String, dynamic>.from(json['cc_release'] as Map)),
    );

MappingBase<T> _$MappingBaseFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) =>
    MappingBase<T>(
      jp: _$nullableGenericFromJson(json['JP'], fromJsonT),
      cn: _$nullableGenericFromJson(json['CN'], fromJsonT),
      tw: _$nullableGenericFromJson(json['TW'], fromJsonT),
      na: _$nullableGenericFromJson(json['NA'], fromJsonT),
      kr: _$nullableGenericFromJson(json['KR'], fromJsonT),
    );

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

MappingList<T> _$MappingListFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) =>
    MappingList<T>(
      jp: (json['JP'] as List<dynamic>?)?.map(fromJsonT).toList(),
      cn: (json['CN'] as List<dynamic>?)?.map(fromJsonT).toList(),
      tw: (json['TW'] as List<dynamic>?)?.map(fromJsonT).toList(),
      na: (json['NA'] as List<dynamic>?)?.map(fromJsonT).toList(),
      kr: (json['KR'] as List<dynamic>?)?.map(fromJsonT).toList(),
    );

MappingDict<V> _$MappingDictFromJson<V>(
  Map json,
  V Function(Object? json) fromJsonV,
) =>
    MappingDict<V>(
      jp: (json['JP'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), fromJsonV(e)),
      ),
      cn: (json['CN'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), fromJsonV(e)),
      ),
      tw: (json['TW'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), fromJsonV(e)),
      ),
      na: (json['NA'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), fromJsonV(e)),
      ),
      kr: (json['KR'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), fromJsonV(e)),
      ),
    );

WikiData _$WikiDataFromJson(Map json) => WikiData(
      servants: (json['servants'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            ServantExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      craftEssences: (json['craftEssences'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            CraftEssenceExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      commandCodes: (json['commandCodes'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            CommandCodeExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      events: (json['events'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            EventExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      wars: (json['wars'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            WarExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      summons: (json['summons'] as Map?)?.map(
        (k, e) => MapEntry(k as String,
            LimitedSummon.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      webcrowMapping: (json['webcrowMapping'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), e as int),
          ) ??
          const {},
    );

ServantExtra _$ServantExtraFromJson(Map json) => ServantExtra(
      collectionNo: json['collectionNo'] as int,
      nameOther: (json['nameOther'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      obtains: (json['obtains'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$SvtObtainEnumMap, e))
              .toList() ??
          const [],
      aprilFoolAssets: (json['aprilFoolAssets'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      aprilFoolProfile: json['aprilFoolProfile'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['aprilFoolProfile'] as Map)),
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
    );

const _$SvtObtainEnumMap = {
  SvtObtain.friendPoint: 'friendPoint',
  SvtObtain.story: 'story',
  SvtObtain.permanent: 'permanent',
  SvtObtain.heroine: 'heroine',
  SvtObtain.limited: 'limited',
  SvtObtain.unavailable: 'unavailable',
  SvtObtain.eventReward: 'eventReward',
  SvtObtain.clearReward: 'clearReward',
  SvtObtain.unknown: 'unknown',
};

CraftEssenceExtra _$CraftEssenceExtraFromJson(Map json) => CraftEssenceExtra(
      collectionNo: json['collectionNo'] as int,
      obtain: $enumDecodeNullable(_$CEObtainEnumMap, json['obtain']) ??
          CEObtain.unknown,
      profile: json['profile'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['profile'] as Map)),
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      unknownCharacters: (json['unknownCharacters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
    );

const _$CEObtainEnumMap = {
  CEObtain.exp: 'exp',
  CEObtain.shop: 'shop',
  CEObtain.story: 'story',
  CEObtain.permanent: 'permanent',
  CEObtain.valentine: 'valentine',
  CEObtain.limited: 'limited',
  CEObtain.eventReward: 'eventReward',
  CEObtain.campaign: 'campaign',
  CEObtain.bond: 'bond',
  CEObtain.unknown: 'unknown',
};

CommandCodeExtra _$CommandCodeExtraFromJson(Map json) => CommandCodeExtra(
      collectionNo: json['collectionNo'] as int,
      profile: json['profile'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['profile'] as Map)),
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      unknownCharacters: (json['unknownCharacters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
    );

EventExtraItems _$EventExtraItemsFromJson(Map json) => EventExtraItems(
      id: json['id'] as int,
      detail: json['detail'] as String?,
      items: (json['items'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), e as String),
          ) ??
          const {},
    );

EventExtra _$EventExtraFromJson(Map json) => EventExtra(
      id: json['id'] as int,
      name: json['name'] as String,
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      titleBanner: json['titleBanner'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['titleBanner'] as Map)),
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['noticeLink'] as Map)),
      huntingQuestIds: (json['huntingQuestIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      extraItems: (json['extraItems'] as List<dynamic>?)
              ?.map((e) =>
                  EventExtraItems.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      startTime: json['startTime'] == null
          ? null
          : MappingBase<int>.fromJson(
              Map<String, dynamic>.from(json['startTime'] as Map)),
      endTime: json['endTime'] == null
          ? null
          : MappingBase<int>.fromJson(
              Map<String, dynamic>.from(json['endTime'] as Map)),
      rarePrism: json['rarePrism'] as int? ?? 0,
      grail: json['grail'] as int? ?? 0,
      crystal: json['crystal'] as int? ?? 0,
      grail2crystal: json['grail2crystal'] as int? ?? 0,
      foukun4: json['foukun4'] as int? ?? 0,
      relatedSummons: (json['relatedSummons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

WarExtra _$WarExtraFromJson(Map json) => WarExtra(
      id: json['id'] as int,
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      titleBanner: json['titleBanner'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['titleBanner'] as Map)),
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['noticeLink'] as Map)),
    );

ExchangeTicket _$ExchangeTicketFromJson(Map json) => ExchangeTicket(
      id: json['id'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
      items: (json['items'] as List<dynamic>).map((e) => e as int).toList(),
    );

FixedDrop _$FixedDropFromJson(Map json) => FixedDrop(
      id: json['id'] as int,
      items: (json['items'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String), e as int),
      ),
    );

LimitedSummon _$LimitedSummonFromJson(Map json) => LimitedSummon(
      id: json['id'] as String,
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      name: json['name'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['name'] as Map)),
      banner: json['banner'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['banner'] as Map)),
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['noticeLink'] as Map)),
      startTime: json['startTime'] == null
          ? null
          : MappingBase<int>.fromJson(
              Map<String, dynamic>.from(json['startTime'] as Map)),
      endTime: json['endTime'] == null
          ? null
          : MappingBase<int>.fromJson(
              Map<String, dynamic>.from(json['endTime'] as Map)),
      type: $enumDecodeNullable(_$SummonTypeEnumMap, json['type']) ??
          SummonType.unknown,
      rollCount: json['rollCount'] as int? ?? 11,
      subSummons: (json['subSummons'] as List<dynamic>?)
              ?.map((e) =>
                  SubSummon.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

const _$SummonTypeEnumMap = {
  SummonType.story: 'story',
  SummonType.limited: 'limited',
  SummonType.gssr: 'gssr',
  SummonType.gssrsr: 'gssrsr',
  SummonType.unknown: 'unknown',
};

SubSummon _$SubSummonFromJson(Map json) => SubSummon(
      title: json['title'] as String,
      probs: (json['probs'] as List<dynamic>?)
              ?.map((e) =>
                  ProbGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

ProbGroup _$ProbGroupFromJson(Map json) => ProbGroup(
      isSvt: json['isSvt'] as bool,
      rarity: json['rarity'] as int,
      weight: (json['weight'] as num).toDouble(),
      display: json['display'] as bool,
      ids: (json['ids'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
    );
