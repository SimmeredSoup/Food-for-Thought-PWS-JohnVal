import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_food_for_thought/bloc/bloc_provider.dart';
import 'package:flutter_food_for_thought/bloc/timer_events.dart';
import 'package:flutter_food_for_thought/components/timer.dart';
import 'package:flutter_food_for_thought/screens/home_screen.dart';
import 'package:flutter_food_for_thought/components/word_button.dart';
import 'package:flutter_food_for_thought/utilities/constants.dart';
import 'package:flutter_food_for_thought/utilities/user_scores.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:math';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_food_for_thought/utilities/score_db.dart';

class GameScreenTransform extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreenTransform> {
  //create the needed variables
  //general variables:
  DB _database;
  int lives = 4;
  int maxScore = 1200;
  int durationSeconds = 75;
  int oldScoreCount = 0;
  int newScoreCount = 0;
  Stopwatch roundwatch = Stopwatch();
  bool paused = false;
  DateTime start;
  TimerEventBloc _timerEventBloc =
      TimerEventBloc(TimerState(active: true, restart: false));

  //variables needed for initNumber()
  Random rnd = new Random();
  int min;
  int max;

  int ogNumber;
  int ogMultiplier;
  int ogAdder;
  bool isNeg;
  int ogAnswer = 0;
  int ogDifficulty = 0;

  int answer = 0;

  @override
  void initState() {
    super.initState();
    //load the database, and then make _database the input
    DB.loadDatabase().then((db) => _database = db);
    //start a new game
    ogNewGame();
  }

  //function to restart the game
  //
  //called when:
  //-the restart button in the finish alert is pressed
  void ogNewGame() {
    setState(() {
      //restart and activate timer, reset dynamic scores to 0,
      // and create a new calculation with initNumber()
      lives = 4;
      newScoreCount = 0;
      oldScoreCount = 0;
      ogDifficulty = 0;
      initNumber();
    });
    // roundwatch.reset();
    // roundwatch.start();
  }

  //function to create a new question:
  //called when:
  //
  //-the page is first loaded
  //-a new game starts
  //-a correct or wrong answer is submitted
  void initNumber() {
    //answer back to 0
    answer = 0;
    //ogDiffuculty makes the game harder after every question generated
    //by increasing the range of the numbers
    //in different magnitudes.

    //the first (most left) number
    min = 2;
    max = 6 + (ogDifficulty.toDouble() * 1.4).toInt();
    ogNumber = min + rnd.nextInt(max - min);

    //the middle number, which acts as the multiplier
    min = 2;
    max = 5 + (ogDifficulty.toDouble() * 0.6).toInt();
    ogMultiplier = min + rnd.nextInt(max - min);

    //the last number, which is the 'adder'.
    min = 1 + ogDifficulty * 2;
    max = 5 + (ogDifficulty.toDouble() * 2.4).toInt();
    ogAdder = min + rnd.nextInt(max - min);
    //a 50%(?) chance for the adder to be a substracter instead
    isNeg = rnd.nextBool();
    (isNeg) ? ogAdder *= -1 : ogAdder = ogAdder;

    //checks if the adder is larger or equal
    //to the multiplication of the first 2 numbers
    //to prevent the answer from being less than or
    //equal to 0
    if (ogAdder.abs() >= ogNumber * ogMultiplier) {
      ogAdder = ogAdder.abs();
    }

    ogAnswer = ogNumber * ogMultiplier + ogAdder;
    //make the game more difficult next question
    ogDifficulty++;

    //some feedback prints
    print(
        "$ogNumber x $ogMultiplier + $ogAdder = $ogAnswer, round $ogDifficulty");
    // print("resuming timer...");

    //resume the game timer, and start a new timer for the question
    //(the round timer)
    //removed as it updated timer too quick in succession of a restart state update
    // _timerEventBloc.updateState(TimerState(active: true, restart: false));
    roundwatch.reset();
    roundwatch.start();
  }

  //function to go to the home screen:
  //
  //called when:
  //-a home button is pressed (pause and finish Alert)
  void returnHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      ModalRoute.withName('homePage'),
    );
  }

  //function to insert a number into the answer correctly:
  //
  //called when:
  //-a number button is pressed
  void numberPress(int number) {
    setState(() {
      //new number to be added to the answer.
      //by multiplying by 10 the number gains an 0 which is than
      //replaced by the number inserted
      //(e.g.  12 -> 9 is entered -> 12*10+9= 129)
      answer *= 10;
      answer += number;
    });
  }

  //function to remove the last number from the answer
  //
  //called when:
  //-the backspace button is pressed
  void backspace() {
    setState(() {
      //backspace is called, so last number should be removed.
      //Done by dividing by 10 and then jumping to the closest
      //integer lower than the double
      //(e.g. 129 -> 129/10 = 12.9 -> 12)
      answer = (answer / 10).floor();
    });
  }

  //function to submit the answer
  //
  //called when:
  //-the sumbit button is pressed
  void submit() {
    //test if answer is actually set (ogAnswer will never
    //be equal to or less than 0, so answer won't be 0 ever)
    if (answer != 0) {
      //stop the game and round timer
      // print("pausing timer for submit");
      // _timerEventBloc.updateState(TimerState(active: false, restart: false));
      //roundwatch.stop();
      //check if they submitted the correct answer
      if (answer == ogAnswer) {
        //calculate the amount of points they earned this round
        var duration = roundwatch.elapsed;
        //the faster the answer is given, the more points the round should give
        //and higher rounds should give more time/points
        var scoreRound = maxScore *
            (((durationSeconds * 1000) - (duration.abs().inMilliseconds * 5) + (ogDifficulty*300)) /
                (durationSeconds * 1000));
        //make sure that a 200 points is the least they get from a correct answer
        (scoreRound < 200) ? scoreRound = 200 : print(scoreRound.ceil());
        //update the new score so that the score animation can play
        setState(() {
          newScoreCount += scoreRound.ceil();

          initNumber();
          // _timerEventBloc.updateState(TimerState(active: true, restart: false));
        });
      } else {
        // stop the timer
        _timerEventBloc.updateState(TimerState(active: false, restart: false));
        roundwatch.stop();
        //when an incorrect answer is given, remove a heart
        lives -= 1;
        //check if the still have remaining lives
        if (lives > 0) {
          //display a fail message with correct answer
          setState(() {
            failAlert().show();
          });
        } else {
          //game ends because they have no more lives left
          finishAlert(null).show();
        }
      }
    }
  }

  //functgion to pause the game
  //
  //called when:
  //the pause buttons is pressed
  void pause() {
    //make the question dissappear so they can abuse pause less
    setState(() {
      paused = true;
    });
    //pause the round and game timer
    _timerEventBloc.updateState(TimerState(active: false, restart: false));
    roundwatch.stop();
    //show the pause alert
    pauseAlert(null).show();
  }

  //widget to animate the score to its new value
  Widget scoreWidget() {
    // int oldScore;
    // int newScore;
    if (oldScoreCount >= newScoreCount) {
      return Text(
        '$oldScoreCount',
        style: kWordCounterTextStyle,
      );
    } else {
      return TweenAnimationBuilder(
          duration: Duration(seconds: 2),
          tween: Tween<double>(
              begin: oldScoreCount.toDouble(), end: newScoreCount.toDouble()),
          curve: Curves.linearToEaseOut,
          onEnd: () {
            setState(() {
              oldScoreCount = newScoreCount;
            });
          },
          builder: (_, double scoreT, __) {
            return Text(scoreT.toInt().toString(),
                style: kWordCounterTextStyle);
          });
    }
  }

  //widget to create the basic numberpad buttons 0-9
  Widget createButton(number) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5, vertical: 6.0),
      child: Center(
        child: WordButton(
          //display the button number on the button
          buttonTitle: number.toString(),
          //when pressed, call the numberpress function
          onPress: () => numberPress(number),
        ),
      ),
    );
  }

  CountDownTimer timer = null;
  //settings for the countdown timer
  CountDownTimer createTimer() {
    // print("(re)creating timer...");
    if (timer == null) {
      timer = CountDownTimer(
          height: 20,
          width: 20,
          started: true,
          duration: Duration(seconds: durationSeconds),
          callback: (controller) {
            finishAlert(controller).show();
          },
          strokeColor: Colors.red[200]);
    }
    return timer;
  }

  //alert when sumbitting a wrong answer
  Alert failAlert() {
    return Alert(
      context: context,
      style: kFailedAlertStyle,
      type: AlertType.error,
      title:
          "$ogNumber x $ogMultiplier ${((ogAdder >= 0) ? "+" : "-")} ${ogAdder.abs()} = $ogAnswer",
      desc: "Your answer: $answer",
      buttons: [
        DialogButton(
          radius: BorderRadius.circular(10),
          child: Icon(
            MdiIcons.arrowRightThick,
            size: 30.0,
          ),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
              initNumber();
              print("Updating state to resume from fail");
              _timerEventBloc
                  .updateState(TimerState(active: true, restart: false));
            });
          },
          width: 127,
          color: kDialogButtonColor,
          height: 52,
        ),
      ],
    );
  }

  //alert when game is finished
  Alert finishAlert(controller) {
    Score score = Score(
        scoreDate: DateTime.now(), //not used, still stored
        userScore: newScoreCount,
        userName: "player", // not yet used nor changeable
        gameid: "transform");
    if (_database != null && newScoreCount != 0) {
      _database.addScore(score);
      print("added score...");
    } else {
      print(
          "score was zero/database could not be loaded, so session is not saved");
    }

    return Alert(
        style: kGameOverAlertStyle,
        context: context,
        title: "Finished!",
        desc: "Your score is $newScoreCount",
        buttons: [
          DialogButton(
            width: 62,
            onPressed: () => returnHomePage(),
            child: Icon(
              MdiIcons.home,
              size: 30.0,
            ),
            color: kDialogButtonColor,
          ),
          DialogButton(
            width: 62,
            onPressed: () {
              ogNewGame();
              _timerEventBloc
                  .updateState(TimerState(active: true, restart: true));
              Navigator.of(context).pop();
            },
            child: Icon(MdiIcons.refresh, size: 30.0),
//                  width: 90,
            color: kDialogButtonColor,
//                  height: 20,
          ),
        ]);
  }

  //alert when game is paused
  Alert pauseAlert(controller) {
    return Alert(
        style: kGameOverAlertStyle,
        context: context,
        title: "Game paused",
        desc: "Take a break",
        buttons: [
          DialogButton(
            width: 62,
            onPressed: () => returnHomePage(),
            child: Icon(
              MdiIcons.home,
              size: 30.0,
            ),
            color: kDialogButtonColor,
          ),
          DialogButton(
            width: 62,
            onPressed: () {
              setState(() {
                paused = false;
              });
              _timerEventBloc
                  .updateState(TimerState(active: true, restart: false));
              roundwatch.start();
              Navigator.pop(context);
            },
            child: Icon(MdiIcons.play, size: 30.0),
            color: kDialogButtonColor,
          ),
        ]);
  }

  //the screen builder
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimerEventBloc>(
      bloc: _timerEventBloc,
      child: WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 45.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: IconButton(
                                  tooltip: 'Pause',
                                  iconSize: 39,
                                  icon: Icon(MdiIcons.pause),
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onPressed: () => pause(),
                                ),
                              ),
                              Row(
                                //the top row containing the pause button, lives, score and timer
                                children: <Widget>[
                                  Stack(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(top: 0.5),
                                        child: IconButton(
                                          tooltip: 'Lives',
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          iconSize: 39,
                                          icon: lives.toString() == "0"
                                              ? Icon(MdiIcons.heartBroken)
                                              : Icon(MdiIcons.heart),
                                          onPressed: () {},
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.fromLTRB(
                                            8.7, 7.9, 0, 0.8),
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          height: 38,
                                          width: 38,
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                lives.toString() == "0"
                                                    ? " "
                                                    : lives.toString(),
                                                style: TextStyle(
                                                  color: Color(0xFF2C1E68),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'PatrickHand',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                  width: 180,
                                  height: 40,
                                  alignment: Alignment.centerRight,
                                  child: scoreWidget()),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 7.9, 8.7, 0.8),
                                  child: createTimer())
                            ],
                          ),
                        ),
                        Expanded(
                          //contains the question
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: Text(
                                (paused)
                                    ? " "
                                    : " $ogNumber x $ogMultiplier ${((ogAdder >= 0) ? "+" : "-")} ${ogAdder.abs()} ",
                                style: kWordTextStyle,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Expanded(
                          //contains the input of the numberpad (answer)
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 30),
                            width: 221,
                            height: 91,
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                answer.toString() == "0"
                                    ? "_"
                                    : answer.toString(),
                                style: kWordTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Container(
                  padding: EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 10.0),
                  child: Table(
                    //the table creating the numberpad, backspace and sumbit buttons
                    defaultVerticalAlignment:
                        TableCellVerticalAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    //columnWidths: {1: FlexColumnWidth(10)},
                    children: [
                      TableRow(children: [
                        TableCell(
                          child: createButton(1),
                        ),
                        TableCell(
                          child: createButton(2),
                        ),
                        TableCell(
                          child: createButton(3),
                        ),
                      ]),
                      TableRow(children: [
                        TableCell(
                          child: createButton(4),
                        ),
                        TableCell(
                          child: createButton(5),
                        ),
                        TableCell(
                          child: createButton(6),
                        ),
                      ]),
                      TableRow(children: [
                        TableCell(
                          child: createButton(7),
                        ),
                        TableCell(
                          child: createButton(8),
                        ),
                        TableCell(
                          child: createButton(9),
                        ),
                      ]),
                      TableRow(children: [
                        TableCell(
                            child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.5, vertical: 6.0),
                          child: Center(
                            child: IconButton(
                              icon: Icon(MdiIcons.backspaceOutline),
                              onPressed: () => backspace(),
                              tooltip: "back",
                            ),
                          ),
                        )),
                        TableCell(
                          child: createButton(0),
                        ),
                        TableCell(
                            child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.5, vertical: 6.0),
                          child: Center(
                            child: IconButton(
                              icon: Icon(MdiIcons.check),
                              onPressed: () => submit(),
                              tooltip: 'submit',
                            ),
                          ),
                        )),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
