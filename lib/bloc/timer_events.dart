import 'dart:async';
import 'bloc.dart';

int last = 0;

class TimerState {
  //create all the states, so that it can be e.g paused, resumed and reset
  //cur is used to see how many times the TimerState is changed
  bool active;
  bool restart;
  int cur;
  TimerState({this.active, this.restart}) : this.cur = last++;

  @override
  String toString() {
    return "TimerState($active, $restart) ($cur)";
  }
}
//put the state of timer inside the Bloc:
//this Timerstate will be reachable
//by different classes
//now used only by game_transform
class TimerEventBloc implements Bloc {
  TimerState _state;
  TimerState get currentState => _state;

  TimerEventBloc(this._state) {
    _stateController.sink.add(this._state);
  }

  final _stateController = StreamController<TimerState>();

  Stream<TimerState> get stateStream => _stateController.stream;
//a newState is called to change the active and restart state
  void updateState(TimerState newState) {
    print("updating stream with $newState");
    _stateController.add(newState);
  }

  @override
  void dispose() {
    _stateController.close();
  }
}
