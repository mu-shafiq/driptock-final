import 'package:flutter/widgets.dart';

void navigateWithFadeFromBack(BuildContext context, Widget destination) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => destination,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ),
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  ));
}
