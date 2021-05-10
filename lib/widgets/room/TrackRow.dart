import 'package:flutter/material.dart';
import 'package:musiquamiapp/entities/Track.dart';

class TrackRow extends StatelessWidget {
  final Track track;
  final Function onTapEvent;

  TrackRow(this.track, this.onTapEvent);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // make all gesture detector tappable, not just text and image
      behavior: HitTestBehavior.translucent,
      key: Key(track.uri),
      child: Container(
        child: Row(
          children: [
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
      onTap: onTapEvent,
    );
  }
}
