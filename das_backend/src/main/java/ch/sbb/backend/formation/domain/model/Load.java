package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;

@AllArgsConstructor
public class Load {

    private List<Good> goods;
    private List<IntermodalLoadingUnit> intermodalLoadingUnits;

    boolean hasDangerousGoods() {
        return Good.hasDangerousGoods(goods) || IntermodalLoadingUnit.hasDangerousGoods(intermodalLoadingUnits);
    }
}
