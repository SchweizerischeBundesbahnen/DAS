package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplate;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplateContent;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplateRequest;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(name = "notice_template")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class NoticeTemplateEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "notice_template_id_seq")
    @SequenceGenerator(name = "notice_template_id_seq", allocationSize = 1)
    private Integer id;

    private String category;

    private String titleDe;

    private String textDe;

    private String titleFr;

    private String textFr;

    private String titleIt;

    private String textIt;

    public static NoticeTemplateEntity from(NoticeTemplateRequest createRequest) {
        NoticeTemplateEntity entity = new NoticeTemplateEntity();
        entity.setCategory(createRequest.category());
        if (createRequest.de() != null) {
            entity.setTitleDe(createRequest.de().title());
            entity.setTextDe(createRequest.de().text());
        }
        if (createRequest.fr() != null) {
            entity.setTitleFr(createRequest.fr().title());
            entity.setTextFr(createRequest.fr().text());
        }
        if (createRequest.it() != null) {
            entity.setTitleIt(createRequest.it().title());
            entity.setTextIt(createRequest.it().text());
        }
        return entity;
    }

    public NoticeTemplate toNoticeTemplate() {
        return new NoticeTemplate(id, category, new NoticeTemplateContent(titleDe, textDe), new NoticeTemplateContent(titleFr, textFr), new NoticeTemplateContent(titleIt, textIt),
            getLastModifiedBy());
    }
}
