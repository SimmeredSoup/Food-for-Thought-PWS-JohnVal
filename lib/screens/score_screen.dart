import 'package:flutter/material.dart';
import 'package:flutter_food_for_thought/utilities/constants.dart';
import 'package:flutter_food_for_thought/utilities/user_scores.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScoreScreen extends StatelessWidget {
  final List<Score> scores;
  final String title;

  ScoreScreen({this.scores, this.title});

  //a table row to be used as header
  //
  //called when:
  //the table is made (page is opened)
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

//a single text cell of a table
//
//called when:
//a new Row is created by createRow
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
  
  //creates rows with the score and ranking
  //
  //called when:
  //a table is created (page is loaded)
  TableRow createRow(Score score, int ranking) {
    //return a row with the next ranking and userscore.
    //as the scores are sorted from highest score to lowest,
    //this will display a correct ranking.
    return TableRow(children: [
      createTextCell(ranking.toString()),
      createTextCell(score.userScore.toString())
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        //test if there are any scores
        child: scores.length == 0
        //if there are not:
            ? Stack(
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

                  //if there are scores to be displayed:
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
                      //create a table which holds the header, ranking and scores
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        textBaseline: TextBaseline.alphabetic,
                        children: [header()] +
                            scores
                                .asMap()
                                .map((index, score) => MapEntry(
                                    //create a row with the score from the scores database
                                    //as index starts with 0 and ranking should start with 1,
                                    //the index should be increased by 1
                                    index, createRow(score, index + 1)))
                                .values
                                //does not need to be dynamic, so it is not growable
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
