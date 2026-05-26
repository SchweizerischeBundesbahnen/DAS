package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.ruindications.model.Content;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplate;
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

@Table(name = "ru_indication_template")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class RuIndicationTemplateEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "ru_indication_template_id_seq")
    @SequenceGenerator(name = "ru_indication_template_id_seq", allocationSize = 1)
    private Integer id;

    private String category;

    private String titleDe;

    private String textDe;

    private String titleFr;

    private String textFr;

    private String titleIt;

    private String textIt;

    public RuIndicationTemplate toRuIndicationTemplate() {
        return new RuIndicationTemplate(id, category, new Content(titleDe, textDe), new Content(titleFr, textFr), new Content(titleIt, textIt),
            getLastModifiedBy());
    }
}
