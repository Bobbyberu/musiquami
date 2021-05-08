import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:musiquamiapp/services/SpotifyService.dart';

// TODO réorganiser tout ça
// moins de méthodes statiques
// documenter les méthodes

class FirebaseService {
  static Future<Map> createRoom(Map<dynamic, dynamic> credentials) async {
    final userInfo =
        await SpotifyService.getUserInfo(credentials['access_token']);
    if (userInfo['product'] != 'premium') {
      return null;
    } else {
      final room = await getRoomFromUser(userInfo['id'])
          .then((snapshot) => snapshot.value)
          .catchError((err) => print('error: $err'));
      var roomData = _buildRoomData(credentials, userInfo['id']);
      // if user has already created room get code
      // else generate new code
      final roomCode =
          room != null ? room.entries.first.key : _generateRoomCode();
      await FirebaseDatabase.instance
          .reference()
          .child('room/$roomCode')
          .set(roomData);

      roomData['roomCode'] = roomCode;
      return roomData;
    }
  }

  static Map<String, dynamic> _buildRoomData(
      Map<String, dynamic> credentials, String userId) {
    return {
      'owner': userId,
      // room is supposed to expire after 5 hours
      'roomExpiration':
          DateTime.now().add(Duration(hours: 5)).millisecondsSinceEpoch,
      'credentials': {
        'accessToken': credentials['access_token'],
        'refreshToken': credentials['refresh_token'],
        'expiration':
            DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch
      }
    };
  }

  static Future<DataSnapshot> getInfoFromRoomCode(String code) async {
    return FirebaseDatabase.instance.reference().child('room/$code').once();
  }

// return True if room exists
// TODO renvoyer false si la salle est expirée
  static Future<bool> isRoom(String code) async {
    return FirebaseDatabase.instance
        .reference()
        .child('room/$code')
        .once()
        .then((snapshot) => snapshot.value != null);
  }

  static Future<DataSnapshot> getRoomFromUser(String user) async {
    return await FirebaseDatabase.instance
        .reference()
        .child('room')
        .orderByChild('owner')
        .equalTo(user)
        .limitToFirst(1)
        .once();
  }

  static StreamSubscription<Event> getCredentialsChangedListener(
      String code, Function(Event) callback) {
    // avoid duplicating listener at room start
    return FirebaseDatabase.instance
        .reference()
        .child('room/$code')
        .onChildChanged
        .listen(callback);
  }

  static void saveCredentials(SpotifyService spotify, String roomCode) async {
    final updates = {
      '/accessToken': spotify.accessToken,
      '/expiration': spotify.expiration.millisecondsSinceEpoch
    };
    await FirebaseDatabase.instance
        .reference()
        .child('room/$roomCode/credentials')
        .update(updates);
  }

  static String _generateRoomCode() {
    const _chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        4, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static void deleteRoom(String code) async {
    await FirebaseDatabase.instance.reference().child('room/$code').set(null);
  }
}
