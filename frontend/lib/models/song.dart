import 'dart:convert';

// Helper function to decode JSON safely
List<Song> songFromJson(String str) =>
    List<Song>.from(json.decode(str).map((x) => Song.fromJson(x)));

String songToJson(List<Song> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Song {
  final String id;
  final String title;
  final String album;
  final String albumUrl;
  final String albumId;
  final String artist;
  final String artistId;
  final String image;
  final String songUrl;
  final int duration;
  final String language;
  final String label;
  final String labelId;
  final String labelUrl;
  final String releaseDate;
  final String primaryArtists;
  final String primaryArtistsId;
  final String mediaUrl;
  final String mediaPreviewUrl;
  final bool isDrm;
  final bool hasLyrics;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.albumUrl,
    required this.albumId,
    required this.artist,
    required this.artistId,
    required this.image,
    required this.songUrl,
    required this.duration,
    required this.language,
    required this.label,
    required this.labelId,
    required this.labelUrl,
    required this.releaseDate,
    required this.primaryArtists,
    required this.primaryArtistsId,
    required this.mediaUrl,
    required this.mediaPreviewUrl,
    required this.isDrm,
    required this.hasLyrics,
    
  });

  // Factory constructor to create a Song instance from a JSON map
  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] ?? '',
        title: json['song'] ?? 'Unknown Title',
        album: json['album'] ?? 'Unknown Album',
        albumUrl: json['album_url'] ?? '',
        albumId: json['albumid'] ?? '',
        artist: json['artist'] ?? json['primary_artists'] ?? 'Unknown Artist',
        artistId: json['artist_id'] ?? json['primary_artists_id'] ?? '',
        image: json['image'] ?? '',
        songUrl: json['url'] ?? json['media_url'] ?? '',
        duration: int.tryParse(json['duration'] ?? '0') ?? 0,
        language: json['language'] ?? 'Unknown',
        label: json['label'] ?? 'Unknown',
        labelId: json['label_id'] ?? '',
        labelUrl: json['label_url'] ?? '',
        releaseDate: json['release_date'] ?? '',
        primaryArtists: json['primary_artists'] ?? '',
        primaryArtistsId: json['primary_artists_id'] ?? '',
        mediaUrl: json['media_url'] ?? '',
        mediaPreviewUrl: json['media_preview_url'] ?? '',
        isDrm: json['is_drm'] == 1,
        hasLyrics: json['has_lyrics'] == 'true',
      );

  // Method to convert a Song instance back to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'album': album,
        'albumUrl': albumUrl,
        'albumId': albumId,
        'artist': artist,
        'artistId': artistId,
        'image': image,
        'songUrl': songUrl,
        'duration': duration,
        'language': language,
        'label': label,
        'labelId': labelId,
        'labelUrl': labelUrl,
        'releaseDate': releaseDate,
        'primaryArtists': primaryArtists,
        'primaryArtistsId': primaryArtistsId,
        'mediaUrl': mediaUrl,
        'mediaPreviewUrl': mediaPreviewUrl,
        'isDrm': isDrm,
        'hasLyrics': hasLyrics,
      };

  // Get the proper URL for playback
  String getPlaybackUrl() {
    if (isDrm) {
      // For DRM content, use the encrypted media URL
      return songUrl;
    }
    return mediaUrl.isNotEmpty ? mediaUrl : songUrl;
  }
}