package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class Good {

    private boolean isDangerous;

    static boolean hasDangerousGoods(List<Good> goods) {
        if (goods == null) {
            return false;
        }
        return goods.stream()
            .anyMatch(good -> good.isDangerous);
    }
}
