import 'package:preload/component.dart';

class PreloadViewModel {
  PreloadViewModel({required PreloadRepository preloadRepository}) : _preloadRepository = preloadRepository;

  final PreloadRepository _preloadRepository;

  Stream<PreloadDetails> get preloadDetailsStream => _preloadRepository.preloadDetailsStream;

  void triggerPreload() {
    _preloadRepository.triggerPreload();
  }
}
