import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:das_custom_lints/dont_use_src_folder_imports.dart';

// Entrypoint of plugin
PluginBase createPlugin() => _DasCustomLints();

// The class listing all the [LintRule]s and [Assist]s defined by our plugin
class _DasCustomLints extends PluginBase {
  // Lint rules
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [DontUseSrcFolderImports()];

  // Assists
  @override
  List<Assist> getAssists() => [];
}
