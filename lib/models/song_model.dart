class MySong {
  final String path;      // full file path
  final String title;     // extracted file name
  final String artist;    // optional - unknown for file picker

  MySong({
    required this.path,
    required this.title,
    this.artist = "Unknown",
  });
}
