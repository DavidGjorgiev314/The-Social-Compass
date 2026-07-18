import 'package:audioplayers/audioplayers.dart';

enum Sfx {
  messageSend('audio/sfx/msg_send.wav'),
  messageReceive('audio/sfx/msg_receive.wav'),
  notification('audio/sfx/notification.wav'),
  choiceSelect('audio/sfx/choice_select.wav'),
  lock('audio/sfx/lock.wav'),
  unlock('audio/sfx/unlock.wav'),
  error('audio/sfx/error.wav'),
  appOpen('audio/sfx/app_open.wav'),
  appClose('audio/sfx/app_close.wav'),
  like('audio/sfx/like.wav');

  const Sfx(this.path);
  final String path;
}

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  bool enabled = true;
  final Map<Sfx, AudioPlayer> _players = {};
  AudioPlayer? _typingPlayer;

  Future<void> startTyping() async {
    if (!enabled) return;
    try {
      final player = _typingPlayer ??= AudioPlayer()
        ..setReleaseMode(ReleaseMode.loop);
      await player.stop();
      await player.play(AssetSource('audio/sfx/typing.wav'));
    } catch (_) {}
  }

  Future<void> stopTyping() async {
    try {
      await _typingPlayer?.stop();
    } catch (_) {}
  }

  Future<void> play(Sfx sfx) async {
    if (!enabled) return;
    try {
      final player = _players.putIfAbsent(sfx, () {
        final p = AudioPlayer();
        p.setReleaseMode(ReleaseMode.stop);
        p.setPlayerMode(PlayerMode.lowLatency);
        return p;
      });
      await player.stop();
      await player.play(AssetSource(sfx.path));
    } catch (_) {
      // Missing/unsupported sound file: stay silent rather than crash.
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
