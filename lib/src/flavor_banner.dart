import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlavorBanner extends StatelessWidget {
  const FlavorBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (appFlavor == null || appFlavor == 'prod') {
      return child;
    }
    return Banner(
      location: BannerLocation.bottomEnd,
      message: appFlavor!,
      color: Colors.green.withValues(alpha: 0.6),
      textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12.0,
          letterSpacing: 1.0),
      textDirection: TextDirection.ltr,
      child: child,
    );
  }
}
