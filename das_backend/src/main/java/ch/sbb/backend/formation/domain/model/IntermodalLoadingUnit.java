package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class IntermodalLoadingUnit {

    private List<Good> goods;

    static boolean hasDangerousGoods(List<IntermodalLoadingUnit> intermodalLoadingUnits) {
        if (intermodalLoadingUnits == null) {
            return false;
        }
        return intermodalLoadingUnits.stream()
            .anyMatch(IntermodalLoadingUnit::hasDangerousGoods);
    }

    private boolean hasDangerousGoods() {
        return Good.hasDangerousGoods(goods);
    }
}
