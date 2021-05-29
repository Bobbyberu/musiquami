import 'dart:async';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:musiquamiapp/entities/Track.dart';
import 'package:musiquamiapp/services/FirebaseService.dart';
import 'package:musiquamiapp/services/LocalStorageService.dart';
import 'package:musiquamiapp/services/SpotifyService.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:musiquamiapp/widgets/room/PanelHeader.dart';
import 'package:musiquamiapp/widgets/room/PanelQueue.dart';
import 'package:musiquamiapp/widgets/room/ConfirmationDialog.dart';
import 'package:musiquamiapp/widgets/room/RoomPresentation.dart';
import 'package:musiquamiapp/widgets/room/TrackListView.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Room extends StatefulWidget {
  final String code;

  const Room({Key key, @required this.code}) : super(key: key);

  @override
  _RoomState createState() => _RoomState(code);
}

class _RoomState extends State<Room> {
  final String code;
  DateTime expiration;
  SpotifyService spotify;
  bool showTracks = false;
  bool isRoomOwned = false;
  String previousStringValue;
  var _searchController = TextEditingController();
  bool isPanelDraggable = true;
  static StreamSubscription<Event> credentialsChangedListener;
  Future tracks;
  List<Track> tracksQueue;

  final error401 =
      "Il y a eu problème avec la connexion à Spotify. Essaye de recharger la salle";
  final error404Queue =
      "Aucun appareil du propriétaire de la salle ne joue de musique. " +
          "Démarre un son sur un appareil connecté au compte du propriétaire et réessaye !";

  _RoomState(this.code);

  @override
  void initState() {
    super.initState();
    initRoom();
    initDatabaseChildChangedListener();
    initRoomOwned();
    initQueue();
    _searchController.addListener(() {
      // do not call future builder refresh on keyboard dismiss/appear
      if (previousStringValue != _searchController.text) {
        setState(() {
          showTracks = _searchController.text != '';
          previousStringValue = _searchController.text;
          // update tracks in autocomplete only if text field value has changed
          // or query text is not null
          tracks = _searchController.text != '' ? _getTracks() : null;
        });
      }
    });
  }

  void initRoom() async {
    // get info from room
    // init spotify api
    Map<dynamic, dynamic> room =
        await FirebaseService.getRoom(code).then((snapshot) => snapshot.value);
    final tokens = room['tokens'];
    setState(() {
      expiration = DateTime.fromMillisecondsSinceEpoch(room['roomExpiration']);
      spotify = SpotifyService(tokens['accessToken'], tokens['refreshToken'],
          tokens['expiration'], code);
    });
    if (spotify.isTokenExpired()) {
      await spotify.refreshCredentials();
    }
  }

  void initDatabaseChildChangedListener() {
    credentialsChangedListener =
        FirebaseService.getCredentialsChangedListener(code, (event) {
      // update only if node updated is 'credentials' node
      if (event.snapshot.value.containsKey('owner')) {
        setState(() {
          expiration = DateTime.fromMillisecondsSinceEpoch(
              event.snapshot.value['roomExpiration']);
          spotify.updateCredentials(event.snapshot.value['tokens']);
        });
      } else if (event.snapshot.value.containsKey('tracks')) {
        _updateQueue(event.snapshot.value);
      }
    });
  }

  void initRoomOwned() async {
    bool result = await LocalStorageService.iSpotifyRoomOwned(code);
    setState(() {
      isRoomOwned = result;
    });
  }

  void initQueue() async {
    await FirebaseService.getQueueInfo(code).then((snapshot) {
      _updateQueue(snapshot.value);
    });
  }

  void _updateQueue(dynamic snapshotValue) {
    List<dynamic> queue =
        snapshotValue != null ? snapshotValue['tracks'] : List<Track>.empty();
    setState(() {
      tracksQueue = queue.isEmpty
          ? queue
          : queue.map((e) => Track.fromSnapshot(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context),
        child: LoaderOverlay(
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: SlidingUpPanel(
                    isDraggable: isPanelDraggable,
                    backdropEnabled: true,
                    backdropTapClosesPanel: false,
                    parallaxEnabled: true,
                    parallaxOffset: 0.15,
                    padding: EdgeInsets.only(top: 0, left: 10),
                    minHeight: 65,
                    // sliding up panel height is 90% of device screen
                    maxHeight: MediaQuery.of(context).size.height * 0.90,
                    color: Theme.of(context).bottomAppBarColor,
                    panelBuilder: (ScrollController sc) => PanelQueue(
                        queue: tracksQueue,
                        sc: sc,
                        refresh:
                            (AnimationController animationController) async {
                          animationController.forward();
                          final newTracksQueue = await spotify.updateQueue();
                          setState(() {
                            tracksQueue = newTracksQueue;
                          });
                          animationController.reset();
                        }),
                    header: PanelHeader(
                        tracksQueue != null ? tracksQueue.length : 0),
                    body: SafeArea(
                        child: Stack(children: [
                      if (showTracks)
                        TrackListView(tracks, _showConfirmationDialog)
                      else
                        GestureDetector(
                            child: RoomPresentation(code, isRoomOwned),
                            // make all gesture detector tappable, not just text and buttons
                            behavior: HitTestBehavior.translucent,
                            onTap: () => FocusScope.of(context).unfocus()),
                      Stack(children: [
                        // searchbar background is blurred
                        ClipRect(
                            child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                        color: CustomColors
                                            .sakuraDark.shade100)))),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              autocorrect: false,
                              enableSuggestions: false,
                              style: Theme.of(context).textTheme.headline2,
                              decoration: InputDecoration(
                                  hintText: "Mets-nous un truc sympa",
                                  hintStyle:
                                      TextStyle(fontStyle: FontStyle.italic),
                                  fillColor: CustomColors.sakuraLight.shade100,
                                  prefixIcon: Icon(Icons.search),
                                  suffixIcon: _searchController.text != ''
                                      ? IconButton(
                                          icon: Icon(Icons.close),
                                          color: Theme.of(context).accentColor,
                                          onPressed: () =>
                                              _searchController.clear(),
                                        )
                                      : null),
                              controller: _searchController,
                            ))
                      ])
                    ]))))));
  }

  @override
  void dispose() {
    // avoid duplicating listener at page creation
    credentialsChangedListener?.cancel();
    super.dispose();
  }

  void _showConfirmationDialog(Track track) {
    var dialog = ConfirmationDialog(track, () {
      if (DateTime.now().isBefore(expiration)) {
        context.loaderOverlay.show();
        // ignore: return_of_invalid_type_from_catch_error
        spotify.queue(track.uri).then((value) async {
          context.loaderOverlay.hide();
          // update tracks queue
          final newTracksQueue = await spotify.updateQueue(track);
          setState(() {
            tracksQueue = newTracksQueue;
          });

          _displaySnackbar('Le titre a été ajouté à la file d\'attente !',
              false, FlushbarPosition.BOTTOM);
        }).catchError((error) {
          print('error: $error');
          context.loaderOverlay.hide();
          // room owner has no music playing on any of his spotify devices
          if (error.response.statusCode == 404 &&
              error.response.data['error']['reason'] == 'NO_ACTIVE_DEVICE') {
            _displaySnackbar(error404Queue, true, FlushbarPosition.BOTTOM);
          } else {
            print(error.response.toString());
            _displaySnackbar('Erreur', true, FlushbarPosition.BOTTOM);
          }
        });
        _searchController.clear();
        Navigator.of(context).pop();
      } else {
        _searchController.clear();
        Navigator.of(context).pop();
        _displaySnackbar(
            'Mise en file d\'attente Impossible ! Cette salle a été supprimée ou a expiré.',
            true,
            FlushbarPosition.BOTTOM);
      }
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  void _displaySnackbar(String message, bool isError, flushbarPosition) {
    Flushbar(
        message: message,
        messageColor: CustomColors.sakuraCream,
        duration: Duration(seconds: isError ? 7 : 3),
        flushbarPosition: flushbarPosition,
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: Icon(
          isError ? Icons.error : Icons.check_circle,
          size: 28.0,
          color: CustomColors.sakuraLight2,
        ),
        backgroundColor: CustomColors.darkGrey,
        leftBarIndicatorColor: CustomColors.sakuraLight2,
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.decelerate)
      ..show(context);
  }

  Future<dynamic> _getTracks() async {
    return await spotify.search(_searchController.text).then((response) async {
      List<Track> tracksFromJson = [];

      await response.data['tracks']['items']
          .forEach((track) => tracksFromJson.add(Track.fromJson(track)));
      return tracksFromJson;
    }).catchError((error) {
      if (error.response != null && error.response.statusCode == 401) {
        _displaySnackbar(error401, true, FlushbarPosition.TOP);
      } else {
        _displaySnackbar('Erreur', true, FlushbarPosition.TOP);
      }
      print('error: $error');
      // ignore: return_of_invalid_type_from_catch_error
      return error;
    });
  }
}
