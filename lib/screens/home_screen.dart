// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import '../providers/music_provider.dart';
// import '../theme/theme_provider.dart';
// import 'player_screen.dart';
// import '../widgets/song_tile.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // 1. Controller for the search input
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = "";

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> pickSongs() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['mp3', 'wav', 'm4a'],
//       allowMultiple: true,
//     );

//     if (result != null) {
//       final music = Provider.of<MusicProvider>(context, listen: false);
//       await music.setPickedFiles(result.paths.whereType<String>().toList());
//     }
//   }

//   // 2. Logic to filter songs based on search text
//   List<String> _getFilteredSongs(List<String> allSongs) {
//     if (_searchQuery.isEmpty) return allSongs;

//     return allSongs.where((filePath) {
//       final fileName = filePath.split('/').last.toLowerCase();
//       final query = _searchQuery.toLowerCase();
//       return fileName.contains(query);
//     }).toList();
//   }

//   Widget miniPlayer(BuildContext context) {
//     final music = Provider.of<MusicProvider>(context);
//     if (music.currentSong == null) return const SizedBox();

//     final rawFileName = music.currentSong!.split('/').last;
//     final displayTitle = rawFileName.replaceAll(RegExp(r'\.[^.]*$'), '');

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (_, __, ___) => PlayerScreen(index: music.currentIndex),
//             transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade900,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               height: 45,
//               width: 45,
//               decoration: BoxDecoration(
//                 color: Colors.deepPurpleAccent.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.music_note, color: Colors.deepPurpleAccent),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     displayTitle,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const Text(
//                     "Now Playing",
//                     style: TextStyle(
//                         color: Colors.white54, fontSize: 10, letterSpacing: 0.5),
//                   ),
//                 ],
//               ),
//             ),
//             StreamBuilder(
//               stream: music.player.playingStream,
//               builder: (context, snapshot) {
//                 bool isPlaying = snapshot.data ?? false;
//                 return Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     iconSize: 24,
//                     constraints: const BoxConstraints(),
//                     padding: const EdgeInsets.all(8),
//                     icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
//                         color: Colors.black),
//                     onPressed: () {
//                       isPlaying ? music.player.pause() : music.player.play();
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final music = Provider.of<MusicProvider>(context);
//     final theme = Provider.of<ThemeProvider>(context);

//     // Get the specific list of songs to display
//     final displayedSongs = _getFilteredSongs(music.pickedFiles);

//     return Scaffold(
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
//         child: CustomScrollView(
//           slivers: [
//             // --- 1. App Bar ---
//             SliverAppBar(
//               floating: true,
//               pinned: true, // Keep title visible
//               expandedHeight: 80,
//               backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//               elevation: 0,
//               flexibleSpace: FlexibleSpaceBar(
//                 titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
//                 title: Text(
//                   "My Library",
//                   style: TextStyle(
//                     color: Theme.of(context).textTheme.bodyLarge?.color,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 24,
//                   ),
//                 ),
//               ),
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 12.0),
//                   child: IconButton(
//                     icon: const Icon(Icons.add_circle_outline,
//                         color: Colors.deepPurpleAccent, size: 28),
//                     onPressed: pickSongs,
//                     tooltip: "Add Songs",
//                   ),
//                 ),
//               ],
//             ),

//             // --- 2. Search Bar Area ---
//             if (music.pickedFiles.isNotEmpty)
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Search songs...",
//                       hintStyle: TextStyle(color: Colors.grey.shade500),
//                       prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
//                       suffixIcon: _searchQuery.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear, size: 20),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 setState(() {
//                                   _searchQuery = "";
//                                 });
//                               },
//                             )
//                           : null,
//                       filled: true,
//                       fillColor: theme.themeMode == ThemeMode.light
//                           ? Colors.grey.shade200
//                           : Colors.grey.shade900,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//             // --- 3. Content Logic ---
//             if (music.pickedFiles.isEmpty)
//               // CASE A: Library is totally empty
//               SliverFillRemaining(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.library_music_outlined,
//                           size: 80, color: Colors.grey.shade400),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "No music found",
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "Add songs to get started",
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                       const SizedBox(height: 30),
//                       ElevatedButton.icon(
//                         onPressed: pickSongs,
//                         icon: const Icon(Icons.folder_open),
//                         label: const Text("Browse Files"),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else if (displayedSongs.isEmpty)
//               // CASE B: Library has songs, but Search matched nothing
//               SliverFillRemaining(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.search_off_rounded,
//                           size: 60, color: Colors.grey.shade400),
//                       const SizedBox(height: 10),
//                       Text(
//                         "No results for '$_searchQuery'",
//                         style: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               // CASE C: Show List
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final filePath = displayedSongs[index];
//                     final isLastItem = index == displayedSongs.length - 1;

//                     // IMPORTANT: We need to find the ORIGINAL index for the player to work correctly
//                     // because the filtered list has different indices than the provider list.
//                     final originalIndex = music.pickedFiles.indexOf(filePath);

//                     return Padding(
//                       padding: EdgeInsets.only(
//                           bottom: isLastItem && music.currentSong != null ? 100 : 0),
//                       child: SongTile(
//                         filePath: filePath,
//                         onTap: () {
//                           music.playSong(originalIndex);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   PlayerScreen(index: originalIndex),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                   childCount: displayedSongs.length,
//                 ),
//               ),
//           ],
//         ),
//       ),
//       bottomSheet: music.currentSong != null ? miniPlayer(context) : null,
//     );
//   }
// }



import 'dart:ui'; // Added for Glassmorphism
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/music_provider.dart';
import '../theme/theme_provider.dart';
import 'player_screen.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Controller for the search input
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> pickSongs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
      allowMultiple: true,
    );

    if (result != null) {
      final music = Provider.of<MusicProvider>(context, listen: false);
      await music.setPickedFiles(result.paths.whereType<String>().toList());
    }
  }

  // 2. Logic to filter songs based on search text
  List<String> _getFilteredSongs(List<String> allSongs) {
    if (_searchQuery.isEmpty) return allSongs;

    return allSongs.where((filePath) {
      final fileName = filePath.split('/').last.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return fileName.contains(query);
    }).toList();
  }

  Widget miniPlayer(BuildContext context) {
    final music = Provider.of<MusicProvider>(context);
    if (music.currentSong == null) return const SizedBox();

    final rawFileName = music.currentSong!.split('/').last;
    final displayTitle = rawFileName.replaceAll(RegExp(r'\.[^.]*$'), '');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => PlayerScreen(index: music.currentIndex),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12), // Tighter margins
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Gradient background for Mini Player
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade900.withOpacity(0.95),
              const Color(0xFF1E1E1E).withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24), // Rounded capsule shape
          border: Border.all(color: Colors.white10, width: 1), // Subtle border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rotating Album Art Placeholder
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50), // Fully circular
                border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.music_note_rounded, color: Colors.deepPurpleAccent, size: 28),
            ),
            const SizedBox(width: 14),
            
            // Text Info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Now Playing",
                    style: TextStyle(
                        color: Colors.deepPurpleAccent, fontSize: 11, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),

            // Play/Pause Button
            StreamBuilder(
              stream: music.player.playingStream,
              builder: (context, snapshot) {
                bool isPlaying = snapshot.data ?? false;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  ),
                  child: IconButton(
                    iconSize: 26,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.black),
                    onPressed: () {
                      isPlaying ? music.player.pause() : music.player.play();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final music = Provider.of<MusicProvider>(context);
    // theme is unused in logic but kept for future use if needed
    // final theme = Provider.of<ThemeProvider>(context); 

    final displayedSongs = _getFilteredSongs(music.pickedFiles);

    return Scaffold(
      extendBody: true, // Allows content to slide behind mini player area
      // Apply a subtle gradient background to the entire screen
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900.withOpacity(0.2), // Very subtle purple top
              const Color(0xFF121212), // Mostly dark
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(), // Smoother iOS style scroll
            slivers: [
              // --- 1. Stylish App Bar ---
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: 100, // Taller for better look
                backgroundColor: const Color(0xFF121212), // Match background
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Colors.deepPurpleAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Text(
                      "My Library",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.white, // Required for ShaderMask
                      ),
                    ),
                  ),
                  background: Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [
                           Colors.deepPurple.withOpacity(0.3),
                           Colors.transparent
                         ]
                       )
                     ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_rounded,
                            color: Colors.deepPurpleAccent, size: 28),
                        onPressed: pickSongs,
                        tooltip: "Add Songs",
                      ),
                    ),
                  ),
                ],
              ),

              // --- 2. Search Bar Area ---
              if (music.pickedFiles.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search your tracks...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.4)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 20, color: Colors.white54),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = "";
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E), // Dark card color
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // --- 3. Content Logic ---
              if (music.pickedFiles.isEmpty)
                // CASE A: Library is totally empty
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.music_note_rounded,
                              size: 60, color: Colors.deepPurpleAccent.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Your Library is Empty",
                          style: TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Import songs to start listening",
                          style: TextStyle(color: Colors.white.withOpacity(0.4)),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: pickSongs,
                          icon: const Icon(Icons.folder_open_rounded),
                          label: const Text("Import Files"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                            shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (displayedSongs.isEmpty)
                // CASE B: Search matched nothing
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          "No results found",
                          style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // CASE C: Show List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final filePath = displayedSongs[index];
                      final isLastItem = index == displayedSongs.length - 1;
                      final originalIndex = music.pickedFiles.indexOf(filePath);

                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: isLastItem && music.currentSong != null ? 100 : 0),
                        child: SongTile(
                          filePath: filePath,
                          onTap: () {
                            music.playSong(originalIndex);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlayerScreen(index: originalIndex),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: displayedSongs.length,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomSheet: music.currentSong != null ? miniPlayer(context) : null,
    );
  }
}