package com.greenbite.backend.service;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
public class FileStorageService {

    @Autowired
    private Storage storage;

    @Value("${gcs.bucket-name}") // Inject the bucket name from application.properties
    private String bucketName;

    // Save a file to Google Cloud Storage and return the public URL
    public String saveFile(MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            throw new RuntimeException("Failed to store empty file.");
        }

        // Generate a unique file name
        String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();

        // Upload the file to GCS
        BlobId blobId = BlobId.of(bucketName, fileName);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId).build();
        storage.create(blobInfo, file.getBytes());

        // Return the public URL of the uploaded file
        return String.format("https://storage.googleapis.com/%s/%s", bucketName, fileName);
    }

    // Delete a file from Google Cloud Storage
    public void deleteFile(String fileName) throws IOException {
        BlobId blobId = BlobId.of(bucketName, fileName);
        storage.delete(blobId);
    }
}