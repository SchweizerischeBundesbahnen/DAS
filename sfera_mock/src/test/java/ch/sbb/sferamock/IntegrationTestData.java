package ch.sbb.sferamock;

import ch.sbb.sferamock.messages.model.CompanyCode;
import com.solacesystems.jcsmp.Topic;
import com.solacesystems.jcsmp.impl.TopicImpl;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;
import lombok.experimental.UtilityClass;

@UtilityClass
public class IntegrationTestData {

    public static final CompanyCode RU_COMPANY_CODE_SBB_AG = new CompanyCode("1085");
    public static final CompanyCode IM_COMPANY_CODE_SBB_INFRA = new CompanyCode("0085");

    public static final String OPERATIONAL_NUMBER_T9999 = "T9999";

    public static final LocalDate START_DATE = LocalDate.of(2024, 8, 15);

    public static final UUID CLIENT_ID = UUID.randomUUID();

    public static final String B2G_TOPIC_PREFIX = "90940/2/B2G/";
    public static final String TRAIN_AND_CLIENT_ID_TOPIC_ELEMENTS = "/" + OPERATIONAL_NUMBER_T9999 + "_" + START_DATE.format(DateTimeFormatter.ISO_DATE) + "/" + CLIENT_ID;

    public static final Topic SFERA_INCOMING_TOPIC = TopicImpl.createFastNoValidation(B2G_TOPIC_PREFIX + RU_COMPANY_CODE_SBB_AG.value() + TRAIN_AND_CLIENT_ID_TOPIC_ELEMENTS);

}
