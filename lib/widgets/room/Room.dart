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
import 'package:musiquamiapp/widgets/home/Home.dart';
import 'package:musiquamiapp/widgets/room/ConfirmationDialog.dart';
import 'package:skeleton_text/skeleton_text.dart';

class Room extends StatefulWidget {
  final String code;

  const Room({Key key, @required this.code}) : super(key: key);

  @override
  _RoomState createState() => _RoomState(code);
}

class _RoomState extends State<Room> {
  final String code;
  SpotifyService spotify;
  bool showTracks = false;
  bool isRoomOwned = false;
  String previousStringValue;
  var _searchController = TextEditingController();
  static StreamSubscription<Event> credentialsChangedListener;
  Future tracks;

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
    initCredentialsChangedListener();
    initRoomOwned();
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
    await FirebaseService.getInfoFromRoomCode(code).then((snapshot) async {
      Map<dynamic, dynamic> credentials = snapshot.value['credentials'];
      setState(() {
        spotify = SpotifyService(credentials['accessToken'],
            credentials['refreshToken'], credentials['expiration'], code);
      });
      if (spotify.isTokenExpired()) {
        await spotify.refreshCredentials();
      }
    });
  }

  void initCredentialsChangedListener() {
    credentialsChangedListener =
        FirebaseService.getCredentialsChangedListener(code, (event) {
      setState(() {
        spotify.updateCredentials(event.snapshot.value);
      });
    });
  }

  void initRoomOwned() async {
    bool result = await LocalStorageService.iSpotifyRoomOwned(code);
    setState(() {
      isRoomOwned = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context),
        child: LoaderOverlay(
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: SafeArea(
                  child: Stack(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (showTracks)
                        _buildTrackListView()
                      else
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 30, right: 30, bottom: 50),
                                  child: Wrap(children: [
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 40),
                                        child: Text('Bienvenue 👋',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1
                                                .copyWith(fontSize: 30))),
                                    Text(
                                        'Tu peux inviter d\'autres personnes en leur donnant ce code :',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            .copyWith(fontSize: 25))
                                  ])),
                              Text(code,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      .copyWith(fontSize: 45)),
                              if (isRoomOwned)
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 40, right: 40, top: 80),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          // delete room then back to homepage
                                          FirebaseService.deleteRoom(code);
                                          Navigator.of(context).push(
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      Home()));
                                        },
                                        child: Text('Supprimer cette salle',
                                            style: TextStyle(
                                                fontSize: 22,
                                                color:
                                                    CustomColors.sakuraCream)),
                                        style: Theme.of(context)
                                            .elevatedButtonTheme
                                            .style))
                            ]),
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
                            )),
                      ]),
                    ],
                  ),
                ))));
  }

  @override
  void dispose() {
    // avoid duplicating listener at page creation
    credentialsChangedListener?.cancel();
    super.dispose();
  }

  void _showConfirmationDialog(Track track) {
    var dialog = ConfirmationDialog(track, () {
      context.loaderOverlay.show();
      // ignore: return_of_invalid_type_from_catch_error
      spotify.queue(track.uri).then((value) {
        context.loaderOverlay.hide();
        _displaySnackbar('Le titre a été ajouté à la file d\'attente !', false,
            FlushbarPosition.BOTTOM);
      }).catchError((error) {
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
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Widget _buildTrackListView() {
    return FutureBuilder(
        future: tracks,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          } else if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
                padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
                itemCount: 10,
                itemBuilder: (context, index) => Container(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            SkeletonAnimation(
                                shimmerColor: CustomColors.sakuraLight,
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).disabledColor),
                                )),
                            Expanded(
                                child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: SkeletonAnimation(
                                                shimmerColor:
                                                    CustomColors.sakuraLight,
                                                child: Container(
                                                  height: 15,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.60,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: Theme.of(context)
                                                          .disabledColor),
                                                ))),
                                        SkeletonAnimation(
                                            shimmerColor:
                                                CustomColors.sakuraLight,
                                            child: Container(
                                              height: 15,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.50,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                            ))
                                      ],
                                    )))
                          ],
                        ),
                      ),
                    ));
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
            itemBuilder: (context, i) =>
                _buildTrackRow(snapshot.data[i] as Track),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: snapshot.data.length,
            // hide keyboard on scroll
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          );
        });
  }

  Widget _buildTrackRow(Track track) {
    return GestureDetector(
      // make all gesture detector tappable, not just text and image
      behavior: HitTestBehavior.translucent,
      key: Key(track.uri),
      child: Container(
        child: Row(
          children: [
            Image.network(track.imageUrl),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '${track.name}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${track.artists}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    )))
          ],
        ),
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
        _showConfirmationDialog(track);
      },
    );
  }

  void _displaySnackbar(String message, bool isError, flushbarPosition) {
    Flushbar(
        message: message,
        messageColor: CustomColors.sakuraCream,
        duration: Duration(seconds: 7),
        flushbarPosition: flushbarPosition,
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: Icon(
          isError ? Icons.error : Icons.check_circle,
          size: 28.0,
          color: CustomColors.sakuraLighter,
        ),
        backgroundColor: CustomColors.darkGrey,
        leftBarIndicatorColor: CustomColors.sakuraLighter,
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
