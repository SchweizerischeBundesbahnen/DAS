import 'package:preload/component.dart';

class PreloadViewModel({required final PreloadRepository _preloadRepository}) {
  Stream<PreloadDetails> get preloadDetails => _preloadRepository.preloadDetails;

  void triggerPreload() => _preloadRepository.triggerPreload();
}
