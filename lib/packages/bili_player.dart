// // ignore_for_file: depend_on_referenced_packages

// import 'package:flutter/foundation.dart';

// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// import 'package:chaldea/models/models.dart';
// import 'package:chaldea/packages/packages.dart';
// import 'package:chaldea/utils/utils.dart';
// import 'package:chaldea/widgets/widgets.dart';
// import '../app/api/chaldea.dart';

// // don't import webview_flutter_web

// class BiliPlayer extends StatefulWidget {
//   final BiliVideo video;
//   const BiliPlayer({super.key, required this.video});

//   @override
//   State<BiliPlayer> createState() => _BiliPlayerState();

//   static bool get isSupport => PlatformU.isAndroid || PlatformU.isIOS || PlatformU.isWeb;
// }

// class _BiliPlayerState extends State<BiliPlayer> {
//   WebViewController? controller;
//   double? ratio;

//   void init() async {
//     if (!BiliPlayer.isSupport) {
//       return;
//     }
//     late final PlatformWebViewControllerCreationParams params;
//     if (WebViewPlatform.instance is WebKitWebViewPlatform) {
//       params = WebKitWebViewControllerCreationParams(
//         allowsInlineMediaPlayback: true,
//         mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
//       );
//     } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
//       params = AndroidWebViewControllerCreationParams();
//     } else {
//       params = const PlatformWebViewControllerCreationParams();
//     }

//     final controller = WebViewController.fromPlatformCreationParams(params);
//     final platformController = controller.platform;
//     if (platformController is AndroidWebViewController) {
//       AndroidWebViewController.enableDebugging(true);
//       platformController.setMediaPlaybackRequiresUserGesture(false);
//     } else if (platformController is WebKitWebViewController) {
//       //
//     }

//     if (!kIsWeb) {
//       controller
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setBackgroundColor(Colors.grey[100]!)
//         ..enableZoom(false)
//         ..setNavigationDelegate(
//           NavigationDelegate(
//             onWebResourceError: (WebResourceError error) {
//               print([error.errorType, error.errorCode, error.description]);
//             },
//             onNavigationRequest: (NavigationRequest request) {
//               return NavigationDecision.prevent;
//             },
//           ),
//         );
//     }
//     controller.loadHtmlString(_playerHtml(null, true, null));
//     this.controller = controller;
//     if (mounted) setState(() {});
//     final resp = await CachedApi.biliVideoInfo(aid: widget.video.av, bvid: widget.video.bv);
//     int p = widget.video.p ?? 1;
//     if (p == 0) p = 1;
//     int? cid;
//     String? bvid;
//     try {
//       final data = resp?['data'] as Map?;
//       if (data != null) {
//         bvid = data['bvid'];
//         final pages = data['pages'] as List;
//         final pageData = pages.firstWhereOrNull((page) => page['page'] == p) as Map?;
//         if (pageData != null) {
//           cid = pageData['cid'];
//           ratio = pageData['dimension']!['width']! / pageData['dimension']!['height']!;
//         }
//       }
//       if (bvid == null || cid == null) {
//         controller.loadHtmlString(_playerHtml(null, false, 'Something went wrong.'));
//       } else {
//         controller.loadHtmlString(_playerHtml(
//           'https://player.bilibili.com/player.html?bvid=$bvid&cid=$cid&page=$p&high_quality=1&danmaku=0&enable_ssl=1&as_wide=1',
//           true,
//           null,
//         ));
//       }
//     } catch (e, s) {
//       logger.e('fetch bili video info failed', e, s);
//       controller.loadHtmlString(_playerHtml(null, false, e.toString()));
//     }
//     if (mounted) setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget child;
//     if (controller == null) {
//       child = Container(
//         color: Colors.black26,
//         child: Center(
//           child: GestureDetector(
//             onTap: init,
//             child: const Icon(
//               Icons.play_arrow_rounded,
//               color: Colors.white,
//               size: 100.0,
//             ),
//           ),
//         ),
//       );
//     } else {
//       child = WebViewWidget(controller: controller!);
//       if (ratio != null) {
//         child = AspectRatio(aspectRatio: ratio!, child: child);
//       }
//     }
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 50),
//       reverseDuration: const Duration(milliseconds: 200),
//       child: child,
//     );
//   }
// }

// // https://player.bilibili.com/player.html?bvid=BV113411z7mA&cid=940662723&page=70&high_quality=1&danmaku=0&enable_ssl=1&as_wide=1
// String _iframe(String url) => """
//     <div style="position: relative; padding: 0">
//       <iframe
//         src="$url"
//         scrolling="no"
//         border="0"
//         frameborder="no"
//         framespacing="0"
//         allowfullscreen="false"
//         style="width: 100%; height: 100%; left: 0; top: 0"
//         onload="loaded()"
//       >
//       </iframe>
//     </div>
// """;

// String _loader() => """
//     <div class="loader-container">
//       <div class="loader"></div>
//     </div>
// """;

// String _playerHtml(String? url, bool loader, String? error) => """
// <html>
//   <head>
//     <style>
//       .loader-container {
//         justify-content: center;
//       }
//       .loader {
//         border: 16px solid #f3f3f3; /* Light grey */
//         border-top: 16px solid #3498db; /* Blue */
//         border-radius: 50%;
//         animation: spin 2s linear infinite;

//         position: fixed;
//         top: 50%;
//         left: 50%;
//         margin-top: -50px;
//         margin-left: -50px;
//         width: 100px;
//         height: 100px;
//       }

//       @keyframes spin {
//         0% {
//           transform: rotate(0deg);
//         }
//         100% {
//           transform: rotate(360deg);
//         }
//       }
//     </style>
//     <script>
//       function loaded() {
//         let elements = document.getElementsByClassName("loader-container");
//         if (elements.length) {
//           elements[0].remove();
//         }
//       }
//     </script>
//   </head>
//   <body>
//     ${loader ? _loader() : ""}
//     ${url == null ? "" : _iframe(url)}
//     ${error ?? ""}
//   </body>
// </html>""";
