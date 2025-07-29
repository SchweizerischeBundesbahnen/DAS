package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class Goods {

    private boolean isDangerous;

    static boolean hasDangerousGoods(List<Goods> goodsList) {
        if (goodsList == null) {
            return false;
        }
        return goodsList.stream()
            .anyMatch(goods -> goods.isDangerous);
    }
}
