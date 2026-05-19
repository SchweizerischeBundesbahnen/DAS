package ch.sbb.das.backend.admin.domain.notices;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import ch.sbb.das.backend.admin.application.notices.model.NoticeContent;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatch;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatchesRequest;
import ch.sbb.das.backend.admin.application.notices.model.NoticePeriod;
import ch.sbb.das.backend.admin.application.notices.model.NoticeScope;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplateContent;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

class NoticeMatchServiceLanguageResolutionTest {

    @Test
    void acceptsRfc7231HeaderFormat_andResolvesLanguage() {
        NoticeRepository noticeRepository = mock(NoticeRepository.class);
        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);

        Notice notice = new Notice(
            1,
            new NoticeContent(null, null, new NoticeTemplateContent("Avis FR", "Texte FR"), new NoticeTemplateContent("Avviso IT", "Testo IT")),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00020"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 1), Set.of())),
            null,
            null
        );

        when(noticeRepository.findAll()).thenReturn(List.of(notice));
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 6, 1))).thenReturn(List.of());

        NoticeMatchServiceImpl underTest = new NoticeMatchServiceImpl(noticeRepository, specialHolidayRepository);

        NoticeMatchesRequest request = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            200,
            LocalDate.of(2026, 6, 1),
            Set.of(TafTapLocationReference.of("CH00020"))
        );

        // RFC7231 format with region and q-values -> extract first 'fr' correctly
        List<NoticeMatch> rfc7231Format = underTest.findMatches(request, "fr-CH,fr;q=0.9,en;q=0.8");
        assertThat(rfc7231Format.getFirst().noticeContents())
            .containsExactly(new NoticeTemplateContent("Avis FR", "Texte FR"));
    }

    @Test
    void fallsBackWhenRequestedLanguageUnavailable() {
        NoticeRepository noticeRepository = mock(NoticeRepository.class);
        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);

        Notice notice = new Notice(
            1,
            new NoticeContent(null, new NoticeTemplateContent("Hinweis DE", "Text DE"), null, new NoticeTemplateContent("Avviso IT", "Testo IT")),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00090"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of())),
            null,
            null
        );

        when(noticeRepository.findAll()).thenReturn(List.of(notice));
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 1, 1))).thenReturn(List.of());

        NoticeMatchServiceImpl underTest = new NoticeMatchServiceImpl(noticeRepository, specialHolidayRepository);

        NoticeMatchesRequest request = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            200,
            LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00090"))
        );

        // Request FR, but only DE and IT available -> fallback to DE
        List<NoticeMatch> result = underTest.findMatches(request, "fr-CH");

        assertThat(result).hasSize(1);
        assertThat(result.getFirst().noticeContents())
            .containsExactly(new NoticeTemplateContent("Hinweis DE", "Text DE"));
    }

    @Test
    void usesRequestedLanguageWhenAvailable() {
        NoticeRepository noticeRepository = mock(NoticeRepository.class);
        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);

        Notice notice = new Notice(
            1,
            new NoticeContent(null,
                new NoticeTemplateContent("Hinweis DE", "Text DE"),
                new NoticeTemplateContent("Avis FR", "Texte FR"),
                new NoticeTemplateContent("Avviso IT", "Testo IT")
            ),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00091"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of())),
            null,
            null
        );

        when(noticeRepository.findAll()).thenReturn(List.of(notice));
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 1, 1))).thenReturn(List.of());

        NoticeMatchServiceImpl underTest = new NoticeMatchServiceImpl(noticeRepository, specialHolidayRepository);

        NoticeMatchesRequest request = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            200,
            LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00091"))
        );

        // All three languages available -> use the one requested
        List<NoticeMatch> italianResult = underTest.findMatches(request, "it-IT");
        assertThat(italianResult.getFirst().noticeContents())
            .containsExactly(new NoticeTemplateContent("Avviso IT", "Testo IT"));

        List<NoticeMatch> frenchResult = underTest.findMatches(request, "fr");
        assertThat(frenchResult.getFirst().noticeContents())
            .containsExactly(new NoticeTemplateContent("Avis FR", "Texte FR"));
    }

    @Test
    void usesDefaultFallbackOrderWhenNoLanguageSpecified() {
        NoticeRepository noticeRepository = mock(NoticeRepository.class);
        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);

        Notice notice = new Notice(
            1,
            new NoticeContent(null, null, new NoticeTemplateContent("Avis FR", "Texte FR"), new NoticeTemplateContent("Avviso IT", "Testo IT")),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00092"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of())),
            null,
            null
        );

        when(noticeRepository.findAll()).thenReturn(List.of(notice));
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 1, 1))).thenReturn(List.of());

        NoticeMatchServiceImpl underTest = new NoticeMatchServiceImpl(noticeRepository, specialHolidayRepository);

        NoticeMatchesRequest request = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            200,
            LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00092"))
        );

        // No language header -> fallback order DE, FR, IT -> returns FR (first available)
        List<NoticeMatch> result = underTest.findMatches(request, null);
        assertThat(result).hasSize(1);
        assertThat(result.getFirst().noticeContents())
            .containsExactly(new NoticeTemplateContent("Avis FR", "Texte FR"));
    }
}

