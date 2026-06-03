package ch.sbb.das.backend.admin.application.ruindications.model;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.util.Set;
import org.junit.jupiter.api.Test;

class TrainNumberFilterRequestTest {

    private static Set<ConstraintViolation<TrainNumberFilterRequest>> validate(TrainNumberFilterRequest request) {
        try (ValidatorFactory validatorFactory = Validation.buildDefaultValidatorFactory()) {
            Validator validator = validatorFactory.getValidator();
            return validator.validate(request);
        }
    }

    @Test
    void validate_acceptsSingleTrainNumberExpression() {
        TrainNumberFilterRequest request = new TrainNumberFilterRequest("300", TrainNumberParity.ANY);

        Set<ConstraintViolation<TrainNumberFilterRequest>> violations = validate(request);

        assertThat(violations).isEmpty();
        assertThat(request.isRangeValid()).isTrue();
    }

    @Test
    void validate_acceptsTrainNumberRangeExpression() {
        TrainNumberFilterRequest request = new TrainNumberFilterRequest("300-400", TrainNumberParity.EVEN);

        Set<ConstraintViolation<TrainNumberFilterRequest>> violations = validate(request);

        assertThat(violations).isEmpty();
        assertThat(request.isRangeValid()).isTrue();
    }

    @Test
    void validate_rejectsInvalidExpressionFormat() {
        TrainNumberFilterRequest request = new TrainNumberFilterRequest("300-", TrainNumberParity.ANY);

        Set<ConstraintViolation<TrainNumberFilterRequest>> violations = validate(request);

        assertThat(request.isRangeValid()).isTrue();
        assertThat(violations)
            .extracting(ConstraintViolation::getMessage)
            .contains("expression must match '<number>' or '<from>-<to>'");
    }

    @Test
    void validate_rejectsBlankExpression() {
        TrainNumberFilterRequest request = new TrainNumberFilterRequest(" ", TrainNumberParity.ANY);

        Set<ConstraintViolation<TrainNumberFilterRequest>> violations = validate(request);

        assertThat(violations)
            .extracting(ConstraintViolation::getPropertyPath)
            .anySatisfy(path -> assertThat(path).hasToString("expression"));
    }

    @Test
    void validate_rejectsNullParity() {
        TrainNumberFilterRequest request = new TrainNumberFilterRequest("300", null);

        Set<ConstraintViolation<TrainNumberFilterRequest>> violations = validate(request);

        assertThat(violations)
            .extracting(ConstraintViolation::getPropertyPath)
            .anySatisfy(path -> assertThat(path).hasToString("parity"));
    }

    @Test
    void validate_rejectsRangeWithFromGreaterThanTo() {
        TrainNumberFilterRequest request = new TrainNumberFilterRequest("401-400", TrainNumberParity.ANY);

        Set<ConstraintViolation<TrainNumberFilterRequest>> violations = validate(request);

        assertThat(request.isRangeValid()).isFalse();
        assertThat(violations)
            .extracting(ConstraintViolation::getMessage)
            .contains("range expression must have from <= to");
    }
}
