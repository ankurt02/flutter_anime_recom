import 'package:flutter/material.dart';
import 'screens/home.screen.dart';
import 'themes/dark_theme.dart';

import 'package:device_preview/device_preview.dart';

void main() => runApp(
  DevicePreview(
    // enabled: !kReleaseMode,
    builder: (context) => MyApp(), // Wrap your app
  ),
);
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: RecommendationScreen(),
    );
  }
}
