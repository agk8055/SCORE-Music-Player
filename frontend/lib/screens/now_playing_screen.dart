import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:score/services/audio_handler.dart';
import 'package:flutter/rendering.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  static final AudioHandler _audioHandler = audioHandler;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, 
                 color: Color(0xFFFFDB4D), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, 
                   color: Color(0xFFFFDB4D)),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<MediaItem?>(
        stream: _audioHandler.mediaItem,
        builder: (context, mediaSnapshot) {
          final mediaItem = mediaSnapshot.data;
          
          return StreamBuilder<PlaybackState>(
            stream: _audioHandler.playbackState,
            builder: (context, playbackSnapshot) {
              final playbackState = playbackSnapshot.data;

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.8,
                            maxHeight: screenWidth * 0.8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFDB4D).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: mediaItem?.artUri != null
                                ? CachedNetworkImage(
                                    imageUrl: mediaItem!.artUri.toString(),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => _artPlaceholder(),
                                    errorWidget: (context, url, error) => _artPlaceholder(),
                                  )
                                : _artPlaceholder(),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: screenHeight * 0.06,
                              child: MarqueeWidget(
                                child: Text(
                                  mediaItem?.title ?? 'No song playing',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              mediaItem?.artist ?? '',
                              style: TextStyle(
                                color: const Color(0xFFFFDB4D).withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            if (mediaItem != null) 
                              _PositionIndicator(mediaItem: mediaItem),
                            SizedBox(height: screenHeight * 0.02),
                            _PlaybackControls(
                              playbackState: playbackState,
                              audioHandler: _audioHandler,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _artPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFDB4D).withOpacity(0.1),
            Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note,
          color: Color(0xFFFFDB4D),
          size: 64,
        ),
      ),
    );
  }
}

class _PositionIndicator extends StatefulWidget {
  const _PositionIndicator({required this.mediaItem});
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
        
        final progress = _isDragging
            ? _dragValue
            : duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

        return Column(
          children: [
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  disabledThumbRadius: 8,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16,
                ),
                activeTrackColor: const Color(0xFFFFDB4D),
                inactiveTrackColor: const Color(0xFFFFDB4D).withOpacity(0.2),
                thumbColor: const Color(0xFFFFDB4D),
                overlayColor: const Color(0xFFFFDB4D).withOpacity(0.1),
              ),
              child: Slider(
                value: progress,
                onChangeStart: (value) {
                  setState(() => _isDragging = true);
                },
                onChanged: (value) {
                  setState(() => _dragValue = value);
                },
                onChangeEnd: (value) {
                  setState(() => _isDragging = false);
                  _audioHandler.seek(
                    Duration(
                      milliseconds: (value * duration.inMilliseconds).round(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: TextStyle(
                      color: const Color(0xFFFFDB4D).withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: const Color(0xFFFFDB4D).withOpacity(0.8),
                      fontSize: 14,
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

class _PlaybackControls extends StatelessWidget {
  final PlaybackState? playbackState;
  final AudioHandler audioHandler;

  const _PlaybackControls({
    required this.playbackState,
    required this.audioHandler,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: const Color(0xFFFFDB4D).withOpacity(0.7),
            size: 28,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: Color(0xFFFFDB4D),
            size: 40,
          ),
          onPressed: () => audioHandler.skipToPrevious(),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFDB4D),
                const Color(0xFFFFDB4D).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFDB4D).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            iconSize: 64,
            padding: EdgeInsets.zero,
            icon: Icon(
              playbackState?.playing == true
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: Colors.black,
            ),
            onPressed: () {
              if (playbackState?.playing == true) {
                audioHandler.pause();
              } else {
                audioHandler.play();
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            color: Color(0xFFFFDB4D),
            size: 40,
          ),
          onPressed: () => audioHandler.skipToNext(),
        ),
        IconButton(
          icon: Icon(
            Icons.repeat,
            color: const Color(0xFFFFDB4D).withOpacity(0.7),
            size: 28,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Duration animationDuration, backDuration, pauseDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.animationDuration = const Duration(seconds: 3),
    this.backDuration = const Duration(milliseconds: 800),
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scroll();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _scroll() async {
    while (scrollController.hasClients) {
      await Future.delayed(widget.pauseDuration);
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.easeInOut,
        );
      }
      await Future.delayed(widget.pauseDuration);
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          0.0,
          duration: widget.backDuration,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      child: Row(
        children: [
          widget.child,
          SizedBox(width: MediaQuery.of(context).size.width * 0.1),
        ],
      ),
    );
  }
}