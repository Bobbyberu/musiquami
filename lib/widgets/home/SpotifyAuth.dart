import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musiquamiapp/services/SpotifyService.dart';
import 'package:musiquamiapp/widgets/home/CannotCreateRoom.dart';
import 'package:musiquamiapp/widgets/roomsas/RoomSas.dart';
import 'package:page_transition/page_transition.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotifyAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
        userAgent: "random",
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: SpotifyService.getAuthorizeUrl(),
        navigationDelegate: (navReq) async {
          // hide keyboard on new web page
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          if (navReq.url.startsWith('http://url/')) {
            final SpotifyService credentials =
                await SpotifyService.getCredentialsFromCode(
                    Uri.dataFromString(navReq.url).queryParameters['code']);
            if (credentials != null) {
              Navigator.push(
                  context,
                  PageTransition(
                      child: RoomSas(credentials.roomCode),
                      type: PageTransitionType.rightToLeft));
            } else {
              Navigator.push(
                  context,
                  PageTransition(
                      child: CannotCreateRoom(),
                      type: PageTransitionType.rightToLeft));
            }
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
        onWebViewCreated: (controller) {
          //controller.clearCache();
          //CookieManager().clearCookies();
        });
  }
}
