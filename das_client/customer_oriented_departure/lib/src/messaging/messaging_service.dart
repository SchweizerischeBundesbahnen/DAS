import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';

abstract class MessagingService {
  const MessagingService();

  String? get tokenValue;

  Stream<String?> get token;

  Stream<TrainStatusMessageDto> get message;

  void dispose();
}
