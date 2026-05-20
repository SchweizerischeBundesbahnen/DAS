package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import ch.sbb.das.backend.admin.application.notices.model.NoticeContent;
import ch.sbb.das.backend.admin.application.notices.model.NoticePeriod;
import ch.sbb.das.backend.admin.application.notices.model.NoticeScope;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplateContent;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTrainNumberFilterRequest;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.common.CompanyCodeListConverter;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(name = "notice")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class NoticeEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "notice_id_seq")
    @SequenceGenerator(name = "notice_id_seq", allocationSize = 1)
    private Integer id;

    private String category;

    private String titleDe;

    private String textDe;

    private String titleFr;

    private String textFr;

    private String titleIt;

    private String textIt;

    @Convert(converter = CompanyCodeListConverter.class)
    private List<CompanyCode> companies;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<NoticeTrainNumberFilterRequest> operationalTrainNumberFilters;

    @Convert(converter = TafTapLocationReferenceListConverter.class)
    private List<TafTapLocationReference> tafTapLocationReferences;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<NoticePeriod> periods;

    public static NoticeEntity from(Notice notice) {
        NoticeEntity entity = new NoticeEntity();
        entity.setId(notice.id());
        if (notice.content() != null) {
            entity.setCategory(notice.content().category());
            if (notice.content().de() != null) {
                entity.setTitleDe(notice.content().de().title());
                entity.setTextDe(notice.content().de().text());
            }
            if (notice.content().fr() != null) {
                entity.setTitleFr(notice.content().fr().title());
                entity.setTextFr(notice.content().fr().text());
            }
            if (notice.content().it() != null) {
                entity.setTitleIt(notice.content().it().title());
                entity.setTextIt(notice.content().it().text());
            }
        }
        if (notice.scope() != null) {
            entity.setCompanies(notice.scope().companies() == null ? List.of() : notice.scope().companies().stream().distinct().toList());
            entity.setOperationalTrainNumberFilters(notice.scope().operationalTrainNumberFilters() == null ? List.of() : notice.scope().operationalTrainNumberFilters());
            entity.setTafTapLocationReferences(notice.scope().tafTapLocationReferences() == null ? List.of() : notice.scope().tafTapLocationReferences().stream().distinct().toList());
        }
        entity.setPeriods(notice.periods());
        return entity;
    }

    private static NoticeTemplateContent toTemplateContent(String title, String text) {
        if (title == null && text == null) {
            return null;
        }
        return new NoticeTemplateContent(title, text);
    }

    public Notice toNotice() {
        NoticeContent content = new NoticeContent(
            category,
            toTemplateContent(titleDe, textDe),
            toTemplateContent(titleFr, textFr),
            toTemplateContent(titleIt, textIt)
        );

        NoticeScope scope = new NoticeScope(
            companies == null ? Set.of() : new HashSet<>(companies),
            operationalTrainNumberFilters == null ? List.of() : operationalTrainNumberFilters,
            tafTapLocationReferences == null ? Set.of() : new HashSet<>(tafTapLocationReferences)
        );

        return new Notice(
            id,
            content,
            scope,
            periods == null ? List.of() : periods,
            getLastModifiedAt(),
            getLastModifiedBy()
        );
    }
}
