package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.List;
import org.junit.jupiter.api.Test;

class LoadTest {

    @Test
    void hasDangerousGoods_null() {
        Load load = new Load(null, null);

        boolean result = load.hasDangerousGoods();

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_empty() {
        Load load = new Load(List.of(), List.of());

        boolean result = load.hasDangerousGoods();

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_withGoods() {
        Load load = new Load(List.of(new Goods(false)), List.of());

        boolean result = load.hasDangerousGoods();

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_withDangerousGoods() {
        Load load = new Load(List.of(new Goods(true), new Goods(false)), List.of());

        boolean result = load.hasDangerousGoods();

        assertTrue(result);
    }

    @Test
    void hasDangerousGoods_withIntermodalLoadingUnits() {
        Load load = new Load(List.of(), List.of(new IntermodalLoadingUnit(false, List.of(new Goods(false)))));

        boolean result = load.hasDangerousGoods();

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_withDangerousIntermodalLoadingUnit() {
        Load load = new Load(List.of(), List.of(
            new IntermodalLoadingUnit(true, List.of(new Goods(false), new Goods(false))),
            new IntermodalLoadingUnit(false, List.of(new Goods(false), new Goods(false)))));

        boolean result = load.hasDangerousGoods();

        assertTrue(result);
    }

    @Test
    void hasDangerousGoods_withDangerousIntermodalLoadingUnitsGoods() {
        Load load = new Load(List.of(), List.of(
            new IntermodalLoadingUnit(false, List.of(new Goods(true), new Goods(false))),
            new IntermodalLoadingUnit(false, List.of(new Goods(false), new Goods(false)))));

        boolean result = load.hasDangerousGoods();

        assertTrue(result);
    }
}