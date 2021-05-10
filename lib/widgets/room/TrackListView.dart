import 'package:flutter/material.dart';
import 'package:musiquamiapp/entities/Track.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:skeleton_text/skeleton_text.dart';

import 'TrackRow.dart';

class TrackListView extends StatelessWidget {
  final Future tracks;
  final Function showConfirmationDialog;

  TrackListView(this.tracks, this.showConfirmationDialog);

  @override
  Widget build(BuildContext context) {
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
                TrackRow(snapshot.data[i] as Track, () {
              FocusScope.of(context).unfocus();
              //_showConfirmationDialog(snapshot.data[i]);
              showConfirmationDialog(snapshot.data[i]);
            }),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: snapshot.data.length,
            // hide keyboard on scroll
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          );
        });
  }
}
