import 'dart:math';

import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:flutter/material.dart';

import '../../../packages/method_channel/method_channel_chaldea.dart';
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
    MethodChannelChaldea.setAlwaysOnTop(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return root.appState.showWindowManager
        ? _multiple(context)
        : root.appState.showSidebar && SplitRoute.isSplit(context)
            ? _wrapSidebar(_one(context))
            : _one(context);
  }

  Widget _wrapSidebar(Widget child) {
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
        Expanded(child: child),
      ],
    );
  }

  Widget _one(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: root.appState.activeIndex,
        children: List.generate(
          root.appState.children.length,
          (index) {
            final _delegate = root.appState.children[index];
            if (index == root.appState.activeIndex) {
              return _delegate.build(context);
            } else {
              return Offstage(child: _delegate.build(context));
            }
          },
        ),
      ),
    );
  }

  Widget _multiple(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    int crossCount = windowSize.width ~/ 300;
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor.withOpacity(0.8),
      appBar: AppBar(title: const Text('Tabs')),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: max(crossCount, 2),
          childAspectRatio: windowSize.aspectRatio,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 72),
          children: List.generate(
            root.appState.children.length,
            (index) => _windowThumb(context, index),
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

  Widget _windowThumb(BuildContext context, int index) {
    final childDelegate = root.appState.children[index];
    final url = childDelegate.currentConfiguration?.url;

    Widget child = Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          root.appState.activeIndex = index;
          root.appState.showWindowManager = false;
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
                  color: Theme.of(context).highlightColor.withOpacity(0.9),
                  border: Border(
                    bottom: BorderSide(
                      width: 3,
                      color: index == root.appState.activeIndex
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  title: Text('Tab $index' + (url == null ? '' : ': $url')),
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
    return child;
  }
}
