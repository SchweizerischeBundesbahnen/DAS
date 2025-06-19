export 'authenticated_scope.dart';
export 'das_base_scope.dart';
export 'di_scope.dart';
export 'sfera_mock_scope.dart';
export 'tms_scope.dart';

// === Scope Stack ===
//
// ----------------------
// | JourneyScope       |
// ----------------------
//
// ----------------------
// | AuthenticatedScope |
// ----------------------
//
// -----------------------    ---------------------
// | SferaMockScope      | OR | TmsScope          |
// -----------------------    ---------------------
//
// -----------------------
// | DASBaseScope        |
// -----------------------
//
// -------------------------
// | GetIt's baseScope     |
// | --------------------- |
// | - "Empty" Flavor      |
// | - ScopeHandler        |
// | - All scope instances |
// -------------------------
