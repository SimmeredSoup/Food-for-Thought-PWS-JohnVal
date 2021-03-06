import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_food_for_thought/bloc/bloc_provider.dart';
import 'package:flutter_food_for_thought/bloc/timer_events.dart';

class CountDownTimer extends StatefulWidget {
  final Function(AnimationController) callback;
  final double width;
  final double height;
  final Color strokeColor;
  final Duration duration;
  final bool started;
//make the following variables dynamic, so that
//games can differ in timer
  CountDownTimer(
      {this.callback,
      this.width,
      this.height,
      this.strokeColor,
      this.started,
      this.duration = const Duration(seconds: 60)});

  final _CountDownTimerState _state = _CountDownTimerState();

  @override
  _CountDownTimerState createState() => _state;
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  AnimationController controller;
  bool isRestarting = false;

  _CountDownTimerState();

  void initTimer() {
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    controller.addStatusListener((status) {
      switch (status) {
        //because the animation runs in reverse, the animation
        //is dismissed when it is completed
        // - when it reaches 0
        case AnimationStatus.dismissed:
          if (!this.isRestarting) {
            this.widget.callback(controller);
          }

          break;
        case AnimationStatus.completed:
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose(); // super dispose NA controller dispose!
  }

  @override
  void initState() {
    super.initState();
    initTimer();
  }

  void updateController(TimerState newState) {
    print("$newState testing");
    if (newState.restart) {
      print("restarting...");
      this.isRestarting = true;
      controller.reset();
      controller.reverse(from: 1.0);
      this.isRestarting = false;
      print("restarted...");
    } else if (newState.active) {
      if (!controller.isAnimating) {
        controller.reverse(
            from: controller.value == 0.0 ? 1.0 : controller.value);
      }
    } else {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TimerState>(
      //should start as active, and as it is already 'fresh',
      //a restart is unneeded
        initialData: TimerState(active: true, restart: false),
        stream: BlocProvider.of<TimerEventBloc>(context).stateStream,
        builder: (context, snapshot) {
          TimerState newState = snapshot.data;
          updateController(newState);
          return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                //the actual timer:
                return Container(
                  height: widget.height,
                  width: widget.width,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                              painter: CustomTimerPainter(
                            animation: controller,
                            backgroundColor: widget.strokeColor,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          )),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}

class CustomTimerPainter extends CustomPainter {
  //the animation of the timer:
  CustomTimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);
  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  //this makes the animation appear on screen
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    //create a circle in the middle
    canvas.drawCircle(size.center(Offset.zero), (size.width) / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false,
        paint..strokeWidth = 5);
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    //it should repaint the circle if the value still changes 
    //and the (background)color is also changed
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
