package ch.sbb.sferamock.messages.sfera;

import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import java.time.format.DateTimeFormatter;

final class SferaTopicHelper {

    private SferaTopicHelper() {
    }

    public static String getG2BTopic(String publishDestination, RequestContext requestContext) {
        return getTopic(publishDestination, requestContext);
    }

    // for testing purposes events are sent to a topic with the clientId as suffix (like reply/request)
    public static String getG2BEventTopic(String publishDestination, RequestContext requestContext) {
        return getTopic(publishDestination, requestContext);
    }

    private static String getTopic(String publishDestination, RequestContext requestContext) {
        return String.format("%s%s/%s/%s", publishDestination, // publishDestination ends with a slash
            requestContext.tid().companyCode().value(),
            formatTrainIdentification(requestContext.tid()),
            requestContext.clientId().value());
    }

    private static String formatTrainIdentification(TrainIdentification tid) {
        return tid.additionalNumber().isPresent()
            ? String.format("%s_%s_%s", tid.operationalNumber(), tid.date().format(DateTimeFormatter.ISO_DATE),
            tid.additionalNumber().get())
            : String.format("%s_%s", tid.operationalNumber(), tid.date().format(DateTimeFormatter.ISO_DATE));
    }
}
