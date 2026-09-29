import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: LightColors.primary,
  scaffoldBackgroundColor: LightColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: LightColors.secondary,
    titleTextStyle: TextStyle(
      color: LightColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: LightColors.textPrimary),
  ),
  buttonTheme: ButtonThemeData(buttonColor: LightColors.primary),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: white,
      backgroundColor: LightColors.primary,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: LightColors.textPrimary),
    bodyMedium: TextStyle(color: LightColors.textSecondary),
  ),
  cardColor: LightColors.surface,
  colorScheme: ColorScheme.light(
    primary: LightColors.primary,
    secondary: LightColors.secondary,
    surface: LightColors.surface,
    onPrimary: white,
    onSecondary: white,
    onSurface: LightColors.textPrimary,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: DarkColors.primary,
  scaffoldBackgroundColor: DarkColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: DarkColors.surface,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: DarkColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: DarkColors.textPrimary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: white,
      backgroundColor: DarkColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DarkColors.primary,
      side: BorderSide(color: DarkColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: DarkColors.primary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DarkColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: DarkColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: DarkColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: DarkColors.primary, width: 2),
    ),
    hintStyle: TextStyle(color: DarkColors.textSecondary),
    labelStyle: TextStyle(color: DarkColors.textSecondary),
  ),
  cardTheme: CardThemeData(
    color: DarkColors.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
      side: BorderSide(color: DarkColors.border, width: 1),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: DarkColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  ),
  dividerTheme: DividerThemeData(color: DarkColors.border, thickness: 1),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: DarkColors.surface,
    contentTextStyle: TextStyle(color: DarkColors.textPrimary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    behavior: SnackBarBehavior.floating,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((
      final Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return DarkColors.primary;
      }
      return DarkColors.border;
    }),
    checkColor: WidgetStateProperty.all(white),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: DarkColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: DarkColors.textPrimary),
    displayMedium: TextStyle(color: DarkColors.textPrimary),
    displaySmall: TextStyle(color: DarkColors.textPrimary),
    headlineLarge: TextStyle(color: DarkColors.textPrimary),
    headlineMedium: TextStyle(color: DarkColors.textPrimary),
    headlineSmall: TextStyle(color: DarkColors.textPrimary),
    titleLarge: TextStyle(color: DarkColors.textPrimary),
    titleMedium: TextStyle(color: DarkColors.textPrimary),
    titleSmall: TextStyle(color: DarkColors.textPrimary),
    bodyLarge: TextStyle(color: DarkColors.textPrimary),
    bodyMedium: TextStyle(color: DarkColors.textSecondary),
    bodySmall: TextStyle(color: DarkColors.textSecondary),
    labelLarge: TextStyle(color: DarkColors.textPrimary),
    labelMedium: TextStyle(color: DarkColors.textSecondary),
    labelSmall: TextStyle(color: DarkColors.textSecondary),
  ),
  cardColor: DarkColors.surface,
  colorScheme: ColorScheme.dark(
    primary: DarkColors.primary,
    secondary: DarkColors.secondary,
    surface: DarkColors.surface,
    onPrimary: white,
    onSecondary: white,
    onSurface: DarkColors.textPrimary,
    error: errorColor,
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
);
