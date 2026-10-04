#!/bin/sh
rm ./build/web/main.dart.*.js || echo "main.dart.js not found"
dart ./scripts/gen_git_info.dart && \
dart ./scripts/patch_before_build.dart web && \
flutter build web --source-maps && \
dart ./scripts/patch_web_build.dart
