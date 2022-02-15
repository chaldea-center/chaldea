class WikiTool {
  static String mcDomain = 'https://fgo.wiki';
  static String fandomDomain = 'https://fategrandorder.fandom.com';

  static String mcFullLink(String title) {
    return Uri.parse('$mcDomain/w/$title').toString();
  }

  static String fandomFullLink(String title) {
    return Uri.parse('$fandomDomain/wiki/$title').toString();
  }
}
