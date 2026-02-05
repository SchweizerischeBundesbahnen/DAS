package ch.sbb.backend.preload.infrastructure.util;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.function.Function;
import lombok.experimental.UtilityClass;

@UtilityClass
public class ListUtil {

    public static <T, U> List<T> removeDuplicatesKeepLast(List<T> list, Function<T, U> getKey) {
        List<T> result = new ArrayList<>();
        Set<U> keys = new HashSet<>();
        list.reversed().forEach(item -> {
            if (keys.add(getKey.apply(item))) {
                result.add(item);
            }
        });
        return result.reversed();
    }

}
