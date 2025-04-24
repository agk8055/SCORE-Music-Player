import 'dart:convert';
import 'song.dart';

class Album {
  final String id;
  final String name;
  final String artist;
  final String imageUrl;
  final List<Song> songs;
  final int songCount;
  final String releaseDate;
  final String language;
  final String url;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    required this.imageUrl,
    required this.songs,
    required this.songCount,
    required this.releaseDate,
    required this.language,
    required this.url,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      artist: json['artist'] ?? '',
      imageUrl: json['image'] ?? '',
      songs: (json['songs'] as List?)
          ?.map((song) => Song.fromJson(song))
          .toList() ?? [],
      songCount: json['song_count'] ?? 0,
      releaseDate: json['release_date'] ?? '',
      language: json['language'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
