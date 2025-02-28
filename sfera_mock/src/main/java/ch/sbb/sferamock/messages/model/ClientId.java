package ch.sbb.sferamock.messages.model;

import lombok.NonNull;

public record ClientId(@NonNull String value) implements Comparable<ClientId> {

    @Override
    public int compareTo(ClientId other) {
        return value.compareTo(other.value);
    }
}
