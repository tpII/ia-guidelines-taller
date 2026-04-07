# 🏛️ Architecture Decision — Documentación de Decisiones

> Contexto para registrar decisiones arquitectónicas al usar IA.

---

## ¿Cuándo registrar una decisión?

#### ✅ REGISTRA si:
- Copilot propuso algo no obviamente trivial
- Es una decisión que afecta múltiples módulos
- Requiere trade-offs entre opciones
- Será difícil de revertir luego

#### ❌ NO REGISTRES si:
- Es una decisión local (nombre de variable)
- Es una implementación directa de especificación
- Es corrección de bug obvio

---

## Plantilla ADR (usar en VS Code)

Archivos de clase: `adr/ADR-XXX-short-title.md`

```markdown
# ADR-XXX: [Título corto de la decisión]

**Estado:** Propuesta | Aceptada | Rechazada | Deprecada

**Fecha:** YYYY-MM-DD

**Autores:** username (+ Copilot si fue significativo)

---

## Contexto

[Describe la situación que requería tomar una decisión]
[Qué presiones u objetivos teníamos]

### Problema específico
[Cuál era el problema a resolver]

---

## Opciones Consideradas

### Opción A: [Nombre]
**Ventajas:**
- [ ] Ventaja 1
- [ ] Ventaja 2

**Desventajas:**
- [ ] Desventaja 1
- [ ] Desventaja 2

**Evidencia técnica:**
```
[Código, benchmark, o referencia si aplica]
```

### Opción B: [Nombre]
**Ventajas:**
- 
**Desventajas:**
-

### Opción C: [Nombre]
**Ventajas:**
-
**Desventajas:**
-

---

## Decisión

**SE ELIGE:** Opción [X]

**Rationale:**
[Explicá por qué elegiste esta opción. Mentioná si Copilot sugirió algo.]

**Implicaciones:**
- Implicación 1
- Implicación 2
- (Posibles costos técnicos futuros)

---

## Consecuencias

### Positivas
- [ ] Beneficio 1
- [ ] Beneficio 2

### Negativas
- [ ] Costo 1
- [ ] Costo 2

### Acciones Requeridas
- [ ] Tarea 1
- [ ] Tarea 2

---

## Referencias

- Link a documentación
- Link a Copilot assistance (si la usaste)
- Relacionado con ADR-XXX (si aplica)

---

## Notas

[Cualquier cosa adicional que quieras registrar]
```

---

## Ejemplos Reales

### Ejemplo 1: ¿Por qué MQTT y no HTTP Polling?

**Archivo:** `adr/ADR-001-mqtt-vs-polling.md`

```markdown
# ADR-001: MQTT para manejo de eventos vs HTTP Polling

**Estado:** Aceptada

**Fecha:** 2024-01-15

**Autores:** devteam (Copilot sugirió arquitectura)

---

## Contexto

Necesitábamos que Arduino envíe datos de sensores a backend en tiempo real.
Requerimiento: latencia < 500ms, múltiples Arduino (50+), escalable.

---

## Opciones Consideradas

### Opción A: HTTP Polling
Arduino hace GET /api/report_data cada 5 segundos

**Ventajas:**
- Protocolo HTTP estándar
- Sin dependencias extra (no MQTT)

**Desventajas:**
- Overhead: 50 Arduino × 1 request/5s = 10 req/s picos
- Si backend cae, Arduino sigue haciendo requests
- Latencia variable según response time del servidor
- Difícil escalar a 500+ dispositivos

**Benchmark:**
```
HTTP: ~200ms por round-trip (WiFi + network latency + parse)
```

### Opción B: MQTT Pub/Sub
Arduino publica a "sensors/+/data", backend suscribe

**Ventajas:**
- Modelo evento-driven (publish-subscribe)
- Broker maneja desconexiones (QoS levels)
- Bajo overhead: payload pequeño
- Arduino no espera respuesta (fire and forget)
- Backend puede procesarlos asincronicamente

**Desventajas:**
- Dependencia adicional: MQTT broker (Mosquitto, etc)
- Learning curve (QoS levels, topics, retained messages)
- Require port abierto en firewall (1883 o 8883)

**Benchmark:**
```
MQTT: ~50ms latencia (directo a broker, no espera response)
Puede manejar 1000+ mensajes/segundo en broker estándar
```

### Opción C: WebSocket desde Arduino
Arduino mantiene conexión WebSocket bidireccional

**Ventajas:**
- Comunicación bidireccional en tiempo real
- Control granular desde backend

**Desventajas:**
- WiFi shield Arduino limita WebSocket (no todos soportanrequiere librería específica)
- Conexión persistente consume más batería
- Más difícil de escalar (estado server)

---

## Decisión

**SE ELIGE:** Opción B - MQTT

**Rationale:**

Copilot sugirió que para IoT escalable, MQTT es el estándar industrial por dos razones:
1. Modelo publish-subscribe desacopla Arduino de backend
2. Broker puede manejar reconexiones automáticas sin que Arduino sepa

El trade-off de agregar broker (Mosquitto) es justificado porque:
- Mensajes más rápidos (50ms vs 200ms)
- Puede escalar a 1000+ dispositivos sin problema
- QoS 1 garantiza entrega al menos una vez

---

## Consecuencias

### Positivas
- Latencia mejorada: 50ms vs 200ms
- Backend procesa eventos en caché Redis
- Arduino puede "dormirse" entre lecturas (baja energía)
- Fácil agregar más sensores sin impactar servidor

### Negativas
- una dependencia más (Mosquitto broker)
- Port 1883 debe estar abierto en firewall

### Acciones Requeridas
- [ ] Instalar Mosquitto en servidor
- [ ] Configurar docker-compose con MQTT
- [ ] Escribir listener MQTT en backend
- [ ] Tests con mock MQTT broker
```

---

### Ejemplo 2: ¿Por qué caché Redis?

**Archivo:** `adr/ADR-002-redis-cache-strategy.md`

```markdown
# ADR-002: Redis para caché de lecturas vs caché en memoria

**Estado:** Aceptada

**Fecha:** 2024-01-18

**Autores:** devteam

---

## Contexto

Backend procesa 100s de eventos MQTT/segundo y frontend hace queries a `/api/readings`.
Problema: queries a BD son lentas (> 500ms) con 1M registros históricos.

---

## Opciones Consideradas

### Opción A: Caché en memoria (Python @lru_cache)
```python
@lru_cache(maxsize=1000)
def get_readings(sensor_id):
    return db.query(Reading).filter...
```

**Ventajas:**
- Simple, 0 dependencias
- Acceso muy rápido

**Desventajas:**
- **NO es compartido** entre workers Uvicorn (4 workers = 4 cachés independentes)
- Inconsistencias: dos requests pueden ver datos diferentes
- Difícil invalidar caché (no hay control central)

### Opción B: Redis
Mensaje MQTT → guarda en Redis → queries leen de Redis primero

**Ventajas:**
- **Compartido entre workers:** todos leen del mismo caché
- TTL automático: sin invalidación manual
- Compatible con MQTT stream (publish a Redis channel)

**Desventajas:**
- Otra dependencia (Redis server)
- Pequeño overhead de red (pero solo si falla caché)

---

## Decisión

**SE ELIGE:** Opción B - Redis

**Rationale:**

Copilot señaló que con múltiples workers Uvicorn, caché local causa data inconsistency.
Redis es el estándar para IaC escalable (compartible, auto-sync).

Además, Redis pub/sub es ideal porque:
- MQTT listener puede publicar a Redis channel
- WebSocket backend se suscribe a Redis (sin pooling)
- Frontend recibe datos < 100ms después de Arduino

---

## Consecuencias

### Positivas
- Consistencia entre workers
- TTL automático (sin bugs de mem leak)
- Pub/sub para events
- Rendimiento: queries 500ms → 5ms (100x más rápido)

### Negativas
- Otra dependencia (Redis server)
- Requiere configuración: eviction policy, maxmemory

### Acciones Requeridas
- [ ] Redis en docker-compose
- [ ] Configurar maxmemory a 512MB
- [ ] Tests con mock Redis
```

---

## Ejemplo 3: ¿Por qué Pydantic para validación?

**Archivo:** `adr/ADR-003-input-validation-with-pydantic.md`

```markdown
# ADR-003: Validación de entrada con Pydantic vs manual

**Estado:** Aceptada

**Fecha:** 2024-01-20

---

## Contexto

Múltiples endpoints reciben JSON que debe ser validado:
- Tipos de datos correctos
- Rangos válidos (temp: -50 a 70)
- Campos obligatorios vs opcionales

---

## Opciones Consideradas

### Opción A: Validación manual en cada endpoint
```python
@router.post("/readings")
def create_reading(data: dict):
    if "temp" not in data:
        return {"error": "temp requerido"}
    if not isinstance(data["temp"], (int, float)):
        return {"error": "temp debe ser número"}
    if data["temp"] < -50 or data["temp"] > 70:
        return {"error": "temp fuera de rango"}
    # ...
```

**Desventajas:**
- Repetitivo
- Bugs de validación
- Inconsistencia entre endpoints
- Difícil de testear

### Opción B: Pydantic models
```python
class ReadingRequest(BaseModel):
    temp: float = Field(..., ge=-50, le=70)
    humidity: float = Field(..., ge=0, le=100)
```

**Ventajas:**
- Declarativo, DRY
- Auto docs Swagger
- Type checking automático
- Reutilizable en múltiples endpoints

---

## Decisión

**SE ELIGE:** Opción B - Pydantic

**Rationale:**

Copilot sugirió que con FastAPI + Pydantic, la validación es "casi gratis":
- Decorador @router.post() + Pydantic model
- Swagger docs se generan automáticamente
- Errores de validación devuelven 422 estándar
```

---

## Cómo Writes ADR en práctica

1. **Después de tomar decisión:**
   ```bash
   cp adr/template.md adr/ADR-NNN-titulo.md
   ```

2. **Editar en VS Code** completando secciones

3. **Una vez finalizado:**
   ```bash
   git add adr/ADR-NNN-titulo.md
   git commit -m "docs(adr): ADR-NNN decisión sobre [tema]"
   ```

---

## Preguntas que te ayudan a escribir ADR

- ¿Por qué elegí esto en lugar de las alternativas?
- ¿Qué costos tiene esta decisión a futuro?
- ¿Esta decisión afecta otros sistemas?
- ¿Podemos probarla o es reversible?
- ¿Copilot sugirió esto? ¿Por qué?

---

## ADRs Típicas en Talleres

- **ADR-001:** Elección de stack principal
- **ADR-002:** Arquitectura macro (MQTT vs polling, monolito vs microservicios)
- **ADR-003:** Estrategia de caché
- **ADR-004:** Autenticación (JWT vs sesiones)
- **ADR-005:** ORM (SQLAlchemy vs otra)
- **ADR-006:** Frontend framework (React vs Vue)

---

*Recuerda: ADRs no son opcional. Documenta decisiones mientras las tomas, no al final.*
