import 'package:preload/component.dart';

class PreloadViewModel {
  PreloadViewModel({required PreloadRepository preloadRepository}) : _preloadRepository = preloadRepository;

  final PreloadRepository _preloadRepository;

  Stream<PreloadDetails> get preloadDetails => _preloadRepository.preloadDetails;

  void triggerPreload() {
    _preloadRepository.triggerPreload();
  }
}
