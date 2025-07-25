package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class Load {

    private List<Goods> goodsList;
    private List<IntermodalLoadingUnit> intermodalLoadingUnits;

    boolean hasDangerousGoods() {
        return Goods.hasDangerousGoods(goodsList) || IntermodalLoadingUnit.hasDangerousGoods(intermodalLoadingUnits);
    }
}
