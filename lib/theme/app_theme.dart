import 'package:material_ui/material_ui.dart';

abstract final class ConsoleColors {
  static const ink = Color(0xff10233b);
  static const muted = Color(0xff465a70);
  static const canvas = Color(0xfff5f7fa);
  static const surface = Colors.white;
  static const line = Color(0xffdce4ee);
  static const navy = Color(0xff10233b);
  static const navText = Color(0xffbdcde0);
  static const blue = Color(0xff224d94);
  static const blueSoft = Color(0xffeaf2ff);
  static const red = Color(0xffa32632);
  static const redSoft = Color(0xfffdeef0);
  static const orange = Color(0xff845000);
  static const orangeSoft = Color(0xfffff3dc);
  static const grey = Color(0xff465468);
  static const greySoft = Color(0xffedf1f5);
  static const green = Color(0xff21614f);
  static const greenSoft = Color(0xffe8f5ef);
}

final appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: ConsoleColors.canvas,
  colorScheme: ColorScheme.fromSeed(seedColor: ConsoleColors.blue).copyWith(
    primary: ConsoleColors.blue,
    onPrimary: ConsoleColors.surface,
    surface: ConsoleColors.surface,
    onSurface: ConsoleColors.ink,
    onSurfaceVariant: ConsoleColors.muted,
    outline: ConsoleColors.line,
  ),
  dividerColor: ConsoleColors.line,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ConsoleColors.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: ConsoleColors.line),
    ),
    isDense: true,
  ),
);

BoxDecoration panelDecoration({Color color = ConsoleColors.surface}) =>
    BoxDecoration(
      color: color,
      border: Border.all(color: ConsoleColors.line),
      borderRadius: BorderRadius.circular(12),
    );
