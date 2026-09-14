import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';

class NoOpModalViewModel() extends ModalViewModel {
  @override
  void close() {}

  @override
  Stream<DASModalSheetBuilder?> get contentBuilder => Stream.empty(broadcast: true);

  @override
  void dispose() {}

  @override
  Stream<bool> get isModalOpen => Stream.value(false).asBroadcastStream();

  @override
  bool get isModalOpenValue => false;

  @override
  void open(DASModalSheetBuilder builder, {bool maximize = false, Object? contentKey}) {}

  @override
  Stream<DetailModalType?> get openModalType => Stream.empty(broadcast: true);

  @override
  DetailModalType? get openModalTypeValue => null;

  @override
  void setMaximized(bool maximized) {}

  @override
  DASModalSheetController? get controller => null;
}
