/**
 * Central error handling: every error response produced by the backend is a {@link ch.sbb.das.backend.common.Problem} created by
 * {@link ch.sbb.das.backend.common.error.ProblemFactory}.
 * <p>
 * Controllers only return successful responses; failures are thrown (see {@link ch.sbb.das.backend.common.error.ProblemException} subclasses).
 */
@org.springframework.modulith.NamedInterface("error")
package ch.sbb.das.backend.common.error;
