import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_food_for_thought/components/action_button.dart';
import 'package:flutter_food_for_thought/utilities/constants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'game_transform.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  //final HangmanWords hangmanWords = HangmanWords();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void transformScores() {
    SystemSound.play(SystemSoundType.click);
  }
  void symbowlScores() {}

  Alert selectAlert() {
    return Alert(
        style: kGameOverAlertStyle,
        context: context,
        title: "Choose game",
       // desc: "Take a break",
        buttons: [
          DialogButton(
            width: 62,
            onPressed: () { transformScores();
            Navigator.pop(context); },
            child: Icon(
              MdiIcons.formatListNumbered,
              size: 30.0,
            ),
            color: kDialogButtonColor,
          ),
          DialogButton(
            width: 62,
            onPressed: () {
              symbowlScores();
              Navigator.pop(context);
            },
            child: Icon(MdiIcons.bowlMix, size: 30.0),
//                  width: 90,
            color: kDialogButtonColor,
//                  height: 20,
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    //widget.hangmanWords.readWords();
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 8.0),
              child: Text(
                'Brain Food',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 58.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3.0),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.012,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset(
                'images/sashimi.png',
                height: height * 0.5,
              ),
            ),
          ),
          SizedBox(
            height: height * 0.049,
          ),
          Center(
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
//                    width: 155,
                    height: 64,
                    child: ActionButton(
                      buttonTitle: 'Start',
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreenTransform(
                              //hangmanObject: widget.hangmanWords,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 18.0,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                                         width: 100,
                        height: 56,
                         alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.queue_music,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 28.0,
                            semanticLabel: 'Hi there',
                          ),
                          onPressed: () {
                            selectAlert().show();
                          },
                        ),
                      ), Container(
//                    width: 155,
                        alignment: Alignment.centerRight,
                        height: 56,
                        width: 100,
                        
                        child: IconButton(
                          icon: Icon(
                            MdiIcons.podium,
                            color: Colors.white,
                            size: 28.0,
                            semanticLabel: 'Hi there',
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadingScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
//  Container(
// //                    width: 155,
//                     height: 64,
//                   //  alignment: Alignment.centerRight,
//                     child: IconButton(
//                       icon: MdiIcons.podium,
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LoadingScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//             ),
