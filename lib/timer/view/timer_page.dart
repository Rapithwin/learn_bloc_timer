import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:flutter_timer/timer/timer.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Timer"),
      ),
      body: Stack(
        children: <Widget>[],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({super.key});

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      "$minutesStr:$secondsStr",
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ...switch (state) {
              TimerInitial() => <Widget>[
                  FloatingActionButton(
                    onPressed: () => context.read<TimerBloc>().add(
                          TimerStarted(duration: state.duration),
                        ),
                    child: Icon(Icons.play_arrow),
                  )
                ],
              TimerRunInProgress() => <Widget>[
                  FloatingActionButton(
                    child: Icon(Icons.pause),
                    onPressed: () => context.read<TimerBloc>().add(
                          const TimerPaused(),
                        ),
                  ),
                  FloatingActionButton(
                    child: Icon(Icons.square),
                    onPressed: () => context.read<TimerBloc>().add(
                          const TimerReset(),
                        ),
                  ),
                ],
              TimerRunPause() => <Widget>[
                  FloatingActionButton(
                    child: const Icon(Icons.play_arrow),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerResumed()),
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.square),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerReset()),
                  ),
                ],
              TimerRunComplete() => <Widget>[
                  FloatingActionButton(
                    onPressed: () => context.read<TimerBloc>().add(
                          const TimerReset(),
                        ),
                    child: Icon(Icons.square),
                  )
                ]
            }
          ],
        );
      },
    );
  }
}
