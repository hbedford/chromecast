part of chromecast;

final ChromeCastPlatform _chromeCastPlatform = ChromeCastPlatform.instance;

/// Controller for a single ChromeCastButton instance running on the host platform.
class ChromeCastController {
  final _streamPosition = StreamController<Duration>.broadcast();

  Timer? _timer;

  /// The id for this controller
  final int id;

  ChromeCastController._({required this.id});

  /// Initialize control of a [ChromeCastButton] with [id].
  static Future<ChromeCastController> init(int id) async {
    await _chromeCastPlatform.init(id);
    return ChromeCastController._(id: id);
  }

  /// Add listener for receive callbacks.
  Future<void> addSessionListener() {
    return _chromeCastPlatform.addSessionListener(id: id);
  }

  /// Remove listener for receive callbacks.
  Future<void> removeSessionListener() {
    return _chromeCastPlatform.removeSessionListener(id: id);
  }

  /// Load a new media by providing an [url].
  Future<void> loadMedia(String url,
          {bool autoPlay = false, Duration? startPosition}) =>
      _chromeCastPlatform.loadMedia(url,
          id: id, autoPlay: autoPlay, startPosition: startPosition);

  _checkPosition() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      Duration newPosition = await position();
      _streamPosition.add(newPosition);
    });
  }

  /// Plays the video playback.
  Future<void> play() async {
    if (!await isFinished()) {
      await _chromeCastPlatform.play(id: id);
      _checkPosition();
    } else {
      print("no media loaded");
    }

    return;
  }

  /// Pauses the video playback.
  Future<void> pause() async {
    await _chromeCastPlatform.pause(id: id);
    _timer?.cancel();
    return;
  }

  /// If [relative] is set to false sets the video position to an [interval] from the start.
  ///
  /// If [relative] is set to true sets the video position to an [interval] from the current position.
  Future<void> seek({bool relative = false, int interval = 10}) {
    return _chromeCastPlatform.seek(relative, interval, id: id);
  }

  /// Set volume 0-1
  Future<void> setVolume({double volume = 0}) {
    return _chromeCastPlatform.setVolume(volume, id: id);
  }

  /// Get current volume
  Future<double> getVolume() {
    return _chromeCastPlatform.getVolume(id: id);
  }

  /// Stop the current video.
  Future<void> stop() {
    _timer?.cancel();
    return _chromeCastPlatform.stop(id: id);
  }

  /// Returns `true` when a cast session is connected, `false` otherwise.
  Future<bool?> isConnected() {
    return _chromeCastPlatform.isConnected(id: id);
  }

  /// End current session
  Future<void> endSession() {
    _timer?.cancel();
    return _chromeCastPlatform.endSession(id: id);
  }

  /// Returns `true` when a cast session is playing, `false` otherwise.
  Future<bool> isPlaying() async {
    return await _chromeCastPlatform.isPlaying(id: id);
  }

  Future<bool> isFinished() async {
    return await _chromeCastPlatform.isFinished(id: id);
  }

  /// Returns current position.
  Future<Duration> position() {
    return _chromeCastPlatform.position(id: id);
  }

  /// Returns video duration.
  Future<Duration> duration() {
    return _chromeCastPlatform.duration(id: id);
  }

  Stream<Duration> listenPosition() => _streamPosition.stream;
}
