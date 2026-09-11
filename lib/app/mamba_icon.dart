import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme.dart';

/// Stroke icons drawn from 24×24 SVG paths.
enum MambaIcons {
  timer(
    '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 1.5"/>'
    '<path d="M10 2h4"/><path d="M12 2v3"/>',
  ),
  meals(
    '<circle cx="12" cy="12" r="5"/>'
    '<path d="M1.5 4v5a1.5 1.5 0 0 0 3 0V4M3 4v16M22.5 20V4c-2 1.5-3 4-3 7h3"/>',
  ),
  calendar(
    '<rect x="3" y="4" width="18" height="18" rx="3"/>'
    '<path d="M16 2v4M8 2v4M3 10h18"/>',
  ),
  settings(
    '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8'
    'l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5'
    'V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1'
    'a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3'
    'a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1'
    'a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3'
    'a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1'
    'a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21'
    'a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>',
  ),
  sliders(
    '<path d="M4 21v-7M4 10V3M12 21v-9M12 8V3M20 21v-5M20 12V3'
    'M1 14h6M9 8h6M17 16h6"/>',
  ),
  alert(
    '<path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9'
    'a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/>',
  ),
  check('<path d="M20 6 9 17l-5-5"/>'),
  close('<path d="M18 6 6 18M6 6l12 12"/>'),
  chevronRight('<path d="m9 18 6-6-6-6"/>'),
  arrowLeft('<path d="M19 12H5"/><path d="m12 19-7-7 7-7"/>'),
  plus('<path d="M12 5v14M5 12h14"/>'),
  pencil('<path d="M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5z"/>'),
  trash(
    '<path d="M3 6h18"/>'
    '<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/>'
    '<path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>'
    '<path d="M10 11v6M14 11v6"/>',
  ),
  clock('<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>'),
  flag('<path d="M4 22V4a1 1 0 0 1 1-1h11l-1.5 4L16 11H5"/>'),
  target(
    '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/>'
    '<circle cx="12" cy="12" r="1"/>',
  ),
  minus('<path d="M5 12h14"/>'),
  info('<circle cx="12" cy="12" r="9"/><path d="M12 16v-4M12 8h.01"/>'),
  logOut(
    '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>'
    '<path d="m16 17 5-5-5-5"/><path d="M21 12H9"/>',
  ),
  eye(
    '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/>'
    '<circle cx="12" cy="12" r="3"/>',
  ),
  eyeOff(
    '<path d="M9.9 4.2A10 10 0 0 1 12 4c6.5 0 10 8 10 8a17 17 0 0 1-2.2 3.2"/>'
    '<path d="M6.6 6.6A16 16 0 0 0 2 12s3.5 8 10 8a10 10 0 0 0 5.4-1.6"/>'
    '<path d="m2 2 20 20"/><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"/>',
  );

  const MambaIcons(this.paths);

  final String paths;
}

class MambaIcon extends StatelessWidget {
  const MambaIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.color,
    this.strokeWidth = 1.8,
    this.semanticLabel,
  });

  final MambaIcons icon;
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="currentColor" stroke-width="$strokeWidth" '
      'stroke-linecap="round" stroke-linejoin="round">${icon.paths}</svg>',
      width: size,
      height: size,
      theme: SvgTheme(
        currentColor:
            color ?? IconTheme.of(context).color ?? MambaColors.textPrimary,
      ),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
