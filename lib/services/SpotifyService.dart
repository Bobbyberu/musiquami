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

  static Future<SpotifyService> getCredentialsFromCode(String code) async {
    /// Allow to get tokens from Spotify using code returned during auth
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
    if (roomData != null) {
      final credentials = roomData['credentials'];

      return SpotifyService(
          credentials['accessToken'],
          credentials['refreshToken'],
          credentials['expiration'],
          roomData['roomCode']);
    } else {
      return null;
    }
  }

  Future<void> refreshCredentials() async {
    /// Refresh user's access token and expiration date
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

  void updateCredentials(Map<dynamic, dynamic> credentials) {
    /// Save new credentials in db
    accessToken = credentials['accessToken'];
    expiration = DateTime.fromMillisecondsSinceEpoch(credentials['expiration']);
  }

  static String getAuthorizeUrl() {
    /// Build and return url to get access to Spotify connection page
    final params = {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': 'http://192.168.0.29:3000/',
      'scope': 'user-modify-playback-state user-read-private'
    };
    return Uri.https('accounts.spotify.com', '/authorize', params).toString();
  }

  static Future<Map<String, String>> getUserInfo(String accessToken) async {
    /// Get user id and product value ('premium' or 'open')
    final response = await Dio().get('https://api.spotify.com/v1/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
    return {'id': response.data['id'], 'product': response.data['product']};
  }

  Future<Response> search(String query) async {
    /// Return list of Spotify track given a string search query
    final params = {'q': query, 'type': 'track', 'limit': '20'};
    return await _requestApi(_buildUrl('search', params), 'get');
  }

  Future<Response> queue(String trackUri) async {
    /// Put track with given uri in user's Spotify queue
    final params = {'uri': trackUri};
    return await _requestApi(_buildUrl('me/player/queue', params), 'post');
  }

  bool isTokenExpired() {
    /// return true is access token expiration date is before now
    return expiration.isBefore(DateTime.now());
  }

  Map<String, String> _buildAuthorizationHeader() {
    return {'Authorization': 'Bearer $accessToken'};
  }

  String _buildUrl(String endpoint, Map<String, dynamic> params) {
    return Uri.https('api.spotify.com', '/v1/$endpoint', params).toString();
  }

  Future<Response> _requestApi(String url, String method) async {
    /// perform http call with given url and method (get, post, etc)
    /// (etc is not an http method, it just means that there are more methods)
    if (expiration.isBefore(DateTime.now())) {
      await refreshCredentials();
    }
    return await Dio().request(url,
        options: Options(headers: _buildAuthorizationHeader(), method: method));
  }
}
