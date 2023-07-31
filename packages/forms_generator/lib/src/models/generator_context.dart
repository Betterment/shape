/// A model containing information about the current context of the
/// forms generator.
class GeneratorContext {
  const GeneratorContext({
    this.isNullSafetyEnabled = true,
  });

  /// The singleton instance of the generator context.
  static GeneratorContext instance = const GeneratorContext();

  /// Indicates if the generator is running in a null-safe context.
  final bool isNullSafetyEnabled;
}
