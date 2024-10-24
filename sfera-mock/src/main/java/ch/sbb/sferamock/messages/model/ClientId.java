package ch.sbb.sferamock.messages.model;

import java.util.UUID;
import lombok.NonNull;

public record ClientId(@NonNull UUID value) implements Comparable<ClientId> {

    @Override
    public int compareTo(ClientId other) {
        return value.compareTo(other.value);
    }
}
