package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;

@AllArgsConstructor
public class IntermodalLoadingUnit {

    private List<Good> goods;

    static boolean hasDangerousGoods(List<IntermodalLoadingUnit> intermodalLoadingUnits) {
        if (intermodalLoadingUnits == null || intermodalLoadingUnits.isEmpty()) {
            return false;
        }
        return intermodalLoadingUnits.stream()
            .anyMatch(IntermodalLoadingUnit::hasLoadDangerousGoods);
    }

    private boolean hasLoadDangerousGoods() {
        return Good.hasDangerousGoods(goods);
    }
}
