import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:train_identification/src/api/companies/companies_request.dart';
import 'package:train_identification/src/api/dto/company_dto.dart';
import 'package:train_identification/src/api/dto/company_match_dto.dart';
import 'package:train_identification/src/api/dto/train_identification_response_dto.dart';
import 'package:train_identification/src/api/train_identification_api_service.dart';
import 'package:train_identification/src/model/company.dart';
import 'package:train_identification/src/model/company_match.dart';
import 'package:train_identification/src/repository/train_identification_repository_impl.dart';

import 'train_identification_repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TrainIdentificationApiService>(),
  MockSpec<CompaniesRequest>(),
  MockSpec<CompaniesResponse>(),
])
void main() {
  group('TrainIdentificationRepositoryImpl', () {
    test('sends yesterday, today and tomorrow as start dates', () async {
      final apiService = MockTrainIdentificationApiService();
      final request = MockCompaniesRequest();
      final response = MockCompaniesResponse();
      final repository = TrainIdentificationRepositoryImpl(apiService: apiService);

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
      final apiService = MockTrainIdentificationApiService();
      final request = MockCompaniesRequest();
      final response = MockCompaniesResponse();
      final repository = TrainIdentificationRepositoryImpl(apiService: apiService);

      when(apiService.companies).thenReturn(request);
      when(response.body).thenReturn(
        TrainIdentificationResponseDto(
          data: [
            CompanyMatchDto(
              company: CompanyDto(code: '1085', shortName: 'SBB'),
              startDate: DateTime(2026, 7, 20),
            ),
            CompanyMatchDto(
              company: CompanyDto(code: '0421', shortName: 'BLS'),
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
            company: Company(code: '1085', shortName: 'SBB'),
            startDate: DateTime(2026, 7, 20),
          ),
          CompanyMatch(
            company: Company(code: '0421', shortName: 'BLS'),
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
  });
}

DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);
