import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'reader_preferences.g.dart';

class _ColorConverter {
  static Color fromJson(Color defaultValue, int json) {
    return json == null ? defaultValue : Color(json);
  }

  static int toJson(Color object) {
    return object?.value;
  }
}

class _FontWeightConverter {
  static FontWeight fromJson(FontWeight defaultValue, int json) {
    return json == null ? defaultValue : FontWeight.values[json];
  }

  static int toJson(FontWeight object) {
    return object?.index;
  }
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
  @JsonKey(defaultValue: PageTurningType.COVERAGE, name: 'pageTurning')
  PageTurningType pageTurning;

  static Color _backgroundFromJson(int v) => _ColorConverter.fromJson(Color.fromRGBO(213, 239, 210, 1), v);

  @JsonKey(
    name: 'background',
    nullable: false,
    fromJson: _backgroundFromJson,
    toJson: _ColorConverter.toJson,
  )
  Color background;

  static Color _fontColorFromJson(int v) => _ColorConverter.fromJson(Colors.black87, v);

  @JsonKey(
    name: 'fontColor',
    nullable: false,
    fromJson: _fontColorFromJson,
    toJson: _ColorConverter.toJson,
  )
  Color fontColor;

  @JsonKey(defaultValue: 18, name: 'fontSize')
  double fontSize;

  static FontWeight _fontWeightFromJson(int v) => _FontWeightConverter.fromJson(FontWeight.normal, v);

  @JsonKey(
    name: 'fontWeight',
    nullable: false,
    fromJson: _fontWeightFromJson,
    toJson: _FontWeightConverter.toJson,
  )
  FontWeight fontWeight;

  @JsonKey(defaultValue: 1.3, name: 'height')
  double height;

  @JsonKey(defaultValue: 1, name: 'paragraphHeight')
  double paragraphHeight;

  @JsonKey(defaultValue: true, name: 'fullScreen')
  bool fullScreen;

  @JsonKey(defaultValue: false, name: 'nightMode')
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
