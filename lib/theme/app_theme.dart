import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.indigo,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 15,
    appBarStyle: FlexAppBarStyle.background,
    bottomAppBarElevation: 2,
    subThemesData: const FlexSubThemesData(
      inputDecoratorRadius: 12,
      cardRadius: 12,
      filledButtonRadius: 12,
      elevatedButtonRadius: 12,
      popupMenuRadius: 12,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );

  static final ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.indigo,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 15,
    appBarStyle: FlexAppBarStyle.background,
    bottomAppBarElevation: 2,
    subThemesData: const FlexSubThemesData(
      inputDecoratorRadius: 12,
      cardRadius: 12,
      filledButtonRadius: 12,
      elevatedButtonRadius: 12,
      popupMenuRadius: 12,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );
}
