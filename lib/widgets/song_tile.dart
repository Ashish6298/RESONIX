import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';

class SongTile extends StatelessWidget {
  final String filePath;      // Full local path
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Get MusicProvider to check which song is playing
    final music = Provider.of<MusicProvider>(context);
    final isPlayingThis = music.currentSong == filePath;

    // 2. Clean the filename (Remove .mp3 extension)
    final rawFileName = filePath.split('/').last;
    final title = rawFileName.replaceAll(RegExp(r'\.[^.]*$'), '');

    return Container(
      // 3. Card Styling (Margins create the "separate row" look)
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Adapts to Dark/Light mode
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 4. Album Art Placeholder
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    // Change color if this specific song is playing
                    gradient: LinearGradient(
                      colors: isPlayingThis
                          ? [Colors.deepPurpleAccent, Colors.purple]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    // Change icon to visualizer if playing
                    isPlayingThis ? Icons.bar_chart_rounded : Icons.music_note_rounded,
                    color: isPlayingThis ? Colors.white : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(width: 16),

                // 5. Song Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // Highlight text color if playing
                          color: isPlayingThis 
                              ? Colors.deepPurpleAccent 
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPlayingThis ? "Now Playing" : "Unknown Artist",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                // 6. More Options Button (Logic included for Delete)
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('Remove from library'),
                            onTap: () {
                              // Find index and remove
                              final index = music.pickedFiles.indexOf(filePath);
                              music.removeSong(index);
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}