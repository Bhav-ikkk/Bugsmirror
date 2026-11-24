import 'package:material_ui/material_ui.dart';

abstract final class TripwireColors {
  static const canvas = Color(0xfff3f0ea);
  static const surface = Colors.white;
  static const tint = Color(0xfff7f5f0);
  static const track = Color(0xffedeae2);
  static const ink = Color(0xff141414);
  static const secondary = Color(0xff666259);
  static const muted = Color(0xff746f65);
  static const border = Color(0xffe5e1d8);
  static const row = Color(0xffefece5);
  static const darkRule = Color(0xff34312d);
  static const darkMuted = Color(0xffbdb7ac);
  static const high = Color(0xffe1261c);
  static const highInk = Color(0xffb91c1b);
  static const highSoft = Color(0xfffceceb);
  static const medium = Color(0xfff47b16);
  static const mediumInk = Color(0xff9a4004);
  static const mediumSoft = Color(0xfffef3e6);
  static const low = Color(0xff8a857b);
  static const lowInk = Color(0xff57534e);
  static const lowSoft = Color(0xfff1efea);
  static const green = Color(0xff15803d);
  static const greenSoft = Color(0xfff0fdf4);
  static const greenBorder = Color(0xffbbf7d0);
  static const syntaxString = Color(0xfff8c998);
  static const syntaxNumber = Color(0xffc9d9cb);
}

@immutable
class TripwireTheme extends ThemeExtension<TripwireTheme> {
  const TripwireTheme({this.panelRadius = 14, this.controlRadius = 8});
  final double panelRadius;
  final double controlRadius;

  @override
  TripwireTheme copyWith({double? panelRadius, double? controlRadius}) =>
      TripwireTheme(
        panelRadius: panelRadius ?? this.panelRadius,
        controlRadius: controlRadius ?? this.controlRadius,
      );

  @override
  TripwireTheme lerp(covariant TripwireTheme? other, double t) => other == null
      ? this
      : TripwireTheme(
          panelRadius: panelRadius + (other.panelRadius - panelRadius) * t,
          controlRadius:
              controlRadius + (other.controlRadius - controlRadius) * t,
        );
}

const tripwire = TripwireTheme();
const contentWidth = 1180.0;

TextStyle mono({
  double size = 11,
  Color color = TripwireColors.secondary,
  double spacing = 0,
  FontWeight weight = FontWeight.w400,
}) => TextStyle(
  fontFamily: 'IBM Plex Mono',
  fontFamilyFallback: const ['monospace'],
  fontSize: size,
  color: color,
  letterSpacing: spacing,
  fontWeight: weight,
);

TextStyle pageTitle(double width) => TextStyle(
  fontSize: width < 600 ? 31 : 42,
  height: 1.08,
  fontWeight: FontWeight.w600,
  letterSpacing: -1.6,
);

ButtonStyle control({bool filled = false}) => ButtonStyle(
  minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
  padding: const WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: 16, vertical: 11),
  ),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tripwire.controlRadius),
    ),
  ),
  side: filled
      ? null
      : const WidgetStatePropertyAll(BorderSide(color: TripwireColors.border)),
  backgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return TripwireColors.track;
    return filled ? TripwireColors.ink : TripwireColors.surface;
  }),
);

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Space Grotesk',
  fontFamilyFallback: const ['Segoe UI', 'Arial'],
  scaffoldBackgroundColor: TripwireColors.canvas,
  colorScheme: ColorScheme.fromSeed(seedColor: TripwireColors.ink).copyWith(
    primary: TripwireColors.ink,
    onPrimary: TripwireColors.surface,
    surface: TripwireColors.surface,
    onSurface: TripwireColors.ink,
    onSurfaceVariant: TripwireColors.secondary,
    outline: TripwireColors.border,
    outlineVariant: TripwireColors.row,
  ),
  extensions: const [tripwire],
  dividerColor: TripwireColors.row,
  dividerTheme: const DividerThemeData(color: TripwireColors.row, thickness: 1),
  filledButtonTheme: FilledButtonThemeData(style: control(filled: true)),
  outlinedButtonTheme: OutlinedButtonThemeData(style: control()),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: TripwireColors.surface,
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tripwire.controlRadius),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tripwire.controlRadius),
      borderSide: const BorderSide(color: TripwireColors.border),
    ),
  ),
);

BoxDecoration panelDecoration({Color color = TripwireColors.surface}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(tripwire.panelRadius),
      border: Border.all(
        color: color == TripwireColors.ink
            ? TripwireColors.ink
            : TripwireColors.border,
      ),
    );
