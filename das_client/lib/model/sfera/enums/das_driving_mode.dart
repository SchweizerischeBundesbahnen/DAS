enum DASDrivingMode {
  inactive(xmlValue: "Inactive"),
  timetable(xmlValue: "Timetable"),
  readOnly(xmlValue: "Read-Only"),
  dasNotConnected(xmlValue: "DAS not connected to ATP"),
  goa1(xmlValue: "GoA1"),
  goa2(xmlValue: "GoA2"),
  goa3(xmlValue: "GoA3"),
  goa4(xmlValue: "GoA4");

  const DASDrivingMode({
    required this.xmlValue,
  });

  final String xmlValue;
}
