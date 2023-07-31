import 'package:forms_generator/src/models/models.dart';

extension StringExtensions on String {
  /// Appends the provided [suffix] to the string if it is not already present.
  String appendIfNotPresent(String suffix) {
    if (endsWith(suffix)) {
      return this;
    } else {
      return '$this$suffix';
    }
  }

  /// Returns this string with a question mark appended ("T?") if running in a
  /// null-safe context, or "T" with any question marks removed otherwise.
  String get nullableTypeString {
    final isNullSafe = GeneratorContext.instance.isNullSafetyEnabled;

    if (!isNullSafe) {
      final questionMarkIndex = indexOf('?');
      if (questionMarkIndex != -1) {
        return substring(0, questionMarkIndex);
      } else {
        return this;
      }
    } else {
      return appendIfNotPresent('?');
    }
  }
}
