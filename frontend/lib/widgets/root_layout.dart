import 'package:flutter/material.dart';
import 'music_controller.dart';

class RootLayout extends StatelessWidget {
  final Widget child;

  const RootLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MusicController(),
          ),
        ],
      ),
    );
  }
} 