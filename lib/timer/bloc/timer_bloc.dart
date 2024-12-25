import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_timer/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

/// [TimerBloc] class which extends the original [Bloc] class. Takes a stream of [TimerEvent]
/// as an input and transforms them into a stream of [TimerState] as an output.
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  // TimerBloc constructor, passes the initial state to the parent class [Bloc].
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
    // When the [TimerBloc] recieves an event, it will call the event handler related to that event.
    on<TimerStarted>(_onStarted);
    on<_TimerTicked>(_onTicked);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  /// Pushes a [TimerRunInProgress] state with the start duration. If there is an open [_tickerSubscription], it cancels it.
  /// Lastly, it listesns to the [_ticker.tick] stream and on every tick adds a [_TimerTicked] event with the remaining duration.
  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }

  /// Pushes an updated [TimerRunInProgress] with a new duration every time a [_TimerTicked] event is recieved and the duration
  /// is greater than 0. When the timer ends, pushes a [TimerRunComplete] state
  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(event.duration > 0
        ? TimerRunInProgress(event.duration)
        : TimerRunComplete());
  }

  /// If the ```state``` of our [TimerBloc] is [TimerRunInProgress], it pauses the ```_tickerSubscription```
  /// and pushes a [TimerRunPause] state with the current timer duration.
  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  /// If the ```state``` of our [TimerBloc] is [TimerRunPause], it resumes the ```_tickerSubscription```
  /// and pushes a [TimerRunInProgress] state with the current timer duration.
  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  /// If the [TimerBloc] recieves a [TimerReset] event, cancels the current ```_tucjerSubscription```
  /// and pushes a [TimerInitial] state with the original duration.
  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(TimerInitial(_duration));
  }
}
