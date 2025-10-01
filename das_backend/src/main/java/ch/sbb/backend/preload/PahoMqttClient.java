package ch.sbb.backend.preload;

import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.mqttv5.client.IMqttMessageListener;
import org.eclipse.paho.mqttv5.client.MqttClient;
import org.eclipse.paho.mqttv5.client.MqttConnectionOptions;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.eclipse.paho.mqttv5.common.MqttSubscription;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class PahoMqttClient {

    private final int qos = 2;
    @Value("${sfera.broker-url}")
    String broker;
    @Value("${sfera.clientId}")
    String clientId;
    @Value("${sfera.username}")
    String username;
    @Value("${sfera.password}")
    String password;
    private MqttClient client;

    public void subscribe(final String topicFilter, final IMqttMessageListener messageListener) {
        try {
            final MqttSubscription[] subscriptions = {new MqttSubscription(topicFilter, qos)};
            IMqttMessageListener[] messageListeners = {messageListener};
            client.subscribe(subscriptions, messageListeners);
        } catch (final MqttException mqttException) {
            log.error("Error subscribing to topic: " + mqttException.getMessage());
        }
    }

    void connect() throws MqttException {
        this.client = new MqttClient(broker, clientId);
        MqttConnectionOptions connOpts = new MqttConnectionOptions();
        connOpts.setCleanStart(true);
        connOpts.setUserName(username);
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
