import 'package:flutter/material.dart';
import 'package:musiquamiapp/entities/Track.dart';

class TrackRow extends StatelessWidget {
  final Track track;

  TrackRow(this.track);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: [
      Image.network(
        track.imageUrl,
        height: 64,
      ),
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
                          .copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${track.artists}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ])))
    ]));
  }
}
