part of datatypes;

@JsonSerializable()
class KeyValueEntry {
  String? key;
  dynamic value;

  KeyValueEntry({this.key, this.value});

  factory KeyValueEntry.fromJson(Map<String, dynamic> data) =>
      _$KeyValueEntryFromJson(data);

  Map<String, dynamic> toJson() => _$KeyValueEntryToJson(this);
}

@JsonSerializable()
class KeyValueListEntry {
  String? key;
  List valueList;

  KeyValueListEntry({this.key, List? valueList}) : valueList = valueList ?? [];

  factory KeyValueListEntry.fromJson(Map<String, dynamic> data) =>
      _$KeyValueListEntryFromJson(data);

  Map<String, dynamic> toJson() => _$KeyValueListEntryToJson(this);
}
