import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:musiquamiapp/entities/Track.dart';
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

  SpotifyService.fromMap(Map<dynamic, dynamic> tokens) {
    this.accessToken = tokens['accessToken'];
    this.refreshToken = tokens['refreshToken'];
    this.expiration = DateTime.fromMillisecondsSinceEpoch(tokens['expiration']);
    this.roomCode = tokens['roomCode'];
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

    final credentials = await FirebaseService.createRoom(response.data);
    if (credentials != null) {
      return SpotifyService.fromMap(credentials['tokens']);
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
      'scope':
          'user-modify-playback-state user-read-private user-read-currently-playing user-read-recently-played',
      'show_dialog': 'true'
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

  Future<Response> getRecentlyPlayedTracks(int after) async {
    final params = {'after': after.toString(), 'limit': '30'};
    return await _requestApi(
        _buildUrl('me/player/recently-played', params), 'get');
  }

  Future<Response> getCurrentlyPlayingTrack() async {
    final params = {'market': 'from_token'};
    return await _requestApi(
        _buildUrl('me/player/currently-playing', params), 'get');
  }

  Future<List> updateQueue([Track track]) async {
    final queueInfo = await FirebaseService.getQueueInfo(roomCode)
        .then((snapshot) => snapshot.value);
    // get id of track currenty playing
    final uriTrackCurrentlyPlaying = await getCurrentlyPlayingTrack()
        .then((response) => response.data['item']['uri']);

    Queue tracksQueue;
    // track playing not in queue -> queue is up to date
    // or has been completely consumed
    if (queueInfo != null && queueInfo['tracks'] != null) {
      // get previously played track since last database's queue update
      final recentlyLength =
          await getRecentlyPlayedTracks(queueInfo['lastUpdate'])
              .then((response) => response.data['items'].length);
      tracksQueue = Queue.from(queueInfo['tracks']);
      if (tracksQueue.firstWhere(
              (element) => element['uri'] == uriTrackCurrentlyPlaying,
              orElse: () => null) !=
          null) {
        // removing all tracks that has been played in database's queue
        for (var i = 1;
            _shoudlContinueRemovingFromQueue(
                i, recentlyLength, uriTrackCurrentlyPlaying, tracksQueue);
            i++) {
          tracksQueue.removeFirst();
        }

        // removing song currently playing from queue
        if (tracksQueue.first['uri'] == uriTrackCurrentlyPlaying) {
          tracksQueue.removeFirst();
        }
      } else if (recentlyLength > 0) {
        // queue has been completely consumed
        tracksQueue = Queue();
      }
    } else {
      tracksQueue = Queue();
    }

    if (track != null) {
      tracksQueue.add(track.toMap());
    }

    await FirebaseService.saveNewQueue(
        roomCode, tracksQueue, DateTime.now().millisecondsSinceEpoch);

    // returning List<Track> instead of List<Map>
    return tracksQueue.map((e) => Track.fromSnapshot(e)).toList();
  }

  bool _shoudlContinueRemovingFromQueue(
      int i, int recentlyLength, String uriTrackCurrentlyPlaying, Queue queue) {
    /// Return true if all tracks from queue until the one currently playing have been removed
    /// i: the index of loop
    /// recentlyLength: the length of recently played tracks
    /// uriTrackCurrentlyPlaying
    /// queue: the tracks queue currently stored in database
    return i < recentlyLength || queue.first['uri'] != uriTrackCurrentlyPlaying;
  }
}
