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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.music_note, color: Colors.deepPurpleAccent),
            ),
            const SizedBox(width: 12),
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
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    "Now Playing",
                    style: TextStyle(
                        color: Colors.white54, fontSize: 10, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: music.player.playingStream,
              builder: (context, snapshot) {
                bool isPlaying = snapshot.data ?? false;
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 24,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
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
    final theme = Provider.of<ThemeProvider>(context);

    // Get the specific list of songs to display
    final displayedSongs = _getFilteredSongs(music.pickedFiles);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: CustomScrollView(
          slivers: [
            // --- 1. App Bar ---
            SliverAppBar(
              floating: true,
              pinned: true, // Keep title visible
              expandedHeight: 80,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
                title: Text(
                  "My Library",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.deepPurpleAccent, size: 28),
                    onPressed: pickSongs,
                    tooltip: "Add Songs",
                  ),
                ),
              ],
            ),

            // --- 2. Search Bar Area ---
            if (music.pickedFiles.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search songs...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.themeMode == ThemeMode.light
                          ? Colors.grey.shade200
                          : Colors.grey.shade900,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),

            // --- 3. Content Logic ---
            if (music.pickedFiles.isEmpty)
              // CASE A: Library is totally empty
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_music_outlined,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 20),
                      const Text(
                        "No music found",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Add songs to get started",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: pickSongs,
                        icon: const Icon(Icons.folder_open),
                        label: const Text("Browse Files"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (displayedSongs.isEmpty)
              // CASE B: Library has songs, but Search matched nothing
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        "No results for '$_searchQuery'",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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

                    // IMPORTANT: We need to find the ORIGINAL index for the player to work correctly
                    // because the filtered list has different indices than the provider list.
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
      bottomSheet: music.currentSong != null ? miniPlayer(context) : null,
    );
  }
}