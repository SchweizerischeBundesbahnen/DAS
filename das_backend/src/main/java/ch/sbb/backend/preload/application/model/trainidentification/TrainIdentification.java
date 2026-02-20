package ch.sbb.backend.preload.application.model.trainidentification;

import ch.sbb.backend.preload.infrastructure.xml.XmlDateHelper;
import ch.sbb.backend.preload.sfera.model.v0300.JPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.OTNID;
import java.time.LocalDate;
import java.util.Set;
import lombok.NonNull;

public record TrainIdentification(@NonNull Integer id, @NonNull String operationalTrainNumber, @NonNull LocalDate startDate, @NonNull Set<CompanyCode> companies) {

    public CompanyCode company() {
        return companies.stream().findFirst().orElseThrow(() -> new IllegalStateException("TrainIdentification must have at least one company"));
    }

    public JPRequest toJpRequest() {
        JPRequest result = new JPRequest();
        ch.sbb.backend.preload.sfera.model.v0300.TrainIdentification trainIdentification = new ch.sbb.backend.preload.sfera.model.v0300.TrainIdentification();
        OTNID otnid = new OTNID();
        otnid.setTeltsiCompany(company().getValue());
        otnid.setTeltsiOperationalTrainNumber(operationalTrainNumber);
        otnid.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(startDate));
        trainIdentification.setOTNID(otnid);
        result.setTrainIdentification(trainIdentification);
        return result;
    }
}
