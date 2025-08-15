package ch.sbb.sferamock.messages.model.localregulations;

import java.util.List;

public record DocumentNode(
    List<Version> versions,
    List<DocumentNode> children) {

}
