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
          name: $checkedConvert('name', (v) => v as String),
          updated:
              $checkedConvert('updated', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'name': instance.name,
      'updated': instance.updated.toIso8601String(),
    };
