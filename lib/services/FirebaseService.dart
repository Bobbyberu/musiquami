import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:musiquamiapp/services/SpotifyService.dart';

// TODO gérer code dupliqués
class FirebaseService {
  /// create or update room using spotify user credentials
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

      // if user has room non expired get code
      // else generate new code
      final roomCode = _shouldGenerateRoomCode(room)
          ? _generateRoomCode()
          : room.entries.first.key;

      await FirebaseDatabase.instance
          .reference()
          .child('room/$roomCode')
          .set(roomData);

      roomData['roomCode'] = roomCode;
      return roomData;
    }
  }

  static Future<DataSnapshot> getInfoFromRoomCode(String code) async {
    /// get all info from room with given code
    return FirebaseDatabase.instance.reference().child('room/$code').once();
  }

  static Future<Map> isRoomAndNotExpired(String code) async {
    /// return Map with 2 bool
    /// exists: true if room exists
    /// isExpired : true if room expiration is before now
    return FirebaseDatabase.instance
        .reference()
        .child('room/$code')
        .once()
        .then((snapshot) {
      if (snapshot.value == null) {
        return {'exists': false, 'isExpired': false};
      } else {
        return {
          'exists': true,
          'isExpired': DateTime.fromMillisecondsSinceEpoch(
                  snapshot.value['roomExpiration'])
              .isBefore(DateTime.now())
        };
      }
    });
  }

  static Future<DataSnapshot> getRoomFromUser(String user) async {
    /// get first room with given user as owner
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
    /// get Firebase listener for given room
    /// code: the code for the room
    /// callback: the function to call a new event occur on this room

    // avoid duplicating listener at room start
    return FirebaseDatabase.instance
        .reference()
        .child('room/$code')
        .onChildChanged
        .listen(callback);
  }

  static void saveCredentials(SpotifyService spotify, String roomCode) async {
    /// save new credentials for given room in database
    final updates = {
      '/accessToken': spotify.accessToken,
      '/expiration': spotify.expiration.millisecondsSinceEpoch
    };
    await FirebaseDatabase.instance
        .reference()
        .child('room/$roomCode/credentials')
        .update(updates);
  }

  static void deleteRoom(String code) async {
    /// delete room with given code
    await FirebaseDatabase.instance.reference().child('room/$code').set(null);
  }

  static bool _shouldGenerateRoomCode(dynamic room) {
    if (room == null) {
      return true;
    } else {
      deleteRoom(room.entries.first.key);
      return DateTime.fromMillisecondsSinceEpoch(
              room.entries.first.value['roomExpiration'])
          .isBefore(DateTime.now());
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

  static String _generateRoomCode() {
    const _chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        4, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}
