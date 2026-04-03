package com.haraay.ywarchitects.service;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.haraay.ywarchitects.exception.ImageUploadException;

import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

@Service

public class S3Service {

	@Value("${cloud.aws.s3.bucket}")
	private String bucketName;

	@Autowired
	private  S3Client s3Client;

	

	public String generateFileName(MultipartFile file) {
		String original = file.getOriginalFilename();

		if (original == null || original.isBlank()) {
			throw new ImageUploadException("Invalid file name");
		}

		// remove path info (important for Windows uploads)
		original = original.replace("\\", "/");
		original = original.substring(original.lastIndexOf("/") + 1);

		// split name and extension
		int dotIndex = original.lastIndexOf(".");
		String name = (dotIndex > 0) ? original.substring(0, dotIndex) : original;
		String extension = (dotIndex > 0) ? original.substring(dotIndex) : "";

		// sanitize name (VERY IMPORTANT)
		name = name.trim().replaceAll("[^a-zA-Z0-9-_]", "_");

		// short UUID (cleaner than full UUID)
		String randomId = UUID.randomUUID().toString().substring(0, 8);

		return name + "_" + randomId + extension;
	}

	public String uploadFile(MultipartFile file) {
		String fileName = this.generateFileName(file);

		try {
			PutObjectRequest putReq = PutObjectRequest.builder().bucket(bucketName).key(fileName)
//                    .acl("public-read")
					.contentType(file.getContentType()).build();

			s3Client.putObject(putReq, RequestBody.fromBytes(file.getBytes()));
			// Return the public URL
			return s3Client.utilities().getUrl(builder -> builder.bucket(bucketName).key(fileName)).toExternalForm();
		} catch (IOException e) {
			throw new ImageUploadException("Failed to upload file" + e.getMessage());
		}
	}
	
	public String uploadProfileImage(MultipartFile file,String userName) {
		String fileName = userName+"profileimage";

		try {
			PutObjectRequest putReq = PutObjectRequest.builder().bucket(bucketName).key(fileName)
//                    .acl("public-read")
					.contentType(file.getContentType()).build();

			s3Client.putObject(putReq, RequestBody.fromBytes(file.getBytes()));
			// Return the public URL
			return s3Client.utilities().getUrl(builder -> builder.bucket(bucketName).key(fileName)).toExternalForm();
		} catch (IOException e) {
			throw new ImageUploadException("Failed to upload file" + e.getMessage());
		}
	}

	public void deleteFileByUrl(String fullUrl) {
		try {
			URI uri = new URI(fullUrl);
			// uri.getPath() returns "/bucketName/<key>" if using virtual‐hosted–style URL,
			// or just "/<key>" if path‐style. We handle both cases.

			String path = uri.getPath(); // e.g. "/7f724638-5076-4bc3-a5f2-80939204be09_.png"
			String key;
			// If path starts with "/" + bucketName + "/", strip that prefix:
			String prefix = "/" + bucketName + "/";
			if (path.startsWith(prefix)) {
				key = path.substring(prefix.length());
			} else if (path.startsWith("/")) {
				// e.g. "/7f724638-5076-4bc3-a5f2-80939204be09_.png"
				key = path.substring(1);
			} else {
				key = path;
			}

			DeleteObjectRequest deleteReq = DeleteObjectRequest.builder().bucket(bucketName).key(key).build();
			s3Client.deleteObject(deleteReq);

		} catch (URISyntaxException e) {
			throw new RuntimeException("Invalid S3 URL: " + fullUrl, e);
		}
	}

//	public String uploadAttendanceImage(MultipartFile file, String employeeName) {
//
//		String fileName = employeeName + UUID.randomUUID().toString();
//
//		try {
//			PutObjectRequest putReq = PutObjectRequest.builder().bucket(bucketName).key(fileName)
////                    .acl("public-read")
//					.contentType(file.getContentType()).build();
//
//			s3Client.putObject(putReq, RequestBody.fromBytes(file.getBytes()));
//			// Return the public URL
//			return s3Client.utilities().getUrl(builder -> builder.bucket(bucketName).key(fileName)).toExternalForm();
//		} catch (IOException e) {
//			throw new ImageUploadException("Failed to upload file" + e.getMessage());
//		}
//	}
	
	public String uploadWebsiteImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ImageUploadException("Image file must not be empty");
        }
 
        String original = file.getOriginalFilename();
        if (original == null || original.isBlank()) {
            throw new ImageUploadException("Invalid file name");
        }
 
        // Normalize path separators (Windows safety)
        original = original.replace("\\", "/");
        original = original.substring(original.lastIndexOf("/") + 1);
 
        // Split name and extension
        int dotIndex     = original.lastIndexOf(".");
        String name      = (dotIndex > 0) ? original.substring(0, dotIndex) : original;
        String extension = (dotIndex > 0) ? original.substring(dotIndex)    : "";
 
        // Sanitize name — keep only safe characters
        name = name.trim().replaceAll("[^a-zA-Z0-9-_]", "_");
 
        // Build final key with "website_" prefix
        String randomId  = UUID.randomUUID().toString().substring(0, 8);
        String fileName  = "website_" + name + "_" + randomId + extension;
 
        try {
            PutObjectRequest putReq = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(fileName)
                    .contentType(file.getContentType())
                    .build();
 
            s3Client.putObject(putReq, RequestBody.fromBytes(file.getBytes()));
 
            return s3Client.utilities()
                    .getUrl(builder -> builder.bucket(bucketName).key(fileName))
                    .toExternalForm();
 
        } catch (IOException e) {
            throw new ImageUploadException("Failed to upload website image: " + e.getMessage());
        }
    }
}
