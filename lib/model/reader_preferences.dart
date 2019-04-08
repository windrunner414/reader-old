import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'reader_preferences.g.dart';

class _ColorConverter implements JsonConverter<Color, int> {
  const _ColorConverter();

  Color fromJson(int json) => Color(json);

  int toJson(Color object) => object.value;
}

class _FontWeightConverter implements JsonConverter<FontWeight, int> {
  const _FontWeightConverter();

  FontWeight fromJson(int json) => FontWeight.values[json];

  int toJson(FontWeight object) => object.index;
}

enum PageTurningType {
  COVERAGE,
  TRANSLATION,
  SIMULATION,
  ROLL,
  NONE,
}

@JsonSerializable()
class ReaderPreferences {
  @JsonKey(name: 'pageTurning')
  PageTurningType pageTurning;

  @JsonKey(name: 'background')
  @_ColorConverter()
  Color background;

  @JsonKey(name: 'fontColor')
  @_ColorConverter()
  Color fontColor;

  @JsonKey(name: 'fontSize')
  double fontSize;

  @JsonKey(name: 'fontWeight')
  @_FontWeightConverter()
  FontWeight fontWeight;

  @JsonKey(name: 'height')
  double height;

  @JsonKey(name: 'paragraphHeight')
  double paragraphHeight;

  @JsonKey(name: 'fullScreen')
  bool fullScreen;

  @JsonKey(name: 'nightMode')
  bool nightMode;

  @JsonKey(ignore: true)
  Color get realBackground => nightMode ? Color.fromRGBO(34, 34, 34, 1) : background;

  @JsonKey(ignore: true)
  Color get realFontColor => nightMode ? Color.fromRGBO(124, 124, 124, 1) : fontColor;

  @JsonKey(ignore: true)
  Color get menuFontColor => Color.fromRGBO(51, 153, 255, 1);

  @JsonKey(ignore: true)
  Color get menuBackground => nightMode ? Color.fromRGBO(22, 22, 22, 1) : Colors.white;

  ReaderPreferences({
    this.pageTurning,
    this.background,
    this.fontColor,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.paragraphHeight,
    this.fullScreen,
    this.nightMode,
  });

  factory ReaderPreferences.fromJson(Map<String, dynamic> srcJson) => _$ReaderPreferencesFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ReaderPreferencesToJson(this);
}
