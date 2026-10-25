package com.razwan;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class AppContractTest {

    @Container
    static GenericContainer<?> appContainer = new GenericContainer<>(DockerImageName.parse("advanced-cicd-app:2.0.0"))
            .withExposedPorts(8080)
            .withEnv("SPRING_PROFILES_ACTIVE", "test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", () -> "jdbc:tc:postgresql:15:///testdb");
    }

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void healthEndpointContract() {
        // Test the health endpoint contract
        ResponseEntity<String> response = restTemplate.getForEntity("/actuator/health", String.class);
        
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getHeaders().getContentType()).isNotNull();
        assertThat(response.getHeaders().getContentType().toString()).startsWith("application/json");
        
        // Verify JSON structure
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody()).contains("status");
        assertThat(response.getBody()).contains("UP");
    }

    @Test
    void rootEndpointContract() {
        // Test the root endpoint contract
        ResponseEntity<String> response = restTemplate.getForEntity("/", String.class);
        
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getHeaders().getContentType()).isNotNull();
        assertThat(response.getHeaders().getContentType().toString()).startsWith("text/plain");
        
        // Verify response content
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody()).contains("Advanced CI/CD Pipeline App");
    }

    @Test
    void actuatorInfoEndpointContract() {
        // Test the info endpoint contract
        ResponseEntity<String> response = restTemplate.getForEntity("/actuator/info", String.class);
        
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getHeaders().getContentType()).isNotNull();
        assertThat(response.getHeaders().getContentType().toString()).startsWith("application/json");
    }
}