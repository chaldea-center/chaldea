import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/custom_table.dart';
import 'package:chaldea/widgets/custom_tile.dart';
import 'package:chaldea/widgets/image/fullscreen_image_viewer.dart';
import 'package:chaldea/widgets/tile_items.dart';
import '../common/not_found.dart';
import '../creator/chara_detail.dart';
import '../creator/creator_detail.dart';

class CmdCodeDetailPage extends StatefulWidget {
  final int? id;
  final CommandCode? cc;
  final CommandCode? Function(CommandCode current, bool reversed)? onSwitch;

  const CmdCodeDetailPage({Key? key, this.id, this.cc, this.onSwitch})
      : super(key: key);

  @override
  _CmdCodeDetailPageState createState() => _CmdCodeDetailPageState();
}

class _CmdCodeDetailPageState extends State<CmdCodeDetailPage> {
  Language? lang;
  CommandCode? _cc;

  CommandCode get cc => _cc!;

  @override
  void initState() {
    super.initState();
    _cc = widget.cc ??
        db.gameData.commandCodes[widget.id] ??
        db.gameData.commandCodesById[widget.id];
  }

  @override
  void didUpdateWidget(covariant CmdCodeDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cc = widget.cc ??
        db.gameData.commandCodes[widget.id] ??
        db.gameData.commandCodesById[widget.id];
  }

  @override
  Widget build(BuildContext context) {
    if (_cc == null) {
      return NotFoundPage(
        title: S.current.command_code,
        url: Routes.commandCodeI(widget.id ?? 0),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(cc.lName.l, maxLines: 1),
        titleSpacing: 0,
        actions: [
          _popupButton,
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child:
                  CmdCodeDetailBasePage(cc: cc, lang: lang, showSummon: true),
            ),
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
                      nextCc = db
                          .gameData.commandCodes[cc.collectionNo + [-1, 1][i]];
                    }
                    if (nextCc == null) {
                      EasyLoading.showToast(S.current.list_end_hint(i == 0));
                    } else {
                      setState(() {
                        _cc = nextCc!;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      textStyle:
                          const TextStyle(fontWeight: FontWeight.normal)),
                  child:
                      Text([S.current.previous_card, S.current.next_card][i]),
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
  final Language? lang;
  final bool showSummon;

  const CmdCodeDetailBasePage(
      {Key? key, required this.cc, this.lang, this.showSummon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTable(
      children: <Widget>[
        CustomTableRow(children: [
          TableCellData(
            child: Text(cc.lName.l,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            isHeader: true,
          )
        ]),
        if (!Transl.isJP)
          CustomTableRow(children: [
            TableCellData(text: cc.lName.jp, textAlign: TextAlign.center)
          ]),
        if (!Transl.isEN)
          CustomTableRow(children: [
            TableCellData(text: cc.lName.na, textAlign: TextAlign.center)
          ]),
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
                  CustomTableRow.fromTexts(
                      texts: ['No. ${cc.collectionNo}', 'No. ${cc.id}']),
                  CustomTableRow(children: [
                    TableCellData(text: S.current.illustrator, isHeader: true),
                    TableCellData(
                        child: Text.rich(SharedBuilder.textButtonSpan(
                          context: context,
                          text: Transl.illustratorNames(cc.illustrator).l,
                          onTap: () {
                            router.pushPage(
                                CreatorDetail.illust(name: cc.illustrator));
                          },
                        )),
                        flex: 3,
                        maxLines: 1)
                  ]),
                  CustomTableRow(children: [
                    TableCellData(text: S.current.rarity, isHeader: true),
                    TableCellData(text: cc.rarity.toString()),
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
        CustomTableRow(
            children: [TableCellData(text: S.current.skill, isHeader: true)]),
        for (final skill in cc.skills..sort2((e) => e.num * 100 + e.priority))
          SkillDescriptor(skill: skill),
        CustomTableRow(children: [
          TableCellData(text: S.current.characters_in_card, isHeader: true)
        ]),
        CustomTableRow(
            children: [TableCellData(child: localizeCharacters(context))]),
        CustomTableRow(children: [
          TableCellData(text: S.current.card_description, isHeader: true)
        ]),
        if (!Transl.isJP && cc.extra.profile.ofRegion(Transl.current) != null)
          CustomTableRow(
            children: [
              TableCellData(
                text: cc.extra.profile.ofRegion(Transl.current) ?? '???',
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              )
            ],
          ),
        CustomTableRow(
          children: [
            TableCellData(
              text: cc.comment,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            )
          ],
        ),
      ],
    );
  }

  Widget localizeCharacters(BuildContext context) {
    List<Widget> children = [];
    for (final svtId in cc.extra.characters) {
      final svt = db.gameData.servants[svtId];
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
