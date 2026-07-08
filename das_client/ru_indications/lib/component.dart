import 'package:http_x/component.dart';
import 'package:ru_indications/src/api/ru_indications_api_service_impl.dart';
import 'package:ru_indications/src/repository/ru_indications_repository.dart';
import 'package:ru_indications/src/repository/ru_indications_repository_impl.dart';

export 'package:ru_indications/src/model/ru_indication.dart';
export 'package:ru_indications/src/repository/ru_indications_repository.dart';

class RuIndicationsComponent {
  const RuIndicationsComponent._();

  static RuIndicationsRepository createRepository({
    required String baseUrl,
    required Client client,
  }) {
    return RuIndicationsRepositoryImpl(
      apiService: RuIndicationsApiServiceImpl(baseUrl: baseUrl, httpClient: client),
    );
  }
}
