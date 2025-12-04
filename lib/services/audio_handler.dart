import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = <MediaItem>[];
  int _currentIndex = -1;

  MyAudioHandler() {
    _init();
  }

  void _init() {
    _player.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState: const {
            PlayerState.stopped: AudioProcessingState.idle,
            PlayerState.playing: AudioProcessingState.ready,
            PlayerState.paused: AudioProcessingState.ready,
            PlayerState.completed: AudioProcessingState.completed,
          }[state]!,
          playing: playing,
        ),
      );
    });

    _player.onPositionChanged.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    _player.onDurationChanged.listen((duration) {
      final index = _currentIndex;
      if (index >= 0 && index < _playlist.length) {
        final item = _playlist[index];
        if (item.duration != duration) {
          mediaItem.add(item.copyWith(duration: duration));
        }
      }
    });

    // Autoplay: skip to next song when current song completes
    _player.onPlayerComplete.listen((_) {
      skipToNext();
    });
  }

  Future<void> setPlaylist(List<Song> songs) async {
    _playlist.clear();
    _playlist.addAll(
      songs.map(
        (song) => MediaItem(
          id: song.path,
          album: "Unknown Album",
          title: song.title,
          artist: song.artist,
          artUri: null, // Can add art URI if available
          extras: {'path': song.path},
        ),
      ),
    );
    queue.add(_playlist);
  }

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await _playCurrent();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _playCurrent();
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    final index = _playlist.indexWhere((item) => item.id == mediaItem.id);
    if (index != -1) {
      _currentIndex = index;
      await _playCurrent();
    }
  }

  // Custom method to play a specific song from the provider
  Future<void> playSong(Song song) async {
    // Find in playlist or add it?
    // For simplicity, let's assume the provider sets the playlist first.
    // But if we just want to play a song, we can find it in the current queue.

    final index = _playlist.indexWhere((item) => item.id == song.path);
    if (index != -1) {
      _currentIndex = index;
      await _playCurrent();
    }
  }

  Future<void> _playCurrent() async {
    if (_currentIndex >= 0 && _currentIndex < _playlist.length) {
      final item = _playlist[_currentIndex];
      mediaItem.add(item);
      await _player.play(DeviceFileSource(item.id));
    }
  }

  // Expose player for direct access if needed (though discouraged)
  AudioPlayer get player => _player;
}
