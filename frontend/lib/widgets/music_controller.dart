import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:score/services/audio_handler.dart';
import 'package:score/screens/now_playing_screen.dart';

/// A compact, Spotify‑style music controller that sits at the bottom of the
/// screen. It displays the current media item (artwork, title, artist), a
/// progress indicator, and playback controls (previous, play/pause, next).
class MusicController extends StatelessWidget {
  const MusicController({super.key});

  static final AudioHandler _audioHandler = audioHandler;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: _audioHandler.playbackState,
      builder: (context, playbackSnapshot) {
        final playbackState = playbackSnapshot.data;
        return StreamBuilder<MediaItem?>(
          stream: _audioHandler.mediaItem,
          builder: (context, mediaSnapshot) {
            final mediaItem = mediaSnapshot.data;
            
            // Show loading only when actually loading a new song
            if (playbackState?.processingState == AudioProcessingState.loading) {
              return _buildLoadingController();
            }

            // Show error state if there's an error
            if (playbackSnapshot.hasError || mediaSnapshot.hasError) {
              return _buildErrorController();
            }

            // Build the main controller
            return Material(
              color: Colors.black,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NowPlayingScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFFDB4D),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Progress indicator – thin line at the top.
                      if (mediaItem != null) _PositionIndicator(
                        mediaItem: mediaItem,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              // Album art or placeholder
                              if (mediaItem != null && mediaItem.artUri != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    imageUrl: mediaItem.artUri!.toString(),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => _artPlaceholder(),
                                    errorWidget: (context, url, error) => _artPlaceholder(),
                                  ),
                                )
                              else
                                _artPlaceholder(),
                              const SizedBox(width: 12),
                              // Title & artist or placeholder
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mediaItem?.title ?? 'No song playing',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mediaItem?.artist ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFFFFDB4D),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Controls
                              if (mediaItem != null) ...[
                                IconButton(
                                  icon: const Icon(Icons.skip_previous, color: Color(0xFFFFDB4D)),
                                  onPressed: () => _audioHandler.skipToPrevious(),
                                ),
                                IconButton(
                                  icon: Icon(
                                    playbackState?.playing == true
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    color: const Color(0xFFFFDB4D),
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    if (playbackState?.playing == true) {
                                      _audioHandler.pause();
                                    } else {
                                      _audioHandler.play();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next, color: Color(0xFFFFDB4D)),
                                  onPressed: () => _audioHandler.skipToNext(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingController() {
    return Material(
      color: Colors.black,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFDB4D),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFDB4D)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorController() {
    return Material(
      color: Colors.black,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFDB4D),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Error loading player',
            style: TextStyle(color: Color(0xFFFFDB4D)),
          ),
        ),
      ),
    );
  }

  // Small grey placeholder box with a music note icon.
  Widget _artPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.black,
      child: const Icon(Icons.music_note, color: Color(0xFFFFDB4D)),
    );
  }
}

/// Top progress bar + duration labels.
class _PositionIndicator extends StatefulWidget {
  const _PositionIndicator({
    required this.mediaItem,
  });

  final MediaItem mediaItem;

  @override
  State<_PositionIndicator> createState() => _PositionIndicatorState();
}

class _PositionIndicatorState extends State<_PositionIndicator> {
  static final AudioHandler _audioHandler = audioHandler;
  double _dragValue = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _audioHandler.playbackState.map((state) => state.position),
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = widget.mediaItem.duration ?? Duration.zero;
        
        // Calculate progress based on drag or actual position
        final progress = _isDragging
            ? _dragValue
            : duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

        return Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onHorizontalDragStart: (_) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragValue = (progress + details.delta.dx / MediaQuery.of(context).size.width)
                        .clamp(0.0, 1.0);
                  });
                },
                onHorizontalDragEnd: (_) {
                  setState(() {
                    _isDragging = false;
                  });
                  final newPosition = Duration(
                    milliseconds: (_dragValue * duration.inMilliseconds).round(),
                  );
                  _audioHandler.seek(newPosition);
                },
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFDB4D)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(
                      color: Color(0xFFFFDB4D),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: Color(0xFFFFDB4D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
