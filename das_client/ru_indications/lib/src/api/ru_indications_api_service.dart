import 'package:ru_indications/src/api/matches/matches_request.dart';

abstract class RuIndicationsApiService {
  /// Returns matching ru indication for the given company, train number, start date and locations.
  MatchesRequest get matches;
}
