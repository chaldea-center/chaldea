import 'dart:convert';

import 'package:flutter/material.dart';

const String kAppName = 'Chaldea';
const String kPackageName = 'cc.narumi.chaldea';
const String kPackageNameFDroid = 'cc.narumi.chaldea.fdroid';
const String kUserDataFilename = 'userdata.json';
const String kGameDataFilename = 'dataset.json';
const String kSupportTeamEmailAddress = 'support@chaldea.center';
const String kAppStoreLink = 'itms-apps://itunes.apple.com/app/id1548713491';
const String kAppStoreHttpLink = 'https://itunes.apple.com/app/id1548713491';
const String kGooglePlayLink = 'https://play.google.com/store/apps/details?id=cc.narumi.chaldea';
const String kProjectHomepage = 'https://github.com/chaldea-center/chaldea';
const String kProjectDocRoot = 'https://docs.chaldea.center';
const String kStaticHostRoot = 'https://static.chaldea.center';

const String kLaplaceName = 'Laplace';

/// The global key passed to [MaterialApp], so you can access context anywhere
final kAppKey = GlobalKey<NavigatorState>();
const kDefaultDivider = Divider(height: 1, thickness: 0.5);
const kIndentDivider = Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16);
const kMonoFont = 'RobotoMono';
const kMonoStyle = TextStyle(fontFamily: kMonoFont);

const kStarChar = '☆';
const kStarChar2 = '★';
const kULLeading = ' ꔷ ';
const kLargePoint = '●';
// 0x01ffffff
final kOnePixel = base64.decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAA1JREFUGFdj+P//PyMACP0C//k2WXcAAAAASUVORK5CYII=');

final kDWCharRegExp = RegExp(r'[\ue000-\ue00a]');
final kDWCharReplace = {
  "\ue000": "{jin}",
  "\ue001": "鯖",
  "\ue002": "辿",
  "\ue00b": "槌",
  for (int c = 0xe003; c <= 0xe00a; c++) String.fromCharCode(c): '\u2593', // "▓"
};
String kReplaceDWChars(String s) {
  return s.replaceAllMapped(kDWCharRegExp, (match) => kDWCharReplace[match.group(0)] ?? match.group(0)!);
}

// 2027-01-15
const int kNeverClosedTimestamp = 1800000000;
// 2025-07-01, 1751299200
const int kNeverClosedTimestampCN = 1751299000;
const int kSecsPerDay = 24 * 3600;
