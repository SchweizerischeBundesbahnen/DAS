/**
 * Synchronous calls to downstream services (GEMS, ORCA, atlas and the Entra ID token endpoint): timeouts, retries, logging of failed attempts and the
 * translation of failures into {@link ch.sbb.das.backend.common.error.DownstreamCallException}.
 *
 * @see <a href="https://github.com/SchweizerischeBundesbahnen/DAS/tree/main/docs/content/architecture/09_design_decisions/downstream_resilience_adr.md">ADR downstream
 *     resilience</a>
 */
@org.springframework.modulith.NamedInterface("downstream")
package ch.sbb.das.backend.common.downstream;
