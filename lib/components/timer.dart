import 'dart:math' as math;

import 'package:flutter/material.dart';

//void main() => runApp(MyApp());

class TimerController {
  Function start;
  Function restart;
  Function stop;
  Function resume;
}

class CountDownTimer extends StatefulWidget {
  Function(AnimationController) callback;
  final double width;
  final double height;
  final Color strokeColor;
  final Duration duration;
  //  final int secondsRemaining;
  final bool started;

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

  _CountDownTimerState();

  void initTimer() {
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    // controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
    controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          this.widget.callback(controller);
          break;
        case AnimationStatus.completed:
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.started) {
        controller.reset();
        controller.reverse(
            from: controller.value == 0.0 ? 1.0 : controller.value);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initTimer();
  }

  @override
  Widget build(BuildContext context) {
    //ThemeData themeData = Theme.of(context);
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
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
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);
  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), (size.width) / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false,
        paint..strokeWidth = 5);
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}