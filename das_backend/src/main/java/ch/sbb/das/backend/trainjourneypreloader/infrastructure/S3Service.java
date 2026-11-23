package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import java.util.List;
import java.util.Optional;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration.PreloadBucketProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

@Service
@Slf4j
public class S3Service {

    private static final String CONTENT_TYPE_ZIP = "application/zip";

    private final S3Client s3Client;

    private final String bucketName;

    public S3Service(S3Client s3Client, PreloadBucketProperties preloadBucketProperties) {
        this.s3Client = s3Client;
        this.bucketName = preloadBucketProperties.name();
    }

    public void uploadZip(String key, byte[] data) {
        PutObjectRequest put = PutObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .contentType(CONTENT_TYPE_ZIP)
            .build();
        s3Client.putObject(put, RequestBody.fromBytes(data));
    }

    public Optional<byte[]> downloadZip(String key) {
        try {
            GetObjectRequest get = GetObjectRequest.builder()
                .bucket(bucketName)
                .key(key)
                .build();
            ResponseBytes<GetObjectResponse> response = s3Client.getObjectAsBytes(get);
            return Optional.of(response.asByteArray());
        } catch (NoSuchKeyException _) {
            return Optional.empty();
        }
    }

    /** The objects in the bucket with their size in bytes. */
    public List<BucketObject> listObjects() {
        ListObjectsV2Request listReq = ListObjectsV2Request.builder()
            .bucket(bucketName)
            .build();

        return s3Client.listObjectsV2(listReq).contents().stream().map(object -> new BucketObject(object.key(), object.size())).toList();
    }

    public void deleteObjects(List<String> keys) {
        List<ObjectIdentifier> objectIds = keys.stream().map(key -> ObjectIdentifier.builder().key(key).build()).toList();
        DeleteObjectsRequest delReq = DeleteObjectsRequest.builder()
            .bucket(bucketName)
            .delete(delete -> delete.objects(objectIds))
            .build();
        List<S3Error> errors = s3Client.deleteObjects(delReq).errors();
        if (!errors.isEmpty()) {
            log.warn("Failed to delete {} objects from S3 {}", errors.size(), errors.getFirst());
        }
    }

    /** An object in the bucket: its key and its size in bytes. */
    public record BucketObject(String key, long size) {

    }
}
