// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/remote_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteConfig _$RemoteConfigFromJson(Map json) => $checkedCreate('RemoteConfig', json, ($checkedConvert) {
  final val = RemoteConfig(
    blockedCarousels: $checkedConvert(
      'blockedCarousels',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    blockedErrors: $checkedConvert(
      'blockedErrors',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    urls: $checkedConvert(
      'urls',
      (v) => v == null ? null : ServerUrlConfig.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    silenceStart: $checkedConvert('silenceStart', (v) => (v as num?)?.toInt() ?? 0),
    silenceEnd: $checkedConvert('silenceEnd', (v) => (v as num?)?.toInt() ?? 0),
    ad: $checkedConvert('ad', (v) => v == null ? null : AdConfig.fromJson(Map<String, dynamic>.from(v as Map))),
    versionConstraints: $checkedConvert(
      'versionConstraints',
      (v) => v == null ? null : VersionConstraintsSetting.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
  );
  return val;
});

Map<String, dynamic> _$RemoteConfigToJson(RemoteConfig instance) => <String, dynamic>{
  'blockedCarousels': instance.blockedCarousels,
  'blockedErrors': instance.blockedErrors,
  'urls': instance.urls.toJson(),
  'silenceStart': instance.silenceStart,
  'silenceEnd': instance.silenceEnd,
  'ad': instance.ad.toJson(),
  'versionConstraints': instance.versionConstraints?.toJson(),
};

ServerUrlConfig _$ServerUrlConfigFromJson(Map json) => $checkedCreate('ServerUrlConfig', json, ($checkedConvert) {
  final val = ServerUrlConfig(
    api: $checkedConvert('api', (v) => v == null ? null : UrlProxy.fromJson(Map<String, dynamic>.from(v as Map))),
    worker: $checkedConvert('worker', (v) => v == null ? null : UrlProxy.fromJson(Map<String, dynamic>.from(v as Map))),
    data: $checkedConvert('data', (v) => v == null ? null : UrlProxy.fromJson(Map<String, dynamic>.from(v as Map))),
    atlasApi: $checkedConvert(
      'atlasApi',
      (v) => v == null ? null : UrlProxy.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    atlasAsset: $checkedConvert(
      'atlasAsset',
      (v) => v == null ? null : UrlProxy.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
  );
  return val;
});

Map<String, dynamic> _$ServerUrlConfigToJson(ServerUrlConfig instance) => <String, dynamic>{
  'api': instance.api.toJson(),
  'worker': instance.worker.toJson(),
  'data': instance.data.toJson(),
  'atlasApi': instance.atlasApi.toJson(),
  'atlasAsset': instance.atlasAsset.toJson(),
};

UrlProxy _$UrlProxyFromJson(Map json) => $checkedCreate('UrlProxy', json, ($checkedConvert) {
  final val = UrlProxy._(
    global: $checkedConvert('global', (v) => v as String?),
    cn: $checkedConvert('cn', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$UrlProxyToJson(UrlProxy instance) => <String, dynamic>{
  'global': instance.global,
  'cn': instance.cn,
};

AdConfig _$AdConfigFromJson(Map json) => $checkedCreate('AdConfig', json, ($checkedConvert) {
  final val = AdConfig(enabled: $checkedConvert('enabled', (v) => v as bool? ?? false));
  return val;
});

Map<String, dynamic> _$AdConfigToJson(AdConfig instance) => <String, dynamic>{'enabled': instance.enabled};
