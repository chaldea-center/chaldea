import 'dart:math';

import 'package:flutter/material.dart';

import '../../../components/method_channel_chaldea.dart';
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
    return root.appState.showWindowManager ? _multiple(context) : _one(context);
  }

  Widget _one(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: root.activeIndex,
        children: List.generate(
          root.children.length,
          (index) {
            final _delegate = root.children[index];
            if (index == root.activeIndex) {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).highlightColor.withOpacity(0.8),
        appBar: AppBar(
          toolbarHeight: 0.0,
          bottom: const TabBar(tabs: [Tab(text: 'Tabs'), Tab(text: 'Debug')]),
        ),
        body: SafeArea(
          child: GridView.count(
            crossAxisCount: max(crossCount, 2),
            childAspectRatio: windowSize.aspectRatio,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 72),
            children: List.generate(
              root.children.length,
              (index) => _windowThumb(context, index),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            root.addDelegate();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _windowThumb(BuildContext context, int index) {
    final childDelegate = root.children[index];
    final url = childDelegate.currentConfiguration?.url;

    Widget child = Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          print('click $index');
          root.activeIndex = index;
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
                      color: index == root.activeIndex
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
                      if (root.children.length <= 1) return;
                      root.removeDelegate(index);
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
