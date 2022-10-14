import 'package:carousel_slider/carousel_slider.dart';

import 'package:chaldea/widgets/widgets.dart';

const _kAspectRatio = 8 / 3;
const _kMaxHeight = 150.0;
const _kMaxViewport = 0.8;

class CarouselLimitHeightOption {
  double? height;
  double viewportFraction;
  double aspectRatio;
  bool enlargeCenterPage;
  CenterPageEnlargeStrategy enlargeStrategy;

  CarouselLimitHeightOption({
    this.height,
    this.viewportFraction = 1.0,
    this.aspectRatio = _kAspectRatio,
    this.enlargeCenterPage = false,
    this.enlargeStrategy = CenterPageEnlargeStrategy.scale,
  });

  bool get limited => height != null;
}

class CarouselUtil {
  static CarouselLimitHeightOption limitHeight({
    required double? width,
    double maxHeight = _kMaxHeight,
    double maxViewport = _kMaxViewport,
    double aspectRatio = _kAspectRatio,
  }) {
    // the critical height is larger than maxHeight
    double criticalWidth = maxHeight * aspectRatio / maxViewport;
    bool limited =
        width != null && width != double.infinity && width >= criticalWidth;
    if (limited) {
      return CarouselLimitHeightOption(
        height: maxHeight,
        viewportFraction: maxHeight * aspectRatio / width,
        aspectRatio: aspectRatio,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
      );
    } else {
      return CarouselLimitHeightOption(
        height: null,
        viewportFraction: 1.0,
        aspectRatio: aspectRatio,
        enlargeCenterPage: false,
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
      );
    }
  }

  static CarouselOptions limitHeightOption({
    required double? width,
    double maxHeight = _kMaxHeight,
    double maxViewport = _kMaxViewport,
    double aspectRatio = _kAspectRatio,
    CarouselOptions? baseOption,
  }) {
    final limitOption = limitHeight(
      width: width,
      maxHeight: maxHeight,
      maxViewport: maxViewport,
      aspectRatio: aspectRatio,
    );
    baseOption ??= CarouselOptions();
    return CarouselOptions(
      height: limitOption.height,
      aspectRatio: limitOption.aspectRatio,
      viewportFraction: limitOption.viewportFraction,
      enlargeCenterPage: limitOption.enlargeCenterPage,
      enlargeStrategy: limitOption.enlargeStrategy,
      // baseOption
      initialPage: baseOption.initialPage,
      enableInfiniteScroll: baseOption.enableInfiniteScroll,
      reverse: baseOption.reverse,
      autoPlay: baseOption.autoPlay,
      autoPlayInterval: baseOption.autoPlayInterval,
      autoPlayAnimationDuration: baseOption.autoPlayAnimationDuration,
      autoPlayCurve: baseOption.autoPlayCurve,
      onPageChanged: baseOption.onPageChanged,
      onScrolled: baseOption.onScrolled,
      scrollPhysics: baseOption.scrollPhysics,
      pageSnapping: baseOption.pageSnapping,
      scrollDirection: baseOption.scrollDirection,
      pauseAutoPlayOnTouch: baseOption.pauseAutoPlayOnTouch,
      pauseAutoPlayOnManualNavigate: baseOption.pauseAutoPlayOnManualNavigate,
      pauseAutoPlayInFiniteScroll: baseOption.pauseAutoPlayInFiniteScroll,
      pageViewKey: baseOption.pageViewKey,
      disableCenter: baseOption.disableCenter,
    );
  }

  static Widget limitHeightWidget({
    required BuildContext context,
    required List<String?> imageUrls,
    double maxHeight = _kMaxHeight,
    double maxViewport = _kMaxViewport,
    double aspectRatio = _kAspectRatio,
    CarouselOptions? baseOption,
  }) {
    final items = imageUrls
        .whereType<String>()
        .map((e) => CachedImage(
              imageUrl: e,
              cachedOption: CachedImageOption(
                imageBuilder: (context, image) =>
                    FittedBox(child: Image(image: image)),
                errorWidget: (context, url, error) => const SizedBox(),
              ),
              placeholder: (_, __) => const SizedBox(),
            ))
        .toList();
    if (items.isEmpty) return const SizedBox();
    baseOption ??= CarouselOptions(
        autoPlay: items.length > 1,
        autoPlayInterval: const Duration(seconds: 6));
    return LayoutBuilder(builder: (context, constraints) {
      return CarouselSlider(
        items: items,
        options: limitHeightOption(
          width: constraints.maxWidth,
          maxHeight: maxHeight,
          maxViewport: maxViewport,
          aspectRatio: aspectRatio,
          baseOption: baseOption,
        ),
      );
    });
  }
}
