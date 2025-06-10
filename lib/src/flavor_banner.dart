import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlavorBanner extends StatelessWidget {
  static const flavor = appFlavor ?? 'bland';

  const FlavorBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (flavor == 'prod') {
      return child;
    }

    return Banner(
      message: flavor,
      location: BannerLocation.bottomEnd,
      color: Colors.green.withValues(alpha: 0.6),
      textStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12.0,
        letterSpacing: 1.0,
      ),
      textDirection: TextDirection.ltr,
      child: child,
    );
  }
}
