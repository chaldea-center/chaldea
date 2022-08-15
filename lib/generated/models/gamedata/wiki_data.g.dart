// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/wiki_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      nicknames: json['nicknames'] == null
          ? null
          : MappingList<String>.fromJson(
              Map<String, dynamic>.from(json['nicknames'] as Map)),
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
      mcSprites: (json['mcSprites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fandomSprites: (json['fandomSprites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      mcProfiles: (json['mcProfiles'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      fandomProfiles: (json['fandomProfiles'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
    );

const _$SvtObtainEnumMap = {
  SvtObtain.permanent: 'permanent',
  SvtObtain.story: 'story',
  SvtObtain.limited: 'limited',
  SvtObtain.eventReward: 'eventReward',
  SvtObtain.friendPoint: 'friendPoint',
  SvtObtain.clearReward: 'clearReward',
  SvtObtain.heroine: 'heroine',
  SvtObtain.unavailable: 'unavailable',
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
  CEObtain.drop: 'drop',
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
      detail: json['detail'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['detail'] as Map)),
      items: (json['items'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                e == null
                    ? null
                    : MappingBase<String>.fromJson(
                        Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
    );

EventExtraFixedItems _$EventExtraFixedItemsFromJson(Map json) =>
    EventExtraFixedItems(
      id: json['id'] as int,
      detail: json['detail'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['detail'] as Map)),
      items: (json['items'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), e as int),
      ),
    );

EventExtra _$EventExtraFromJson(Map json) => EventExtra(
      id: json['id'] as int,
      name: json['name'] as String,
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      forceShown: json['forceShown'] as bool? ?? false,
      titleBanner: json['titleBanner'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['titleBanner'] as Map)),
      officialBanner: json['officialBanner'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['officialBanner'] as Map)),
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['noticeLink'] as Map)),
      huntingId: json['huntingId'] as int? ?? 0,
      huntingQuestIds: (json['huntingQuestIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      extraFixedItems: (json['extraFixedItems'] as List<dynamic>?)
              ?.map((e) => EventExtraFixedItems.fromJson(
                  Map<String, dynamic>.from(e as Map)))
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
      officialBanner: json['officialBanner'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['officialBanner'] as Map)),
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
      replaced: json['replaced'] == null
          ? null
          : MappingList<int>.fromJson(
              Map<String, dynamic>.from(json['replaced'] as Map)),
      multiplier: json['multiplier'] as int? ?? 1,
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
      officialBanner: json['officialBanner'] == null
          ? null
          : MappingBase<String>.fromJson(
              Map<String, dynamic>.from(json['officialBanner'] as Map)),
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
