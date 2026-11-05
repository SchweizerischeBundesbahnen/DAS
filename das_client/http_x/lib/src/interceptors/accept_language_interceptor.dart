import 'dart:async';
import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:logging/logging.dart';

final _log = Logger('AcceptLanguageInterceptor');

String _platformLocaleName() => Platform.localeName;

class const AcceptLanguageInterceptor({final String Function() localeName = _platformLocaleName})
    implements HttpInterceptor {
  @override
  FutureOr<bool> shouldInterceptRequest({required BaseRequest request}) async => true;

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      final deviceLocale = localeName();
      final languageTag = _toLanguageTag(deviceLocale);
      if (languageTag == null) {
        _log.warning('Skip accept-language header for unsupported device locale "$deviceLocale"');
      } else {
        request.headers['Accept-Language'] = languageTag;
      }
    } catch (e, s) {
      _log.severe('Set accept-language header failed', e, s);
    }
    return request;
  }

  @override
  FutureOr<bool> shouldInterceptResponse({required BaseResponse response}) async => false;

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) async => response;

  /// Converts a POSIX/ICU locale name (e.g. `de_CH.UTF-8`) to a BCP 47 language tag (e.g. `de-CH`).
  /// Returns null for locales without a language (empty, `C`, `POSIX`).
  static String? _toLanguageTag(String localeName) {
    final withoutCodesetAndModifier = localeName.split(RegExp('[.@]')).first;
    if (withoutCodesetAndModifier.isEmpty || withoutCodesetAndModifier == 'C' || withoutCodesetAndModifier == 'POSIX') {
      return null;
    }
    return withoutCodesetAndModifier.replaceAll('_', '-');
  }
}
