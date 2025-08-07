package ch.sbb.sferamock.messages.model.localregulations;

import java.util.Map;

public record DocumentRoot(
    DocumentNode document,
    Map<String, OperatingPoint> operatingPoints
) {

}
