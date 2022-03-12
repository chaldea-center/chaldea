import 'package:flutter/material.dart';

const String kAppName = 'Chaldea';
const String kPackageName = 'cc.narumi.chaldea';
const String kUserDataFilename = 'userdata.json';
const String kGameDataFilename = 'dataset.json';
const String kSupportTeamEmailAddress = 'chaldea@narumi.cc';
const String kDatasetAssetKey = 'res/data/dataset.zip';
const String kDatasetServerPath = '/chaldea/dataset.zip';
// String get kServerRoot => 'http://localhost:8083';
const String kServerRoot = 'http://api.chaldea.center';
const String kAppStoreLink = 'itms-apps://itunes.apple.com/app/id1548713491';
const String kAppStoreHttpLink = 'https://itunes.apple.com/app/id1548713491';
const String kGooglePlayLink =
    'https://play.google.com/store/apps/details?id=cc.narumi.chaldea';
const String kProjectHomepage = 'https://github.com/chaldea-center/chaldea';
const String kProjectDocRoot = 'https://docs.chaldea.center';
const String kStaticHostRoot = 'https://static.chaldea.center';
const String kDatasetHomepage =
    'https://github.com/chaldea-center/chaldea-dataset';

/// The global key passed to [MaterialApp], so you can access context anywhere
final kAppKey = GlobalKey<NavigatorState>();
const kDefaultDivider = Divider(height: 1, thickness: 0.5);
const kIndentDivider =
    Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16);
const kMonoFont = 'RobotoMono';
const kMonoStyle = TextStyle(fontFamily: kMonoFont);
