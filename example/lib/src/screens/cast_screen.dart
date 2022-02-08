import 'dart:async';

import 'package:chromecast/chromecast.dart';
import 'package:flutter/material.dart';
import 'timer.dart';

class CastScreen extends StatefulWidget {
  static const _iconSize = 50.0;

  const CastScreen({Key? key}) : super(key: key);

  @override
  _CastScreenState createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  late ChromeCastController _controller;
  AppState _state = AppState.idle;
  bool? _playing = false;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  double volume = 0;

  Timer _timer = Timer();
  StreamSubscription<int>? _tickerSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste'),
        actions: <Widget>[
          ChromeCastButton(
            size: CastScreen._iconSize,
            color: Colors.white,
            onButtonCreated: _onButtonCreated,
            onSessionStarted: _onSessionStarted,
            onSessionEnded: _onSessionEnded,
            onRequestCompleted: _onRequestCompleted,
            onRequestFailed: _onRequestFailed,
          ),
        ],
      ),
      body: Column(
        children: [Center(child: _handleState())],
      ),
    );
  }

  Widget _handleState() {
    switch (_state) {
      case AppState.idle:
        return const Text('ChromeCast not connected');
      case AppState.connected:
        return const Text('No media loaded');
      case AppState.mediaLoaded:
        return _mediaControls();
      case AppState.error:
        return const Text('An error has occurred');
      default:
        return Container();
    }
  }

  Widget _mediaControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _RoundIconButton(
              icon: Icons.replay_10,
              onPressed: () =>
                  _controller.seek(relative: true, interval: -10.0),
            ),
            _RoundIconButton(
                icon: _playing! ? Icons.pause : Icons.play_arrow,
                onPressed: _playPause),
            _RoundIconButton(
              icon: Icons.forward_10,
              onPressed: () => _controller.seek(relative: true, interval: 10.0),
            ),
          ],
        ),
        Slider(
          value: _sliderValue(),
          onChanged: (double value) {
            _changeSliderValue(value);
          },
        ),
        Text(_time()),
        /*
        //End session
        _RoundIconButton(
          icon: Icons.stop,
          onPressed: () => _controller.endSession(),
        ),
         */
      ],
    );
  }

  String _time() {
    if (duration.inHours > 0) {
      return "${formatHour(position)} / ${formatHour(duration)}";
    } else {
      return "${format(position)} / ${format(duration)}";
    }
  }

  format(Duration d) => d.toString().substring(2, 7);
  formatHour(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  double _sliderValue() {
    return position.inSeconds /
        (duration.inSeconds == 0 ? 5 : duration.inSeconds);
  }

  _changeSliderValue(double value) {
    position = Duration(
      seconds:
          ((duration.inSeconds == 0 ? 5 : duration.inSeconds) * value).toInt(),
    );
    _changePosition(position);
    setState(() {});
  }

  _changePosition(Duration position) async {
    if ((await _controller.isConnected()) ?? false) {
      await _controller.seek(interval: position.inSeconds.toDouble());
      position = await _controller.position();
      setState(() {});
    }
  }

  Future<void> _playPause() async {
    final bool playing = (await _controller.isPlaying()) ?? false;
    if (playing) {
      await _controller.pause();
      _tickerSubscription?.cancel();
    } else {
      await _controller.play();
      _tickerSubscription?.cancel();
      _tickerSubscription = _timer.tick(ticks: 0).listen((time) async {
        position = await _controller.position();
        setState(() {});
      });
    }
    setState(() => _playing = !playing);
  }

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    setState(() => _state = AppState.connected);
    await _controller.loadMedia(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    );
    _controller.play();
  }

  Future<void> _onSessionEnded() async {
    _tickerSubscription?.cancel();
    position = Duration.zero;
    duration = Duration.zero;
    setState(() => _state = AppState.idle);
  }

  Future<void> _onRequestCompleted() async {
    final playing = await _controller.isPlaying();
    setState(() {
      _state = AppState.mediaLoaded;
      _playing = playing;
    });
    duration = await _controller.duration();
    setState(() {});
  }

  Future<void> _onRequestFailed(String? error) async {
    _tickerSubscription?.cancel();
    setState(() => _state = AppState.error);
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Icon(icon, color: Colors.white),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          shape:
              MaterialStateProperty.all<OutlinedBorder>(const CircleBorder()),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(16.0),
          ),
        ),
        onPressed: onPressed);
  }
}

enum AppState { idle, connected, mediaLoaded, error }