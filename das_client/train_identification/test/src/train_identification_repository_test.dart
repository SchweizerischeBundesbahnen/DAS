import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/src/data/repository/sfera_local_repo.dart';
import 'package:train_identification/src/api/companies/companies_request.dart';
import 'package:train_identification/src/api/dto/company_dto.dart';
import 'package:train_identification/src/api/dto/company_match_dto.dart';
import 'package:train_identification/src/api/dto/train_identification_response_dto.dart';
import 'package:train_identification/src/api/train_identification_api_service.dart';
import 'package:train_identification/src/repository/train_identification_repository_impl.dart';

import 'train_identification_repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TrainIdentificationApiService>(),
  MockSpec<CompaniesRequest>(),
  MockSpec<CompaniesResponse>(),
  MockSpec<SferaLocalRepo>(),
])
void main() {
  late MockTrainIdentificationApiService apiService;
  late MockCompaniesRequest request;
  late MockCompaniesResponse response;
  late MockSferaLocalRepo sferaLocalRepo;
  late TrainIdentificationRepositoryImpl repository;

  setUp(() {
    apiService = MockTrainIdentificationApiService();
    request = MockCompaniesRequest();
    response = MockCompaniesResponse();
    sferaLocalRepo = MockSferaLocalRepo();
    repository = TrainIdentificationRepositoryImpl(
      apiService: apiService,
      sferaLocalRepo: sferaLocalRepo,
    );
  });

  test('sends yesterday, today and tomorrow as start dates', () async {
    when(apiService.companies).thenReturn(request);
    when(response.body).thenReturn(TrainIdentificationResponseDto(data: const <CompanyMatchDto>[]));
    when(
      request.call(
        operationalTrainNumber: anyNamed('operationalTrainNumber'),
        startDates: anyNamed('startDates'),
      ),
    ).thenAnswer((_) async => response);

    final now = DateTime.now();
    await repository.findTrainIdentifications(operationalTrainNumber: '12345');

    final captured = verify(
      request.call(
        operationalTrainNumber: captureAnyNamed('operationalTrainNumber'),
        startDates: captureAnyNamed('startDates'),
      ),
    ).captured;

    expect(captured[0], '12345');
    final startDates = captured[1] as List<DateTime>;
    expect(startDates, hasLength(3));
    expect(_dateOnly(startDates[0]), _dateOnly(now.subtract(const Duration(days: 1))));
    expect(_dateOnly(startDates[1]), _dateOnly(now));
    expect(_dateOnly(startDates[2]), _dateOnly(now.add(const Duration(days: 1))));
  });

  test('maps company matches from the api response', () async {
    when(apiService.companies).thenReturn(request);
    when(response.body).thenReturn(
      TrainIdentificationResponseDto(
        data: [
          CompanyMatchDto(
            company: CompanyDto(code: '1285', shortName: 'SBB'),
            startDate: DateTime(2026, 7, 20),
          ),
          CompanyMatchDto(
            company: CompanyDto(code: '1163', shortName: 'BLS'),
            startDate: DateTime(2026, 7, 21),
          ),
        ],
      ),
    );
    when(
      request.call(
        operationalTrainNumber: anyNamed('operationalTrainNumber'),
        startDates: anyNamed('startDates'),
      ),
    ).thenAnswer((_) async => response);

    final result = await repository.findTrainIdentifications(operationalTrainNumber: '12345');

    expect(
      result,
      [
        CompanyMatch(
          ru: RailwayUndertaking.sbbP,
          startDate: DateTime(2026, 7, 20),
        ),
        CompanyMatch(
          ru: RailwayUndertaking.blsP,
          startDate: DateTime(2026, 7, 21),
        ),
      ],
    );
    verify(
      request.call(
        operationalTrainNumber: '12345',
        startDates: anyNamed('startDates'),
      ),
    ).called(1);
  });

  test('falls back to local database when API call fails', () async {
    when(apiService.companies).thenReturn(request);
    when(
      request.call(
        operationalTrainNumber: anyNamed('operationalTrainNumber'),
        startDates: anyNamed('startDates'),
      ),
    ).thenThrow(Exception('network error'));

    when(
      sferaLocalRepo.findCompanyMatchesByTrainNumber(
        '12345',
        startDates: anyNamed('startDates'),
      ),
    ).thenAnswer(
      (_) async => {
        CompanyMatch(
          ru: RailwayUndertaking.sbbP,
          startDate: DateTime(2026, 7, 21),
        ),
      },
    );

    final result = await repository.findTrainIdentifications(operationalTrainNumber: '12345');

    expect(result, hasLength(1));
    expect(result.first.ru, RailwayUndertaking.sbbP);
    expect(result.first.startDate, DateTime(2026, 7, 21));
    verify(
      sferaLocalRepo.findCompanyMatchesByTrainNumber(
        '12345',
        startDates: anyNamed('startDates'),
      ),
    ).called(1);
  });

  test('returns empty list when API fails and no local data exists', () async {
    when(apiService.companies).thenReturn(request);
    when(
      request.call(
        operationalTrainNumber: anyNamed('operationalTrainNumber'),
        startDates: anyNamed('startDates'),
      ),
    ).thenThrow(Exception('network error'));

    when(
      sferaLocalRepo.findCompanyMatchesByTrainNumber(
        any,
        startDates: anyNamed('startDates'),
      ),
    ).thenAnswer((_) async => {});

    final result = await repository.findTrainIdentifications(operationalTrainNumber: '99999');

    expect(result, isEmpty);
  });
}

DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);
