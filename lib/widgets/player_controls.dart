import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart'; // Import just_audio for LoopMode
import '../providers/music_provider.dart';
import '../utils/format_duration.dart'; 

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final music = Provider.of<MusicProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- 1. Progress Bar & Timestamps ---
        StreamBuilder<Duration>(
          stream: music.player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = music.player.duration ?? Duration.zero;

            final maxDuration = duration.inSeconds.toDouble() > 0 
                ? duration.inSeconds.toDouble() 
                : 1.0;
            final currentValue = position.inSeconds.toDouble().clamp(0.0, maxDuration);

            return Column(
              children: [
                // Custom Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.deepPurpleAccent,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayColor: Colors.deepPurpleAccent.withOpacity(0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                  ),
                  child: Slider(
                    value: currentValue,
                    min: 0,
                    max: maxDuration,
                    onChanged: (value) {
                      music.player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                
                // Time Labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(position),
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                      Text(
                        formatDuration(duration),
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // --- 2. Control Buttons ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // SHUFFLE BUTTON
            IconButton(
              icon: Icon(
                Icons.shuffle, 
                // Change color if active
                color: music.isShuffle ? Colors.deepPurpleAccent : Colors.grey.shade600, 
                size: 24
              ),
              onPressed: music.toggleShuffle, // Call the provider function
            ),

            // PREVIOUS BUTTON
            _NeumorphicControlButton(
              icon: Icons.skip_previous_rounded,
              onTap: music.playPrevious,
              size: 35,
            ),

            // PLAY / PAUSE (Main Button)
            StreamBuilder<bool>(
              stream: music.player.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                
                return Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 32,
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.black, 
                    ),
                    onPressed: () {
                      isPlaying ? music.player.pause() : music.player.play();
                    },
                  ),
                );
              },
            ),

            // NEXT BUTTON
            _NeumorphicControlButton(
              icon: Icons.skip_next_rounded,
              onTap: music.playNext,
              size: 35,
            ),

            // REPEAT BUTTON
            IconButton(
              icon: Icon(
                // Change Icon based on mode (One vs All)
                music.loopMode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded, 
                // Change color if active
                color: music.loopMode != LoopMode.off ? Colors.deepPurpleAccent : Colors.grey.shade600, 
                size: 24
              ),
              onPressed: music.toggleLoop, // Call the provider function
            ),
          ],
        ),
      ],
    );
  }
}

// --- Helper Widget for Next/Prev Buttons ---
class _NeumorphicControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _NeumorphicControlButton({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        splashColor: Colors.deepPurpleAccent.withOpacity(0.5),
        highlightColor: Colors.deepPurpleAccent.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}