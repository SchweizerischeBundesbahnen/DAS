import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:das_custom_lints/dont_use_src_folder_imports.dart';
import 'package:das_custom_lints/non_production_code_info.dart';

PluginBase createPlugin() => _DasCustomLints();

/// The class listing all the [LintRule]s and [Assist]s defined by DAS
class _DasCustomLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        DontUseSrcFolderImports(),
        NonProductionCodeInfo(),
      ];

  @override
  List<Assist> getAssists() => [];
}
