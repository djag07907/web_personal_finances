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
  buttonTheme: ButtonThemeData(
    buttonColor: LightColors.primary,
  ),
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
  primaryColor: DarkColors.primary,
  scaffoldBackgroundColor: DarkColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: DarkColors.surface,
    titleTextStyle: TextStyle(
      color: DarkColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: DarkColors.textPrimary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: black,
      backgroundColor: DarkColors.primary,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: DarkColors.textPrimary),
    bodyMedium: TextStyle(color: DarkColors.textSecondary),
  ),
  cardColor: DarkColors.surface,
  colorScheme: ColorScheme.dark(
    primary: DarkColors.primary,
    surface: DarkColors.surface,
    onPrimary: black,
    onSurface: DarkColors.textPrimary,
  ),
);
