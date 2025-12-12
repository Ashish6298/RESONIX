import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicProvider extends ChangeNotifier {
  final player = AudioPlayer();

  List<String> pickedFiles = [];
  int currentIndex = -1;
  String? currentSong;

  MusicProvider() {
    loadSongsFromPrefs(); // Load saved songs on app start
  }

  /// Set picked files, copy to app storage, and save paths
  Future<void> setPickedFiles(List<String> files) async {
    List<String> localPaths = [];

    for (var path in files) {
      final copiedPath = await copyToLocal(path);
      // Prevent adding duplicates to the list
      if (!pickedFiles.contains(copiedPath)) {
        localPaths.add(copiedPath);
      }
    }

    // FIX: Use addAll so we don't wipe out previous songs
    pickedFiles.addAll(localPaths);

    if (pickedFiles.isNotEmpty && currentIndex == -1) {
      currentIndex = 0;
      currentSong = pickedFiles[0];
    }

    notifyListeners();
    await saveSongsToPrefs();
  }

  /// Copy file to app's local storage
  Future<String> copyToLocal(String path) async {
    final file = File(path);
    final appDir = await getApplicationDocumentsDirectory();
    // Clean filename to prevent path errors
    final fileName = path.split('/').last; 
    final newPath = '${appDir.path}/$fileName';

    // Check if file already exists
    if (File(newPath).existsSync()) return newPath;

    final newFile = await file.copy(newPath);
    return newFile.path;
  }

  /// Play selected song
  Future<void> playSong(int index) async {
    if (index < 0 || index >= pickedFiles.length) return;

    currentIndex = index;
    currentSong = pickedFiles[index];

    // Safety check: ensure file still exists before playing
    if (File(currentSong!).existsSync()) {
      await player.setFilePath(currentSong!);
      player.play();
    } 
    notifyListeners();
  }

  void playNext() {
    if (currentIndex < pickedFiles.length - 1) {
      playSong(currentIndex + 1);
    }
  }

  void playPrevious() {
    if (currentIndex > 0) {
      playSong(currentIndex - 1);
    }
  }

  bool get isPlaying => player.playing;

  /// FIX: Save ONLY filenames to SharedPreferences
  Future<void> saveSongsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert full paths to just filenames (e.g., "song.mp3")
    final fileNames = pickedFiles.map((path) => path.split('/').last).toList();
    
    await prefs.setStringList('saved_songs', fileNames);
  }

  /// FIX: Load filenames and reconstruct valid paths
  Future<void> loadSongsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFileNames = prefs.getStringList('saved_songs') ?? [];

    final appDir = await getApplicationDocumentsDirectory();
    List<String> validatedPaths = [];

    for (var name in savedFileNames) {
      // Rebuild the full path using the CURRENT app directory
      final fullPath = '${appDir.path}/$name';
      
      // Only add if the file actually exists on disk
      if (File(fullPath).existsSync()) {
        validatedPaths.add(fullPath);
      }
    }

    if (validatedPaths.isNotEmpty) {
      pickedFiles = validatedPaths;
      // If nothing is playing, ready the first song
      if (currentIndex == -1) {
         currentIndex = 0;
         currentSong = pickedFiles[0];
      }
      notifyListeners();
    }
  }

  /// Remove a song from the list
  Future<void> removeSong(int index) async {
    if (index < 0 || index >= pickedFiles.length) return;

    final file = File(pickedFiles[index]);
    if (file.existsSync()) await file.delete();

    pickedFiles.removeAt(index);

    // Adjust index if we removed the currently playing song
    if (index == currentIndex) {
      // Logic to stop or play next could go here
      player.stop();
      currentSong = null;
      currentIndex = -1;
    } else if (index < currentIndex) {
      currentIndex--;
    }

    notifyListeners();
    await saveSongsToPrefs();
  }
}