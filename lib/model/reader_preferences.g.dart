// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReaderPreferences _$ReaderPreferencesFromJson(Map<String, dynamic> json) {
  return ReaderPreferences(
      pageTurning:
          _$enumDecodeNullable(_$PageTurningTypeEnumMap, json['pageTurning']),
      background: json['background'] == null
          ? null
          : const _ColorConverter().fromJson(json['background'] as int),
      fontColor: json['fontColor'] == null
          ? null
          : const _ColorConverter().fromJson(json['fontColor'] as int),
      fontSize: (json['fontSize'] as num)?.toDouble(),
      fontWeight: json['fontWeight'] == null
          ? null
          : const _FontWeightConverter().fromJson(json['fontWeight'] as int),
      height: (json['height'] as num)?.toDouble(),
      paragraphHeight: (json['paragraphHeight'] as num)?.toDouble(),
      fullScreen: json['fullScreen'] as bool,
      nightMode: json['nightMode'] as bool);
}

Map<String, dynamic> _$ReaderPreferencesToJson(ReaderPreferences instance) =>
    <String, dynamic>{
      'pageTurning': _$PageTurningTypeEnumMap[instance.pageTurning],
      'background': instance.background == null
          ? null
          : const _ColorConverter().toJson(instance.background),
      'fontColor': instance.fontColor == null
          ? null
          : const _ColorConverter().toJson(instance.fontColor),
      'fontSize': instance.fontSize,
      'fontWeight': instance.fontWeight == null
          ? null
          : const _FontWeightConverter().toJson(instance.fontWeight),
      'height': instance.height,
      'paragraphHeight': instance.paragraphHeight,
      'fullScreen': instance.fullScreen,
      'nightMode': instance.nightMode
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$PageTurningTypeEnumMap = <PageTurningType, dynamic>{
  PageTurningType.COVERAGE: 'COVERAGE',
  PageTurningType.TRANSLATION: 'TRANSLATION',
  PageTurningType.SIMULATION: 'SIMULATION',
  PageTurningType.ROLL: 'ROLL',
  PageTurningType.NONE: 'NONE'
};
