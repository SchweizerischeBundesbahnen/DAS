package ch.sbb.backend.preload;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.core.sync.ResponseTransformer;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

@Service
public class S3Service {

    private final S3Client s3Client;

    @Value("${aws.bucketName}")
    private String bucketName;

    public S3Service(S3Client s3Client) {
        this.s3Client = s3Client;
    }

    public void uploadFile(String key, Path filePath) {
        PutObjectRequest putObjectRequest = PutObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .build();

        s3Client.putObject(putObjectRequest, RequestBody.fromFile(filePath));
        System.out.println("Uploaded " + filePath + " to s3://" + bucketName + "/" + key);
    }

    public void downloadFile(String key, Path destination) {
        GetObjectRequest getObjectRequest = GetObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .build();

        s3Client.getObject(getObjectRequest, ResponseTransformer.toFile(destination));
        System.out.println("Downloaded s3://" + bucketName + "/" + key + " to " + destination);
    }

    // Für Swagger-Download als Bytes
    public byte[] getObjectBytes(String key) {
        GetObjectRequest req = GetObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .build();
        ResponseBytes<GetObjectResponse> bytes = s3Client.getObject(req, ResponseTransformer.toBytes());
        return bytes.asByteArray();
    }

    // Objekte unter Prefix auflisten (Paginator)
    public List<S3Object> listObjects(String prefix) {
        List<S3Object> out = new ArrayList<>();
        ListObjectsV2Request req = ListObjectsV2Request.builder()
            .bucket(bucketName)
            .prefix(prefix == null ? "" : prefix)
            .build();

        s3Client.listObjectsV2Paginator(req)
            .stream()
            .flatMap(r -> r.contents().stream())
            .forEach(out::add);
        return out;
    }

    public void deleteObject(String key) {
        s3Client.deleteObject(DeleteObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .build());
        System.out.println("Deleted s3://" + bucketName + "/" + key);
    }
}
