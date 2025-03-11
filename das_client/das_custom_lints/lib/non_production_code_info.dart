import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
// ignore: undefined_hidden_name, necessary to support lower analyzer versions

class NonProductionCodeInfo extends DartLintRule {
  const NonProductionCodeInfo() : super(code: _code);

  // Lint rule metadata
  static const _code = LintCode(
    name: 'non_production_code_info',
    problemMessage: 'Code should be removed or be prevented from use on production.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Iterate through all compilation units (files)
    context.registry.addCompilationUnit((CompilationUnit unit) {
      // Visit all declarations (classes, methods, etc.)
      for (final declaration in unit.declarations) {
        _checkForNonProductionAnnotation(declaration, reporter);
      }
    });
  }

  void _checkForNonProductionAnnotation(Declaration declaration, ErrorReporter reporter) {
    for (final annotation in declaration.metadata) {
      final element = annotation.elementAnnotation?.element;
      if (element != null) {
        if (element is ConstructorElement && element.enclosingElement3.name == 'NonProduction') {
          reporter.atNode(declaration, _code);
        }
      }
    }
  }

  @override
  List<Fix> getFixes() => [];
}
