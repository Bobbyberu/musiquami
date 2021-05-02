import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:musiquamiapp/entities/Track.dart';
import 'package:musiquamiapp/services/FirebaseService.dart';
import 'package:musiquamiapp/services/SpotifyService.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:musiquamiapp/widgets/room/ConfirmationDialog.dart';

class Room extends StatefulWidget {
  final String code;

  const Room({Key key, @required this.code}) : super(key: key);

  @override
  _RoomState createState() => _RoomState(code);
}

class _RoomState extends State<Room> {
  final String code;
  SpotifyService spotify;
  List<Track> tracks = [];
  bool showTracks = false;
  var _searchController = TextEditingController();
  static StreamSubscription<Event> credentialsChangedListener;

  final error401 =
      "Il y a eu problème avec la connexion à Spotify. Essaye de recharger la salle";
  final error404Queue =
      "Aucun appareil du propriétaire de la salle ne joue de musique. " +
          "Démarre un son sur un appareil connecté au compte du propriétaire et réessaye!";

  _RoomState(this.code);

  @override
  void initState() {
    super.initState();
    initRoom();
    initCredentialsChangedListener();
  }

  void initRoom() async {
    // get info from room
    // init spotify api
    await FirebaseService.getInfoFromRoomCode(code).then((snapshot) async {
      Map<dynamic, dynamic> credentials = snapshot.value['credentials'];
      setState(() {
        spotify = SpotifyService(credentials['accessToken'],
            credentials['refreshToken'], credentials['expiration'], code);
      });
      if (spotify.isTokenExpired()) {
        print('on va rafraichir');
        await spotify.refreshCredentials();
      }
    });
  }

  void initCredentialsChangedListener() {
    credentialsChangedListener =
        FirebaseService.getCredentialsChangedListener(code, (event) {
      debugPrint('nouvel évènement sur la room $code');
      setState(() {
        spotify.updateCredentials(event.snapshot.value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Wrap(
        children: <Widget>[
          TextField(
            onChanged: (value) async => await _getTracks(value),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            controller: _searchController,
          ),
          if (tracks.length != 0 && showTracks)
            SizedBox(
              height: 200,
              child: _buildTrackListView(),
            ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    // avoid duplicating listener at page creation
    credentialsChangedListener?.cancel();
    super.dispose();
  }

  void _showConfirmationDialog(Track track) {
    var dialog = ConfirmationDialog(track, () {
      // ignore: return_of_invalid_type_from_catch_error
      spotify
          .queue(track.uri)
          .then((value) => _displayErrorSnackbar(
              'Le titre a été ajouté à la file d\'attente!', false))
          .catchError((error) {
        // room owner has no music playing on any of his spotify devices
        if (error.response.statusCode == 404 &&
            error.response.data['error']['reason'] == 'NO_ACTIVE_DEVICE') {
          _displayErrorSnackbar(error404Queue, true);
        } else {
          _displayErrorSnackbar('Erreur', true);
        }
      });
      setState(() {
        tracks.clear();
        showTracks = false;
      });
      _searchController.clear();
      Navigator.of(context).pop();
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Widget _buildTrackListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, i) => _buildTrackRow(i),
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemCount: tracks.length,
      // hide keyboard on scroll
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    );
  }

  Widget _buildTrackRow(int i) {
    final track = tracks[i];

    return GestureDetector(
      key: Key(track.uri),
      child: Text('${track.artists} - ${track.name}'),
      onTap: () {
        FocusScope.of(context).unfocus();
        _showConfirmationDialog(track);
      },
    );
  }

  void _displayErrorSnackbar(String message, bool isError) {
    Flushbar(
        message: message,
        duration: Duration(seconds: 7),
        flushbarPosition: FlushbarPosition.TOP,
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: Icon(
          isError ? Icons.error : Icons.check_circle,
          size: 28.0,
          color: Colors.white,
        ),
        backgroundGradient: LinearGradient(colors: [
          CustomColors.sakuraDark,
          CustomColors.sakuraLight,
          CustomColors.sakuraLighter
        ]),
        leftBarIndicatorColor: Colors.white,
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.decelerate)
      ..show(context);
  }

  Future<void> _getTracks(query) async {
    // prevent multiple http calls
    EasyDebounce.debounce('search-tracks-debounce', Duration(milliseconds: 200),
        () async {
      if (query != '') {
        // avoid getting last query result displaying after
        // empty string no result if text field emptied
        setState(() {
          showTracks = true;
        });
        await spotify.search(query).then((response) async {
          List<Track> tracksFromJson = [];

          await response.data['tracks']['items']
              .forEach((track) => tracksFromJson.add(Track.fromJson(track)));

          setState(() {
            tracks = tracksFromJson;
          });
        }).catchError((error) {
          if (error.response != null && error.response.statusCode == 401) {
            _displayErrorSnackbar(error401, true);
          } else {
            _displayErrorSnackbar('Erreur', true);
          }
        });
      } else {
        setState(() {
          tracks.clear();
          showTracks = false;
        });
      }
    });
  }
}
