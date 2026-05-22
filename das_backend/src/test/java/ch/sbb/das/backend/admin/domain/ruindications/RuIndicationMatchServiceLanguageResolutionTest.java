package ch.sbb.das.backend.admin.domain.ruindications;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.admin.application.ruindications.model.Content;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationContent;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationMatch;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationMatchesRequest;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationPeriod;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationScope;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

class RuIndicationMatchServiceLanguageResolutionTest {

    @Test
    void acceptsRfc7231HeaderFormat_andResolvesLanguage() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);

        RuIndication ruIndication = new RuIndication(
            1,
            new RuIndicationContent(null, null, new Content("Avis FR", "Texte FR"), new Content("Avviso IT", "Testo IT")),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00020"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 1), Set.of())),
            null,
            null
        );

        when(ruIndicationRepository.findAll()).thenReturn(List.of(ruIndication));
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 6, 1))).thenReturn(List.of());

        RuIndicationMatchServiceImpl underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        RuIndicationMatchesRequest request = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            200,
            LocalDate.of(2026, 6, 1),
            Set.of(TafTapLocationReference.of("CH00020"))
        );

        // RFC7231 format with region and q-values -> extract first 'fr' correctly
        List<RuIndicationMatch> rfc7231Format = underTest.findMatches(request, "fr-CH,fr;q=0.9,en;q=0.8");
        assertThat(rfc7231Format.getFirst().ruIndicationContents())
            .containsExactly(new Content("Avis FR", "Texte FR"));
    }

    @Test
    void fallsBackWhenRequestedLanguageUnavailable() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);

        RuIndication ruIndication = new RuIndication(
            1,
            new RuIndicationContent(null, new Content("Hinweis DE", "Text DE"), null, new Content("Avviso IT", "Testo IT")),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00090"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of())),
            null,
            null
        );

        when(ruIndicationRepository.findAll()).thenReturn(List.of(ruIndication));
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 1, 1))).thenReturn(List.of());

        RuIndicationMatchServiceImpl underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        RuIndicationMatchesRequest request = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            200,
            LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00090"))
        );

        // Request FR, but only DE and IT available -> fallback to DE
        List<RuIndicationMatch> result = underTest.findMatches(request, "fr-CH");

        assertThat(result).hasSize(1);
        assertThat(result.getFirst().ruIndicationContents())
            .containsExactly(new Content("Hinweis DE", "Text DE"));
    }

    @Test
    void usesRequestedLanguageWhenAvailable() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);

        RuIndication ruIndication = new RuIndication(
            1,
            new RuIndicationContent(null,
                new Content("Hinweis DE", "Text DE"),
                new Content("Avis FR", "Texte FR"),
                new Content("Avviso IT", "Testo IT")
            ),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00091"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of())),
            null,
            null
        );

        when(ruIndicationRepository.findAll()).thenReturn(List.of(ruIndication));
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 1, 1))).thenReturn(List.of());

        RuIndicationMatchServiceImpl underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        RuIndicationMatchesRequest request = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            200,
            LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00091"))
        );

        // All three languages available -> use the one requested
        List<RuIndicationMatch> italianResult = underTest.findMatches(request, "it-IT");
        assertThat(italianResult.getFirst().ruIndicationContents())
            .containsExactly(new Content("Avviso IT", "Testo IT"));

        List<RuIndicationMatch> frenchResult = underTest.findMatches(request, "fr");
        assertThat(frenchResult.getFirst().ruIndicationContents())
            .containsExactly(new Content("Avis FR", "Texte FR"));
    }

    @Test
    void usesDefaultFallbackOrderWhenNoLanguageSpecified() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);

        RuIndication ruIndication = new RuIndication(
            1,
            new RuIndicationContent(null, null, new Content("Avis FR", "Texte FR"), new Content("Avviso IT", "Testo IT")),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00092"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of())),
            null,
            null
        );

        when(ruIndicationRepository.findAll()).thenReturn(List.of(ruIndication));
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 1, 1))).thenReturn(List.of());

        RuIndicationMatchServiceImpl underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        RuIndicationMatchesRequest request = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            200,
            LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00092"))
        );

        // No language header -> fallback order DE, FR, IT -> returns FR (first available)
        List<RuIndicationMatch> result = underTest.findMatches(request, null);
        assertThat(result).hasSize(1);
        assertThat(result.getFirst().ruIndicationContents())
            .containsExactly(new Content("Avis FR", "Texte FR"));
    }
}

