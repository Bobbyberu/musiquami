import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinksService {
  static Future<String> createDynamicLink(String parameter) async {
    String uriPrefix = "https://musiquami.page.link";

    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: uriPrefix,
        link: Uri.parse('https://example.com/$parameter'),
        androidParameters: AndroidParameters(
            packageName: 'com.bobbybel.musiquami', minimumVersion: 125),
        iosParameters: IosParameters(
          bundleId: 'com.bobbybel.musiquami',
          minimumVersion: '1.1.0',
          appStoreId: '123456789',
        ),
        googleAnalyticsParameters: GoogleAnalyticsParameters(
          campaign: 'example-promo',
          medium: 'social',
          source: 'orkut',
        ),
        itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
          providerToken: '123456',
          campaignToken: 'example-promo',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Allez viens !',
          description:
              'Rejoins dès maintenant la salle $parameter sur l\'appli Musiquami',
        ));

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl.toString();
  }

  static void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDynamicLink(data);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      print('link received!!');
      _handleDynamicLink(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  static _handleDynamicLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    print('got to app through link!');

    if (deepLink == null) {
      return;
    }
    if (deepLink.pathSegments.contains('refer')) {
      var title = deepLink.queryParameters['code'];
      if (title != null) {
        print("refercode=$title");
      }
    }
  }
}
