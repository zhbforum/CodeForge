import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/core/models/track.dart';

enum Tech { html, css, js, react, ts, python, node, db, lock }

extension on Tech {
  String get asset {
    switch (this) {
      case Tech.html:
        return 'assets/icons/html.svg';
      case Tech.css:
        return 'assets/icons/css.svg';
      case Tech.js:
        return 'assets/icons/javascript.svg';
      case Tech.react:
        return 'assets/icons/react.svg';
      case Tech.ts:
        return 'assets/icons/typescript.svg';
      case Tech.python:
        return 'assets/icons/python.svg';
      case Tech.node:
        return 'assets/icons/nodejs.svg';
      case Tech.db:
        return 'assets/icons/database.svg';
      case Tech.lock:
        return 'assets/icons/lock.svg';
    }
  }
}

class TechIconsRow extends StatelessWidget {
  const TechIconsRow({
    required this.items, super.key,
    this.size = 18,
    this.spacing = 6,
  });

  final List<Tech> items;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final t in items)
          SvgPicture.asset(t.asset, width: size, height: size),
      ],
    );
  }
}

List<Tech> iconsForTrackId(TrackId id) {
  switch (id) {
    case TrackId.fullstack:
      return const [Tech.html, Tech.css, Tech.js, Tech.react];
    case TrackId.backend:
      return const [Tech.node, Tech.db, Tech.lock];
    case TrackId.vanillaJs:
      return const [Tech.js];
    case TrackId.python:
      return const [Tech.python];
    case TrackId.typescript:
      return const [Tech.ts];
    case TrackId.html:
      return const [Tech.html];
    case TrackId.css:
      return const [Tech.css];
  }
}
