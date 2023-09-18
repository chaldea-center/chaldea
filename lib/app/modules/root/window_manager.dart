import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/home/bootstrap/bootstrap.dart';
import 'package:chaldea/app/modules/root/global_fab.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/material.dart';
import '../../routes/root_delegate.dart';
import 'multi_screenshots.dart';

class WindowManager extends StatefulWidget {
  final RootAppRouterDelegate delegate;

  const WindowManager({super.key, required this.delegate});

  @override
  _WindowManagerState createState() => _WindowManagerState();
}

class _WindowManagerState extends State<WindowManager> {
  RootAppRouterDelegate get root => widget.delegate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!root.appState.dataReady) {
      return BootstrapPage();
    }
    Widget child;
    switch (root.appState.windowState) {
      case WindowStateEnum.single:
        child = root.appState.showSidebar && SplitRoute.isSplit(context)
            ? WrapSideBar(root: root, child: OneWindow(root: root))
            : OneWindow(root: root);
        break;
      case WindowStateEnum.windowManager:
        child = MultipleWindow(root: root);
        break;
      case WindowStateEnum.screenshot:
        child = MultiScreenshots(root: root);
        break;
    }

    final maxWidth = db.settings.display.maxWindowWidth?.toDouble();
    if ((kIsWeb || kDebugMode) && maxWidth != null) {
      if (maxWidth >= 360 && maxWidth < 1920) {
        final mq = MediaQuery.of(context);
        final size = mq.size;
        child = Scaffold(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          body: Center(
            child: Material(
              elevation: 16,
              child: ClipRect(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: MediaQuery(
                    data: mq.copyWith(size: Size(min(size.width, maxWidth), size.height)),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return child;
  }
}

class WrapSideBar extends StatelessWidget {
  const WrapSideBar({
    super.key,
    required this.root,
    required this.child,
  });

  final RootAppRouterDelegate root;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.separated(
      padding: const EdgeInsets.all(4),
      itemCount: root.appState.children.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final isActive = index == root.appState.activeIndex;
        return MaterialButton(
          elevation: 1,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          color: isActive ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
          onPressed: () {
            root.appState.activeIndex = index;
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        );
      },
    );
    final ltr = Directionality.maybeOf(context);
    final mqData = MediaQuery.of(context).removePadding(
      removeLeft: ltr == TextDirection.ltr,
      removeRight: ltr == TextDirection.rtl,
    );
    final headerIcon = Container(
      color: Theme.of(context).primaryColorDark,
      height: kToolbarHeight,
      padding: const EdgeInsets.all(6),
      child: Icon(
        Icons.menu,
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SizedBox(
            width: 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerIcon,
                Flexible(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: listView,
                  ),
                ),
                const Divider(indent: 2, endIndent: 2),
                IconButton(
                  onPressed: () {
                    root.appState.addWindow();
                  },
                  icon: const Icon(Icons.add),
                  iconSize: 18,
                ),
                IconButton(
                  onPressed: () {
                    root.appState.windowState = WindowStateEnum.windowManager;
                  },
                  icon: const Icon(Icons.grid_view),
                )
              ],
            ),
          ),
        ),
        VerticalDivider(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 0,
        ),
        Expanded(
          child: MediaQuery(
            data: mqData.copyWith(size: Size(mqData.size.width - 48, mqData.size.height)),
            child: child,
          ),
        ),
      ],
    );
  }
}

class OneWindow extends StatelessWidget {
  const OneWindow({
    super.key,
    required this.root,
  });

  final RootAppRouterDelegate root;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: root.appState.activeIndex,
        children: List.generate(
          root.appState.children.length,
          (index) {
            final _delegate = root.appState.children[index];
            final child = AppShell(
              appState: root.appState,
              routerDelegate: _delegate,
              active: index == root.appState.activeIndex && root.appState.windowState.isSingle,
            );
            if (index == root.appState.activeIndex) {
              return child;
            } else {
              return Offstage(child: child);
            }
          },
        ),
      ),
      // if not set, FAB will animate from right to center
      // when showing window manager
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class MultipleWindow extends StatelessWidget {
  const MultipleWindow({super.key, required this.root});

  final RootAppRouterDelegate root;

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    int crossCount = windowSize.width ~/ 300;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).highlightColor.withOpacity(0.8),
        appBar: AppBar(
          toolbarHeight: 42,
          title: const Text(kAppName),
          actions: [
            DropdownButton<Language>(
              value: Language.getLanguage(S.current.localeName),
              items: [
                for (final lang in Language.supportLanguages) DropdownMenuItem(value: lang, child: Text(lang.name))
              ],
              icon: Icon(
                Icons.arrow_drop_down,
                color: SharedBuilder.appBarForeground(context),
              ),
              selectedItemBuilder: (context) => [
                for (final lang in Language.supportLanguages)
                  DropdownMenuItem(
                    value: lang,
                    child: Text(
                      lang.name,
                      style: TextStyle(color: SharedBuilder.appBarForeground(context)),
                    ),
                  )
              ],
              onChanged: (lang) {
                if (lang == null) return;
                db.settings.setLanguage(lang);
                db.notifyAppUpdate();
              },
              underline: const SizedBox(),
            ),
          ],
          bottom: FixedHeight.tabBar(TabBar(tabs: [const Tab(text: 'Tabs'), Tab(text: S.current.history)])),
        ),
        body: TabBarView(children: [
          SafeArea(
            child: GridView.count(
              crossAxisCount: max(crossCount, 2),
              childAspectRatio: windowSize.aspectRatio,
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 72),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(
                root.appState.children.length,
                (index) => WindowThumb(key: ObjectKey(root.appState.children[index]), root: root, index: index),
              ),
            ),
          ),
          buildHistory(context),
        ]),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            root.appState.addWindow();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget buildHistory(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final url = AppRouterDelegate.urlHistory[AppRouterDelegate.urlHistory.length - 1 - index];
          return ListTile(
            dense: true,
            title: Text(url),
            onTap: () {
              root.appState.activeRouter.push(url: url);
              root.appState.windowState = WindowStateEnum.single;
            },
          );
        },
        itemCount: AppRouterDelegate.urlHistory.length,
      ),
    );
  }
}

class WindowThumb extends StatelessWidget {
  const WindowThumb({
    super.key,
    required this.root,
    required this.index,
    this.absorbPointer = true,
    this.gesture = true,
    this.showTitle = true,
  });

  final RootAppRouterDelegate root;
  final int index;
  final bool absorbPointer;
  final bool gesture;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final childDelegate = root.appState.children[index];
    final url = childDelegate.currentConfiguration?.url;
    Widget child = AbsorbPointer(
      absorbing: absorbPointer,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox.fromSize(
          size: MediaQuery.of(context).size,
          child: childDelegate.build(context),
        ),
      ),
    );
    child = Stack(
      // alignment: Alignment.bottomLeft,
      children: [
        Positioned.fill(child: child),
        showTitle
            ? Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor.withOpacity(1),
                      border: Border(
                        top: BorderSide(
                          width: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        bottom: BorderSide(
                          width: 3,
                          color: index == root.appState.activeIndex
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        root.appState.activeIndex = index;
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 0, 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "[$index] ${url ?? ""}".breakWord,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (root.appState.children.length <= 1) return;
                                root.appState.removeWindow(index);
                              },
                              icon: const Icon(Icons.clear),
                              padding: const EdgeInsets.all(4),
                              iconSize: 16,
                              constraints: const BoxConstraints(minWidth: 24),
                            )
                          ],
                        ),
                      ),
                    )),
              )
            : Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    root.appState.activeIndex = index;
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(width: double.infinity, height: 8),
                ),
              ),
      ],
    );

    if (gesture) {
      child = GestureDetector(
        onTap: () {
          root.appState.activeIndex = index;
          root.appState.windowState = WindowStateEnum.single;
          WindowManagerFab.markNeedRebuild();
        },
        onLongPress: url == null || url.isEmpty
            ? null
            : () async {
                final fullUrl = ChaldeaUrl.app(url);
                await copyToClipboard(fullUrl);
                EasyLoading.showToast('${S.current.copied}\n$fullUrl');
              },
        child: child,
      );
    }

    return child;
  }
}
