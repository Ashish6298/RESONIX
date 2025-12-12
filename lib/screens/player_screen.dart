import 'dart:ui'; // Required for ImageFilter (Glassmorphism)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends StatelessWidget {
  final int index;

  const PlayerScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final music = Provider.of<MusicProvider>(context);
    final fav = Provider.of<FavoritesProvider>(context);

    final filePath = music.pickedFiles[index];
    final String rawFileName = filePath.split('/').last;
    final String displayTitle = rawFileName.replaceAll(RegExp(r'\.[^.]*$'), '');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              fav.isFavorite(filePath) ? Icons.favorite : Icons.favorite_border_rounded,
              color: fav.isFavorite(filePath) ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => fav.toggleFavorite(filePath),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade900,
                  const Color(0xFF121212), // Deep black-grey
                ],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 1), // Push content down slightly

                  // 3. Central Album Art Card with Shadow & Glow
                  Container(
                    height: 320,
                    width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        // Soft glow effect behind the card
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withOpacity(0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1), // Glass effect
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.music_note_rounded,
                              size: 140,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1), // Equal spacing below card

                  // 4. Song Info
                  Column(
                    children: [
                      Text(
                        displayTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Unknown Artist",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 5. Controls
                  Theme(
                    data: ThemeData.dark(),
                    child: const PlayerControls(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}