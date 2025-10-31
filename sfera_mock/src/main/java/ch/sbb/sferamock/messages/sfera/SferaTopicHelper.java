package ch.sbb.sferamock.messages.sfera;

import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;

final class SferaTopicHelper {

    private SferaTopicHelper() {
    }

    public static String getG2BTopic(String[] publishDestinations, RequestContext requestContext) {
        return getTopic(publishDestinations, requestContext);
    }

    // for testing purposes events are sent to a topic with the clientId as suffix (like reply/request)
    public static String getG2BEventTopic(String[] publishDestinations, RequestContext requestContext) {
        return getTopic(publishDestinations, requestContext);
    }

    private static String getTopic(String[] publishDestinations, RequestContext requestContext) {
        String publishDestination = Arrays.asList(publishDestinations).stream().filter(s -> {
            String[] elements = s.split("/");
            String version = elements[elements.length - 2];
            return requestContext.version().value().equals(version);
        }).findFirst().get();
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
