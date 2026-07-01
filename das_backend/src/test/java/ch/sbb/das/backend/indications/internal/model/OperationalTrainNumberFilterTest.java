package ch.sbb.das.backend.indications.internal.model;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.util.Set;
import org.junit.jupiter.api.Test;

class OperationalTrainNumberFilterTest {

    private static Set<ConstraintViolation<OperationalTrainNumberFilter>> validate(OperationalTrainNumberFilter request) {
        try (ValidatorFactory validatorFactory = Validation.buildDefaultValidatorFactory()) {
            Validator validator = validatorFactory.getValidator();
            return validator.validate(request);
        }
    }

    @Test
    void validate_acceptsSingleTrainNumberExpression() {
        OperationalTrainNumberFilter request = new OperationalTrainNumberFilter("300", TrainNumberParity.ANY);

        Set<ConstraintViolation<OperationalTrainNumberFilter>> violations = validate(request);

        assertThat(violations).isEmpty();
        assertThat(request.isRangeValid()).isTrue();
    }

    @Test
    void validate_acceptsTrainNumberRangeExpression() {
        OperationalTrainNumberFilter request = new OperationalTrainNumberFilter("300-400", TrainNumberParity.EVEN);

        Set<ConstraintViolation<OperationalTrainNumberFilter>> violations = validate(request);

        assertThat(violations).isEmpty();
        assertThat(request.isRangeValid()).isTrue();
    }

    @Test
    void validate_rejectsInvalidExpressionFormat() {
        OperationalTrainNumberFilter request = new OperationalTrainNumberFilter("300-", TrainNumberParity.ANY);

        Set<ConstraintViolation<OperationalTrainNumberFilter>> violations = validate(request);

        assertThat(request.isRangeValid()).isTrue();
        assertThat(violations)
            .extracting(ConstraintViolation::getMessage)
            .contains("expression must match '<number>' or '<from>-<to>'");
    }

    @Test
    void validate_rejectsBlankExpression() {
        OperationalTrainNumberFilter request = new OperationalTrainNumberFilter(" ", TrainNumberParity.ANY);

        Set<ConstraintViolation<OperationalTrainNumberFilter>> violations = validate(request);

        assertThat(violations)
            .extracting(ConstraintViolation::getPropertyPath)
            .anySatisfy(path -> assertThat(path).hasToString("expression"));
    }

    @Test
    void validate_rejectsNullParity() {
        OperationalTrainNumberFilter request = new OperationalTrainNumberFilter("300", null);

        Set<ConstraintViolation<OperationalTrainNumberFilter>> violations = validate(request);

        assertThat(violations)
            .extracting(ConstraintViolation::getPropertyPath)
            .anySatisfy(path -> assertThat(path).hasToString("parity"));
    }

    @Test
    void validate_rejectsRangeWithFromGreaterThanTo() {
        OperationalTrainNumberFilter request = new OperationalTrainNumberFilter("401-400", TrainNumberParity.ANY);

        Set<ConstraintViolation<OperationalTrainNumberFilter>> violations = validate(request);

        assertThat(request.isRangeValid()).isFalse();
        assertThat(violations)
            .extracting(ConstraintViolation::getMessage)
            .contains("range expression must have from <= to");
    }
}
