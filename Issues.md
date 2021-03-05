# Issues

## TODO
>**New features:**
 - add transition animation and swipe support

>**Bug fix:**
 - ImageWithText: image pos shift with alignment
 - portrait detail page -> landscape: master side is black(nothing), or always use transparent?

>**Enhance:**
 - move Servant.unavailable to dataset.json
 - remember tab no
 - add NEXT button in input list on iOS.
 - backup user data when app version updated, backup through file/folder picker
 - add hunting in plan page，
 - performance: item stat update
 - event detail: add switch (including ticket page?).
 - item detail->events tab: tap to event detail page
 - svt traits auto added? 
 - voice: mac and ios? not support wav file

## [Windows] package_info/device_info only support android/ios
Catcher plugin will invoke platform info and raise MissingPluginException at startup.

## [Windows] exe version 
won't be same as version in pubspec.yaml (not implemented officially)
edit `VERSION_AS_NUMBER` and `VERSION_AS_STRING` in `windows/runner/Runner.rc`
