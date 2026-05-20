package ch.sbb.das.backend.admin.domain.notices;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import ch.sbb.das.backend.admin.application.notices.model.NoticeContent;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatch;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatchesRequest;
import ch.sbb.das.backend.admin.application.notices.model.NoticePeriod;
import ch.sbb.das.backend.admin.application.notices.model.NoticeScope;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplateContent;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTrainNumberFilterRequest;
import ch.sbb.das.backend.admin.application.notices.model.ScheduleType;
import ch.sbb.das.backend.admin.application.notices.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.notices.model.TrainNumberParity;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

class NoticeMatchServiceImplTest {

    private static final NoticeTemplateContent DEFAULT_DE_CONTENT = new NoticeTemplateContent("Hinweis", "Text");

    private NoticeMatchServiceImpl underTest;

    @Test
    void findMatches_matchesAllCriteria_andGroupsNoticeContentsByLocation() {
        NoticeRepository noticeRepository = new InMemoryNoticeRepository();
        noticeRepository.save(new Notice(null,
            new NoticeContent(null, new NoticeTemplateContent("Hinweis 1", "Text 1"), null, null),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(new NoticeTrainNumberFilterRequest("100-200", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00002"), TafTapLocationReference.of("CH00004"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
        ));

        noticeRepository.save(new Notice(null,
            new NoticeContent(null, new NoticeTemplateContent("Irrelevant", "Irrelevant"), null, null),
            new NoticeScope(
                Set.of(new CompanyCode("2222")),
                List.of(new NoticeTrainNumberFilterRequest("100-200", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00002"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
        ));

        noticeRepository.save(new Notice(null,
            new NoticeContent(null, new NoticeTemplateContent("Hinweis 2", "Text 2"), null, null),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00002"), TafTapLocationReference.of("CH00003"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
        ));

        underTest = new NoticeMatchServiceImpl(noticeRepository, new InMemorySpecialHolidayRepository());

        NoticeMatchesRequest request = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            150,
            LocalDate.of(2026, 5, 11),
            Set.of(TafTapLocationReference.of("CH00002"), TafTapLocationReference.of("CH00003"))
        );

        List<NoticeMatch> result = underTest.findMatches(request, null);

        assertThat(result)
            .hasSize(2)
            .anySatisfy(relevantNotice -> {
                assertThat(relevantNotice.tafTapLocationReference()).isEqualTo(TafTapLocationReference.of("CH00002"));
                assertThat(relevantNotice.noticeContents()).containsExactly(
                    new NoticeTemplateContent("Hinweis 1", "Text 1"),
                    new NoticeTemplateContent("Hinweis 2", "Text 2")
                );
            })
            .anySatisfy(relevantNotice -> {
                assertThat(relevantNotice.tafTapLocationReference()).isEqualTo(TafTapLocationReference.of("CH00003"));
                assertThat(relevantNotice.noticeContents()).containsExactly(new NoticeTemplateContent("Hinweis 2", "Text 2"));
            });
    }

    @Test
    void findMatches_appliesTrainParityAndRange() {
        NoticeRepository noticeRepository = new InMemoryNoticeRepository();
        noticeRepository.save(new Notice(null,
            new NoticeContent(null, DEFAULT_DE_CONTENT, null, null),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(new NoticeTrainNumberFilterRequest("300-310", TrainNumberParity.EVEN)),
                Set.of(TafTapLocationReference.of("CH00010"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of(DayOfWeek.TUESDAY)))
        ));
        underTest = new NoticeMatchServiceImpl(noticeRepository, new InMemorySpecialHolidayRepository());

        NoticeMatchesRequest oddTrainRequest = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            301,
            LocalDate.of(2026, 1, 6),
            Set.of(TafTapLocationReference.of("CH00010"))
        );

        NoticeMatchesRequest evenTrainRequest = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            302,
            LocalDate.of(2026, 1, 6),
            Set.of(TafTapLocationReference.of("CH00010"))
        );

        assertThat(underTest.findMatches(oddTrainRequest, null)).isEmpty();
        assertThat(underTest.findMatches(evenTrainRequest, null)).hasSize(1);
    }

    @Test
    void findMatches_requiresLocationIntersection() {
        NoticeRepository noticeRepository = new InMemoryNoticeRepository();
        noticeRepository.save(new Notice(null,
            new NoticeContent(null, DEFAULT_DE_CONTENT, null, null),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00050"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of()))
        ));
        underTest = new NoticeMatchServiceImpl(noticeRepository, new InMemorySpecialHolidayRepository());

        NoticeMatchesRequest requestWithoutOverlap = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            999,
            LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00051"))
        );

        assertThat(underTest.findMatches(requestWithoutOverlap, null)).isEmpty();
    }

    @Test
    void findMatches_matchesMondayWeekdayForMondayScheduleSpecialHoliday() {
        NoticeRepository noticeRepository = new InMemoryNoticeRepository();
        noticeRepository.save(new Notice(null,
            new NoticeContent(null, DEFAULT_DE_CONTENT, null, null),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00070"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
        ));

        InMemorySpecialHolidayRepository specialHolidayRepository = new InMemorySpecialHolidayRepository();
        specialHolidayRepository.save(new SpecialHoliday(null, "Special Monday", LocalDate.of(2026, 5, 14), ScheduleType.MONDAY_SCHEDULE, Set.of(new CompanyCode("1111"))));

        underTest = new NoticeMatchServiceImpl(noticeRepository, specialHolidayRepository);

        NoticeMatchesRequest request = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            300,
            LocalDate.of(2026, 5, 14),
            Set.of(TafTapLocationReference.of("CH00070"))
        );

        assertThat(underTest.findMatches(request, null)).hasSize(1);
    }

    @Test
    void findMatches_matchesOriginalTrainForShadowRequestOnly() {
        NoticeRepository noticeRepository = new InMemoryNoticeRepository();
        noticeRepository.save(new Notice(null,
            new NoticeContent(null, DEFAULT_DE_CONTENT, null, null),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(new NoticeTrainNumberFilterRequest("150", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00080"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
        ));
        noticeRepository.save(new Notice(null,
            new NoticeContent(null, new NoticeTemplateContent("Hinweis Shadow", "Text Shadow"), null, null),
            new NoticeScope(
                Set.of(new CompanyCode("1111")),
                List.of(new NoticeTrainNumberFilterRequest("70160", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00081"))
            ),
            List.of(new NoticePeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
        ));

        underTest = new NoticeMatchServiceImpl(noticeRepository, new InMemorySpecialHolidayRepository());

        NoticeMatchesRequest shadowTrainRequest = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            70_150,
            LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00080"))
        );
        NoticeMatchesRequest originalTrainRequest = new NoticeMatchesRequest(
            new CompanyCode("1111"),
            160,
            LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00081"))
        );

        assertThat(underTest.findMatches(shadowTrainRequest, null)).hasSize(1);
        assertThat(underTest.findMatches(originalTrainRequest, null)).isEmpty();
    }
}



