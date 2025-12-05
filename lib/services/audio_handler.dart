import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  // We'll use the 'queue' behavior subject from BaseAudioHandler to store the playlist
  int _currentIndex = 0;

  MyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Broadcast playback state changes
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
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
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _currentIndex,
        ),
      );
    });

    // Propagate processing state to playback state and handle auto-advance
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });

    // Sync duration
    _player.durationStream.listen((duration) {
      if (duration != null) {
        final index = _currentIndex;
        if (index >= 0 && index < queue.value.length) {
          final item = queue.value[index];
          if (item.duration != duration) {
            // Update the item in the queue
            final newItem = item.copyWith(duration: duration);
            queue.value[index] = newItem;
            // Also update current mediaItem if it matches
            if (mediaItem.value?.id == item.id) {
              mediaItem.add(newItem);
            }
          }
        }
      }
    });
  }

  Future<void> setPlaylist(List<Song> songs) async {
    print('Setting playlist with ${songs.length} songs');
    // Convert songs to MediaItems
    final mediaItems = songs
        .map(
          (song) => MediaItem(
            id: song.path,
            album: song.album ?? "Unknown Album",
            title: song.title,
            artist: song.artist,
            artUri: null, // Can add art URI if available
            extras: {'path': song.path},
          ),
        )
        .toList();

    // Update the queue
    queue.add(mediaItems);
    _currentIndex = 0;

    // Don't auto-play, just be ready
    if (mediaItems.isNotEmpty) {
      mediaItem.add(mediaItems[0]);
      // Preload the first song? Optional.
      // await _player.setAudioSource(AudioSource.uri(Uri.file(mediaItems[0].id)));
    }
  }

  @override
  Future<void> play() async {
    if (_player.processingState == ProcessingState.idle) {
      await _playCurrent();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (queue.value.isEmpty) return;

    if (_currentIndex < queue.value.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0; // Loop back to start
    }
    await _playCurrent();
  }

  @override
  Future<void> skipToPrevious() async {
    if (queue.value.isEmpty) return;

    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = queue.value.length - 1; // Loop to end
    }
    await _playCurrent();
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    // Find index in queue
    final index = queue.value.indexWhere((item) => item.id == mediaItem.id);
    if (index != -1) {
      _currentIndex = index;
      await _playCurrent();
    }
  }

  // Custom method to play a specific song from the provider
  Future<void> playSong(Song song) async {
    final index = queue.value.indexWhere((item) => item.id == song.path);
    if (index != -1) {
      _currentIndex = index;
      await _playCurrent();
    }
  }

  Future<void> _playCurrent() async {
    if (queue.value.isEmpty) return;

    final item = queue.value[_currentIndex];
    mediaItem.add(item);

    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.file(item.id), tag: item),
      );
      await _player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  // Expose player for direct access if needed (though discouraged)
  AudioPlayer get player => _player;
}
