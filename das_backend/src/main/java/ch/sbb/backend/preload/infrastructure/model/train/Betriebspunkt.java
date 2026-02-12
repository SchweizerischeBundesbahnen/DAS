package ch.sbb.backend.preload.infrastructure.model.train;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.NonNull;

@Getter
public class Betriebspunkt {

    @NonNull
    @JsonProperty("bp_uic_laendercode")
    Integer bpUicLaendercode;

}
