package com.fincore.corebanking;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Basic health endpoint.
 * <p>
 * Reports that the service is up. No database connection is attempted here so
 * the service can start and be health-checked independently of the database.
 */
@RestController
public class HealthController {

	@Value("${spring.application.name:core-banking-service}")
	private String service;

	@GetMapping("/health")
	public ResponseEntity<Map<String, String>> health() {
		Map<String, String> body = new LinkedHashMap<>();
		body.put("status", "UP");
		body.put("service", service);
		return ResponseEntity.ok(body);
	}
}
