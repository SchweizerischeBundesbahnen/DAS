import 'dart:io';

abstract class const ConnectionCheckService._() {
  Future<bool> hasInternetConnection();
}

class const ConnectionCheckServiceImpl() implements ConnectionCheckService {
  static const lookupHost = 'google.com';

  @override
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(lookupHost);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
