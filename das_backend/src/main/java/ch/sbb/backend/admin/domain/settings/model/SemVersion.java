package ch.sbb.backend.admin.domain.settings.model;

import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.jspecify.annotations.NonNull;

/**
 * Represents a semantic version, consisting of major, minor and patch numbers as defined by <a href="https://semver.org/">Semantic Versioning</a>
 */
public class SemVersion implements Comparable<SemVersion> {

    public static final String SEM_VERSION_PATTERN = "(\\d+)\\.(\\d+)\\.(\\d+)";

    private final int major;
    private final int minor;
    private final int patch;

    public SemVersion(String version) {
        Matcher matcher = Pattern.compile(SEM_VERSION_PATTERN).matcher(version);
        if (!matcher.matches()) {
            throw new IllegalArgumentException("Version must match SemVersion pattern");
        }
        this.major = Integer.parseInt(matcher.group(1));
        this.minor = Integer.parseInt(matcher.group(2));
        this.patch = Integer.parseInt(matcher.group(3));
    }

    @Override
    public int compareTo(@NonNull SemVersion other) {
        long result = major - other.major;
        if (result == 0) {
            result = minor - other.minor;
            if (result == 0) {
                result = patch - other.patch;
                if (result == 0) {
                    return 0;
                }
            }
        }
        return result < 0 ? -1 : 1;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        SemVersion that = (SemVersion) o;
        return compareTo(that) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hash(major, minor, patch);
    }

    public boolean isLowerThan(SemVersion other) {
        return compareTo(other) < 0;
    }
}
