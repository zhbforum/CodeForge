enum TrackId { fullstack, python, backend, vanillaJs, typescript, html, css }

class Track {
  const Track({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.locked = false,
    this.iconName,
  });

  final TrackId id;
  final String title;
  final String subtitle;
  final double progress;
  final bool locked;
  final String? iconName;
}
