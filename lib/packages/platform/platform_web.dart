import 'platform_type.dart';

PlatformType get currentPlatform => PlatformType.web;

String get currentOperatingSystem => 'web';

String get currentOperatingSystemVersion => '';

String get currentResolvedExecutable => throw UnimplementedError('Not for web');
