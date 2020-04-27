import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hangman/bloc/bloc_provider.dart';
import 'package:flutter_hangman/bloc/timer_events.dart';
import 'package:flutter_hangman/components/timer.dart';
import 'package:flutter_hangman/screens/home_screen.dart';
import 'package:flutter_hangman/components/word_button.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter_hangman/utilities/hangman_words.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:math';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_hangman/utilities/score_db.dart' as score_database;
// import 'package:flutter_hangman/utilities/user_scores.dart';

class GameScreenTransform extends StatefulWidget {
  GameScreenTransform({@required this.hangmanObject});

  final HangmanWords hangmanObject;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreenTransform> {
  final database = score_database.openDB();
  int lives = 5;
  // CountDownTimer timer;
  int maxScore = 1200;
  int durationSeconds = 20;
  int scoreCount = 0;
  int ogNumber;
  int ogMultiplier;
  int ogAdder;
  int ogAnswer = 12318;
  int answer = 0;
  int transformScore = 0;
  Random rnd;
  int min = 5;
  int max = 30;
  DateTime start;
  TimerEventBloc _timerEventBloc =
      TimerEventBloc(TimerState(active: true, restart: false));

  void ogNewGame() {
    setState(() {
      _timerEventBloc.updateState(TimerState(active: true, restart: true));
      lives = 3;
      scoreCount = 0;
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

    rnd = new Random();
    min = 5;
    max = 30;
    ogNumber = min + rnd.nextInt(max - min);

    rnd = new Random();
    min = 2;
    max = 10;
    ogMultiplier = min + rnd.nextInt(max - min);

    rnd = new Random();
    min = -50;
    max = 50;
    ogAdder = min + rnd.nextInt(max - min);

    ogAnswer = ogNumber * ogMultiplier + ogAdder;

    print("$ogNumber x $ogMultiplier + $ogAdder = $ogAnswer ");
    print("resuming timer...");
    _timerEventBloc.updateState(TimerState(active: true, restart: false));
    start = DateTime.now();
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

  Alert successAlert() {
    var duration = DateTime.now().difference(start);
    var scoreRound = maxScore *
        ((durationSeconds - duration.abs().inSeconds) / durationSeconds);
    return Alert(
      context: context,
      style: kSuccessAlertStyle,
      type: AlertType.success,
      title: "You did it",
      desc: "You guessed it right! + $scoreRound points",
      buttons: [
        DialogButton(
          radius: BorderRadius.circular(10),
          child: Icon(
            MdiIcons.arrowRightThick,
            size: 30.0,
          ),
          onPressed: () {
            setState(() {
              scoreCount += scoreRound.ceil();
              Navigator.pop(context);
              initNumber();
            });
          },
          width: 127,
          color: kDialogButtonColor,
          height: 52,
        )
      ],
    );
  }

  Alert failAlert() {
    return Alert(
      context: context,
      style: kFailedAlertStyle,
      type: AlertType.error,
      title: ogNumber.toString(),
//            desc: "You Lost!",
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
    return Alert(
        style: kGameOverAlertStyle,
        context: context,
        title: "Finished!",
        desc: "Your score is $scoreCount",
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

  void submit() {
    _timerEventBloc.updateState(TimerState(active: false, restart: false));
    if (answer == ogAnswer) {
      setState(() {
        successAlert().show();
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

  @override
  void initState() {
    super.initState();
    initNumber();
  }

  CountDownTimer createTimer() {
    return CountDownTimer(
        height: 35,
        width: 35,
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
                                          icon: Icon(MdiIcons.heart),
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
                                                lives.toString() == "1"
                                                    ? "I"
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
                                child: Text(
                                  scoreCount == 1 ? "I" : '$scoreCount',
                                  style: kWordCounterTextStyle,
                                ),
                              ),
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
                            alignment: Alignment.bottomCenter,
                            child: FittedBox(
                              child: Text(
                                "$ogNumber x $ogMultiplier ${((ogAdder >= 0) ? "+" : "-")} ${ogAdder.abs()}",
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
                                answer.toString(),
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
