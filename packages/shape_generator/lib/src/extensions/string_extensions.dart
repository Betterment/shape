/// Extensions on [String] for convenience.
extension StringExtensions on String {
  /// Appends the provided [suffix] to the string if it is not already present.
  String appendIfNotPresent(String suffix) {
    if (endsWith(suffix)) {
      return this;
    } else {
      return '$this$suffix';
    }
  }

  /// Returns this string with a question mark appended ("T?").
  String get nullableTypeString => appendIfNotPresent('?');
}
