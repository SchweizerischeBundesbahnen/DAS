package ch.sbb.sferamock.messages.model.localregulations;

public record OperatingPoint(
    int id,
    TitleContent title,
    String shortTitle,
    String sapId
) {

}
