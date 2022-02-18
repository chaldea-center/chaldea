// GENERATED CODE - DO NOT MODIFY BY HAND

part of userdata;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map json) => $checkedCreate(
      'UserData',
      json,
      ($checkedConvert) {
        final val = UserData(
          version: $checkedConvert(
              'version', (v) => v as int? ?? UserData.modelVersion),
          curUserKey: $checkedConvert('curUserKey', (v) => v as int? ?? 0),
          users: $checkedConvert(
              'users',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'version': instance.version,
      'curUserKey': instance.curUserKey,
      'users': instance.users.map((e) => e.toJson()).toList(),
    };

User _$UserFromJson(Map json) => $checkedCreate(
      'User',
      json,
      ($checkedConvert) {
        final val = User(
          name: $checkedConvert('name', (v) => v as String? ?? 'Gudako'),
          isGirl: $checkedConvert('isGirl', (v) => v as bool? ?? true),
          use6thDrops:
              $checkedConvert('use6thDrops', (v) => v as bool? ?? true),
          region: $checkedConvert('region',
              (v) => $enumDecodeNullable(_$RegionEnumMap, v) ?? Region.jp),
          servants: $checkedConvert(
              'servants',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k as String),
                        SvtStatus.fromJson(
                            Map<String, dynamic>.from(e as Map))),
                  )),
          svtPlanGroups: $checkedConvert(
              'svtPlanGroups',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => (e as Map).map(
                        (k, e) => MapEntry(
                            int.parse(k as String),
                            SvtPlan.fromJson(
                                Map<String, dynamic>.from(e as Map))),
                      ))
                  .toList()),
          curSvtPlanNo: $checkedConvert('curSvtPlanNo', (v) => v as int? ?? 0),
          planNames: $checkedConvert(
              'planNames',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as String),
                  )),
          items: $checkedConvert(
              'items',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as int),
                  )),
          craftEssences: $checkedConvert(
              'craftEssences',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String),
                        $enumDecodeNullable(_$CraftStatusEnumMap, e)),
                  )),
          mysticCodes: $checkedConvert(
              'mysticCodes',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as int),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'isGirl': instance.isGirl,
      'use6thDrops': instance.use6thDrops,
      'region': _$RegionEnumMap[instance.region],
      'servants':
          instance.servants.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'svtPlanGroups': instance.svtPlanGroups
          .map((e) => e.map((k, e) => MapEntry(k.toString(), e.toJson())))
          .toList(),
      'curSvtPlanNo': instance.curSvtPlanNo,
      'planNames': instance.planNames.map((k, e) => MapEntry(k.toString(), e)),
      'items': instance.items.map((k, e) => MapEntry(k.toString(), e)),
      'craftEssences': instance.craftEssences
          .map((k, e) => MapEntry(k.toString(), _$CraftStatusEnumMap[e])),
      'mysticCodes':
          instance.mysticCodes.map((k, e) => MapEntry(k.toString(), e)),
    };

const _$RegionEnumMap = {
  Region.jp: 'jp',
  Region.cn: 'cn',
  Region.tw: 'tw',
  Region.na: 'na',
  Region.kr: 'kr',
};

const _$CraftStatusEnumMap = {
  CraftStatus.owned: 'owned',
  CraftStatus.met: 'met',
  CraftStatus.notMet: 'notMet',
};

SvtStatus _$SvtStatusFromJson(Map json) => $checkedCreate(
      'SvtStatus',
      json,
      ($checkedConvert) {
        final val = SvtStatus(
          cur: $checkedConvert(
              'cur',
              (v) => v == null
                  ? null
                  : SvtPlan.fromJson(Map<String, dynamic>.from(v as Map))),
          coin: $checkedConvert('coin', (v) => v as int? ?? 0),
          priority: $checkedConvert('priority', (v) => v as int? ?? 1),
          bond: $checkedConvert('bond', (v) => v as int? ?? 0),
          equipCmdCodes: $checkedConvert('equipCmdCodes',
              (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtStatusToJson(SvtStatus instance) => <String, dynamic>{
      'cur': instance.cur.toJson(),
      'coin': instance.coin,
      'priority': instance.priority,
      'bond': instance.bond,
      'equipCmdCodes': instance.equipCmdCodes,
    };

SvtPlan _$SvtPlanFromJson(Map json) => $checkedCreate(
      'SvtPlan',
      json,
      ($checkedConvert) {
        final val = SvtPlan(
          favorite: $checkedConvert('favorite', (v) => v as bool? ?? false),
          ascension: $checkedConvert('ascension', (v) => v as int? ?? 0),
          skills: $checkedConvert('skills',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          appendSkills: $checkedConvert('appendSkills',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          costumes: $checkedConvert('costumes',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          grail: $checkedConvert('grail', (v) => v as int? ?? 0),
          fouHp: $checkedConvert('fouHp', (v) => v as int? ?? 0),
          fouAtk: $checkedConvert('fouAtk', (v) => v as int? ?? 0),
          bondLimit: $checkedConvert('bondLimit', (v) => v as int? ?? 0),
          npLv: $checkedConvert('npLv', (v) => v as int?),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtPlanToJson(SvtPlan instance) => <String, dynamic>{
      'favorite': instance.favorite,
      'ascension': instance.ascension,
      'skills': instance.skills,
      'appendSkills': instance.appendSkills,
      'costumes': instance.costumes,
      'grail': instance.grail,
      'fouHp': instance.fouHp,
      'fouAtk': instance.fouAtk,
      'bondLimit': instance.bondLimit,
      'npLv': instance.npLv,
    };
