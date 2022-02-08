// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/wiki_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MappingData _$MappingDataFromJson(Map json) => MappingData(
      itemNames: (json['itemNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      mcNames: (json['mcNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      costumeNames: (json['costumeNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      cvNames: (json['cvNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      illustratorNames: (json['illustratorNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      ccNames: (json['ccNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      svtNames: (json['svtNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      ceNames: (json['ceNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      eventNames: (json['eventNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      warNames: (json['warNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      questNames: (json['questNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      spotNames: (json['spotNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      entityNames: (json['entityNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      tdTypes: (json['tdTypes'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      bgmNames: (json['bgmNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      summonNames: (json['summonNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      charaNames: (json['charaNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      buffNames: (json['buffNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      buffDetail: (json['buffDetail'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      funcPopuptext: (json['funcPopuptext'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      skillNames: (json['skillNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      skillDetail: (json['skillDetail'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      tdNames: (json['tdNames'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      tdRuby: (json['tdRuby'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      tdDetail: (json['tdDetail'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      trait: (json['trait'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      mcDetail: (json['mcDetail'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      costumeDetail: (json['costumeDetail'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      skillState: (json['skillState'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      tdState: (json['tdState'] as Map?)?.map(
        (k, e) => MapEntry(k,
            MappingBase<dynamic>.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    );

MappingBase<T> _$MappingBaseFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) =>
    MappingBase<T>.typed(
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

WikiData _$WikiDataFromJson(Map json) => WikiData(
      servants: (json['servants'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                ServantExtra.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      craftEssences: (json['craftEssences'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                CraftEssenceExtra.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      commandCodes: (json['commandCodes'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                CommandCodeExtra.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      events: (json['events'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                EventExtra.fromJson(Map<String, dynamic>.from(e as Map))),
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
          : MappingBase<dynamic>.fromJson(
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
      type:
          $enumDecodeNullable(_$CETypeEnumMap, json['type']) ?? CEType.unknown,
      profile: json['profile'] == null
          ? null
          : MappingBase<dynamic>.fromJson(
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

const _$CETypeEnumMap = {
  CEType.exp: 'exp',
  CEType.shop: 'shop',
  CEType.story: 'story',
  CEType.permanent: 'permanent',
  CEType.valentine: 'valentine',
  CEType.limited: 'limited',
  CEType.eventReward: 'eventReward',
  CEType.campaign: 'campaign',
  CEType.bond: 'bond',
  CEType.unknown: 'unknown',
};

CommandCodeExtra _$CommandCodeExtraFromJson(Map json) => CommandCodeExtra(
      collectionNo: json['collectionNo'] as int,
      profile: json['profile'] == null
          ? null
          : MappingBase<dynamic>.fromJson(
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
          : MappingBase<dynamic>.fromJson(
              Map<String, dynamic>.from(json['titleBanner'] as Map)),
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<dynamic>.fromJson(
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
          : MappingBase<dynamic>.fromJson(
              Map<String, dynamic>.from(json['startTime'] as Map)),
      endTime: json['endTime'] == null
          ? null
          : MappingBase<dynamic>.fromJson(
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

ExchangeTicket _$ExchangeTicketFromJson(Map json) => ExchangeTicket(
      key: json['key'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
      items: (json['items'] as List<dynamic>).map((e) => e as int).toList(),
    );

FixedDrop _$FixedDropFromJson(Map json) => FixedDrop(
      key: json['key'] as int,
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
          : MappingBase<dynamic>.fromJson(
              Map<String, dynamic>.from(json['name'] as Map)),
      banner: json['banner'] == null
          ? null
          : MappingBase<dynamic>.fromJson(
              Map<String, dynamic>.from(json['banner'] as Map)),
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<dynamic>.fromJson(
              Map<String, dynamic>.from(json['noticeLink'] as Map)),
      startTime: json['startTime'] == null
          ? null
          : MappingBase<dynamic>.fromJson(
              Map<String, dynamic>.from(json['startTime'] as Map)),
      endTime: json['endTime'] == null
          ? null
          : MappingBase<dynamic>.fromJson(
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
