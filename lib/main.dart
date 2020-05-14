import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_food_for_thought/screens/home_screen.dart';
import 'package:flutter_food_for_thought/utilities/constants.dart';
import 'package:flutter_food_for_thought/screens/score_screen.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: kTooltipColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        accentColor: Color(0xFFFA8072),
        scaffoldBackgroundColor: Color(0xFF353643),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'PatrickHand'),
      ),
      //startup page should be the home page
      initialRoute: 'homePage',
      home: HomeScreen(),
      routes: {
        // /homepage seems the only one to actually work,
        // doesnt seem necessary to remove others though
        'homePage': (context) => HomeScreen(),
        '/homePage': (context) => HomeScreen(),
        'scorePage': (context) => ScoreScreen(),
      },
    );
  }
}
