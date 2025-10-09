package ch.sbb.backend.preload;

import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.mqttv5.client.IMqttMessageListener;
import org.eclipse.paho.mqttv5.client.MqttClient;
import org.eclipse.paho.mqttv5.client.MqttConnectionOptions;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.eclipse.paho.mqttv5.common.MqttSubscription;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class PahoMqttClient {

    public static final String USER_NAME = "JWT";
    public static final String SECRET_PREFIX = "OAUTH";
    public static final String SECRET_DELIMITER = "~";

    private final SferaAuthService sferaAuthService;
    private final int qos = 2;

    @Value("${sfera.broker-url}")
    String broker;

    @Value("${sfera.clientId}")
    String clientId;

    @Value("${sfera.oauth-profile}")
    String oauthProfile;

    private MqttClient client;

    public PahoMqttClient(SferaAuthService sferaAuthService) {
        this.sferaAuthService = sferaAuthService;
    }

    public void subscribe(final String topicFilter, final IMqttMessageListener messageListener) {
        try {
            final MqttSubscription[] subscriptions = {new MqttSubscription(topicFilter, qos)};
            IMqttMessageListener[] messageListeners = {messageListener};
            client.subscribe(subscriptions, messageListeners);
        } catch (final MqttException mqttException) {
            log.error("Error subscribing to topic: {}", topicFilter, mqttException);
        }
    }

    void connect() throws MqttException {
        OAuth2AccessToken accessToken = sferaAuthService.getAccessToken();
        if (accessToken == null) {
            log.error("Cannot connect to MQTT broker, could not obtain access token");
            return;
        }
        String password = SECRET_PREFIX + SECRET_DELIMITER + oauthProfile + SECRET_DELIMITER + accessToken.getTokenValue();
        this.client = new MqttClient(broker, clientId);
        MqttConnectionOptions connOpts = new MqttConnectionOptions();
        connOpts.setCleanStart(true);
        connOpts.setUserName(USER_NAME);
        connOpts.setPassword(password.getBytes());
        client.connect(connOpts);
    }

    void publish(String topic, String content) {
        MqttMessage message = new MqttMessage(content.getBytes());
        message.setQos(qos);
        try {
            client.publish(topic, message);
        } catch (MqttException e) {
            log.error("Got exception while publishing message to topic={} message={}.... ", topic, content.substring(0, 100), e);
        }
    }

    public void disconnect() {
        try {
            client.disconnect();
            client.close();
        } catch (final MqttException mqttException) {
            log.error("Got exception while closing connection ", mqttException);
        }
    }
}
