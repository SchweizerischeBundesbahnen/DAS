package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadResult;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PahoMqttClient;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.SferaMessagingConfig;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SFERAB2GRequestMessage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;
import org.eclipse.paho.mqttv5.client.IMqttMessageListener;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest(classes = {SferaService.class, SferaMessageCreator.class, XmlHelper.class, SferaMessagingConfig.class})
@ActiveProfiles("test")
class PreloadIntegrationTest {

    @Autowired
    private SferaService underTest;

    @MockitoBean
    private PahoMqttClient mqttClient;

    @MockitoBean
    private PreloadedSegmentProfileRepository preloadedSegmentProfileRepository;

    @Autowired
    private XmlHelper xmlHelper;

    private static String sferaReply(String filename, String correlationId) throws IOException {
        return Files.readString(Path.of("src/test/resources/trainjourneypreloader/" + filename)).replace("${correlationId}", correlationId);
    }

    @DisplayName("Connect delegates to mqtt client|tests:914")
    @Test
    void connect_delegatesToMqttClient() {
        underTest.connect();
        verify(mqttClient, times(1)).connect(anyString());
    }

    @DisplayName("Disconnect delegates to mqtt client|tests:914")
    @Test
    void disconnect_delegatesToMqttClient() {
        underTest.disconnect();
        verify(mqttClient, times(1)).disconnect();
    }

    @DisplayName("Preload when train identification and sfera data received results jps, sps and tcs|tests:914,1653,2271")
    @Test
    void preload_ok() throws Exception {
        AtomicReference<IMqttMessageListener> listenerRef = new AtomicReference<>();
        AtomicInteger publishCount = new AtomicInteger(0);

        doAnswer(invocation -> {
            IMqttMessageListener listener = invocation.getArgument(1, IMqttMessageListener.class);
            listenerRef.set(listener);
            return null;
        }).when(mqttClient).subscribe(anyString(), any(IMqttMessageListener.class));

        doAnswer(invocation -> {
            String publishedXml = invocation.getArgument(1, String.class);
            Object parsed = xmlHelper.xmlToObject(publishedXml);

            if (parsed instanceof SFERAB2GRequestMessage req) {
                String correlationId = req.getMessageHeader().getMessageID();
                int step = publishCount.incrementAndGet();

                String reply = switch (step) {
                    case 1 -> sferaReply("hs_ack_reply.xml", correlationId);
                    case 2 -> sferaReply("jp_reply.xml", correlationId);
                    case 3 -> sferaReply("sp_reply.xml", correlationId);
                    case 4 -> sferaReply("tc_reply.xml", correlationId);
                    default -> throw new IllegalStateException("Unexpected publish step: " + step);
                };

                listenerRef.get().messageArrived("ignored", new MqttMessage(reply.getBytes()));
            }

            return null;
        }).when(mqttClient).publish(anyString(), anyString());

        TrainIdentification trainId =
            new TrainIdentification(
                0,
                "12345",
                OffsetDateTime.now(),
                Set.of(new CompanyCode("1285")));

        PreloadResult result = underTest.preload(trainId, new HashMap<>());
        assertThat(result).isInstanceOf(PreloadResult.Success.class);

        PreloadResult.Success success = (PreloadResult.Success) result;
        assertThat(success.jp()).isNotNull();
        assertThat(success.sps()).isNotEmpty();
        assertThat(success.tcs()).isNotEmpty();

        verify(mqttClient, times(1)).unsubscribe(anyString());
        verify(mqttClient, times(4)).publish(anyString(), anyString());
    }

    @DisplayName("Preload when sfera returns hs error then nothing stored|tests:914,1653,2271")
    @Test
    void preload_throwsWhenHsError() throws Exception {
        AtomicReference<IMqttMessageListener> listenerRef = new AtomicReference<>();
        AtomicReference<String> lastPublishedXml = new AtomicReference<>();

        doAnswer(invocation -> {
            IMqttMessageListener listener = invocation.getArgument(1, IMqttMessageListener.class);
            listenerRef.set(listener);
            return null;
        })
            .when(mqttClient)
            .subscribe(anyString(), any(IMqttMessageListener.class));

        doAnswer(invocation -> {
            lastPublishedXml.set(invocation.getArgument(1, String.class));

            Object parsed = xmlHelper.xmlToObject(lastPublishedXml.get());
            if (parsed instanceof SFERAB2GRequestMessage req) {
                String correlationId = req.getMessageHeader().getMessageID();
                String reply = sferaReply("hs_error.xml", correlationId);
                listenerRef.get().messageArrived("ignored", new MqttMessage(reply.getBytes()));
            }

            return null;
        })
            .when(mqttClient)
            .publish(anyString(), anyString());

        TrainIdentification trainId =
            new TrainIdentification(
                0,
                "12345",
                OffsetDateTime.now(),
                Set.of(new CompanyCode("1285")));

        assertThatExceptionOfType(IllegalStateException.class).isThrownBy(() -> underTest.preload(trainId, new HashMap<>())).withMessage("Handshake request G2B error: 51, 54");
    }
}
