import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:score/models/song.dart';
import 'package:rxdart/rxdart.dart';

// Singleton instance of the handler
// Late initialization is safe here because we initialize it in main() before runApp()
late AudioHandler _audioHandler;

// Getter for easy access in the UI
AudioHandler get audioHandler => _audioHandler;

Future<void> setupAudioHandler() async {
  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.score.channel.audio',
      androidNotificationChannelName: 'Score Music',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final _mediaItem = BehaviorSubject<MediaItem?>.seeded(null);
  final _playbackState = BehaviorSubject<PlaybackState>.seeded(
    PlaybackState(
      controls: [],
      systemActions: const {},
      androidCompactActionIndices: const [],
      processingState: AudioProcessingState.idle,
      playing: false,
      updatePosition: Duration.zero,
      bufferedPosition: Duration.zero,
      speed: 1.0,
      queueIndex: 0,
    ),
  );

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
  }

  @override
  BehaviorSubject<MediaItem?> get mediaItem => _mediaItem;

  @override
  BehaviorSubject<PlaybackState> get playbackState => _playbackState;

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      _playbackState.add(_playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
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
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      if (index == null) return;
      final mediaItem = _mediaItem.value;
      if (mediaItem != null) {
        _mediaItem.add(mediaItem.copyWith(duration: duration));
      }
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      if (index == null) return;
      final sequence = _player.sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final source = sequence[index];
      if (source.tag is MediaItem) {
        _mediaItem.add(source.tag as MediaItem);
      }
    });
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.dispose();
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    try {
      final playbackUrl = mediaItem.extras?['playbackUrl'] as String?;
      if (playbackUrl == null) {
        throw Exception('No playback URL provided');
      }

      // Clear current playlist
      await _playlist.clear();

      // Add the current song
      final audioSource = AudioSource.uri(
        Uri.parse(playbackUrl),
        tag: mediaItem,
      );
      await _playlist.add(audioSource);

      // Update media item and start playback
      _mediaItem.add(mediaItem);
      await _player.seek(Duration.zero, index: 0);
      await play();
    } catch (e) {
      print('Error playing media item: $e');
    }
  }

  Future<void> playPlaylist(MediaItem currentSong, List<MediaItem> playlist) async {
    try {
      // Clear current playlist
      await _playlist.clear();

      // Add all songs to the playlist
      final audioSources = playlist.map((item) => AudioSource.uri(
        Uri.parse(item.extras!['playbackUrl'] as String),
        tag: item,
      ));
      await _playlist.addAll(audioSources.toList());

      // Find the index of the current song
      final currentIndex = playlist.indexWhere((item) => item.id == currentSong.id);
      if (currentIndex == -1) {
        throw Exception('Current song not found in playlist');
      }

      // Update media item and start playback
      _mediaItem.add(currentSong);
      await _player.seek(Duration.zero, index: currentIndex);
      await play();
    } catch (e) {
      print('Error playing playlist: $e');
    }
  }
}