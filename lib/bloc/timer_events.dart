import 'dart:async';

import 'bloc.dart';

class TimerState {
  bool active;
  int start;
  TimerState(active);
}

class TimerEventBloc implements Bloc {
  TimerState _state;
  TimerState get currentState => _state;

  TimerEventBloc(this._state) {
    _stateController.sink.add(this._state);
  }

  final _stateController = StreamController<TimerState>();

  Stream<TimerState> get stateStream => _stateController.stream;

  void updateState(TimerState change) {
    _stateController.sink.add(_state);
  }

  @override
  void dispose() {
    _stateController.close();
  }
}
