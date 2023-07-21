import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/extra_assets_page.dart';
import '../common/not_found.dart';
import '../creator/chara_detail.dart';
import '../creator/creator_detail.dart';
import '../servant/tabs/profile_tab.dart';

class CmdCodeDetailPage extends StatefulWidget {
  final int? id;
  final CommandCode? cc;
  final CommandCode? Function(CommandCode current, bool reversed)? onSwitch;

  const CmdCodeDetailPage({super.key, this.id, this.cc, this.onSwitch});

  @override
  _CmdCodeDetailPageState createState() => _CmdCodeDetailPageState();
}

class _CmdCodeDetailPageState extends State<CmdCodeDetailPage> {
  bool _loading = false;
  CommandCode? _cc;
  CommandCode get cc => _cc!;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    _loading = true;
    if (mounted) setState(() {});
    _cc = widget.cc ?? db.gameData.commandCodes[widget.id] ?? db.gameData.commandCodesById[widget.id];
    final id = widget.cc?.id ?? widget.id;
    if (id == null || _cc != null) return;
    _cc = await AtlasApi.cc(id);
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_cc == null) {
      return NotFoundPage(
        title: S.current.command_code,
        url: Routes.commandCodeI(widget.id ?? 0),
        loading: _loading,
      );
    }
    final status = cc.status;
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(cc.lName.l, maxLines: 1),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                status.status = (status.status + 1) % 3;
              });
              db.notifyUserdata();
              EasyLoading.showToast(status.statusText);
            },
            icon: status.status == CmdCodeStatus.owned
                ? const Icon(Icons.favorite, color: Colors.redAccent)
                : status.status == CmdCodeStatus.met
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_outline),
            tooltip: status.statusText,
          ),
          _popupButton,
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: CmdCodeDetailBasePage(cc: cc, showExtra: true),
            ),
          ),
          if (status.status == CmdCodeStatus.owned)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${status.statusText}: '),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return InputCancelOkDialog(
                          title: S.current.total_counts,
                          text: status.count.toString(),
                          validate: (s) {
                            final v = int.tryParse(s);
                            return v != null && v >= 0;
                          },
                          onSubmit: (v) {
                            status.count = int.tryParse(v) ?? status.count;
                            if (mounted) setState(() {});
                          },
                        );
                      },
                    );
                  },
                  child: Text(' ${status.count} '),
                ),
              ],
            ),
          SafeArea(
            child: ButtonBar(alignment: MainAxisAlignment.center, children: [
              // ProfileLangSwitch(
              //   primary: lang,
              //   onChanged: (v) {
              //     setState(() {
              //       lang = v;
              //     });
              //   },
              // ),
              for (var i = 0; i < 2; i++)
                ElevatedButton(
                  onPressed: () {
                    CommandCode? nextCc;
                    if (widget.onSwitch != null) {
                      // if navigated from filter list, let filter list decide which is the next one
                      nextCc = widget.onSwitch!(cc, i == 0);
                    } else {
                      nextCc = db.gameData.commandCodes[cc.collectionNo + [-1, 1][i]];
                    }
                    if (nextCc == null) {
                      EasyLoading.showToast(S.current.list_end_hint(i == 0));
                    } else {
                      setState(() {
                        _cc = nextCc!;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontWeight: FontWeight.normal)),
                  child: Text([S.current.previous_card, S.current.next_card][i]),
                ),
            ]),
          )
        ],
      ),
    );
  }

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return SharedBuilder.websitesPopupMenuItems(
          atlas: Atlas.dbCommandCode(cc.id),
          mooncell: cc.extra.mcLink,
          fandom: cc.extra.fandomLink,
        );
      },
    );
  }
}

class CmdCodeDetailBasePage extends StatelessWidget {
  final CommandCode cc;
  final bool showExtra;
  final bool enableLink;

  const CmdCodeDetailBasePage({
    super.key,
    required this.cc,
    this.showExtra = false,
    this.enableLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = RubyText(
      [RubyTextData(cc.name, ruby: cc.ruby)],
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );

    return CustomTable(
      selectable: true,
      children: <Widget>[
        CustomTableRow(children: [
          TableCellData(
            child: enableLink
                ? TextButton(
                    onPressed: () {
                      cc.routeTo();
                    },
                    style: kTextButtonDenseStyle,
                    child: name,
                  )
                : name,
            isHeader: true,
            padding: enableLink ? EdgeInsets.zero : const EdgeInsets.all(4),
          )
        ]),
        if (!Transl.isJP) CustomTableRow(children: [TableCellData(text: cc.lName.l, textAlign: TextAlign.center)]),
        if (!Transl.isEN) CustomTableRow(children: [TableCellData(text: cc.lName.na, textAlign: TextAlign.center)]),
        CustomTableRow(
          children: [
            TableCellData(
              child: InkWell(
                child: db.getIconImage(cc.borderedIcon, height: 72),
                onTap: () {
                  FullscreenImageViewer.show(
                    context: context,
                    urls: [cc.charaGraph],
                    placeholder: placeholder,
                  );
                },
              ),
              flex: 1,
              padding: const EdgeInsets.all(3),
            ),
            TableCellData(
              flex: 3,
              padding: EdgeInsets.zero,
              child: CustomTable(
                hideOutline: true,
                children: <Widget>[
                  CustomTableRow.fromTexts(texts: ['No. ${cc.collectionNo}', 'No. ${cc.id}']),
                  CustomTableRow(children: [
                    TableCellData(text: S.current.illustrator, isHeader: true),
                    TableCellData(
                      child: Text.rich(SharedBuilder.textButtonSpan(
                        context: context,
                        text: Transl.illustratorNames(cc.illustrator).l,
                        onTap: () {
                          router.pushPage(CreatorDetail.illust(name: cc.illustrator));
                        },
                      )),
                      flex: 3,
                    )
                  ]),
                  CustomTableRow(children: [
                    TableCellData(text: S.current.rarity, isHeader: true),
                    TableCellData(text: cc.rarity.toString(), flex: 3),
                  ]),
                ],
              ),
            ),
          ],
        ),
        CustomTableRow(
          children: [
            TableCellData(
              child: CustomTile(
                title: Center(child: Text(S.current.view_illustration)),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  FullscreenImageViewer.show(
                    context: context,
                    urls: [cc.charaGraph],
                    placeholder: placeholder,
                  );
                },
              ),
              isHeader: true,
            ),
          ],
        ),
        CustomTableRow(children: [TableCellData(text: S.current.skill, isHeader: true)]),
        for (final skill in cc.skills..sort2((e) => e.svt.num * 100 + e.svt.priority)) SkillDescriptor(skill: skill),
        CustomTableRow(children: [TableCellData(text: S.current.characters_in_card, isHeader: true)]),
        CustomTableRow(children: [TableCellData(child: localizeCharacters(context))]),
        CustomTableRow(children: [TableCellData(text: S.current.card_description, isHeader: true)]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: getProfiles().toList(),
          ),
        ),
        CustomTableRow.fromTexts(
          texts: [S.current.illustration],
          isHeader: true,
        ),
        ExtraAssetsPage(
          assets: cc.extraAssets,
          scrollable: false,
        ),
        if (showExtra) ...[
          CustomTableRow.fromTexts(
            texts: [S.current.cc_equipped_svt],
            isHeader: true,
          ),
          CustomTableRow.fromChildren(children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _equippedSvts(context),
            ),
          ]),
        ]
      ],
    );
  }

  List<Widget> _equippedSvts(BuildContext context) {
    List<Widget> svts = [];
    db.curUser.servants.forEach((svtNo, status) {
      final svt = db.gameData.servantsWithDup[svtNo];
      if (status.equipCmdCodes.contains(cc.collectionNo) && svt != null) {
        svts.add(svt.iconBuilder(context: context, height: 48));
      }
    });
    if (svts.isEmpty) svts.add(const Text('-'));
    return svts;
  }

  Iterable<Widget> getProfiles() sync* {
    final profiles = <String?>{
      cc.comment,
      if (!Transl.isJP) cc.extra.profile.l,
      cc.extra.profile.ofRegion(Region.jp),
    };
    for (final profile in profiles.whereType<String>()) {
      yield ProfileCommentCard(
        title: Text(S.current.card_description),
        comment: profile,
      );
    }
  }

  Widget localizeCharacters(BuildContext context) {
    List<Widget> children = [];
    for (final svtId in cc.extra.characters) {
      final svt = db.gameData.servantsNoDup[svtId];
      if (svt == null) {
        children.add(Text('SVT $svtId'));
      } else {
        children.add(InkWell(
          child: Text(
            svt.lName.l,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () => router.push(url: svt.route),
        ));
      }
    }
    for (final name in cc.extra.unknownCharacters) {
      children.add(InkWell(
        child: Text(
          Transl.charaNames(name).l,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        onTap: () => router.pushPage(CharaDetail(name: name)),
      ));
    }
    if (children.isEmpty) {
      return const Text('-');
    }
    children = divideTiles(children, divider: const Text('/'));
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  Widget placeholder(BuildContext context, String? url) {
    return const SizedBox();
  }
}
