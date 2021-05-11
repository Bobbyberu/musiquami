import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Track {
  String uri;
  String name;
  String imageUrl;
  String artists;

  Track({this.uri, this.name, this.imageUrl, this.artists});

  factory Track.fromJson(Map<String, dynamic> json) {
    List<String> artistsName = [];
    json['artists'].forEach((artist) => artistsName.add(artist['name']));
    String artists = artistsName.join(", ");

    return Track(
        uri: json['uri'] as String,
        name: json['name'] as String,
        // take album image with second best resolution
        imageUrl: json['album']['images'][1]['url'] as String,
        artists: artists);
  }

  factory Track.fromSnapshot(Map<dynamic, dynamic> snapshot) {
    return Track(
        uri: snapshot['uri'],
        name: snapshot['name'],
        // take album image with second best resolution
        imageUrl: snapshot['imageUrl'],
        artists: snapshot['artists']);
  }

  Map<String, dynamic> toMap() {
    return {'uri': uri, 'name': name, 'imageUrl': imageUrl, 'artists': artists};
  }
}
