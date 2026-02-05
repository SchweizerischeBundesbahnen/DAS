package ch.sbb.backend.preload.infrastructure.model.traindata;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Getter
public class Zuglaufpunkt {

    @NonNull
    Betriebspunkt betriebspunkt;

    @JsonProperty("kommerzielle_zeit_ab")
    Integer kommZeitAb;  // nullable

    @JsonProperty("kommerzielle_zeit_an")
    Integer kommZeitAn; // nullable

    @JsonProperty("betr_zeit_ab")
    Integer betrZeitAb;  // nullable

    @JsonProperty("betr_zeit_an")
    Integer betrZeitAn; // nullable

    @JsonProperty("sms_evu")
    String smsEvu; // nullable

    Halt halt; // nullable
}
