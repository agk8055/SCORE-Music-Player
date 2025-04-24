import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/api_service.dart';
import '../services/audio_handler.dart';
import '../widgets/search_bar.dart';
import '../widgets/song_list_item.dart';
import '../widgets/playlist_horizontal_list.dart';
import '../widgets/base_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Song> _searchResults = [];
  List<Song> _recentlyPlayed = [];
  List<Playlist> _curatedPlaylists = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;
  String _currentSearchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.trim().isNotEmpty) {
        _performSearch(query.trim());
      } else {
        _clearSearch();
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final playlists = await _apiService.getCuratedPlaylists();
      setState(() {
        _curatedPlaylists = playlists;
        _isLoading = false;
      });

      _apiService.getRecentlyPlayed().then((songs) {
        if (mounted) {
          setState(() => _recentlyPlayed = songs);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.searchSongs(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  void _clearSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    setState(() {
      _searchResults = [];
      _isLoading = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BaseLayout(
      title: 'Score',
      showSearch: true,
      onSearchChanged: (query) {
        setState(() => _currentSearchQuery = query);
        _handleSearchChanged(query);
      },
      child: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage != null
              ? _buildErrorState()
              : _currentSearchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildHomeContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: const Color(0xFFFFDB4D),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFFFDB4D).withOpacity(0.8),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: TextStyle(
                color: const Color(0xFFFFDB4D).withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
            child: Text(
              'No results found',
              style: TextStyle(
                color: const Color(0xFFFFDB4D).withOpacity(0.6),
                fontSize: 18,
              ),
            ),
          )
        : ListView.separated(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            itemCount: _searchResults.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.white.withOpacity(0.1),
              height: 24,
            ),
            itemBuilder: (context, index) {
              final song = _searchResults[index];
              return SongListItem(
                song: song,
                onTap: () => _playSong(song),
              );
            },
          );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (_recentlyPlayed.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Recently Played'),
                  const SizedBox(height: 16),
                  _buildRecentlyPlayed(),
                ],
              ),
            ),
          ),
        if (_curatedPlaylists.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: PlaylistHorizontalList(
                key: ValueKey('curated_playlists'),
                title: 'Curated Playlists',
                playlists: _curatedPlaylists,
              ),
            ),
          ),
        ..._buildGenreSections(),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  List<Widget> _buildGenreSections() {
    final genres = [
      'Malayalam',
      'Tamil',
      'Anirudh Ravichander',
      'Sushin Shyam',
      'A.R. Rahman',
    ];

    return genres.map((genre) {
      final genrePlaylists = _curatedPlaylists.where((p) => p.name.contains(genre)).toList();
      if (genrePlaylists.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

      return SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 16,
        ),
        sliver: SliverToBoxAdapter(
          child: PlaylistHorizontalList(
            key: ValueKey('genre_$genre'),
            title: genre,
            playlists: genrePlaylists,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayed() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.24,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentlyPlayed.length,
        itemBuilder: (context, index) {
          final song = _recentlyPlayed[index];
          return Container(
            width: MediaQuery.of(context).size.width * 0.35,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: song.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildImagePlaceholder(),
                          errorWidget: (context, url, error) => _buildImagePlaceholder(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  song.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artist,
                  style: TextStyle(
                    color: const Color(0xFFFFDB4D).withOpacity(0.8),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: const Color(0xFFFFDB4D).withOpacity(0.3),
          size: 40,
        ),
      ),
    );
  }

  void _playSong(Song song) {
    final mediaItem = MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      artUri: Uri.parse(song.image),
      extras: {'playbackUrl': song.getPlaybackUrl()},
    );
    audioHandler.playMediaItem(mediaItem);
  }
}