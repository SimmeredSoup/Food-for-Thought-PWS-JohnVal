import 'package:flutter/material.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter_hangman/utilities/user_scores.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScoreScreen extends StatelessWidget {
  final List<Score> scores;
  final String title;

  ScoreScreen({this.scores, this.title});

  TableRow header() {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Center(
            child: Text(
              "Rank",
              style: kHighScoreTableHeaders,
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 15.0),
        //   child: Center(
        //     child: Text(
        //       "Date",
        //       style: kHighScoreTableHeaders,
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Center(
            child: Text(
              "Score",
              style: kHighScoreTableHeaders,
            ),
          ),
        ),
      ],
    );
  }

  TableCell createTextCell(String text) {
    return TableCell(
        child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              text,
              style: kHighScoreTableRowsStyle,
              textAlign: TextAlign.center,
            )));
  }

  TableRow createRow(Score score, int ranking) {
    return TableRow(children: [
      createTextCell(ranking.toString()),
      createTextCell(score.userScore.toString())
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: scores.length == 0
            ? Stack(
//                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Text(
                      "No Scores Yet!",
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 15.0),
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      tooltip: 'Home',
                      iconSize: 35,
                      icon: Icon(MdiIcons.home),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 15.0),
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Home',
                          iconSize: 35,
                          icon: Icon(MdiIcons.home),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 15.0),
                          child: Text(
                            'High Scores',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 45.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                      child: Text(
                    title,
                    style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.w300,)
                  )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        textBaseline: TextBaseline.alphabetic,
                        children: [header()] +
                            scores
                                .asMap()
                                .map((index, score) => MapEntry(
                                    index, createRow(score, index + 1)))
                                .values
                                .toList(growable: false),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
