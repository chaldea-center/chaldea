import 'dart:math';
import 'dart:ui' as ui;

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'class_board.dart';

class ClassBoardMap extends StatefulWidget {
  final ClassBoard board;
  final bool showPlanned;
  const ClassBoardMap({super.key, required this.board, required this.showPlanned});

  @override
  State<ClassBoardMap> createState() => _ClassBoardMapState();
}

class _ClassBoardMapState extends State<ClassBoardMap> {
  ClassBoard get board => widget.board;
  final _mapKey = GlobalKey();
  final imageLoader = ImageLoader();

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 10,
      child: GestureDetector(
        onTapUp: (details) => onTap(details.localPosition),
        child: CustomPaint(
          key: _mapKey,
          painter: ClassBoardMapPainter(
            board: board,
            images: imageLoader.images,
            onLoadImage: (url) async {
              final img = await imageLoader.loadImage(url);
              if (img != null && mounted) setState(() {});
            },
            showPlanned: widget.showPlanned,
            unlockSquares: board.status.unlockedSquares.toSet(),
            enhancedSquares: board.status.enhancedSquares.toSet(),
          ),
          size: const Size(2048, 2048),
        ),
      ),
    );
  }

  void onTap(Offset localPosition) async {
    final size = _mapKey.currentContext?.size;
    if (size == null) return;
    final width = min(size.width, size.height);
    final x = (localPosition.dx - size.width / 2) / width * 2048;
    final y = -(localPosition.dy - size.height / 2) / width * 2048;
    ClassBoardSquare? target;
    double minDist = 5000;
    for (final square in board.squares) {
      final distance = Maths.distance(x, y, square.posX, square.posY);
      if (distance < 40 && distance < minDist) {
        minDist = distance;
        target = square;
      }
    }
    if (target != null) {
      await SimpleCancelOkDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (target.icon != null) ...[
              CachedImage(imageUrl: target.icon, width: 24, height: 24),
              const SizedBox(width: 8),
            ],
            Text("No.${target.id}"),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: ClassBoardSquareDetail(board: board, square: target),
        ),
        scrollable: true,
        hideCancel: true,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(8, 10, 8, 24),
      ).showDialog(context);
      if (mounted) setState(() {});
    }
  }
}

class ClassBoardMapPainter extends CustomPainter {
  final ClassBoard board;
  final Map<String, ui.Image> images;
  final Function(String url) onLoadImage;
  final bool showPlanned;
  final Set<int> unlockSquares;
  final Set<int> enhancedSquares;

  static const double w0 = 2048;

  ClassBoardMapPainter({
    required this.board,
    required this.images,
    required this.onLoadImage,
    required this.showPlanned,
    required this.unlockSquares,
    required this.enhancedSquares,
  });

  Paint getPaint() => Paint()..filterQuality = FilterQuality.high;

  @override
  void paint(Canvas canvas, Size size) {
    final width = min(size.width, size.height);
    final scale = width / w0;
    final _paint = getPaint();
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    Rect getRect(Offset c, double w, double h) {
      return Rect.fromCenter(center: c * scale, width: w * scale, height: h * scale);
    }

    void drawImage(String? url, Rect dest, {Paint? paint, Rect Function(ui.Image img)? src}) {
      if (url == null) return;
      final img = images[url];
      if (img == null) {
        onLoadImage(url);
        return;
      }
      canvas.drawImageRect(
        img,
        src?.call(img) ?? Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        dest,
        paint ?? _paint,
      );
    }

    drawImage(asset('Bg/bg.png'), getRect(Offset.zero, 2048, 2048));
    drawImage(
      asset2("Select/ClassScoreSelectionAtlas/circle_05.png"),
      getRect(Offset.zero, 1040, 1040),
      paint: getPaint()..color = const Color.fromRGBO(0, 0, 0, 0.7),
    );
    drawImage(asset2("Select/ClassScoreSelectionAtlas/circle_00.png"), getRect(Offset.zero, 920, 920));
    drawImage(
      asset2("Select/ClassScoreSelectionAtlas/circle_03.png"),
      getRect(Offset.zero, 560, 560),
      // paint: getPaint()..color = const Color.fromRGBO(0, 0, 0, 0.7),
    );
    drawImage(asset('Bg/coat_color.png'), getRect(Offset.zero, 512, 512));
    drawImage(
      asset2("UI/DownloadClassBoardUIAtlas/DownloadClassBoardUIAtlas1/btn_class.png"),
      getRect(Offset.zero, 130, 130),
    );
    drawImage(board.uiIcon, getRect(Offset.zero, 128, 128));

    final squaresMap = {for (final s in board.squares) s.id: s};
    const double sw = 56;

    Set<int> lightenSquares = {};
    for (final square in board.squares) {
      if (square.items.isNotEmpty) {
        if (enhancedSquares.contains(square.id)) {
          lightenSquares.add(square.id);
        }
      } else if (square.lock != null) {
        if (unlockSquares.contains(square.id)) {
          lightenSquares.add(square.id);
        }
      }
    }

    for (final line in board.lines) {
      final prev = squaresMap[line.prevSquareId], next = squaresMap[line.nextSquareId];
      if (prev == null || next == null) continue;
      Paint p =
          Paint()
            ..color = Colors.white60
            ..strokeWidth = sw * scale / 10;
      if (showPlanned && lightenSquares.contains(prev.id) && lightenSquares.contains(next.id)) {
        p
          ..color = Colors.white
          ..strokeWidth = sw * scale / 5;
      }
      canvas.drawLine(prev.offset * scale, next.offset * scale, p);
    }

    final darkenPaint = getPaint()..color = const Color.fromRGBO(0, 0, 0, 0.6);

    for (final square in board.squares) {
      // buffIcon: 110
      // lock/light: 158
      // point(blank): 28*24 or 40*34
      final center = square.offset;
      if (square.flags.length == 1 && square.flags.contains(ClassBoardSquareFlag.blank)) {
        // point,point_off,point_on
        drawImage(
          asset2("Main/DownloadClassBoardSquareLineAtlas1/point.png"),
          getRect(center, sw * 40 / 110 * 3, sw * 34 / 110 * 3),
        );
        continue;
      }

      final lock = square.lock;
      if (lock != null) {
        bool darkenLock = showPlanned && !unlockSquares.contains(square.id);

        int? itemId;
        for (final itemAmount in lock.items) {
          if (itemAmount.itemId >= 51 && itemAmount.itemId <= 53) {
            itemId = itemAmount.itemId;
            break;
          }
        }
        if (itemId != null) {
          const double lw = sw * 158 / 110 * 1.2;
          if (showPlanned) {
            drawImage(
              asset("Icon/lock_${darkenLock ? "off" : "light"}_$itemId.png"),
              getRect(center, lw * 1.5, lw * 1.5),
            );
          }
          drawImage(asset("Icon/lock_$itemId.png"), getRect(center, lw, lw), paint: darkenLock ? darkenPaint : null);
        }
      } else {
        final radius = sw / 2 * scale;
        canvas.drawCircle(center * scale, radius, Paint()..color = Colors.white24);
        canvas.drawCircle(
          center * scale,
          radius,
          Paint()
            ..color = Colors.white70
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius / 10,
        );
      }

      bool darkenSquare = showPlanned && !enhancedSquares.contains(square.id);
      if (showPlanned && !darkenSquare) {
        // drawImage(asset2("Main/glow_01.png"), getRect(center, sw * 2, sw * 2));
        drawImage(
          asset2("Main/DownloadClassBoardSquareLineAtlas1/square_on_light.png"),
          getRect(center, sw * 1.8, sw * 1.8),
        );
        drawImage(asset2("Main/DownloadClassBoardSquareLineAtlas1/square_on.png"), getRect(center, sw * 2, sw * 2));
      }
      drawImage(
        square.icon,
        getRect(center, sw, sw),
        paint: darkenSquare ? (getPaint()..color = const Color.fromRGBO(0, 0, 0, 0.6)) : null,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ClassBoardMapPainter oldDelegate) {
    return oldDelegate.board != board ||
        !oldDelegate.images.keys.toSet().equalTo(images.keys.toSet()) ||
        oldDelegate.showPlanned != showPlanned ||
        !oldDelegate.unlockSquares.equalTo(unlockSquares) ||
        oldDelegate.enhancedSquares.equalTo(enhancedSquares);
  }

  String asset(String p) {
    p = p.trimChar('/');
    return "https://static.atlasacademy.io/JP/ClassBoard/$p";
  }

  String asset2(String p) {
    p = p.trimChar('/');
    return "https://static.atlasacademy.io/file/aa-fgo-extract-jp/ClassBoard/$p";
  }
}
