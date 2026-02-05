package ch.sbb.backend.preload.infrastructure.model.traindata;

import java.util.List;
import lombok.Getter;
import lombok.NonNull;

@Getter
public class Halt {

    @NonNull
    List<String> haltezwecke;

}
