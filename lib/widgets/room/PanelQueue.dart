import 'package:flutter/material.dart';
import 'package:musiquamiapp/entities/Track.dart';
import 'package:progress_indicator_button/progress_button.dart';

import 'TrackRow.dart';

class PanelQueue extends StatefulWidget {
  final List<Track> queue;
  final ScrollController sc;
  final Function refresh;

  const PanelQueue(
      {Key key,
      @required this.queue,
      @required this.sc,
      @required this.refresh})
      : super(key: key);

  @override
  _PanelQueueState createState() => _PanelQueueState();
}

class _PanelQueueState extends State<PanelQueue> {
  bool isLoading;

  @override
  Widget build(BuildContext context) {
    var queueLength = widget.queue != null ? widget.queue.length : 0;
    return queueLength > 0
        ? ListView.separated(
            controller: widget.sc,
            padding: EdgeInsets.only(left: 10, right: 10, top: 70, bottom: 10),
            itemBuilder: (context, i) {
              if (i == queueLength) {
                return Align(
                    child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ProgressButton(
                                onPressed: widget.refresh,
                                child: Text('Rafraichir',
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Theme.of(context).accentColor)),
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(40.0)))));
              }
              return TrackRow(widget.queue[i]);
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: queueLength + 1)
        : Center(
            child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Aucun morceau dans la file d\'attente !',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontSize: 20))),
              Text('Profites-en pour nous mettre un son 😁',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontSize: 20))
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ));
  }
}
