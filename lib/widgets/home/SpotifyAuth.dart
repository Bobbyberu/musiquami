import 'package:flutter/material.dart';
import 'package:musiquamiapp/services/SpotifyService.dart';
import 'package:musiquamiapp/widgets/roomsas/RoomSas.dart';
import 'package:page_transition/page_transition.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotifyAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: SpotifyService.getAuthorizeUrl(),
        navigationDelegate: (navReq) async {
          if (navReq.url.startsWith('http://192.168.0.29:3000/')) {
            final SpotifyService credentials =
                await SpotifyService.getCredentialsFromCode(
                    Uri.dataFromString(navReq.url).queryParameters['code']);
            Navigator.push(
                context,
                PageTransition(
                    child: RoomSas(credentials.roomCode),
                    type: PageTransitionType.rightToLeft));
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
        onWebViewCreated: (controller) {
          // TODO ajouter un bouton 'se souvenir de moi' qui conditionne les lignes du dessous
          //controller.clearCache();
          //CookieManager().clearCookies();
        });
  }
}
