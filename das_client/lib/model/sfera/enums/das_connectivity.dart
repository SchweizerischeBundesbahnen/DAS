enum DASConnectivity {
  standalone(xmlValue: "Standalone"),
  connected(xmlValue: "Connected");

  const DASConnectivity({
    required this.xmlValue,
  });

  final String xmlValue;
}
