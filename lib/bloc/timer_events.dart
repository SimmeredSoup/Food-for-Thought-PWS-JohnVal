import 'dart:async';

import 'bloc.dart';

int last = 0;

class TimerState {
  bool active;
  bool restart;
  int cur;
  TimerState({this.active, this.restart}) : this.cur = last++;

  @override
  String toString() {
    return "TimerState($active, $restart) ($cur)";
  }
}

class TimerEventBloc implements Bloc {
  TimerState _state;
  TimerState get currentState => _state;

  TimerEventBloc(this._state) {
    _stateController.sink.add(this._state);
  }

  final _stateController = StreamController<TimerState>();

  Stream<TimerState> get stateStream => _stateController.stream;

  void updateState(TimerState newState) {
    print("updating stream with $newState");
    _stateController.add(newState);
  }

  @override
  void dispose() {
    _stateController.close();
  }
}
