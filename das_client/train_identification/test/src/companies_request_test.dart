import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http_x/component.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:train_identification/src/api/companies/companies_request.dart';

import 'companies_request_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Client>()])
void main() {
  test('sends yesterday/today/tomorrow as repeated startDate query params and parses company matches', () async {
    late Uri capturedUri;
    final client = MockClient();

    when(client.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
      capturedUri = invocation.positionalArguments.first as Uri;
      return Response(
        jsonEncode({
          'data': [
            {
              'company': {'code': '85', 'shortName': 'SBB'},
              'startDate': '2026-07-21',
            },
          ],
        }),
        200,
      );
    });

    final request = CompaniesRequest(httpClient: client, baseUrl: 'example.org');

    final response = await request(
      operationalTrainNumber: '12345',
      startDates: [
        DateTime(2026, 7, 20),
        DateTime(2026, 7, 21),
        DateTime(2026, 7, 22),
      ],
    );

    expect(capturedUri.path, '/driver/v1/train-identifications/companies');
    expect(capturedUri.queryParametersAll['operationalTrainNumber'], ['12345']);
    expect(capturedUri.queryParametersAll['startDate'], ['2026-07-20', '2026-07-21', '2026-07-22']);
    verify(client.get(any, headers: anyNamed('headers'))).called(1);

    expect(response.body.data, hasLength(1));
    expect(response.body.data.first.company.code, '85');
    expect(response.body.data.first.company.shortName, 'SBB');
    expect(response.body.data.first.startDate, DateTime(2026, 7, 21));
  });
}
