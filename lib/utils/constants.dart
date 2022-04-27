import 'dart:convert';

import 'package:flutter/material.dart';

const String kAppName = 'Chaldea';
const String kPackageName = 'cc.narumi.chaldea';
const String kUserDataFilename = 'userdata.json';
const String kGameDataFilename = 'dataset.json';
const String kSupportTeamEmailAddress = 'chaldea@narumi.cc';
const String kServerRoot = 'http://api.chaldea.center';
const String kServerRootCN = 'http://api-cn.chaldea.center';
const String kAppStoreLink = 'itms-apps://itunes.apple.com/app/id1548713491';
const String kAppStoreHttpLink = 'https://itunes.apple.com/app/id1548713491';
const String kGooglePlayLink =
    'https://play.google.com/store/apps/details?id=cc.narumi.chaldea';
const String kProjectHomepage = 'https://github.com/chaldea-center/chaldea';
const String kProjectDocRoot = 'https://docs.chaldea.center';
const String kStaticHostRoot = 'https://static.chaldea.center';

/// The global key passed to [MaterialApp], so you can access context anywhere
final kAppKey = GlobalKey<NavigatorState>();
const kDefaultDivider = Divider(height: 1, thickness: 0.5);
const kIndentDivider =
    Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16);
const kMonoFont = 'RobotoMono';
const kMonoStyle = TextStyle(fontFamily: kMonoFont);

const kStarChar = '☆';
// 0x01ffffff
final kOnePixel = base64.decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAA1JREFUGFdj+P//PyMACP0C//k2WXcAAAAASUVORK5CYII=');
