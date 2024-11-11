import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum JpStatus implements XmlEnum {
  valid(xmlValue: 'Valid'),
  invalid(xmlValue: 'Invalid'),
  unavailable(xmlValue: 'Unavailable'),
  update(xmlValue: 'Update'),
  overwrite(xmlValue: 'Overwrite');

  const JpStatus({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
