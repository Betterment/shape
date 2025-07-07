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

  /// Removes the provided [suffix] from the string if it is present.
  String removeIfPresent(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    }
    return this;
  }
}
