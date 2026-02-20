package ch.sbb.backend.preload.infrastructure;

import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectsRequest;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.ObjectIdentifier;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Error;
import software.amazon.awssdk.services.s3.model.S3Object;

@Service
@Slf4j
public class S3Service {

    private static final String CONTENT_TYPE_ZIP = "application/zip";

    private final S3Client s3Client;

    @Value("${aws.bucketName}")
    private String bucketName;

    public S3Service(S3Client s3Client) {
        this.s3Client = s3Client;
    }

    public void uploadZip(String key, byte[] data) {
        PutObjectRequest put = PutObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .contentType(CONTENT_TYPE_ZIP)
            .build();
        s3Client.putObject(put, RequestBody.fromBytes(data));
    }

    public List<String> listObjects() {
        ListObjectsV2Request listReq = ListObjectsV2Request.builder()
            .bucket(bucketName)
            .build();

        return s3Client.listObjectsV2(listReq).contents().stream().map(S3Object::key).toList();
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
}
