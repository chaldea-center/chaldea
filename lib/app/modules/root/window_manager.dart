import 'dart:math';

import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/home/bootstrap.dart';
import 'package:chaldea/app/modules/root/global_fab.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import '../../routes/root_delegate.dart';

class WindowManager extends StatefulWidget {
  final RootAppRouterDelegate delegate;

  const WindowManager({Key? key, required this.delegate}) : super(key: key);

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
    return root.appState.showWindowManager
        ? MultipleWindow(root: root)
        : root.appState.showSidebar && SplitRoute.isSplit(context)
            ? WrapSideBar(root: root, child: OneWindow(root: root))
            : OneWindow(root: root);
  }
}

class WrapSideBar extends StatelessWidget {
  const WrapSideBar({
    Key? key,
    required this.root,
    required this.child,
  }) : super(key: key);

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
          color: isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).canvasColor,
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
                  color: isActive
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).hintColor,
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
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
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
                    root.appState.showWindowManager = true;
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
            data: mqData.copyWith(
                size: Size(mqData.size.width - 48, mqData.size.height)),
            child: child,
          ),
        ),
      ],
    );
  }
}

class OneWindow extends StatelessWidget {
  const OneWindow({
    Key? key,
    required this.root,
  }) : super(key: key);

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
              active: index == root.appState.activeIndex &&
                  !root.appState.showWindowManager,
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
  const MultipleWindow({
    Key? key,
    required this.root,
  }) : super(key: key);

  final RootAppRouterDelegate root;

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    int crossCount = windowSize.width ~/ 300;
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor.withOpacity(0.8),
      appBar: AppBar(title: const Text('Tabs')),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: max(crossCount, 2),
          childAspectRatio: windowSize.aspectRatio,
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 72),
          children: List.generate(
            root.appState.children.length,
            (index) => WindowThumb(root: root, index: index),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          root.appState.addWindow();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class WindowThumb extends StatelessWidget {
  const WindowThumb({
    Key? key,
    required this.root,
    required this.index,
  }) : super(key: key);

  final RootAppRouterDelegate root;
  final int index;

  @override
  Widget build(BuildContext context) {
    final childDelegate = root.appState.children[index];
    final url = childDelegate.currentConfiguration?.url;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          root.appState.activeIndex = index;
          root.appState.showWindowManager = false;
          WindowManagerFab.markNeedRebuild();
        },
        child: Stack(
          // alignment: Alignment.bottomLeft,
          children: [
            Positioned.fill(
              child: AbsorbPointer(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox.fromSize(
                    size: MediaQuery.of(context).size,
                    child: childDelegate.build(context),
                  ),
                ),
              ),
            ),
            Positioned(
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
                child: ListTile(
                  dense: true,
                  title: Text('[$index] ${url == null ? '' : ': $url'}'),
                  trailing: IconButton(
                    onPressed: () {
                      if (root.appState.children.length <= 1) return;
                      root.appState.removeWindow(index);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  contentPadding: const EdgeInsetsDirectional.only(start: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
