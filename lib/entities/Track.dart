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
        imageUrl: json['album']['images'].last['url'] as String,
        artists: artists);
  }
}
