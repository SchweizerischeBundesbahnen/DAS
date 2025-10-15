package ch.sbb.backend.preload;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

@Service
public class S3Service {

    private final S3Client s3Client;

    private static final String CONTENT_TYPE_ZIP = "application/zip";

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
}
