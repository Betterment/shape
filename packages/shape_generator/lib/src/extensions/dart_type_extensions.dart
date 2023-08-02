import 'package:analyzer/dart/element/type.dart';

/// Extensions on [DartType] for convenience.
extension DartTypeExtensions on DartType {
  /// The non-nullable display string of this type.
  ///
  /// ```dart
  /// DartType(String).nonNullableDisplayString; // "String"
  /// DartType(String?).nonNullableDisplayString; // "String"
  /// ```
  String get nonNullableDisplayString =>
      getDisplayString(withNullability: false);

  /// The potentially nullable display string of this type.
  ///
  /// If this type is nullable, the returned display string will be "T?", and
  /// "T" otherwise.
  ///
  /// ```dart
  /// DartType(String).potentiallyNullableDisplayString; // "String"
  /// DartType(String?).potentiallyNullableDisplayString; // "String"
  /// ```
  String get potentiallyNullableDisplayString {
    return getDisplayString(withNullability: true);
  }
}
