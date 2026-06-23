package ch.sbb.das.backend.externallinks.internal;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.net.URI;
import java.util.regex.Pattern;

/**
 * Validator for checking that a String is a valid URL.
 */
public class URLValidator implements ConstraintValidator<ValidURL, String> {

    private static final String SCHEME_REGEX = "^\\p{Alpha}[\\p{Alnum}+\\-.]*";
    private static final Pattern SCHEME_PATTERN = Pattern.compile(SCHEME_REGEX);

    @Override
    public boolean isValid(String request, ConstraintValidatorContext context) {
        URI uri;
        try {
            uri = new URI(request);
        } catch (Exception _) {
            return false;
        }

        return isValidScheme(uri.getScheme());
    }

    protected boolean isValidScheme(final String scheme) {
        if (scheme == null) {
            return false;
        }

        return SCHEME_PATTERN.matcher(scheme).matches();
    }
}
