package ch.sbb.backend.preload.infrastructure.util;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.utils.Bytes;
import tools.jackson.databind.json.JsonMapper;

public class KafkaDeserializer<K, V> {

    private final JsonMapper objectMapper;
    private final Class<K> keyClass;
    private final Class<V> valueClass;

    public KafkaDeserializer(JsonMapper objectMapper, Class<K> keyClass, Class<V> valueClass) {
        this.objectMapper = objectMapper;
        this.keyClass = keyClass;
        this.valueClass = valueClass;
    }

    public K deserializeKey(ConsumerRecord<Bytes, Bytes> r) {
        return objectMapper.readValue(r.key().get(), keyClass);
    }

    public V deserializeValue(final ConsumerRecord<Bytes, Bytes> r) {
        return objectMapper.readValue(r.value().get(), valueClass);
    }

    public ConsumerRecord<K, V> deserializeRecord(final ConsumerRecord<Bytes, Bytes> r) {
        K k = deserializeKey(r);
        V v = deserializeValue(r);
        return new ConsumerRecord<>(r.topic(), r.partition(), r.offset(), r.timestamp(), r.timestampType(), r.serializedKeySize(), r.serializedValueSize(),
            k, v, r.headers(), r.leaderEpoch());
    }
}
