import 'package:app_links_x/component.dart';

/// Processes all deep-links used to open DAS app.
///
/// see: [DAS deep-link documentation](https://github.com/SchweizerischeBundesbahnen/DAS/blob/main/docs/content/architecture/05_building_block_view/05_02_Interfaces/deep_link_client.md)
abstract interface class AppLinksManager {
  const AppLinksManager._();

  Stream<AppLinkIntent> get onAppLinkIntent;

  void dispose();
}
