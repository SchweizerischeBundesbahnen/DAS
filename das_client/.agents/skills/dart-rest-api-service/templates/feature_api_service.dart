import 'package:<feature>/src/api/<action>/<action>_request.dart';

abstract class FeatureApiService {
  /// Example: a request accessible as a getter that returns a callable request object.
  ActionRequest get action;

  /// Add more request getters here, one per API endpoint/action.
  // ActionRequest get anotherAction;
}

