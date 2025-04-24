import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../widgets/song_list_item.dart';
import '../widgets/base_layout.dart';
import '../widgets/music_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_service/audio_service.dart';
import '../services/audio_handler.dart';
import 'now_playing_screen.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistScreen({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  Song? _currentlyPlayingSong;
  bool _isPlaying = false;
  final ScrollController _scrollController = ScrollController();
  double _imageHeight = 300;

  @override
  void initState() {
    super.initState();
    audioHandler.playbackState.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
    
    _scrollController.addListener(() {
      setState(() {
        _imageHeight = 300 - _scrollController.offset.clamp(0, 200);
      });
    });
  }

  void _playSong(Song song) {
    // Create MediaItems for all songs in the playlist
    final mediaItems = widget.playlist.songs.map((s) => MediaItem(
      id: s.id,
      title: s.title,
      artist: s.artist,
      album: s.album,
      artUri: Uri.parse(s.image),
      extras: {'playbackUrl': s.getPlaybackUrl()},
    )).toList();

    // Find the current song's MediaItem
    final currentMediaItem = mediaItems.firstWhere((item) => item.id == song.id);

    // Play the song with the full playlist
    (audioHandler as MyAudioHandler).playPlaylist(currentMediaItem, mediaItems);
    
    setState(() => _currentlyPlayingSong = song);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NowPlayingScreen()));
  }

  void _playAllSongs() {
    if (widget.playlist.songs.isNotEmpty) {
      _playSong(widget.playlist.songs.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BaseLayout(
      title: widget.playlist.name,
      showSearch: true,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.3,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.playlist.imageUrl,
                    width: double.infinity,
                    height: _imageHeight,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImagePlaceholder(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.playlist.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: screenWidth * 0.04 + 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.playlist.songCount} songs',
                        style: TextStyle(
                          color: const Color(0xFFFFDB4D).withOpacity(0.8),
                          fontSize: screenWidth * 0.03 + 12,
                        ),
                      ),
                      Row(
                        children: [
                          _buildGradientButton(
                            icon: Icons.play_arrow_rounded,
                            label: 'Play All',
                            onPressed: _playAllSongs,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          _buildIconButton(
                            icon: Icons.shuffle_rounded,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = widget.playlist.songs[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.005,
                  ),
                  child: SongListItem(
                    song: song,
                    isPlaying: song == _currentlyPlayingSong && _isPlaying,
                    onTap: () => _playSong(song),
                  ),
                );
              },
              childCount: widget.playlist.songs.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MusicController(),
    );
  }

  Widget _buildGradientButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFDB4D).withOpacity(0.9),
            const Color(0xFFFFDB4D).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFDB4D).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFDB4D).withOpacity(0.6),
          width: 2,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFFFDB4D)),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Icon(
          Icons.queue_music_rounded,
          color: const Color(0xFFFFDB4D).withOpacity(0.3),
          size: 80,
        ),
      ),
    );
  }
}