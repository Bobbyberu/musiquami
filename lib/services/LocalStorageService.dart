import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<bool> iSpotifyRoomOwned(String roomCode) async {
    final storage = await SharedPreferences.getInstance();
    return storage.getString('spotifyRoomOwned') == roomCode;
  }

  static void saveSpotifyRoomOwned(String roomCode) async {
    final storage = await SharedPreferences.getInstance();
    storage.setString('spotifyRoomOwned', roomCode);
  }
}
