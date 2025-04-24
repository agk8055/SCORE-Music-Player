import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import 'package:audio_service/audio_service.dart';
import '../services/audio_handler.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback? onTap;

  const SongListItem({
    Key? key,
    required this.song,
    this.isPlaying = false,
    this.onTap,
  }) : super(key: key);

  void _playSong() {
    final mediaItem = MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      artUri: Uri.parse(song.image),
      extras: {
        'playbackUrl': song.getPlaybackUrl(),
      },
    );
    audioHandler.playMediaItem(mediaItem);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        _playSong();
        if (onTap != null) onTap!();
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: song.image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 50,
            height: 50,
            color: Colors.black,
            child: const Icon(Icons.music_note, color: Color(0xFFFFDB4D)),
          ),
          errorWidget: (context, url, error) => Container(
            width: 50,
            height: 50,
            color: Colors.black,
            child: const Icon(Icons.error_outline, color: Color(0xFFFFDB4D)),
          ),
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying ? const Color(0xFFFFDB4D) : Colors.white,
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} • ${song.album}',
        style: TextStyle(
          color: isPlaying ? const Color(0xFFFFDB4D).withOpacity(0.7) : Colors.white.withOpacity(0.7),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isPlaying
          ? const Icon(
              Icons.equalizer,
              color: Color(0xFFFFDB4D),
            )
          : const Icon(
              Icons.play_arrow,
              color: Color(0xFFFFDB4D),
            ),
    );
  }
}