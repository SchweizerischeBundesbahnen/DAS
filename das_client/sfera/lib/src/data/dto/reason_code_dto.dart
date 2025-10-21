import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum ReasonCodeDto implements XmlEnum {
  /// host train is following a conflicting (slower) train
  followTrain(xmlValue: 'followTrain'),

  /// host train is preceding a conflicting (faster) train
  trainFollowing(xmlValue: 'trainFollowing'),

  /// conflicting (faster) train merging ahead and entering common route section first
  merge2nd(xmlValue: 'merge2nd'),

  /// conflicting (slower) train merging ahead, host train enters common route section first
  merge1st(xmlValue: 'merge1st'),

  /// overtake conflicting (slower) train that has (nearly) reached the location of overtaking
  overtakeTrain(xmlValue: 'overtakeTrain'),

  /// follow, then overtake conflicting train that hasn’t yet reached the location of overtaking
  followTrainOvertakeTrain(xmlValue: 'followTrainOvertakeTrain'),

  /// conflicting (faster) train about to overtake
  beingOvertaken(xmlValue: 'beingOvertaken'),

  /// conflicting (faster) train following and then overtaking
  trainFollowingBeingOvertaken(xmlValue: 'trainFollowingBeingOvertaken'),

  /// train crossing
  trainCrossing(xmlValue: 'trainCrossing'),

  /// passing a train on a single-track line
  passTrain(xmlValue: 'passTrain'),

  /// host train being passed on a single-track line
  beingPassed(xmlValue: 'beingPassed'),

  /// recovery time is required due to an upcoming temporary speed restriction
  timeSupplementRequired(xmlValue: 'timeSupplementRequired'),

  /// optimisation of energy consumption
  energyOptimisation(xmlValue: 'energyOptimisation'),

  /// the reason previously communicated is not valid anymore.
  endOfReason(xmlValue: 'endOfReason'),

  /// nationalUse1 is to be interpreted as ADL-fixedTime
  advisedSpeedFixedTime(xmlValue: 'nationalUse1'),
  nationalUse2(xmlValue: 'nationalUse2'),
  nationalUse3(xmlValue: 'nationalUse3'),
  nationalUse4(xmlValue: 'nationalUse4'),
  nationalUse5(xmlValue: 'nationalUse5'),
  nationalUse6(xmlValue: 'nationalUse6'),
  nationalUse7(xmlValue: 'nationalUse7'),
  nationalUse8(xmlValue: 'nationalUse8'),
  nationalUse9(xmlValue: 'nationalUse9'),
  nationalUse10(xmlValue: 'nationalUse10');

  const ReasonCodeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
