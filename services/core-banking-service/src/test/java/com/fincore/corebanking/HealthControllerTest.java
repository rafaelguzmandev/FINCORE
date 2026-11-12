package com.fincore.corebanking;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;

/**
 * Verifies the health endpoint behavior.
 * <p>
 * Full application startup is verified by {@link CoreBankingServiceApplicationTests#contextLoads()}
 * using {@link org.springframework.boot.test.context.SpringBootTest}.
 */
class HealthControllerTest {

	@Test
	void healthEndpointReturnsUp() {
		HealthController controller = new HealthController();
		ReflectionTestUtils.setField(controller, "service", "core-banking-service");

		ResponseEntity<Map<String, String>> response = controller.health();

		assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
		assertThat(response.getBody().get("status")).isEqualTo("UP");
		assertThat(response.getBody().get("service")).isEqualTo("core-banking-service");
	}
}
