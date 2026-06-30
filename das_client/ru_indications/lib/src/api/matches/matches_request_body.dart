import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'matches_request_body.g.dart';

@JsonSerializable()
class MatchesRequestBody {
  MatchesRequestBody({
    required this.company,
    required this.operationalTrainNumber,
    required this.startDate,
    required this.tafTapLocationReferences,
  });

  factory MatchesRequestBody.fromJson(Map<String, dynamic> json) => _$MatchesRequestBodyFromJson(json);

  final String company;
  final String operationalTrainNumber;

  @JsonKey(toJson: _dateToString)
  final DateTime startDate;

  final List<String> tafTapLocationReferences;

  Map<String, dynamic> toJson() => _$MatchesRequestBodyToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = pretty ? JsonEncoder.withIndent(' ' * 2) : JsonEncoder();
    return encoder.convert(json);
  }

  @override
  String toString() {
    return 'MatchesRequestBody{company: $company, operationalTrainNumber: $operationalTrainNumber, startDate: $startDate, tafTapLocationReferences: $tafTapLocationReferences}';
  }
}

/// Converts a [DateTime] to a date-only string in yyyy-MM-dd format.
String _dateToString(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
