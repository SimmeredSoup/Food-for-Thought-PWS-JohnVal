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

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //A test function, does nothing
  //
  //called when:
  //secret menu button is pressed
  void transformScores() {
  }
  //Another test function
  //
  //called when:
  // secret menu button is pressed
  void symbowlScores() {}

  //the secret menu
  //
  //called when:
  //the invisible button is pressed
  //(bottom left corner)
  Alert selectAlert() {
    return Alert(
        style: kGameOverAlertStyle,
        context: context,
        title: "Choose game",
        buttons: [
          DialogButton(
            width: 62,
            onPressed: () {
              transformScores();
              Navigator.pop(context);
            },
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
            color: kDialogButtonColor,
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    //height of screen for reference
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(8.0, 56.0, 8.0, 4.0),
              child: Text(
                'Food for Thought',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 38.0,
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
              //the sashimi image
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
                    //the start button, pressing it will start the game
                    child: ActionButton(
                      buttonTitle: 'Start',
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreenTransform(),
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
                          //this is an invisible button, used to test the implementation
                          //of a second game
                          //for now it just opens a useless menu/alert
                          icon: Icon(
                            Icons.queue_music,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 28.0,
                            semanticLabel: 'Test',
                          ),
                          onPressed: () {
                            selectAlert().show();
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        height: 56,
                        width: 100,
                        //button to go to the score screen via loading screen
                        child: IconButton(
                          icon: Icon(
                            MdiIcons.podium,
                            color: Colors.white,
                            size: 28.0,
                            semanticLabel: 'Ranking',
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
