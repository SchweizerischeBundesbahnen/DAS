package ch.sbb.backend.preload.application.model.dailytrainrun;

import ch.sbb.backend.preload.infrastructure.xml.XmlDateHelper;
import ch.sbb.backend.preload.sfera.model.v0300.JPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.OTNID;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Set;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@Getter
public class TrainIdentification {

    @NonNull
    String operationalTrainNumber;

    @NonNull
    LocalDate startDate;

    @NonNull
    OffsetDateTime departureTime;

    @NonNull
    @Builder.Default
    Set<CompanyCode> companies = Set.of(); // executingRUs

    public JPRequest toJpRequest() {
        JPRequest result = new JPRequest();
        ch.sbb.backend.preload.sfera.model.v0300.TrainIdentification trainIdentification = new ch.sbb.backend.preload.sfera.model.v0300.TrainIdentification();
        OTNID otnid = new OTNID();
        otnid.setTeltsiCompany(companies.stream().findFirst().get().getValue());
        otnid.setTeltsiOperationalTrainNumber(operationalTrainNumber);
        otnid.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(startDate));
        trainIdentification.setOTNID(otnid);
        result.setTrainIdentification(trainIdentification);
        return result;
    }
}
