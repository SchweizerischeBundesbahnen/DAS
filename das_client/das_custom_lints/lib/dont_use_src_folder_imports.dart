import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/error/error.dart'
    hide
        // ignore: undefined_hidden_name, necessary to support lower analyzer versions
        LintCode;

// Lint rule to use src folder imports
class DontUseSrcFolderImports extends DartLintRule {
  const DontUseSrcFolderImports() : super(code: _code);

  // Lint rule metadata
  static const _code = LintCode(
    name: 'dont_use_src_folder_imports',
    problemMessage: 'Don\'t use source folder imports',
    errorSeverity: ErrorSeverity.ERROR,
  );

  // `run` is where you analyze a file and report lint errors
  // Invoked on a file automatically on every file edit
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // A call back fn that runs on all import declarations in a file
    context.registry.addImportDirective((importDirective) {
      var importUri = importDirective.uri.stringValue;

      if (importUri == null || !importUri.contains('/src/')) return;

      var filePath = importDirective.element!.source.fullName;
      // ignore imports from outside the lib folder (mainly tests)
      if (!filePath.contains('/lib/')) return;

      importUri = importUri.substring(importUri.indexOf('/') + 1);
      filePath = filePath.substring(filePath.indexOf('/lib/') + 5);

      final importParts = importUri.split('/src/');
      final fileParts = filePath.split('/src/');

      // allow it if its part of the same package
      if (fileParts[0].startsWith(importParts[0])) return;

      // report a lint error with the `code` and the respective import directive
      reporter.atNode(
          importDirective,
          LintCode(
            name: _code.name,
            problemMessage: 'Don\'t use source folder imports for importing ${importDirective.uri.stringValue}',
            errorSeverity: ErrorSeverity.ERROR,
          ));
    });
  }

  // Possible fixes for the lint error go here
  @override
  List<Fix> getFixes() => [];
}
