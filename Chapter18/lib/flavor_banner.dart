import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlavorBanner extends StatelessWidget {
  final Widget child;

  const FlavorBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final flavor = appFlavor;
    // No banner in production.
    if (flavor == null || flavor == 'prod') {
      return child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        message: flavor.toUpperCase(),
        location: BannerLocation.topStart,
        color: flavor == 'dev'
            ? Colors.green
            : Colors.orange,
        child: child,
      ),
    );
  }
}
