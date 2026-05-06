import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';

abstract class MessagingService {
  const MessagingService();

  String? get tokenValue;

  Stream<String?> get token;

  Stream<BaseMessageDto> get message;

  void dispose();
}
