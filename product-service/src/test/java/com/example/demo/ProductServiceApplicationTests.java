package com.example.demo;

import io.restassured.RestAssured;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Import;
import org.testcontainers.mongodb.MongoDBContainer;

@Import(TestcontainersConfiguration.class)
@SpringBootTest(webEnvironment =  SpringBootTest.WebEnvironment.RANDOM_PORT)
class ProductServiceApplicationTests {
	@ServiceConnection
	static MongoDBContainer mongoDBContainer = new MongoDBContainer("mongo:latest");

	@LocalServerPort
	private Integer port;

	static {
		mongoDBContainer.start();
	}

	@BeforeEach
	void setUp() {
		// Setup logic before each test if needed
		RestAssured.baseURI  = "http://localhost";
		RestAssured.port     = port;


	}

	@Test
	void contextLoads() {
		String requestBody = """
				{
					"name": "iPhone 13",
					"price": 1300
				}
				""";
		RestAssured.given()
				.header("Content-Type", "application/json")
				.body(requestBody).when()
				.post("/api/product")
				.then()
				.statusCode(201)
				.body("id", Matchers.notNullValue())
				.body("name", Matchers.is("iPhone 13"))
		.body("price", Matchers.equalTo(1300));

	}

}
