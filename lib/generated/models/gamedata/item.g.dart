// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map json) => Item(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? "",
      type: $enumDecodeNullable(_$ItemTypeEnumMap, json['type']) ?? ItemType.none,
      uses: (json['uses'] as List<dynamic>?)?.map((e) => $enumDecode(_$ItemUseEnumMap, e)).toList() ?? const [],
      detail: json['detail'] as String? ?? "",
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      icon: json['icon'] as String,
      background: $enumDecodeNullable(_$ItemBGTypeEnumMap, json['background']) ?? ItemBGType.zero,
      value: (json['value'] as num?)?.toInt() ?? 0,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      dropPriority: (json['dropPriority'] as num?)?.toInt() ?? 0,
      startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
      endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
      itemSelects: (json['itemSelects'] as List<dynamic>?)
              ?.map((e) => ItemSelect.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      eventId: (json['eventId'] as num?)?.toInt() ?? 0,
      eventGroupId: (json['eventGroupId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ItemTypeEnumMap[instance.type]!,
      'uses': instance.uses.map((e) => _$ItemUseEnumMap[e]!).toList(),
      'detail': instance.detail,
      'individuality': instance.individuality.map((e) => e.toJson()).toList(),
      'icon': instance.icon,
      'background': _$ItemBGTypeEnumMap[instance.background]!,
      'value': instance.value,
      'priority': instance.priority,
      'dropPriority': instance.dropPriority,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'itemSelects': instance.itemSelects.map((e) => e.toJson()).toList(),
      'eventId': instance.eventId,
      'eventGroupId': instance.eventGroupId,
    };

const _$ItemTypeEnumMap = {
  ItemType.none: 'none',
  ItemType.qp: 'qp',
  ItemType.stone: 'stone',
  ItemType.apRecover: 'apRecover',
  ItemType.apAdd: 'apAdd',
  ItemType.mana: 'mana',
  ItemType.key: 'key',
  ItemType.gachaClass: 'gachaClass',
  ItemType.gachaRelic: 'gachaRelic',
  ItemType.gachaTicket: 'gachaTicket',
  ItemType.limit: 'limit',
  ItemType.skillLvUp: 'skillLvUp',
  ItemType.tdLvUp: 'tdLvUp',
  ItemType.friendPoint: 'friendPoint',
  ItemType.eventPoint: 'eventPoint',
  ItemType.eventItem: 'eventItem',
  ItemType.questRewardQp: 'questRewardQp',
  ItemType.chargeStone: 'chargeStone',
  ItemType.rpAdd: 'rpAdd',
  ItemType.boostItem: 'boostItem',
  ItemType.stoneFragments: 'stoneFragments',
  ItemType.anonymous: 'anonymous',
  ItemType.rarePri: 'rarePri',
  ItemType.costumeRelease: 'costumeRelease',
  ItemType.itemSelect: 'itemSelect',
  ItemType.commandCardPrmUp: 'commandCardPrmUp',
  ItemType.dice: 'dice',
  ItemType.continueItem: 'continueItem',
  ItemType.euqipSkillUseItem: 'euqipSkillUseItem',
  ItemType.svtCoin: 'svtCoin',
  ItemType.friendshipUpItem: 'friendshipUpItem',
  ItemType.purePri: 'purePri',
  ItemType.tradeAp: 'tradeAp',
  ItemType.revivalItem: 'revivalItem',
  ItemType.stormpod: 'stormpod',
  ItemType.battleItem: 'battleItem',
  ItemType.aniplexPlusChargeStone: 'aniplexPlusChargeStone',
  ItemType.purePriShopReset: 'purePriShopReset',
  ItemType.exchangeSvtCoin: 'exchangeSvtCoin',
  ItemType.reduceTradeTime: 'reduceTradeTime',
  ItemType.eventPassiveSkillGiven: 'eventPassiveSkillGiven',
};

const _$ItemUseEnumMap = {
  ItemUse.skill: 'skill',
  ItemUse.appendSkill: 'appendSkill',
  ItemUse.ascension: 'ascension',
  ItemUse.costume: 'costume',
};

const _$ItemBGTypeEnumMap = {
  ItemBGType.zero: 'zero',
  ItemBGType.bronze: 'bronze',
  ItemBGType.silver: 'silver',
  ItemBGType.gold: 'gold',
  ItemBGType.questClearQPReward: 'questClearQPReward',
  ItemBGType.aquaBlue: 'aquaBlue',
};

ItemSelect _$ItemSelectFromJson(Map json) => ItemSelect(
      idx: (json['idx'] as num).toInt(),
      gifts: json['gifts'] == null ? const [] : const GiftsConverter().fromJson(json['gifts'] as List),
      requireNum: (json['requireNum'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$ItemSelectToJson(ItemSelect instance) => <String, dynamic>{
      'idx': instance.idx,
      'gifts': const GiftsConverter().toJson(instance.gifts),
      'requireNum': instance.requireNum,
    };

ItemDropEfficiency _$ItemDropEfficiencyFromJson(Map json) => ItemDropEfficiency(
      targetType:
          $enumDecodeNullable(_$ItemTransitionTargetValueEnumMap, json['targetType']) ?? ItemTransitionTargetValue.none,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      iconName: json['iconName'] as String? ?? '',
      transitionParam: json['transitionParam'] as String? ?? '',
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      closedMessage: json['closedMessage'] as String? ?? '',
    );

Map<String, dynamic> _$ItemDropEfficiencyToJson(ItemDropEfficiency instance) => <String, dynamic>{
      'targetType': _$ItemTransitionTargetValueEnumMap[instance.targetType]!,
      'priority': instance.priority,
      'title': instance.title,
      'iconName': instance.iconName,
      'transitionParam': instance.transitionParam,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'closedMessage': instance.closedMessage,
    };

const _$ItemTransitionTargetValueEnumMap = {
  ItemTransitionTargetValue.none: 'none',
  ItemTransitionTargetValue.questId: 'questId',
  ItemTransitionTargetValue.spotId: 'spotId',
  ItemTransitionTargetValue.warId: 'warId',
  ItemTransitionTargetValue.eventId: 'eventId',
  ItemTransitionTargetValue.missionType: 'missionType',
  ItemTransitionTargetValue.manaPriTargetItemId: 'manaPriTargetItemId',
  ItemTransitionTargetValue.purePriTargetItemId: 'purePriTargetItemId',
  ItemTransitionTargetValue.rarePriTargetItemId: 'rarePriTargetItemId',
  ItemTransitionTargetValue.leafExchangeTargetItemId: 'leafExchangeTargetItemId',
};

ItemAmount _$ItemAmountFromJson(Map json) => ItemAmount(
      item: json['item'] == null ? null : Item.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
      itemId: (json['itemId'] as num?)?.toInt(),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$ItemAmountToJson(ItemAmount instance) => <String, dynamic>{
      'itemId': instance.itemId,
      'amount': instance.amount,
      'item': instance.item?.toJson(),
    };

LvlUpMaterial _$LvlUpMaterialFromJson(Map json) => LvlUpMaterial(
      items: (json['items'] as List<dynamic>)
          .map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      qp: (json['qp'] as num).toInt(),
    );

Map<String, dynamic> _$LvlUpMaterialToJson(LvlUpMaterial instance) => <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'qp': instance.qp,
    };
