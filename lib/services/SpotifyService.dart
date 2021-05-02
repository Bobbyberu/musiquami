import 'package:dio/dio.dart';
import 'package:musiquamiapp/services/SecretService.dart';

import 'FirebaseService.dart';

class SpotifyService {
  String accessToken;
  String refreshToken;
  DateTime expiration;
  String roomCode;

  static final String _clientId = "d65a81d68a8344f78c0efdd4ce283cf6";

  SpotifyService(String accessToken, String refreshToken, int expiration,
      String roomCode) {
    this.accessToken = accessToken;
    this.expiration = DateTime.fromMillisecondsSinceEpoch(expiration);
    this.refreshToken = refreshToken;
    this.roomCode = roomCode;
  }

  bool isTokenExpired() {
    return expiration.isBefore(DateTime.now());
  }

  static Future<SpotifyService> getCredentialsFromCode(String code) async {
    var secrets = await SecretService.getApiKeys();

    final requestBody = {
      'client_id': _clientId,
      'client_secret': secrets.clientSecret,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': 'http://192.168.0.29:3000/'
    };
    final url = 'https://accounts.spotify.com/api/token';

    final response = await Dio().post(url,
        data: requestBody,
        options: Options(contentType: Headers.formUrlEncodedContentType));

    final roomData = await FirebaseService.createRoom(response.data);
    final credentials = roomData['credentials'];

    return SpotifyService(
        credentials['accessToken'],
        credentials['refreshToken'],
        credentials['expiration'],
        roomData['roomCode']);
  }

  Map<String, String> _buildAuthorizationHeader() {
    return {'Authorization': 'Bearer $accessToken'};
  }

  String _buildUrl(String endpoint, Map<String, dynamic> params) {
    return Uri.https('api.spotify.com', '/v1/$endpoint', params).toString();
  }

  Future<Response> _requestApi(String url, String method) async {
    if (expiration.isBefore(DateTime.now())) {
      await refreshCredentials();
    }
    return await Dio().request(url,
        options: Options(headers: _buildAuthorizationHeader(), method: method));
  }

  Future<Response> search(String query) async {
    final params = {'q': query, 'type': 'track', 'limit': '20'};
    return await _requestApi(_buildUrl('search', params), 'get');
  }

  Future<Response> queue(String trackUri) async {
    final params = {'uri': trackUri};
    return await _requestApi(_buildUrl('me/player/queue', params), 'post');
  }

  static String getAuthorizeUrl() {
    final params = {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': 'http://192.168.0.29:3000/',
      'scope': 'user-modify-playback-state',
      'show_dialog': 'true'
    };
    return Uri.https('accounts.spotify.com', '/authorize', params).toString();
  }

  Future<void> refreshCredentials() async {
    var secrets = await SecretService.getApiKeys();
    final requestBody = {
      'client_id': _clientId,
      'client_secret': secrets.clientSecret,
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken
    };

    final response = await Dio().post('https://accounts.spotify.com/api/token',
        data: requestBody,
        // application/x-www-form-urlencoded header
        options: Options(contentType: Headers.formUrlEncodedContentType));

    accessToken = response.data['access_token'];
    expiration = DateTime.now().add(Duration(hours: 1));
    FirebaseService.saveCredentials(this, roomCode);
  }

  // TODO pas static : faire avec token en tant qu'attribut lorsque service instancié
  static Future<String> getUserId(String accessToken) async {
    final response = await Dio().get('https://api.spotify.com/v1/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}));

    return response.data['id'];
  }

  // update service credentials if it has been changed in db
  void updateCredentials(Map<dynamic, dynamic> credentials) {
    accessToken = credentials['accessToken'];
    expiration = DateTime.fromMillisecondsSinceEpoch(credentials['expiration']);
  }
}
