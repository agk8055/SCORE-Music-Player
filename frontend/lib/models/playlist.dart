import 'dart:convert';
import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Song> songs;
  final int songCount;
  final String url;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.songs,
    required this.songCount,
    required this.url,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? '',
      songs: (json['songs'] as List?)
          ?.map((song) => Song.fromJson(song))
          .toList() ?? [],
      songCount: json['song_count'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}
