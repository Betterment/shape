import 'package:analyzer/dart/element/type.dart';
import 'package:forms_generator/src/models/models.dart';

extension DartTypeExtensions on DartType {
  /// The non-nullable display string of this type.
  ///
  /// ```dart
  /// DartType(String).nonNullableDisplayString; // "String"
  /// DartType(String?).nonNullableDisplayString; // "String"
  /// ```
  String get nonNullableDisplayString =>
      getDisplayString(withNullability: false);

  /// The potentially nullable display string of this type, if run in a
  /// null-safe context.
  ///
  /// If this type is nullable and the context is null-safe, the returned
  /// display string will be "T?". If the type is not nullable or the context
  /// is not null-safe, the returned display string will be "T".
  ///
  /// ```dart
  /// // In a null-safe context.
  /// DartType(String).nullableDisplayString; // "String"
  /// DartType(String?).nullableDisplayString; // "String?"
  ///
  /// // In a non-null-safe context.
  /// DartType(String).nullableDisplayString; // "String"
  /// DartType(String?).nullableDisplayString; // "String"
  /// ```
  String get potentiallyNullableDisplayString {
    if (!GeneratorContext.instance.isNullSafetyEnabled) {
      return getDisplayString(withNullability: false);
    } else {
      return getDisplayString(withNullability: true);
    }
  }
}
