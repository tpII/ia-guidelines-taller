# ☕ Java — Instrucciones de Copilot

> Copia este archivo a `.github/copilot-instructions.md` en tu proyecto Java backend.

---

## Stack: Java + Spring Boot

### Versiones
- Java: 21 LTS (recomendado) o 17 LTS
- Spring Boot: 3.2+
- Maven: 3.9+ o Gradle 8+
- PostgreSQL: 14+
- Redis: 7+

---

## Convenciones de Código Java

### Nombrado
```java
// Paquetes: com.domain.module (todo lowercase)
com.iottracking.sensor
com.iottracking.api.controller

// Clases: PascalCase
public class SensorController { }
public class ReadingService { }

// Interfaces: PascalCase con sufijo "I" o sin
public interface ISensorRepository { }
// O moderno (sin prefijo):
public interface SensorRepository { }

// Métodos: camelCase
public void readSensorData() { }
public List<Reading> findBySensorId(int id) { }

// Constantes: UPPER_SNAKE_CASE
public static final int MAX_RETRIES = 3;
public static final String DEFAULT_TIMEZONE = "UTC";

// Atributos privados: camelCase con underscore (opcional)
private String _name;  // Deprecated
private String name;   // Moderno
```

### Format
```java
// Line length: 120 caracteres
// Indentación: 4 espacios (nunca tabs)
// Llaves: estilo  Google (opening bracket en misma línea)

public class Example {
    public void method() {
        // código
    }
}
```

### Estructura de Proyecto (Spring Boot)
```
proyecto-java/
├── src/
│   ├── main/
│   │   ├── java/com/iottracking/
│   │   │   ├── IotBackendApplication.java    # Main class
│   │   │   ├── config/                       # Configuración
│   │   │   │   ├── DatabaseConfig.java
│   │   │   │   └── RedisConfig.java
│   │   │   │
│   │   │   ├── model/                        # JPA entities
│   │   │   │   ├── Sensor.java
│   │   │   │   └── Reading.java
│   │   │   │
│   │   │   ├── dto/                          # Data Transfer Objects
│   │   │   │   ├── SensorDTO.java
│   │   │   │   └── ReadingDTO.java
│   │   │   │
│   │   │   ├── repository/                   # Spring Data JPA
│   │   │   │   ├── SensorRepository.java
│   │   │   │   └── ReadingRepository.java
│   │   │   │
│   │   │   ├── service/                      # Lógica de negocio
│   │   │   │   ├── SensorService.java
│   │   │   │   └── ReadingService.java
│   │   │   │
│   │   │   ├── controller/                   # REST endpoints
│   │   │   │   ├── SensorController.java
│   │   │   │   └── ReadingController.java
│   │   │   │
│   │   │   └── exception/                    # Manejo de errores
│   │   │       └── GlobalExceptionHandler.java
│   │   │
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── application-dev.properties
│   │       └── db/migration/                 # Flyway
│   │           └── V1__init_schema.sql
│   │
│   └── test/
│       └── java/com/iottracking/
│           ├── service/
│           └── controller/
│
├── pom.xml
└── README.md
```

---

## Dependencias (Maven)

```xml
<!-- pom.xml -->
<project>
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.iottracking</groupId>
    <artifactId>iot-backend</artifactId>
    <version>1.0.0</version>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>

    <dependencies>
        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Spring Boot Data JPA -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- Spring Boot Data Redis -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>

        <!-- PostgreSQL -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- Flyway (migrations) -->
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>

        <!-- MQTT -->
        <dependency>
            <groupId>org.springframework.integration</groupId>
            <artifactId>spring-integration-mqtt</artifactId>
        </dependency>

        <!-- Lombok (reduce boilerplate) -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## Patrones Spring Boot

### 1. Entity (JPA Model)

```java
// model/Reading.java
package com.iottracking.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "readings", indexes = {
    @Index(name = "idx_sensor_timestamp", columnList = "sensor_id, timestamp")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Reading {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private Long sensorId;
    
    @Column(nullable = false)
    private Float value;
    
    @Column(nullable = false, length = 10)
    private String unit;
    
    @Column(nullable = false)
    private LocalDateTime timestamp;
    
    @PrePersist
    public void prePersist() {
        if (this.timestamp == null) {
            this.timestamp = LocalDateTime.now();
        }
    }
}
```

### 2. Repository (Spring Data JPA)

```java
// repository/ReadingRepository.java
package com.iottracking.repository;

import com.iottracking.model.Reading;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDateTime;
import java.util.List;

public interface ReadingRepository extends JpaRepository<Reading, Long> {
    
    List<Reading> findBySensorId(Long sensorId);
    
    @Query("SELECT r FROM Reading r WHERE r.sensorId = ?1 AND r.timestamp BETWEEN ?2 AND ?3")
    List<Reading> findBySensorIdAndDateRange(
        Long sensorId,
        LocalDateTime from,
        LocalDateTime to
    );
    
    Page<Reading> findBySensorId(Long sensorId, Pageable pageable);
}
```

### 3. DTO (Data Transfer Object)

```java
// dto/ReadingDTO.java
package com.iottracking.dto;

import lombok.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReadingDTO {
    
    private Long id;
    
    @JsonProperty("sensor_id")
    private Long sensorId;
    
    private Float value;
    
    private String unit;
    
    private LocalDateTime timestamp;
    
    // Mapear de Entity a DTO
    public static ReadingDTO fromEntity(Reading entity) {
        return new ReadingDTO(
            entity.getId(),
            entity.getSensorId(),
            entity.getValue(),
            entity.getUnit(),
            entity.getTimestamp()
        );
    }
}
```

### 4. Service (Lógica de Negocio)

```java
// service/ReadingService.java
package com.iottracking.service;

import com.iottracking.model.Reading;
import com.iottracking.repository.ReadingRepository;
import com.iottracking.dto.ReadingDTO;
import org.springframework.stereotype.Service;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor  // Inyectar dependencias (Lombok)
@Slf4j  // Logger
public class ReadingService {
    
    private final ReadingRepository repository;
    
    public ReadingDTO createReading(ReadingDTO dto) {
        log.info("Creando lectura para sensor {}", dto.getSensorId());
        
        Reading entity = new Reading();
        entity.setSensorId(dto.getSensorId());
        entity.setValue(dto.getValue());
        entity.setUnit(dto.getUnit());
        
        Reading saved = repository.save(entity);
        
        log.info("Lectura creada: id={}", saved.getId());
        return ReadingDTO.fromEntity(saved);
    }
    
    public Page<ReadingDTO> getReadings(Long sensorId, Pageable pageable) {
        return repository.findBySensorId(sensorId, pageable)
                        .map(ReadingDTO::fromEntity);
    }
    
    public List<ReadingDTO> getReadingsInRange(
        Long sensorId,
        LocalDateTime from,
        LocalDateTime to
    ) {
        return repository.findBySensorIdAndDateRange(sensorId, from, to)
                        .stream()
                        .map(ReadingDTO::fromEntity)
                        .toList();
    }
}
```

### 5. Controller (REST API)

```java
// controller/ReadingController.java
package com.iottracking.controller;

import com.iottracking.service.ReadingService;
import com.iottracking.dto.ReadingDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/readings")
@RequiredArgsConstructor
@Slf4j
public class ReadingController {
    
    private final ReadingService service;
    
    @PostMapping
    public ResponseEntity<ReadingDTO> createReading(@RequestBody ReadingDTO dto) {
        log.info("POST /api/readings");
        ReadingDTO result = service.createReading(dto);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping
    public ResponseEntity<Page<ReadingDTO>> getReadings(
        @RequestParam(required = false) Long sensorId,
        Pageable pageable
    ) {
        log.info("GET /api/readings?sensorId={}", sensorId);
        
        Page<ReadingDTO> result = service.getReadings(sensorId, pageable);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/range")
    public ResponseEntity<List<ReadingDTO>> getReadingsInRange(
        @RequestParam Long sensorId,
        @RequestParam LocalDateTime from,
        @RequestParam LocalDateTime to
    ) {
        List<ReadingDTO> result = service.getReadingsInRange(sensorId, from, to);
        return ResponseEntity.ok(result);
    }
}
```

### 6. Configuration

```java
// config/RedisConfig.java
package com.iottracking.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.context.annotation.Bean;

@Configuration
public class RedisConfig {
    
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);
        return template;
    }
}

// config/DatabaseConfig.java
package com.iottracking.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackages = "com.iottracking.repository")
public class DatabaseConfig {
    // Spring Boot configura automáticamente
}
```

### 7. Exception Handler

```java
// exception/GlobalExceptionHandler.java
package com.iottracking.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import lombok.extern.slf4j.Slf4j;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleException(Exception e) {
        log.error("Error no manejado", e);
        return ResponseEntity.status(500).body(Map.of(
            "error": "Internal server error",
            "message": e.getMessage()
        ));
    }
}
```

---

## Documentación de Código

Utilizar **JavaDoc Clásico** obligatorio en todos los métodos públicos de Servicios y Controladores.

```java
/**
 * Procesa la lectura entrante y la inyecta al pipeline de persistencia.
 * 
 * @param sensorId El UUID o identificador del hardware remoto.
 * @param dto El objeto de transferencia conteniendo las métricas leídas.
 * @return ReadingDTO El DTO con el objeto guardado en base de datos.
 * @throws IllegalArgumentException Si el payload tiene parámetros nulos.
 */
public ReadingDTO createReading(Long sensorId, ReadingDTO dto) throws IllegalArgumentException {
    // ...
}
```

---

## Testing con JUnit 5 (TDD y Cobertura >80%)

El desarrollo del backend Java debe orientarse mediante la práctica de **Test-Driven Development (TDD)**. El Asistente IA debe proponer Unit Tests (usando Mockito para aislar dependencias) antes o en simultáneo de generar código productivo.

Asimismo, existe el piso intransigente de >80% de **Line/Branch Coverage** verificable a nivel compilación con el plugin `jacoco-maven-plugin`. El Asistente debe garantizar tests de casos bordes o nulos para superar este umbral por cada servicio.

```java
// service/ReadingServiceTest.java
package com.iottracking.service;

import com.iottracking.model.Reading;
import com.iottracking.repository.ReadingRepository;
import com.iottracking.dto.ReadingDTO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class ReadingServiceTest {
    
    @Autowired
    private ReadingService service;
    
    @MockBean
    private ReadingRepository repository;
    
    @Test
    public void testCreateReading() {
        // Arrange
        ReadingDTO dto = new ReadingDTO(null, 1L, 23.5f, "C", LocalDateTime.now());
        Reading entity = new Reading(null, 1L, 23.5f, "C", LocalDateTime.now());
        entity.setId(1L);
        
        when(repository.save(any())).thenReturn(entity);
        
        // Act
        ReadingDTO result = service.createReading(dto);
        
        // Assert
        assertNotNull(result.getId());
        assertEquals(23.5f, result.getValue());
        verify(repository, times(1)).save(any());
    }
}
```

---

## Propiedades (application.properties)

```properties
# application.properties
spring.application.name=iot-backend

# PostgreSQL
spring.datasource.url=jdbc:postgresql://localhost:5432/iot_db
spring.datasource.username=postgres
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=validate

# Redis
spring.redis.host=localhost
spring.redis.port=6379

# Logging
logging.level.root=INFO
logging.level.com.iottracking=DEBUG
logging.pattern.console=%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n

# Server
server.port=8080
server.servlet.context-path=/api
```

---

## Checklist Antes de Commit

- [ ] Código compila sin errores (`mvn clean install`)
- [ ] Tests pasan (`mvn test`)
- [ ] Cobertura >= 80% (Revisable vía JaCoCo)
- [ ] Formateado con IDE defaults (o `mvn spotless:apply`)
- [ ] No hay warnings críticos
- [ ] DTOs para intercambio de datos (nunca entities en responses)
- [ ] Logging en puntos clave
- [ ] Manejo de excepciones global
- [ ] Documentación en métodos públicos

---

*Recuerda: Spring Boot hace mucho por vos. Respeta las convenciones para aprovecharlas.*
