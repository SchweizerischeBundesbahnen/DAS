package ch.sbb.backend.preload.infrastructure;

import jakarta.annotation.PreDestroy;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.mqttv5.client.IMqttMessageListener;
import org.eclipse.paho.mqttv5.client.MqttClient;
import org.eclipse.paho.mqttv5.client.MqttConnectionOptions;
import org.eclipse.paho.mqttv5.client.persist.MemoryPersistence;
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
    private final Object connectLock = new Object();

    public PahoMqttClient(SferaAuthService sferaAuthService) {
        this.sferaAuthService = sferaAuthService;
    }

    public void connect() {
        synchronized (connectLock) {
            reconnectInternal();
        }
    }

    private void reconnectInternal() {
        OAuth2AccessToken accessToken = sferaAuthService.getAccessToken();
        if (accessToken == null) {
            throw new IllegalStateException("MQTT connect failed: cannot obtain access token");
        }
        closeClientQuietly();
        final String password = SECRET_PREFIX + SECRET_DELIMITER + oauthProfile + SECRET_DELIMITER + accessToken.getTokenValue();
        MqttConnectionOptions connOpts = new MqttConnectionOptions();
        connOpts.setCleanStart(true);
        connOpts.setAutomaticReconnect(true);
        connOpts.setUserName(USER_NAME);
        connOpts.setPassword(password.getBytes());
        try {
            this.client = new MqttClient(broker, clientId, new MemoryPersistence());
            client.connect(connOpts);
        } catch (MqttException e) {
            closeClientQuietly();
            throw new IllegalStateException("MQTT connect failed", e);
        }
    }

    public void subscribe(String topic, IMqttMessageListener messageListener) throws MqttException {
        ensureConnected();
        final MqttSubscription[] subscriptions = {new MqttSubscription(topic, QOS_EXACTLY_ONCE)};
        IMqttMessageListener[] messageListeners = {messageListener};
        client.subscribe(subscriptions, messageListeners);
    }

    public void unsubscribe(String topic) {
        try {
            client.unsubscribe(topic);
        } catch (MqttException e) {
            log.error("unsubscribing failed to topic: {}", topic, e);
        }
    }

    public void publish(String topic, String content) throws MqttException {
        ensureConnected();
        MqttMessage message = new MqttMessage(content.getBytes());
        message.setQos(QOS_EXACTLY_ONCE);
        client.publish(topic, message);
    }

    public void disconnect() {
        synchronized (connectLock) {
            closeClientQuietly();
        }
    }

    private void closeClientQuietly() {
        try {
            if (client != null) {
                if (client.isConnected()) {
                    client.disconnect();
                }
                client.close();
            }
        } catch (MqttException e) {
            log.warn("mqtt client closing failed ", e);
        } finally {
            client = null;
        }
    }

    private void ensureConnected() {
        synchronized (connectLock) {
            if (client == null || !client.isConnected()) {
                reconnectInternal();
            }
        }
    }

    @PreDestroy
    public void predestroy()  {
        closeClientQuietly();
    }
}
