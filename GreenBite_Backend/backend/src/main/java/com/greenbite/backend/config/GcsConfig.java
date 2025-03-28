package com.greenbite.backend.config;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.IOException;

@Configuration
public class GcsConfig {
    @Bean
    public Storage storage() throws IOException {
        // Load the service account key file
        GoogleCredentials credentials = GoogleCredentials.fromStream(

            new FileInputStream("D:/IIT Second Year/Green Bite/gleaming-orbit-453215-j2-3c2c20f90023.json")

        );

        return StorageOptions.newBuilder()
                .setCredentials(credentials)
                .build()
                .getService();
    }
}
