/// Marks code as non production with default message
const NonProduction nonProduction = NonProduction('Code should not be used in production');

/// Annotation used mark code that should not be used for production.
class NonProduction {
  const NonProduction(this.message);

  final String message;

  @override
  String toString() => 'NonProduction: $message';
}
