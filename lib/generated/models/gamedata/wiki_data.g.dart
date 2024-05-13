// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/wiki_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WikiData _$WikiDataFromJson(Map json) => WikiData(
      servants: (json['servants'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), ServantExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      craftEssences: (json['craftEssences'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), CraftEssenceExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      commandCodes: (json['commandCodes'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), CommandCodeExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      events: (json['events'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), EventExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      wars: (json['wars'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), WarExtra.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      summons: (json['summons'] as Map?)?.map(
        (k, e) => MapEntry(k as String, LimitedSummon.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      webcrowMapping: (json['webcrowMapping'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
          ) ??
          const {},
    );

ServantExtra _$ServantExtraFromJson(Map json) => ServantExtra(
      collectionNo: (json['collectionNo'] as num).toInt(),
      nicknames: json['nicknames'] == null
          ? null
          : MappingList<String>.fromJson(Map<String, dynamic>.from(json['nicknames'] as Map)),
      releasedAt: (json['releasedAt'] as num?)?.toInt() ?? 0,
      obtains: (json['obtains'] as List<dynamic>?)?.map((e) => $enumDecode(_$SvtObtainEnumMap, e)).toList() ??
          const [SvtObtain.unknown],
      aprilFoolAssets: (json['aprilFoolAssets'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      aprilFoolProfile: json['aprilFoolProfile'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['aprilFoolProfile'] as Map)),
      mcSprites: (json['mcSprites'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      fandomSprites: (json['fandomSprites'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      mcProfiles: (json['mcProfiles'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      fandomProfiles: (json['fandomProfiles'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      tdAnimations: (json['tdAnimations'] as List<dynamic>?)
              ?.map((e) => BiliVideo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
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

BiliVideo _$BiliVideoFromJson(Map json) => BiliVideo(
      av: (json['av'] as num?)?.toInt(),
      p: (json['p'] as num?)?.toInt(),
      bv: json['bv'] as String?,
    );

CraftEssenceExtra _$CraftEssenceExtraFromJson(Map json) => CraftEssenceExtra(
      collectionNo: (json['collectionNo'] as num).toInt(),
      obtain: $enumDecodeNullable(_$CEObtainEnumMap, json['obtain']) ?? CEObtain.unknown,
      profile: json['profile'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['profile'] as Map)),
      characters: (json['characters'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      unknownCharacters: (json['unknownCharacters'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
    );

const _$CEObtainEnumMap = {
  CEObtain.permanent: 'permanent',
  CEObtain.story: 'story',
  CEObtain.eventReward: 'eventReward',
  CEObtain.limited: 'limited',
  CEObtain.manaShop: 'manaShop',
  CEObtain.bond: 'bond',
  CEObtain.valentine: 'valentine',
  CEObtain.exp: 'exp',
  CEObtain.campaign: 'campaign',
  CEObtain.drop: 'drop',
  CEObtain.regionSpecific: 'regionSpecific',
  CEObtain.unknown: 'unknown',
};

CommandCodeExtra _$CommandCodeExtraFromJson(Map json) => CommandCodeExtra(
      collectionNo: (json['collectionNo'] as num).toInt(),
      profile: json['profile'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['profile'] as Map)),
      characters: (json['characters'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      unknownCharacters: (json['unknownCharacters'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
    );

EventExtraItems _$EventExtraItemsFromJson(Map json) => EventExtraItems(
      id: (json['id'] as num).toInt(),
      infinite: json['infinite'] as bool? ?? false,
      detail: json['detail'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['detail'] as Map)),
      items: (json['items'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                e == null ? null : MappingBase<String>.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
    );

EventExtraFixedItems _$EventExtraFixedItemsFromJson(Map json) => EventExtraFixedItems(
      id: (json['id'] as num).toInt(),
      detail: json['detail'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['detail'] as Map)),
      items: (json['items'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
      ),
    );

EventExtra _$EventExtraFromJson(Map json) => EventExtra(
      id: (json['id'] as num).toInt(),
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      shown: json['shown'] as bool?,
      titleBanner: json['titleBanner'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['titleBanner'] as Map)),
      officialBanner: json['officialBanner'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['officialBanner'] as Map)),
      extraBanners: json['extraBanners'] == null
          ? null
          : MappingList<String>.fromJson(Map<String, dynamic>.from(json['extraBanners'] as Map)),
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['noticeLink'] as Map)),
      extraFixedItems: (json['extraFixedItems'] as List<dynamic>?)
              ?.map((e) => EventExtraFixedItems.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      extraItems: (json['extraItems'] as List<dynamic>?)
              ?.map((e) => EventExtraItems.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script:
          json['script'] == null ? null : EventExtraScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      startTime: json['startTime'] == null
          ? null
          : MappingBase<int>.fromJson(Map<String, dynamic>.from(json['startTime'] as Map)),
      endTime:
          json['endTime'] == null ? null : MappingBase<int>.fromJson(Map<String, dynamic>.from(json['endTime'] as Map)),
      relatedSummons: (json['relatedSummons'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );

EventExtraScript _$EventExtraScriptFromJson(Map json) => EventExtraScript(
      huntingId: (json['huntingId'] as num?)?.toInt() ?? 0,
      raidLink: (json['raidLink'] as Map?)?.map(
            (k, e) => MapEntry(const RegionConverter().fromJson(k as String), e as String),
          ) ??
          const {},
    );

WarExtra _$WarExtraFromJson(Map json) => WarExtra(
      id: (json['id'] as num).toInt(),
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['noticeLink'] as Map)),
      titleBanner: json['titleBanner'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['titleBanner'] as Map)),
      officialBanner: json['officialBanner'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['officialBanner'] as Map)),
      extraBanners: json['extraBanners'] == null
          ? null
          : MappingList<String>.fromJson(Map<String, dynamic>.from(json['extraBanners'] as Map)),
    );

ExchangeTicket _$ExchangeTicketFromJson(Map json) => ExchangeTicket(
      id: (json['id'] as num).toInt(),
      itemId: (json['itemId'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      items: (json['items'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      replaced: json['replaced'] == null
          ? null
          : MappingList<int>.fromJson(Map<String, dynamic>.from(json['replaced'] as Map)),
      multiplier: (json['multiplier'] as num?)?.toInt() ?? 1,
    );

FixedDrop _$FixedDropFromJson(Map json) => FixedDrop(
      id: (json['id'] as num).toInt(),
      items: (json['items'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
      ),
    );

LimitedSummon _$LimitedSummonFromJson(Map json) => LimitedSummon(
      id: json['id'] as String,
      name: json['name'] as String?,
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      banner: json['banner'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['banner'] as Map)),
      officialBanner: json['officialBanner'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['officialBanner'] as Map)),
      noticeLink: json['noticeLink'] == null
          ? null
          : MappingBase<String>.fromJson(Map<String, dynamic>.from(json['noticeLink'] as Map)),
      startTime: json['startTime'] == null
          ? null
          : MappingBase<int>.fromJson(Map<String, dynamic>.from(json['startTime'] as Map)),
      endTime:
          json['endTime'] == null ? null : MappingBase<int>.fromJson(Map<String, dynamic>.from(json['endTime'] as Map)),
      type: $enumDecodeNullable(_$SummonTypeEnumMap, json['type']) ?? SummonType.unknown,
      rollCount: (json['rollCount'] as num?)?.toInt() ?? 11,
      puSvt: (json['puSvt'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      puCE: (json['puCE'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      subSummons: (json['subSummons'] as List<dynamic>?)
              ?.map((e) => SubSummon.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LimitedSummonToJson(LimitedSummon instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mcLink': instance.mcLink,
      'fandomLink': instance.fandomLink,
      'banner': instance.banner.toJson(),
      'officialBanner': instance.officialBanner.toJson(),
      'noticeLink': instance.noticeLink.toJson(),
      'startTime': instance.startTime.toJson(),
      'endTime': instance.endTime.toJson(),
      'type': _$SummonTypeEnumMap[instance.type]!,
      'rollCount': instance.rollCount,
      'puSvt': instance.puSvt,
      'puCE': instance.puCE,
      'subSummons': instance.subSummons.map((e) => e.toJson()).toList(),
    };

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
              ?.map((e) => ProbGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SubSummonToJson(SubSummon instance) => <String, dynamic>{
      'title': instance.title,
      'probs': instance.probs.map((e) => e.toJson()).toList(),
    };

ProbGroup _$ProbGroupFromJson(Map json) => ProbGroup(
      isSvt: json['isSvt'] as bool,
      rarity: (json['rarity'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      display: json['display'] as bool,
      ids: (json['ids'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
    );

Map<String, dynamic> _$ProbGroupToJson(ProbGroup instance) => <String, dynamic>{
      'isSvt': instance.isSvt,
      'rarity': instance.rarity,
      'weight': instance.weight,
      'display': instance.display,
      'ids': instance.ids,
    };
