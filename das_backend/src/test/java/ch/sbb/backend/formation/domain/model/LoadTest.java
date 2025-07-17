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
        Load load = new Load(List.of(new Good(false)), List.of());

        boolean result = load.hasDangerousGoods();

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_withDangerousGoods() {
        Load load = new Load(List.of(new Good(true), new Good(false)), List.of());

        boolean result = load.hasDangerousGoods();

        assertTrue(result);
    }

    @Test
    void hasDangerousGoods_withIntermodalLoadingUnits() {
        Load load = new Load(List.of(), List.of(new IntermodalLoadingUnit(List.of(new Good(false)))));

        boolean result = load.hasDangerousGoods();

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_withDangerousIntermodalLoadingUnits() {
        Load load = new Load(List.of(), List.of(
            new IntermodalLoadingUnit(
                List.of(new Good(true), new Good(false))),
            new IntermodalLoadingUnit(
                List.of(new Good(false), new Good(false)))));

        boolean result = load.hasDangerousGoods();

        assertTrue(result);
    }
}