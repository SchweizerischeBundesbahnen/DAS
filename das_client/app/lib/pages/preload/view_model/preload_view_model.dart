import 'package:preload/component.dart';

class PreloadViewModel {
  PreloadViewModel({required this._preloadRepository});

  final PreloadRepository _preloadRepository;

  Stream<PreloadDetails> get preloadDetails => _preloadRepository.preloadDetails;

  void triggerPreload() => _preloadRepository.triggerPreload();
}
