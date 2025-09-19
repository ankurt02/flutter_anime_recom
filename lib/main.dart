import 'dart:ui';

import 'package:flutter/material.dart';
import 'screens/home.screen.dart';
import 'themes/dark_theme.dart';

import 'package:device_preview/device_preview.dart';

void main() => runApp(
  MyApp(),
);
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),

      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: RecommendationScreen(),
    );
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}