// GENERATED CODE - DO NOT MODIFY BY HAND

part of model;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppData _$AppDataFromJson(Map<String, dynamic> json) {
  return AppData(
      language: json['language'] as String ?? 'chs',
      galleries:
          (json['galleries'] as List)?.map((e) => e as String)?.toList() ?? [],
      curUser: json['curUser'] as String)
    ..users = (json['users'] as Map<String, dynamic>)?.map(
          (k, e) => MapEntry(
              k, e == null ? null : User.fromJson(e as Map<String, dynamic>)),
        ) ??
        {};
}

Map<String, dynamic> _$AppDataToJson(AppData instance) => <String, dynamic>{
      'language': instance.language,
      'galleries': instance.galleries,
      'curUser': instance.curUser,
      'users': instance.users
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      id: json['id'] as String, server: json['server'] as String ?? 'cn');
}

Map<String, dynamic> _$UserToJson(User instance) =>
    <String, dynamic>{'id': instance.id, 'server': instance.server};
