import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/album.dart';

class ApiService {
  static const String _baseUrl = "http://localhost:5000/api";

  Future<List<Song>> searchSongs(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final String encodedQuery = Uri.encodeComponent(query);
    final Uri searchUrl = Uri.parse('$_baseUrl/search?query=$encodedQuery');

    try {
      final response = await http.get(searchUrl).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return songFromJson(response.body);
      } else {
        throw Exception('Failed to load songs from server');
      }
    } catch (e) {
      throw Exception('Failed to fetch songs: $e');
    }
  }

  Future<List<Song>> getRecentlyPlayed() async {
    // Since we don't have a dedicated endpoint, we'll use a predefined search query
    return searchSongs('recent hits');
  }

  Future<List<Playlist>> getCuratedPlaylists() async {
    // Since we don't have a dedicated endpoint, we'll create some predefined playlists
    final List<Song> malayalamSongs = await searchSongs('malayalam hits');
    final List<Song> tamilSongs = await searchSongs('tamil hits');
    final List<Song> anirudhSongs = await searchSongs('anirudh ravichander');
    final List<Song> sushinSongs = await searchSongs('sushin shyam');
    final List<Song> arRahmanSongs = await searchSongs('ar rahman');

    return [
      if (malayalamSongs.isNotEmpty)
        Playlist(
          id: 'malayalam-top',
          name: 'Top Malayalam Hits',
          description: 'Best of Malayalam music',
          imageUrl: malayalamSongs.first.image,
          songs: malayalamSongs,
          songCount: malayalamSongs.length,
          url: '',
        ),
      if (tamilSongs.isNotEmpty)
        Playlist(
          id: 'tamil-top',
          name: 'Top Tamil Hits',
          description: 'Best of Tamil music',
          imageUrl: tamilSongs.first.image,
          songs: tamilSongs,
          songCount: tamilSongs.length,
          url: '',
        ),
      if (anirudhSongs.isNotEmpty)
        Playlist(
          id: 'anirudh-top',
          name: 'Anirudh\'s Best',
          description: 'Top songs by Anirudh',
          imageUrl: anirudhSongs.first.image,
          songs: anirudhSongs,
          songCount: anirudhSongs.length,
          url: '',
        ),
      if (sushinSongs.isNotEmpty)
        Playlist(
          id: 'sushin-top',
          name: 'Sushin\'s Best',
          description: 'Top songs by Sushin Shyam',
          imageUrl: sushinSongs.first.image,
          songs: sushinSongs,
          songCount: sushinSongs.length,
          url: '',
        ),
      if (arRahmanSongs.isNotEmpty)
        Playlist(
          id: 'ar-rahman-top',
          name: 'A.R. Rahman\'s Best',
          description: 'Top songs by A.R. Rahman',
          imageUrl: arRahmanSongs.first.image,
          songs: arRahmanSongs,
          songCount: arRahmanSongs.length,
          url: '',
        ),
    ];
  }

  Future<List<Song>> getTopSongsByLanguage(String language) async {
    return searchSongs('$language hits');
  }

  Future<List<Song>> getTopSongsByArtist(String artistName) async {
    return searchSongs(artistName);
  }

  Future<Song> getSongDetails(String songId) async {
    if (songId.isEmpty) {
      throw Exception('Invalid song ID');
    }

    final String encodedQuery = Uri.encodeComponent(songId);
    final Uri songUrl = Uri.parse('$_baseUrl/song?query=$encodedQuery');

    try {
      final response = await http.get(songUrl).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return Song.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load song details');
      }
    } catch (e) {
      throw Exception('Failed to fetch song details: $e');
    }
  }

  Future<Playlist> getPlaylistDetails(String playlistId) async {
    if (playlistId.isEmpty) {
      throw Exception('Invalid playlist ID');
    }

    final String encodedQuery = Uri.encodeComponent(playlistId);
    final Uri playlistUrl = Uri.parse('$_baseUrl/playlist?query=$encodedQuery');

    try {
      final response = await http.get(playlistUrl).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return Playlist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load playlist details');
      }
    } catch (e) {
      throw Exception('Failed to fetch playlist details: $e');
    }
  }

  Future<Album> getAlbumDetails(String albumId) async {
    if (albumId.isEmpty) {
      throw Exception('Invalid album ID');
    }

    final String encodedQuery = Uri.encodeComponent(albumId);
    final Uri albumUrl = Uri.parse('$_baseUrl/album?query=$encodedQuery');

    try {
      final response = await http.get(albumUrl).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return Album.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load album details');
      }
    } catch (e) {
      throw Exception('Failed to fetch album details: $e');
    }
  }

  Future<String> getLyrics(String songId) async {
    if (songId.isEmpty) {
      throw Exception('Invalid song ID');
    }

    final String encodedQuery = Uri.encodeComponent(songId);
    final Uri lyricsUrl = Uri.parse('$_baseUrl/lyrics?query=$encodedQuery');

    try {
      final response = await http.get(lyricsUrl).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load lyrics');
      }
    } catch (e) {
      throw Exception('Failed to fetch lyrics: $e');
    }
  }
}