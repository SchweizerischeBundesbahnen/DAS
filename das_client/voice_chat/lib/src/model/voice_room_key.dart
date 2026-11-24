class VoiceRoomKey {
  const VoiceRoomKey(this.value);

  factory VoiceRoomKey.fromJourney({required String trainNumber, required DateTime date}) {
    final d = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return VoiceRoomKey('das-$trainNumber-$d');
  }

  final String value;
}
