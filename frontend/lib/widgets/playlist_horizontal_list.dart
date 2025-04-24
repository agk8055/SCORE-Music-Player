import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../screens/playlist_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaylistHorizontalList extends StatelessWidget {
  final String title;
  final List<Playlist> playlists;
  final VoidCallback? onSeeAll;

  const PlaylistHorizontalList({
    Key? key,
    required this.title,
    required this.playlists,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFDB4D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Color(0xFFFFDB4D)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistScreen(playlist: playlist),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: playlist.imageUrl,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 150,
                            height: 150,
                            color: Colors.black,
                            child: const Icon(Icons.music_note, color: Color(0xFFFFDB4D)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 150,
                            height: 150,
                            color: Colors.black,
                            child: const Icon(Icons.error_outline, color: Color(0xFFFFDB4D)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: Text(
                          playlist.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${playlist.songCount} songs',
                        style: const TextStyle(
                          color: Color(0xFFFFDB4D),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 