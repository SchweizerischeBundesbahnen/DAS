import 'dart:io';

import 'package:http_x/component.dart';
import 'package:logging/logging.dart';
import 'package:user_properties/src/api/model/user_property_model.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';
import 'package:user_properties/src/repository/user_properties_repository.dart';

final _log = Logger('UserPropertiesRepositoryImpl');

class UserPropertiesRepositoryImpl({
  required final UserPropertiesApiService _apiService,
}) implements UserPropertiesRepository {
  @override
  Future<void> deleteUserProperty(String key) async {
    _log.info('Deleting user property for key=$key');
    await _apiService.deleteUserProperty(key).call();
  }

  @override
  Future<List<UserPropertyModel>> getAllUserProperties() async {
    _log.info('Loading all user properties');
    try {
      final response = await _apiService.userProperties().call();
      return response.body.data.map((dto) => dto.toModel()).toList();
    } catch (e) {
      _log.severe('API call failed for getAllUserProperties.', e);
      rethrow;
    }
  }

  @override
  Future<UserPropertyModel?> getUserProperty(String key) async {
    _log.info('Loading user property for key=$key');
    try {
      final response = await _apiService.userProperty(key).call();
      if (response.body.data.isEmpty) return null;
      return response.body.data.first.toModel();
    } on HttpException catch (e) {
      if (e.statusCode == HttpStatus.notFound) {
        _log.info('No user property found for key=$key');
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<UserPropertyModel> saveUserProperty(String key, Object? value) async {
    _log.info('Saving user property for key=$key');
    final response = await _apiService.saveUserProperty(key, value).call();
    if (response.body.data.isEmpty) {
      throw StateError('The backend returned no user property for key=$key');
    }
    return response.body.data.first.toModel();
  }
}
