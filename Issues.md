# Issues
## TODO
- move Servant.unavailable to dataset.json
- where to delete FilePickerCross cached files?

## [Windows] package_info only support android/ios
Catcher plugin will invoke platform info and raise MissingPluginException at startup.

## [Windows] exe version 
won't be same as version in pubspec.yaml,
edit `VERSION_AS_NUMBER` and `VERSION_AS_STRING` in `windows/runner/Runner.rc`
it seems these 2 vars are not defined when building

## windows listen keyboard like Tab to move next

## flutter_qjs
1. fail to run ios
Xcode's output:
↳
    ld: framework not found ffiquickjs
    clang: error: linker command failed with exit code 1 (use -v to see invocation)
    note: Using new build system
    note: Building targets in parallel
    note: Planning build
    note: Constructing build description

2. windows build release/profile error
quickjs.c: 41791-41792
    JS_CFUNC_SPECIAL_DEF("floor", 1, f_f, floor ),
    JS_CFUNC_SPECIAL_DEF("ceil", 1, f_f, ceil ),
error C2099: initializer is not a constant

replace floor/ceil to floorl/ceill, see [github issue](https://github.com/codeplea/tinyexpr/issues/34)
(flutter clean will delete quickjs.c, so you may need to modify it after next pub get)

after replace, raise warning rather error, so compile passed.
path_to\chaldea\windows\flutter\ephemeral\.plugin_symlinks\flutter_qjs\cxx\quickjs\quickjs.c(41791,1): warning C4028: 形参 1 与声明不同
 [path_to\chaldea\build\windows\plugins\flutter_qjs\quickjs.vcxproj]
path_to\chaldea\windows\flutter\ephemeral\.plugin_symlinks\flutter_qjs\cxx\quickjs\quickjs.c(41792,1): warning C4028: 形参 1 与声明不同
 [path_to\chaldea\build\windows\plugins\flutter_qjs\quickjs.vcxproj]
