import 'dart:async';

import 'package:app/nav/app_expiration_guard.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:app_links_x/component.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';
import 'package:train_identification/component.dart';

final _log = Logger('JourneySelectionViewModel');

class JourneySelectionViewModel({
  required final SferaRepository _sferaRepo,
  required final SettingsRepository _settingsRepository,
  required final Future<void> Function(ExtendedTrainIdentification?) _onJourneySelected,
  required final TrainIdentificationRepository _trainIdentificationRepository,
  required final LocalKeyValueStore _userSettings,
}) {
  this {
    _emitSelectingWithDefaults();
    _initSferaRepoSubscription();
  }

  StreamSubscription? _sferaRepoSubscription;
  TrainJourneyLinkData? _pendingDeepLinkData;
  Timer? _delayTimer;

  late JourneySelectionModel _currentState;
  final _rxModel = BehaviorSubject<JourneySelectionModel>();

  Stream<JourneySelectionModel> get model => _rxModel.stream;

  JourneySelectionModel get modelValue => _currentState;

  void handleDeepLink(TrainJourneyLinkData linkData) {
    _pendingDeepLinkData = linkData;
    final model = Selecting(
      startDate: linkData.startDate ?? DateTime.now(),
      availableStartDates: _availableStartDates(),
      trainNumber: linkData.operationalTrainNumber,
      isInputComplete: true,
    );
    _emit(model.copyWith(isInputComplete: _validateInput(model)));
    loadJourney();
  }

  Future<bool> loadJourney() async {
    final currentState = _currentState;
    switch (currentState) {
      case Loading() || LoadingCompanyMatches() || Loaded() || Error():
        break;
      case final Selecting state:
        if (!state.isInputComplete) return false;

        if (state.companyCode != null) {
          final trainIdToLoad = _trainIdFrom(state);
          return _loadTrain(trainIdToLoad);
        } else {
          return _findCompanyMatches(state);
        }
      case final SelectingCompanyMatch state:
        if (!state.isInputComplete) return false;

        final trainIdToLoad = TrainIdentification(
          companyCode: state.selectedCompanyMatch!.companyCode,
          trainNumber: state.operationalTrainNumber,
          date: state.selectedCompanyMatch!.startDate,
        );
        return _loadTrain(trainIdToLoad);
    }

    return true;
  }

  Future<bool> _findCompanyMatches(Selecting state) async {
    _emit(
      JourneySelectionModel.loadingCompanyMatches(
        startDate: state.startDate,
        trainNumber: state.operationalTrainNumber,
      ),
    );

    final companyMatches = await _trainIdentificationRepository.findTrainIdentifications(
      operationalTrainNumber: state.operationalTrainNumber,
    );

    final exactDayMatches = companyMatches.where((it) => DateUtils.isSameDay(it.startDate, state.startDate)).toList();
    if (exactDayMatches.length == 1) {
      final match = exactDayMatches.first;
      _log.info('Found exactly one company match: $match');
      return _loadTrain(
        TrainIdentification(
          companyCode: match.companyCode,
          trainNumber: state.operationalTrainNumber,
          date: state.startDate,
        ),
      );
    }

    final lastUsedCompanyCode = _userSettings.lastUsedCompanyCode;
    final lastUsedCompanyMatch = exactDayMatches.firstWhereOrNull((it) => it.companyCode == lastUsedCompanyCode);
    if (lastUsedCompanyMatch != null) {
      _log.info('Found company match with last used company code: $lastUsedCompanyMatch');
      return _loadTrain(
        TrainIdentification(
          companyCode: lastUsedCompanyMatch.companyCode,
          trainNumber: state.operationalTrainNumber,
          date: state.startDate,
        ),
      );
    }

    _emit(
      JourneySelectionModel.selectingCompanyMatch(
        startDate: state.startDate,
        trainNumber: state.operationalTrainNumber,
        availableStartDates: state.availableStartDates,
        companyMatches: exactDayMatches.isNotEmpty ? exactDayMatches.toSet() : companyMatches.toSet(),
        selectedCompanyMatch: null,
        isInputComplete: false,
      ),
    );

    if (_sferaRepo.connectedTrain != null) {
      // Disconnect with a delay (to give time for navigation) from the current train
      _delayTimer?.cancel();
      _delayTimer = Timer(AppExpirationGuard.timeout, () => _onJourneySelected(null));
    }

    return false;
  }

  bool _loadTrain(TrainIdentification trainId) {
    _log.fine('Start loading train journey: $trainId');
    _onJourneySelected(
      ExtendedTrainIdentification(
        trainIdentification: trainId,
        tafTapLocationReferenceStart: _pendingDeepLinkData?.tafTapLocationReferenceStart,
        tafTapLocationReferenceEnd: _pendingDeepLinkData?.tafTapLocationReferenceEnd,
        returnUrl: _pendingDeepLinkData?.returnUrl,
      ),
    );
    _pendingDeepLinkData = null;
    return true;
  }

  void updateDate(DateTime date) {
    _ifInSelectingErrorOrLoadedEmitSelectingWith((model) {
      if (!model.availableStartDates.contains(date)) return model;
      return model.copyWith(startDate: date);
    });
  }

  void updateTrainNumber(String? trainNumber) {
    _ifInSelectingErrorOrLoadedEmitSelectingWith((model) => model.copyWith(operationalTrainNumber: trainNumber));
  }

  void updateCompanies(List<Company> companies) {
    _ifInSelectingErrorOrLoadedEmitSelectingWith(
      (model) => Selecting(
        startDate: model.startDate,
        availableStartDates: model.availableStartDates,
        companyCode: companies.firstOrNull?.code,
        trainNumber: model.trainNumber,
      ),
    );
  }

  void updateSelectedCompanyMatch(CompanyMatch? selectedCompanyMatch) {
    if (modelValue is! SelectingCompanyMatch) return;

    final currentState = modelValue as SelectingCompanyMatch;
    _emit(
      currentState.copyWith(selectedCompanyMatch: selectedCompanyMatch, isInputComplete: selectedCompanyMatch != null),
    );
  }

  void refreshDatesIfDayChanged() {
    if (!_availableDaysChanged) return;

    final currentState = _currentState;
    final newAvailableDates = _availableStartDates();

    switch (currentState) {
      case final Selecting s:
        DateTime updatedSelectedDate = s.startDate;
        if (!newAvailableDates.contains(updatedSelectedDate)) {
          updatedSelectedDate = _midnightToday();
        }
        _emit(currentState.copyWith(startDate: updatedSelectedDate, availableStartDates: newAvailableDates));
      case final Error e:
        DateTime updatedSelectedDate = e.startDate;
        if (!newAvailableDates.contains(updatedSelectedDate)) {
          updatedSelectedDate = _midnightToday();
        }
        _emit(
          JourneySelectionModel.selecting(
            startDate: updatedSelectedDate,
            companyCode: e.companyCode,
            trainNumber: e.operationalTrainNumber,
            availableStartDates: newAvailableDates,
          ),
        );
      default:
        break;
    }
  }

  void dismissSelection() {
    final currentState = _currentState;
    if (currentState is Loading) return;

    _emitSelectingWithDefaults();
  }

  Future<String?> resolveCompanyName(String companyCode) async {
    final company = await _settingsRepository.getCompanyForCode(companyCode);
    return company?.shortName;
  }

  void dispose() {
    _sferaRepoSubscription?.cancel();
    _rxModel.close();
    _delayTimer?.cancel();
    _delayTimer = null;
  }

  void _initSferaRepoSubscription() {
    _sferaRepoSubscription = _sferaRepo.stateStream.listen((state) {
      switch (state) {
        case .offlineData:
        case .connected:
          final currentState = _currentState;
          if (currentState is! Loading && currentState is! LoadingCompanyMatches) return;
          _emit(JourneySelectionModel.loaded(trainIdentification: _sferaRepo.connectedTrain!));
        case .connecting:
          final trainId = _sferaRepo.connectedTrain;
          if (trainId == null) return;
          _emit(JourneySelectionModel.loading(trainIdentification: trainId));
        case .disconnected:
          if (_sferaRepo.lastError == null) return;

          return switch (_currentState) {
            final Loading l => _emit(
              JourneySelectionModel.error(
                trainIdentification: l.trainIdentification,
                errorCode: .fromSfera(error: _sferaRepo.lastError!),
                availableStartDates: _availableStartDates(),
              ),
            ),
            final Selecting s => _emit(
              JourneySelectionModel.error(
                trainIdentification: _trainIdFrom(s),
                errorCode: .fromSfera(error: _sferaRepo.lastError!),
                availableStartDates: s.availableStartDates,
              ),
            ),
            _ => null,
          };
      }
    });
  }

  void _emitSelectingWithDefaults() {
    _emit(
      JourneySelectionModel.selecting(
        startDate: _midnightToday(),
        companyCode: null,
        availableStartDates: _availableStartDates(),
      ),
    );
  }

  void _emit(JourneySelectionModel newState) {
    _currentState = newState;
    _rxModel.add(newState);
  }

  void _ifInSelectingErrorOrLoadedEmitSelectingWith(Selecting Function(Selecting model) updateFunc) {
    switch (modelValue) {
      case final Selecting s:
        final updatedModel = updateFunc(s);
        final isInputComplete = _validateInput(updatedModel);
        _emit(updatedModel.copyWith(isInputComplete: isInputComplete));
      case final SelectingCompanyMatch s:
        final updatedModel = updateFunc(
          Selecting(
            startDate: s.startDate,
            companyCode: null,
            trainNumber: s.operationalTrainNumber,
            availableStartDates: _availableStartDates(),
          ),
        );
        _emit(updatedModel.copyWith(isInputComplete: _validateInput(updatedModel)));
      case final Error e:
        final updatedModel = updateFunc(
          Selecting(
            startDate: e.startDate,
            companyCode: e.companyCode,
            trainNumber: e.operationalTrainNumber,
            availableStartDates: _availableStartDates(),
          ),
        );
        _emit(updatedModel.copyWith(isInputComplete: _validateInput(updatedModel)));
      case final Loaded l:
        final updatedModel = updateFunc(
          Selecting(
            startDate: l.startDate,
            companyCode: l.companyCode,
            trainNumber: l.operationalTrainNumber,
            availableStartDates: _availableStartDates(),
          ),
        );
        _emit(updatedModel.copyWith(isInputComplete: _validateInput(updatedModel)));
      default:
        break;
    }
  }

  bool _validateInput(Selecting updatedModel) => updatedModel.trainNumber?.isNotEmpty == true;

  TrainIdentification _trainIdFrom(JourneySelectionModel selectingState) => TrainIdentification(
    companyCode: selectingState.companyCode!,
    trainNumber: selectingState.operationalTrainNumber.trim().toUpperCase(),
    date: selectingState.startDate,
  );

  List<DateTime> _availableStartDates() {
    final today = _midnightToday();
    return [
      today.subtract(const Duration(days: 1)),
      today,
      today.add(const Duration(days: 1)),
    ];
  }

  DateTime _midnightToday() {
    final now = clock.now().toLocal();
    return DateTime.utc(now.year, now.month, now.day);
  }

  bool get _availableDaysChanged {
    final currentAvailableDays = _currentState.availableStartDates;
    final updatedAvailableDays = _availableStartDates();
    return !ListEquality().equals(currentAvailableDays, updatedAvailableDays);
  }
}
