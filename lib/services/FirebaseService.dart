import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:musiquamiapp/services/SpotifyService.dart';

// TODO gérer code de salle dupliqués
class FirebaseService {
  static Future<Map> createRoom(Map<dynamic, dynamic> credentials) async {
    /// create or update room using spotify user credentials
    final userInfo =
        await SpotifyService.getUserInfo(credentials['access_token']);

    // allowing room creation only for spotify user premium
    if (userInfo['product'] != 'premium') {
      return null;
    } else {
      final room = await getRoomFromUser(userInfo['id'])
          .then((snapshot) => snapshot.value)
          .catchError((err) => print('error: $err'));
      var roomCredentials = _buildRoomCredentials(credentials, userInfo['id']);

      // if user has room non expired get code
      // else generate new code
      final roomCode = _shouldGenerateRoomCode(room)
          ? await _generateRoomCode()
          : room.entries.first.key;

      await FirebaseDatabase.instance
          .reference()
          .child('room/$roomCode/credentials')
          .set(roomCredentials);

      roomCredentials['tokens']['roomCode'] = roomCode;
      return roomCredentials;
    }
  }

  static Future<DataSnapshot> getInfoFromRoomCode(String code) async {
    /// get all info from room with given code
    return FirebaseDatabase.instance.reference().child('room/$code').once();
  }

  static Future<DataSnapshot> getRoom(String code) async {
    return FirebaseDatabase.instance
        .reference()
        .child('room/$code/credentials')
        .once();
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
                  snapshot.value['credentials']['roomExpiration'])
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
        .orderByChild('credentials/owner')
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
    } else if (DateTime.fromMillisecondsSinceEpoch(
            room.entries.first.value['credentials']['roomExpiration'])
        .isBefore(DateTime.now())) {
      deleteRoom(room.entries.first.key);
      return true;
    } else {
      return false;
    }
  }

  static Map<String, dynamic> _buildRoomCredentials(
      Map<String, dynamic> credentials, String userId) {
    return {
      'owner': userId,
      // room is supposed to expire after 5 hours
      'roomExpiration':
          DateTime.now().add(Duration(hours: 5)).millisecondsSinceEpoch,
      'tokens': {
        'accessToken': credentials['access_token'],
        'refreshToken': credentials['refresh_token'],
        'expiration':
            DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch
      }
    };
  }

  static Future<String> _generateRoomCode() async {
    /// Generate valid code for future room
    const _chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    Random _rnd = Random();

    // avoid duplicate room code
    bool roomCodeValid = false;
    String code;
    while (!roomCodeValid) {
      code = String.fromCharCodes(Iterable.generate(
          4, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
      roomCodeValid = await _roomCodeIsValid(code);
    }

    return code;
  }

  static Future<bool> _roomCodeIsValid(String code) async {
    /// return true if no room with given code has been found in db
    return await FirebaseDatabase.instance
        .reference()
        .child('room/$code')
        .once()
        .then((snapshot) => snapshot.value == null);
  }

  static Future<DataSnapshot> getQueueInfo(String code) async {
    return await FirebaseDatabase.instance
        .reference()
        .child('room/$code/queue')
        .once();
  }

  static Future<void> saveNewQueue(
      String code, Queue newQueue, int creationDate) async {
    await FirebaseDatabase.instance
        .reference()
        .child('room/$code/queue')
        .set({'lastUpdate': creationDate, 'tracks': newQueue.toList()});
  }
}
