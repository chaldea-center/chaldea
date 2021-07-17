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

mixin GameCardMixin {
  int get no;

  String get mcLink;

  String get icon;

  String get lName;

  Widget charactersToButtons(BuildContext context, List<String> characters) {
    if (characters.isEmpty) return Text('-');
    List<Widget> children = [];
    for (final name in characters) {
      final svt =
          db.gameData.servants.values.firstWhereOrNull((s) => s.mcLink == name);
      if (svt == null) {
        children.add(Text(name));
      } else {
        children.add(InkWell(
          child: Text(
            svt.info.localizedName,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () => svt.pushDetail(context),
        ));
      }
    }
    children = divideTiles(children, divider: Text('/'));
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
