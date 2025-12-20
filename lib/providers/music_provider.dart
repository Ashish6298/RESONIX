import 'dart:io';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicProvider extends ChangeNotifier {
  final player = AudioPlayer();

  List<String> pickedFiles = [];
  int currentIndex = -1;
  String? currentSong;

  // Shuffle & Loop States
  bool isShuffle = false;
  LoopMode loopMode = LoopMode.off; // off=[], all=[All], one=[1]

  MusicProvider() {
    loadSongsFromPrefs();
    _listenToPlayerState(); // <--- FIX: Start listening for song completion
  }

  /// FIX: Listener to auto-play next song when current one finishes
  void _listenToPlayerState() {
    player.playerStateStream.listen((state) {
      // If the song finished playing naturally...
      if (state.processingState == ProcessingState.completed) {
        // ...and we are NOT in 'Repeat One' mode (handled natively), play next.
        if (loopMode != LoopMode.one) {
          playNext();
        }
      }
    });
  }

  /// Set picked files, copy to app storage, and save paths
  Future<void> setPickedFiles(List<String> files) async {
    List<String> localPaths = [];
    for (var path in files) {
      final copiedPath = await copyToLocal(path);
      if (!pickedFiles.contains(copiedPath)) {
        localPaths.add(copiedPath);
      }
    }
    pickedFiles.addAll(localPaths);

    if (pickedFiles.isNotEmpty && currentIndex == -1) {
      currentIndex = 0;
      currentSong = pickedFiles[0];
    }

    notifyListeners();
    await saveSongsToPrefs();
  }

  Future<String> copyToLocal(String path) async {
    final file = File(path);
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.split('/').last;
    final newPath = '${appDir.path}/$fileName';
    if (File(newPath).existsSync()) return newPath;
    final newFile = await file.copy(newPath);
    return newFile.path;
  }

  /// Toggle Shuffle Mode
  void toggleShuffle() {
    isShuffle = !isShuffle;
    notifyListeners();
  }

  /// Toggle Repeat Mode (Off -> All -> One -> Off)
  void toggleLoop() {
    if (loopMode == LoopMode.off) {
      loopMode = LoopMode.all;
    } else if (loopMode == LoopMode.all) {
      loopMode = LoopMode.one;
    } else {
      loopMode = LoopMode.off;
    }
    // Just_audio handles 'Repeat One' natively, but we handle 'All' and 'Off' manually
    player.setLoopMode(loopMode); 
    notifyListeners();
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= pickedFiles.length) return;

    currentIndex = index;
    currentSong = pickedFiles[index];

    if (File(currentSong!).existsSync()) {
      await player.setFilePath(currentSong!);
      player.play();
    }
    notifyListeners();
  }

  /// Play Next with Shuffle/Repeat logic
  void playNext() {
    if (pickedFiles.isEmpty) return;

    // 1. If Shuffle is ON, pick random song
    if (isShuffle) {
      final random = Random();
      playSong(random.nextInt(pickedFiles.length));
    } 
    // 2. Normal Next Logic
    else if (currentIndex < pickedFiles.length - 1) {
      playSong(currentIndex + 1);
    } 
    // 3. If Loop All is ON and we are at the end, go to start
    else if (loopMode == LoopMode.all) {
      playSong(0);
    }
    // Note: If LoopMode is OFF and we are at the end, we do nothing (Stop).
  }

  /// Play Previous
  void playPrevious() {
    if (pickedFiles.isEmpty) return;

    if (currentIndex > 0) {
      playSong(currentIndex - 1);
    } 
    else if (loopMode == LoopMode.all) {
      playSong(pickedFiles.length - 1);
    }
  }

  bool get isPlaying => player.playing;

  Future<void> saveSongsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final fileNames = pickedFiles.map((path) => path.split('/').last).toList();
    await prefs.setStringList('saved_songs', fileNames);
  }

  Future<void> loadSongsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFileNames = prefs.getStringList('saved_songs') ?? [];
    final appDir = await getApplicationDocumentsDirectory();
    List<String> validatedPaths = [];

    for (var name in savedFileNames) {
      final fullPath = '${appDir.path}/$name';
      if (File(fullPath).existsSync()) {
        validatedPaths.add(fullPath);
      }
    }

    if (validatedPaths.isNotEmpty) {
      pickedFiles = validatedPaths;
      if (currentIndex == -1) {
        currentIndex = 0;
        currentSong = pickedFiles[0];
      }
      notifyListeners();
    }
  }

  Future<void> removeSong(int index) async {
    if (index < 0 || index >= pickedFiles.length) return;
    final file = File(pickedFiles[index]);
    if (file.existsSync()) await file.delete();
    pickedFiles.removeAt(index);

    if (index == currentIndex) {
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