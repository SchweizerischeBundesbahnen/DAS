package ch.sbb.backend.preload.domain;

import ch.sbb.backend.preload.infrastructure.xml.XmlDateHelper;
import ch.sbb.backend.preload.sfera.model.v0300.JPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.OTNID;
import ch.sbb.backend.preload.sfera.model.v0300.TrainIdentification;
import java.time.LocalDate;

public record TrainId(String companyCode, String operationalTrainNumber, LocalDate startDate) {

    public JPRequest toJpRequest() {
        JPRequest result = new JPRequest();
        TrainIdentification trainIdentification = new TrainIdentification();
        OTNID otnid = new OTNID();
        otnid.setTeltsiCompany(companyCode);
        otnid.setTeltsiOperationalTrainNumber(operationalTrainNumber);
        otnid.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(startDate));
        trainIdentification.setOTNID(otnid);
        result.setTrainIdentification(trainIdentification);
        return result;
    }
}
