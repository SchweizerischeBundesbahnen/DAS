package ch.sbb.backend.preload.application;

import lombok.experimental.UtilityClass;

@UtilityClass
public class BitSetUtil {

    private final char DAY_SET = '1';

    public Boolean isDaySet(final Integer dayIndex, final String bitset) {
        return bitset.length() > dayIndex && DAY_SET == bitset.charAt(dayIndex);
    }

}
