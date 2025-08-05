package ch.sbb.sferamock.messages.model.localregulations;

import java.util.List;

public record Version(
    TitleContent title,
    TitleContent content,
    List<Integer> operatingPoints,
    String inForceFrom,
    String inForceTo
) {

}
