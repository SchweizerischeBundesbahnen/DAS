package ch.sbb.backend.preload.infrastructure;

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

    private static final String USER_NAME = "JWT";
    private static final String SECRET_PREFIX = "OAUTH";
    private static final String SECRET_DELIMITER = "~";
    private static final int QOS_EXACTLY_ONCE = 2;

    private final SferaAuthService sferaAuthService;

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

    public void connect() {
        OAuth2AccessToken accessToken = sferaAuthService.getAccessToken();
        if (accessToken == null) {
            log.error("connecting failed, could not obtain access token");
            return;
        }
        final String password = SECRET_PREFIX + SECRET_DELIMITER + oauthProfile + SECRET_DELIMITER + accessToken.getTokenValue();
        MqttConnectionOptions connOpts = new MqttConnectionOptions();
        connOpts.setCleanStart(true);
        connOpts.setUserName(USER_NAME);
        connOpts.setPassword(password.getBytes());
        try {
            this.client = new MqttClient(broker, clientId);
            client.connect(connOpts);
        } catch (MqttException e) {
            log.error("connecting failed ", e);
        }
    }

    public void subscribe(String topic, IMqttMessageListener messageListener) {
        try {
            final MqttSubscription[] subscriptions = {new MqttSubscription(topic, QOS_EXACTLY_ONCE)};
            IMqttMessageListener[] messageListeners = {messageListener};
            client.subscribe(subscriptions, messageListeners);
        } catch (MqttException e) {
            log.error("subscribing failed to topic: {}", topic, e);
        }
    }

    public void publish(String topic, String content) {
        MqttMessage message = new MqttMessage(content.getBytes());
        message.setQos(QOS_EXACTLY_ONCE);
        try {
            client.publish(topic, message);
        } catch (MqttException e) {
            log.error("publishing failed message={}... to topic={}", content.substring(0, 100), topic, e);
        }
    }

    public void disconnect() {
        try {
            client.disconnect();
            client.close();
        } catch (MqttException e) {
            log.error("closing failed ", e);
        }
    }
}
