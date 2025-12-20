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

    // LOGIC: Ensure UI updates when song changes
    final int activeIndex = music.currentIndex >= 0 ? music.currentIndex : 0;
    final int totalSongs = music.pickedFiles.length;
    final filePath = music.pickedFiles[activeIndex];
    
    final String rawFileName = filePath.split('/').last;
    final String displayTitle = rawFileName.replaceAll(RegExp(r'\.[^.]*$'), '');
    final String fileExtension = filePath.split('.').last.toUpperCase(); // Extract MP3/WAV

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
        title: Column(
          children: [
            Text(
              "PLAYING NOW",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Track ${activeIndex + 1} of $totalSongs", // Informative: Track Count
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              fav.isFavorite(filePath) ? Icons.favorite : Icons.favorite_border_rounded,
              color: fav.isFavorite(filePath) ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => fav.toggleFavorite(filePath),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background: Spotlight Effect
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.6), // Spotlight near top center
                radius: 1.2,
                colors: [
                  Colors.deepPurple.shade900,
                  const Color(0xFF0F0F0F), // Darker black-grey
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
                  const Spacer(flex: 2), 

                  // 3. Album Art: Premium Glass Card
                  Container(
                    height: 320,
                    width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        // Deep glow
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withOpacity(0.3),
                          blurRadius: 50,
                          spreadRadius: 5,
                          offset: const Offset(0, 20),
                        ),
                        // Sharp shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // The Glass Container
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ]
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2), 
                                  width: 1.5
                                ),
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
                      ],
                    ),
                  ),

                  const Spacer(flex: 2), 

                  // 4. Song Info
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          displayTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24, // Slightly smaller for elegance
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Artist & Format Badge Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Unknown Artist",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 1,
                            height: 16,
                            color: Colors.white24,
                          ),
                          const SizedBox(width: 10),
                          // Informative Badge: Shows MP3/WAV
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              fileExtension, 
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurpleAccent.shade100,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 5. Controls
                  Theme(
                    data: ThemeData.dark(),
                    child: const PlayerControls(),
                  ),

                  const SizedBox(height: 50), // More bottom breathing room
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}