import 'dart:convert';

import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('LocalMessageStorage');

class LocalMessageStorage {
  static const String _latestMessagesKey = 'latestDepartureOrientedDepartureMessages';

  const LocalMessageStorage();

  /// Gets latest messages saved to local storage
  Future<List<BaseMessageDto>> getLatestMessages() async {
    final prefs = await SharedPreferences.getInstance();

    // reload needed as each isolate (used on background message) has its own memory
    await prefs.reload();

    final latestMessages = prefs.getStringList(_latestMessagesKey) ?? <String>[];
    return latestMessages.map(_tryParseMessage).nonNulls.toList();
  }

  /// Adds message to local storage
  Future<void> addMessage(BaseMessageDto message) async {
    final prefs = await SharedPreferences.getInstance();
    final latestMessages = prefs.getStringList(_latestMessagesKey) ?? <String>[];
    latestMessages.add(message.toJsonString());
    await prefs.setStringList(_latestMessagesKey, latestMessages);
  }

  /// Clears local storage used by customer oriented departure
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latestMessagesKey);
  }

  static BaseMessageDto? _tryParseMessage(String rawMessage) {
    try {
      final messageJson = jsonDecode(rawMessage) as Map<String, dynamic>;
      if (messageJson.containsKey('status')) {
        return TrainStatusMessageDto.fromJson(messageJson);
      }
      return BaseMessageDto.fromJson(messageJson);
    } catch (e) {
      _log.severe('Failed to parse persisted firebase message.', e);
      return null;
    }
  }
}
