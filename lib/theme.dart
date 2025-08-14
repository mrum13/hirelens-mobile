import "package:flutter/material.dart";

// URGENT: Find dark color scheme with black and green
// Primary Color = 697565
// Background Colors = 181c14

class HirelensTheme {
  final TextTheme textTheme;

  const HirelensTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00281d),
      surfaceTint: Color(0xff326856),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004030),
      onPrimaryContainer: Color(0xff75ac97),
      secondary: Color(0xff0f6855),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff33816d),
      onSecondaryContainer: Color(0xfff4fff9),
      tertiary: Color(0xff006874),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3bafbf),
      onTertiaryContainer: Color(0xff003e45),
      error: Color(0xffa43b33),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffff8073),
      onErrorContainer: Color(0xff741814),
      surface: Color(0xfffdf8f6),
      onSurface: Color(0xff1c1b1a),
      onSurfaceVariant: Color(0xff4a473c),
      outline: Color(0xff7b776b),
      outlineVariant: Color(0xffccc6b9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff31302f),
      inversePrimary: Color(0xff9ad2bc),
      primaryFixed: Color(0xffb6efd7),
      onPrimaryFixed: Color(0xff002117),
      primaryFixedDim: Color(0xff9ad2bc),
      onPrimaryFixedVariant: Color(0xff17503f),
      secondaryFixed: Color(0xffa4f2d9),
      onSecondaryFixed: Color(0xff002019),
      secondaryFixedDim: Color(0xff88d5be),
      onSecondaryFixedVariant: Color(0xff005141),
      tertiaryFixed: Color(0xff97f0ff),
      onTertiaryFixed: Color(0xff001f24),
      tertiaryFixedDim: Color(0xff69d6e6),
      onTertiaryFixedVariant: Color(0xff004f58),
      surfaceDim: Color(0xffddd9d7),
      surfaceBright: Color(0xfffdf8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f0),
      surfaceContainer: Color(0xfff1edea),
      surfaceContainerHigh: Color(0xffebe7e5),
      surfaceContainerHighest: Color(0xffe6e2df),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00281d),
      surfaceTint: Color(0xff326856),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004030),
      onPrimaryContainer: Color(0xff9cd4be),
      secondary: Color(0xff003e32),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff297a66),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003c44),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff007985),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff6c1310),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffb74a40),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f6),
      onSurface: Color(0xff121110),
      onSurfaceVariant: Color(0xff39362c),
      outline: Color(0xff565248),
      outlineVariant: Color(0xff716d61),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff31302f),
      inversePrimary: Color(0xff9ad2bc),
      primaryFixed: Color(0xff427764),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff285e4c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff297a66),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00604e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff007985),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff005e68),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c3),
      surfaceBright: Color(0xfffdf8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f0),
      surfaceContainer: Color(0xffebe7e5),
      surfaceContainerHigh: Color(0xffe0dcd9),
      surfaceContainerHighest: Color(0xffd5d1ce),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00281d),
      surfaceTint: Color(0xff326856),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004030),
      onPrimaryContainer: Color(0xffe0fff0),
      secondary: Color(0xff003328),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff005343),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003238),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00515a),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e0607),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff872720),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2f2c23),
      outlineVariant: Color(0xff4c493f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff31302f),
      inversePrimary: Color(0xff9ad2bc),
      primaryFixed: Color(0xff1a5241),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003a2c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff005343),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff003a2e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff00515a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff00393f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b6),
      surfaceBright: Color(0xfffdf8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ed),
      surfaceContainer: Color(0xffe6e2df),
      surfaceContainerHigh: Color(0xffd7d4d1),
      surfaceContainerHighest: Color(0xffc9c6c3),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff9ad2bc),
      surfaceTint: Color(0xff9ad2bc),
      onPrimary: Color(0xff00382a),
      primaryContainer: Color(0xff004030),
      onPrimaryContainer: Color(0xff75ac97),
      secondary: Color(0xff88d5be),
      onSecondary: Color(0xff00382c),
      secondaryContainer: Color(0xff529e89),
      onSecondaryContainer: Color(0xff00281f),
      tertiary: Color(0xff69d6e6),
      onTertiary: Color(0xff00363d),
      tertiaryContainer: Color(0xff3bafbf),
      onTertiaryContainer: Color(0xff003e45),
      error: Color(0xffffb4ab),
      onError: Color(0xff640c0b),
      errorContainer: Color(0xffff8073),
      onErrorContainer: Color(0xff741814),
      surface: Color(0xff141312),
      onSurface: Color(0xffe6e2df),
      onSurfaceVariant: Color(0xffccc6b9),
      outline: Color(0xff959084),
      outlineVariant: Color(0xff4a473c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2df),
      inversePrimary: Color(0xff326856),
      primaryFixed: Color(0xffb6efd7),
      onPrimaryFixed: Color(0xff002117),
      primaryFixedDim: Color(0xff9ad2bc),
      onPrimaryFixedVariant: Color(0xff17503f),
      secondaryFixed: Color(0xffa4f2d9),
      onSecondaryFixed: Color(0xff002019),
      secondaryFixedDim: Color(0xff88d5be),
      onSecondaryFixedVariant: Color(0xff005141),
      tertiaryFixed: Color(0xff97f0ff),
      onTertiaryFixed: Color(0xff001f24),
      tertiaryFixedDim: Color(0xff69d6e6),
      onTertiaryFixedVariant: Color(0xff004f58),
      surfaceDim: Color(0xff141312),
      surfaceBright: Color(0xff3a3937),
      surfaceContainerLowest: Color(0xff0f0e0d),
      surfaceContainerLow: Color(0xff1c1b1a),
      surfaceContainer: Color(0xff201f1e),
      surfaceContainerHigh: Color(0xff2b2a28),
      surfaceContainerHighest: Color(0xff363533),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb0e8d1),
      surfaceTint: Color(0xff9ad2bc),
      onPrimary: Color(0xff002c20),
      primaryContainer: Color(0xff659b87),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xff9eecd3),
      onSecondary: Color(0xff002c22),
      secondaryContainer: Color(0xff529e89),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff81ecfd),
      onTertiary: Color(0xff002a30),
      tertiaryContainer: Color(0xff3bafbf),
      onTertiaryContainer: Color(0xff00181b),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff8073),
      onErrorContainer: Color(0xff400002),
      surface: Color(0xff141312),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe2dcce),
      outline: Color(0xffb7b1a4),
      outlineVariant: Color(0xff959084),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2df),
      inversePrimary: Color(0xff195140),
      primaryFixed: Color(0xffb6efd7),
      onPrimaryFixed: Color(0xff00150e),
      primaryFixedDim: Color(0xff9ad2bc),
      onPrimaryFixedVariant: Color(0xff003e2f),
      secondaryFixed: Color(0xffa4f2d9),
      onSecondaryFixed: Color(0xff00150f),
      secondaryFixedDim: Color(0xff88d5be),
      onSecondaryFixedVariant: Color(0xff003e32),
      tertiaryFixed: Color(0xff97f0ff),
      onTertiaryFixed: Color(0xff001417),
      tertiaryFixedDim: Color(0xff69d6e6),
      onTertiaryFixedVariant: Color(0xff003c44),
      surfaceDim: Color(0xff141312),
      surfaceBright: Color(0xff464442),
      surfaceContainerLowest: Color(0xff080706),
      surfaceContainerLow: Color(0xff1e1d1c),
      surfaceContainer: Color(0xff292826),
      surfaceContainerHigh: Color(0xff333231),
      surfaceContainerHighest: Color(0xff3f3d3c),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc3fce5),
      surfaceTint: Color(0xff9ad2bc),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff97ceb8),
      onPrimaryContainer: Color(0xff000e09),
      secondary: Color(0xffb4ffe7),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff84d1ba),
      onSecondaryContainer: Color(0xff000e0a),
      tertiary: Color(0xffcdf7ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff65d2e2),
      onTertiaryContainer: Color(0xff000e10),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141312),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff6efe1),
      outlineVariant: Color(0xffc8c2b5),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2df),
      inversePrimary: Color(0xff195140),
      primaryFixed: Color(0xffb6efd7),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff9ad2bc),
      onPrimaryFixedVariant: Color(0xff00150e),
      secondaryFixed: Color(0xffa4f2d9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff88d5be),
      onSecondaryFixedVariant: Color(0xff00150f),
      tertiaryFixed: Color(0xff97f0ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff69d6e6),
      onTertiaryFixedVariant: Color(0xff001417),
      surfaceDim: Color(0xff141312),
      surfaceBright: Color(0xff51504e),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1e),
      surfaceContainer: Color(0xff31302f),
      surfaceContainerHigh: Color(0xff3c3b3a),
      surfaceContainerHighest: Color(0xff484645),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

  /// Success
  static const success = ExtendedColor(
    seed: Color(0xff5ab967),
    value: Color(0xff5ab967),
    light: ColorFamily(
      color: Color(0xff006e28),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff5ab967),
      onColorContainer: Color(0xff004617),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff006e28),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff5ab967),
      onColorContainer: Color(0xff004617),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff006e28),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff5ab967),
      onColorContainer: Color(0xff004617),
    ),
    dark: ColorFamily(
      color: Color(0xff7bdb85),
      onColor: Color(0xff003911),
      colorContainer: Color(0xff5ab967),
      onColorContainer: Color(0xff004617),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff7bdb85),
      onColor: Color(0xff003911),
      colorContainer: Color(0xff5ab967),
      onColorContainer: Color(0xff004617),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff7bdb85),
      onColor: Color(0xff003911),
      colorContainer: Color(0xff5ab967),
      onColorContainer: Color(0xff004617),
    ),
  );

  /// Info
  static const info = ExtendedColor(
    seed: Color(0xff00b4df),
    value: Color(0xff00b4df),
    light: ColorFamily(
      color: Color(0xff006781),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00b4df),
      onColorContainer: Color(0xff004153),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff006781),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00b4df),
      onColorContainer: Color(0xff004153),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff006781),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00b4df),
      onColorContainer: Color(0xff004153),
    ),
    dark: ColorFamily(
      color: Color(0xff57d5ff),
      onColor: Color(0xff003544),
      colorContainer: Color(0xff00b4df),
      onColorContainer: Color(0xff004153),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff57d5ff),
      onColor: Color(0xff003544),
      colorContainer: Color(0xff00b4df),
      onColorContainer: Color(0xff004153),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff57d5ff),
      onColor: Color(0xff003544),
      colorContainer: Color(0xff00b4df),
      onColorContainer: Color(0xff004153),
    ),
  );

  List<ExtendedColor> get extendedColors => [success, info];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
