part of 'timer_bloc.dart';

/// Base class [TimerState] which has a duration property.
/// and it extends [Equatable] to avoid triggering rebuilds if the same state occurs.
sealed class TimerState extends Equatable {
  const TimerState(this.duration);
  final int duration;

  @override
  // Two instances are equal if they have the same duration.
  List<Object> get props => [duration];
}

/// [TimerInitial] state: ready to start counting down from the specified duration.
final class TimerInitial extends TimerState {
  const TimerInitial(super.duration);

  @override
  String toString() => "TimerInitial { duration: $duration }";
}

/// [TimerRunPause] state: paused at some remaining duration.
final class TimerRunPause extends TimerState {
  const TimerRunPause(super.duration);

  @override
  String toString() => "TimerRunPause { duration: $duration }";
}

/// [TimerRunInProgress] state: actively counting down from the specified duration.
final class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(super.duration);

  @override
  String toString() => "TimerRunInProgress { duration: $duration }";
}

/// [TimerRunComplete] state: countdown compeleted with a remaining duration of 0.
final class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0);
}
