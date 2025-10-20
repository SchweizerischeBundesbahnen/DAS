package ch.sbb.backend.preload.domain;

import ch.sbb.backend.preload.infrastructure.xml.XmlDateHelper;
import ch.sbb.backend.preload.sfera.model.v0300.JPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.OTNIDComplexType;
import ch.sbb.backend.preload.sfera.model.v0300.TrainIdentificationComplexType;
import java.time.LocalDate;

public record TrainIdentification(String companyCode, String operationalTrainNumber, LocalDate startDate) {

    public JPRequest toJpRequest() {
        JPRequest result = new JPRequest();
        TrainIdentificationComplexType trainIdentification = new TrainIdentificationComplexType();
        OTNIDComplexType otnid = new OTNIDComplexType();
        otnid.setTeltsiCompany(companyCode);
        otnid.setTeltsiOperationalTrainNumber(operationalTrainNumber);
        otnid.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(startDate));
        trainIdentification.setOTNID(otnid);
        result.setTrainIdentification(trainIdentification);
        return result;
    }
}
