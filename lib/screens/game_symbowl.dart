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
// import 'package:flutter_food_for_thought/utilities/user_scores.dart';

class GameScreenSymbolHunt extends StatefulWidget {
  // GameScreenTransform({@required this.hangmanObject});

  //final HangmanWords hangmanObject;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreenSymbolHunt> {
  DB _database;
  int lives = 4; 
  // CountDownTimer timer;
  int maxScore = 800;
  int durationSeconds = 75;
  // int scoreCount = 0;
  int oldScoreCount = 0;
  int newScoreCount = 0;
  int ogNumber;
  int ogMultiplier;
  int ogAdder;
  int ogAnswer = 0;
  int answer = 0;
  int ogDifficulty = 0;
  bool isNeg;
  //int transformScore = 0;
  Random rnd = new Random();
  int min = 5;
  int max = 30;
  Stopwatch roundwatch = Stopwatch();
  bool paused = false;
  DateTime start;
  TimerEventBloc _timerEventBloc =
      TimerEventBloc(TimerState(active: true, restart: false));

  void ogNewGame() {
    setState(() {
      _timerEventBloc.updateState(TimerState(active: true, restart: true));
      lives = 4;
      // scoreCount = 0;
      newScoreCount = 0;
      oldScoreCount = 0;
      ogDifficulty = 0;
      initNumber();
    });
  }

  Widget createButton(number) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5, vertical: 6.0),
      child: Center(
        child: WordButton(
          buttonTitle: number.toString(),
          onPress: () => numberPress(number),
        ),
      ),
    );
  }

  void returnHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      ModalRoute.withName('homePage'),
    );
  }

  void initNumber() {
    answer = 0;

    min = 3;
    max = 6 + (ogDifficulty.toDouble() * 1.6).toInt();
    ogNumber = min + rnd.nextInt(max - min);

    min = 2;
    max = 5 + (ogDifficulty.toDouble() * 0.6).toInt();
    ogMultiplier = min + rnd.nextInt(max - min);

    min = 1 + ogDifficulty * 2;
    max = 10 + (ogDifficulty.toDouble() * 2.4).toInt();
    ogAdder = min + rnd.nextInt(max - min);
    isNeg = rnd.nextBool();
    (isNeg) ? ogAdder *= -1 : ogAdder = ogAdder;
    print("negative : $isNeg, so Adder = $ogAdder");

    if (ogAdder.abs() >= ogNumber * ogMultiplier) {
      ogAdder = ogAdder.abs();
      print("og adder = $ogAdder");
    }

    ogAnswer = ogNumber * ogMultiplier + ogAdder;
    ogDifficulty++;
    print("$ogNumber x $ogMultiplier + $ogAdder = $ogAnswer, $ogDifficulty");
    print("resuming timer...");
    _timerEventBloc.updateState(TimerState(active: true, restart: false));
    roundwatch.reset();
    roundwatch.start();
  }

  //not yet used
  Icon centerIcon(iconchoose, colorchoose) {
    return Icon(
      iconchoose,
      color: colorchoose,
    );
  }

  //todo document method
  void numberPress(int number) {
    setState(() {
      //new number to be added to the answer. by multiplying by 10 the number gains an 0 which is than replaced by the number inserted (e.g.  12 -> 9 is entered -> 12*10+9= 129)
      answer *= 10;
      answer += number;
    });
  }

  //todo documentation
  void backspace() {
    setState(() {
      //backspace is called, so last number should be removed.
      //Done by dividing by 10 and then moving the the closest integer lower than the double (e.g. 129 -> 129/10 = 12.9 -> 12)
      answer = (answer / 10).floor();
    });
  }

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
            });
          },
          width: 127,
          color: kDialogButtonColor,
          height: 52,
        ),
      ],
    );
  }

  Alert finishAlert(controller) {
    Score score = Score(
        scoreDate: DateTime.now(),
        userScore: newScoreCount,
        userName: "henk",
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
//                  width: 90,
            color: kDialogButtonColor,
//                  height: 50,
          ),
          DialogButton(
            width: 62,
            onPressed: () {
              ogNewGame();

              // if (controller != null) {
              //   controller.reset();
              //   controller.reverse(
              //       from: controller.value == 0.0 ? 1.0 : controller.value);
              // }
              Navigator.pop(context);
            },
            child: Icon(MdiIcons.refresh, size: 30.0),
//                  width: 90,
            color: kDialogButtonColor,
//                  height: 20,
          ),
        ]);
  }

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
//                  width: 90,
            color: kDialogButtonColor,
//                  height: 20,
          ),
        ]);
  }

  void submit() {
    if (answer != 0) {
      _timerEventBloc.updateState(TimerState(active: false, restart: false));
      roundwatch.stop();
      if (answer == ogAnswer) {
        var duration = roundwatch.elapsed;
        var scoreRound = maxScore *
            (((durationSeconds * 1000) - (duration.abs().inMilliseconds * 7)) /
                (durationSeconds * 1000));
        (scoreRound < 200) ? scoreRound = 200 : print(scoreRound.ceil());
        setState(() {
          newScoreCount += scoreRound.ceil();
          //newScore = scoreCount;
          initNumber();
        });
      } else {
        lives -= 1;
        if (lives > 0) {
          setState(() {
            failAlert().show();
          });
        } else {
          setState(() {
            finishAlert(null).show();
          });
        }
      }
    }
  }

  void pause() {
    setState(() {
      paused = true;
    });
    _timerEventBloc.updateState(TimerState(active: false, restart: false));
    roundwatch.stop();
    pauseAlert(null).show();
  }

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

  @override
  void initState() {
    super.initState();

    DB.loadDatabase().then((db) => _database = db);
    initNumber();
  }

  CountDownTimer createTimer() {
    return CountDownTimer(
        height: 20,
        width: 20,
        started: true,
        duration: Duration(seconds: durationSeconds),
        callback: (controller) {
          finishAlert(controller).show();
        },
        strokeColor: Colors.red[200]);
  }

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
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: Text(
                                "Press the matching icon",
                                // ogNumber.toString() + "x" + ogMultiplier.toString() +   + ogAdder.abs().toString(),
                                style: kWordTextStyle,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 30),
                            width: 221,
                            height: 91,
                            //color: Color(0xFFFA8072),
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
                Expanded(
                  flex: 7,
                  //padding: EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 10.0),
                  //direction: Axis.vertical,
                  child: Table(
                    defaultVerticalAlignment:
                        TableCellVerticalAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    //columnWidths: {2: FlexColumnWidth(10)},
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
                        TableCell(
                          child: createButton(3),
                        ),
                        TableCell(
                          child: createButton(3),
                        ),
                      ]),
                      TableRow(children: [
                        TableCell(
                          child: createButton(3),
                        ),
                        TableCell(
                          child: createButton(4),
                        ),
                        TableCell(
                          child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.5, vertical: 6.0),
                          child: Center(
                            child: Text(
                              "hello aaaaaaaaaaaaaa",
                              style: kWordTextStyle
                            // style: Style(),
                            ),
                          ),
                        ),
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
                          child: createButton(3),
                        ),
                        TableCell(
                          child: createButton(8),
                        ),
                        TableCell(
                          child: createButton(9),
                        ),
                        TableCell(
                          child: createButton(3),
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
                          child: createButton(3),
                        ),
                        TableCell(
                          child: createButton(3),
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
