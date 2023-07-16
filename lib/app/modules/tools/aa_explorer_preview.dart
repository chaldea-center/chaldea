import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/image/image_viewer.dart';

class AtlasExplorerPreview extends StatefulWidget {
  const AtlasExplorerPreview({super.key});

  @override
  State<AtlasExplorerPreview> createState() => _AtlasExplorerPreviewState();
}

class _AtlasExplorerPreviewState extends State<AtlasExplorerPreview> {
  static const _explorerHost = 'https://explorer.atlasacademy.io';
  static ApiCacheManager api = ApiCacheManager(null);

  late final TextEditingController _textEditingController = TextEditingController(text: folder);
  late final ScrollController _scrollController = ScrollController();
  late final ScrollController _navScrollController = ScrollController();
  String? authCode;

  String folder = '/aa-fgo-extract-jp/';
  List<String> links = [];

  bool useGrid = true;
  final Map<String, double> _scrollOffsets = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _scrollOffsets[folder] = _scrollController.offset;
      }
    });
    setAuth(db.security.atlasAuth?.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _navScrollController.dispose();
    _textEditingController.dispose();
  }

  bool validateAuth(String s) {
    try {
      return utf8.decode(base64Decode(s)).split(':').length > 1;
    } catch (e) {
      return false;
    }
  }

  void setAuth(String? s) {
    if (s == null || s.isEmpty) return;
    if (validateAuth(s)) {
      authCode = s;
      db.security.saveAtlasAuth(s);
      api.createDio = () => DioE(BaseOptions(headers: {"authorization": "Basic $authCode"}));
    }
  }

  String? loadFolder([String? s]) {
    if (authCode == null) {
      EasyLoading.showError('Invalid Auth');
      return null;
    }
    s ??= _textEditingController.text;
    s = s.trim();
    Uri? uri = Uri.tryParse(s);
    if (uri == null) {
      EasyLoading.showError(s);
      return null;
    }
    if (uri.path.endsWith('.png')) {
      EasyLoading.showError('input folder rather file');
      return null;
    }
    if (uri.host.isNotEmpty) {
      s = s.split(uri.host).getOrNull(1) ?? s;
    }
    s = s.trimChar('/');
    folder = s.isEmpty ? '/' : '/$s/';
    _textEditingController.text = folder;
    downloadPage();
    return folder;
  }

  Future<void> downloadPage() async {
    if (authCode == null) return;
    EasyLoading.show();
    String? htmlText = await api.getText(_explorerHost + folder);
    EasyLoading.dismiss();
    htmlText = htmlText?.split('<tbody>').getOrNull(1);
    if (htmlText == null) {
      EasyLoading.showError('Fetch page failed');
      return;
    }
    links.clear();
    for (final match in RegExp(r'href="([^"]*)"').allMatches(htmlText)) {
      String link = match.group(1)!.trim();
      // `..` parent folder
      if (folder.startsWith(link)) continue;
      link = Uri.parse(_explorerHost).resolve(link).toString();
      link = UriX.tryDecodeFull(link) ?? link;
      links.add(link);
    }
    _scrollOffsets.removeWhere((key, value) => !folder.startsWith(key));
    if (mounted) {
      final offset = _scrollOffsets[folder];
      setState(() {});
      ServicesBinding.instance.addPostFrameCallback((timeStamp) {
        if (offset != null && mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(offset.clamp(0, _scrollController.position.maxScrollExtent));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AA Explorer'),
        actions: [
          IconButton(
            onPressed: () {
              InputCancelOkDialog(
                title: 'Edit Auth',
                validate: validateAuth,
                text: db.security.atlasAuth?.toString(),
                onSubmit: (value) {
                  setAuth(value);
                  if (mounted) setState(() {});
                },
              ).showDialog(context);
            },
            icon: const Icon(Icons.login),
            color: authCode == null || authCode!.isEmpty ? Theme.of(context).colorScheme.error : null,
            tooltip: 'Edit Auth',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                useGrid = !useGrid;
              });
            },
            icon: Icon(useGrid ? Icons.list : Icons.grid_view),
            tooltip: 'Grid/List',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: inputField,
          ),
          breadcrumbNav,
          kDefaultDivider,
          Expanded(child: pageView),
        ],
      ),
    );
  }

  Widget get inputField {
    return TextFormField(
      controller: _textEditingController,
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        labelText: 'Path',
        suffix: InkWell(
          onTap: loadFolder,
          child: const Icon(Icons.cloud_download, size: 18),
        ),
      ),
      onFieldSubmitted: loadFolder,
    );
  }

  Widget _navLink(String name, String folderLink) {
    return Text.rich(SharedBuilder.textButtonSpan(
      context: context,
      text: ' $name ',
      onTap: () {
        loadFolder(folderLink);
      },
    ));
  }

  Widget get breadcrumbNav {
    final parents = folder.split('/').where((e) => e.isNotEmpty).toList();
    //  parents.insert(0, '');
    List<Widget> children = [_navLink('Home', '/'), const Text(' / ')];
    for (int index = 0; index < parents.length; index++) {
      children.add(_navLink(parents[index], parents.sublist(0, index + 1).join('/')));
      children.add(const Text(' / '));
    }
    return SizedBox(
      height: 42,
      child: ListView(
        controller: _navScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: children,
      ),
    );
  }

  Widget get pageView {
    List<Widget> children = [];
    final pngLinks = links.where((e) => e.endsWith('.png') || e.endsWith('.jpg')).toList();

    for (final link in links) {
      String name;
      Widget content;
      VoidCallback onTap;
      bool isImage = false;
      if (link.endsWith('/')) {
        name = link.split('/').lastWhereOrNull((e) => e.isNotEmpty) ?? link;
        content = const Icon(Icons.folder_open);
        onTap = () => loadFolder(link);
      } else if (link.endsWith('.png') || link.endsWith('.jpg')) {
        isImage = true;
        name = link.split('/').last;
        content = CachedImage(
          imageUrl: link,
          placeholder: (context, url) => const SizedBox.shrink(),
        );
        onTap = () {
          FullscreenImageViewer.show(context: context, urls: pngLinks, initialPage: pngLinks.indexOf(link));
        };
      } else {
        name = link.split('/').last;
        content = const Icon(Icons.open_in_new);
        onTap = () => launch(link);
      }
      double? maxWidth = (context.findRenderObject() as RenderBox?)?.size.width;
      if (useGrid) {
        children.add(InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Expanded(child: Center(child: content)),
              SizedBox(
                height: 36,
                child: AutoSizeText(
                  name.breakWord,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  minFontSize: 10,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ));
      } else {
        content = ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 40,
            maxWidth: maxWidth == null ? 120 : maxWidth * 0.5,
          ),
          child: content,
        );
        children.add(ListTile(
          leading: isImage ? null : content,
          title: Text(name),
          trailing: isImage ? content : null,
          onTap: onTap,
          dense: true,
        ));
      }
    }
    if (useGrid) {
      return GridView.extent(
        controller: _scrollController,
        maxCrossAxisExtent: 100,
        childAspectRatio: 1,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: children,
      );
    } else {
      return ListView(
        controller: _scrollController,
        children: children,
      );
    }
  }
}
