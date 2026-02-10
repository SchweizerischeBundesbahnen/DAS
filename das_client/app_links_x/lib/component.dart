import 'package:app_links_x/src/app_links_manager.dart';
import 'package:app_links_x/src/app_links_manager_impl.dart';

export 'package:app_links_x/src/app_links_manager.dart';
export 'package:app_links_x/src/train_journey/train_journey_link_data.dart';

class AppLinksComponent {
  const AppLinksComponent._();

  static AppLinksManager appLinksManager() {
    return AppLinksManagerImpl();
  }
}
