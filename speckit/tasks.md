# ✅ Tasks — Desglose de Trabajo

> Tareas accionables desglosadas de `plan.md`. Usar con Copilot para generar código por lotes.

---

## Sprint 1: Infraestructura + MQTT

### T1.1: Setup del proyecto backend
- [ ] Crear venv Python 3.11
- [ ] Iniciar FastAPI project con Uvicorn
- [ ] Configurar PostgreSQL + SQLAlchemy
- [ ] Setup Redis connection
- [ ] Estructura de carpetas `src/models`, `src/services`, `src/api`

**Contexto para Copilot:**
```
Archivo: speckit/constitution.md
Sección: Stack principal Python
```

**Estimación:** 1h

---

### T1.2: Modelo ORM para sensores
- [ ] Crear modelo `Sensor` (device_id, name, tipo, location)
- [ ] Crear modelo `Reading` (sensor_id, timestamp, value, unit)
- [ ] Agregar indexes a `readings.timestamp` y `readings.sensor_id`
- [ ] Crear migration con Alembic

**Tests:**
- [ ] CRUD Sensor es correcto
- [ ] Lectura de últimas 1000 readings < 50ms

**Estimación:** 2h

---

### T1.3: MQTT Listener service
- [ ] Crear `mqtt_service.py` con PahoMQTT
- [ ] Listener que consuma mensajes del topic `sensors/+/data`
- [ ] Parsear JSON y validar schema
- [ ] Persistir en PostgreSQL
- [ ] Agregar logs con timestamps

**Contexto para Copilot:**
```
Stack: Python + MQTT
Referencia: specification RF-001
```

**Tests:**
- [ ] Mock MQTT broker, verificar persistencia
- [ ] Manejo de JSON malformado

**Estimación:** 3h

---

### T1.4: Setup Arduino + librería MQTT
- [ ] Crear sketch básico con WiFi + MQTT
- [ ] Configurar sensor DHT22 (temperatura/humedad)
- [ ] Publicar a `sensors/{device_id}/data` cada 5 segundos
- [ ] Buffer local si pierde conexión

**Hardware:** Arduino Uno + DHT22 + WiFi shield

**Tests:**
- [ ] Simulación en Wokwi
- [ ] Conectar a broker MQTT local

**Estimación:** 4h

---

## Sprint 2: Backend APIs

### T2.1: Endpoint GET /api/readings
- [ ] Query con filtros (sensor_id, from, to, limit)
- [ ] Paginación
- [ ] Cacheado en Redis (TTL 5 min)
- [ ] Response con metadata

**Contexto para Copilot:**
```
Referencia: specification HU-003
Archivo: speckit/plan.md → Integración backend-frontend
```

**Tests:**
- [ ] Query < 200ms (p95)
- [ ] Paginación correcta

**Estimación:** 2h

---

### T2.2: Endpoint GET /api/devices
- [ ] Listar dispositivos registrados
- [ ] Información: ID, nombre, último dato, status (online/offline)
- [ ] Filtrar por user_id (autenticación)

**Tests:**
- [ ] Datos consistentes con MQTT stream

**Estimación:** 1.5h

---

### T2.3: Sistema de alertas (backend)
- [ ] Modelo `Alert` (sensor_id, threshold, condition, user_id)
- [ ] `alert_service.py`: chequear cada 10s si excedan threshold
- [ ] Disparar evento en Redis pub/sub
- [ ] Guardar historia de alertas

**Contexto para Copilot:**
```
Referencia: CU-2 en specification
Stack: Redis pub/sub
```

**Tests:**
- [ ] Alert se dispara correctamente
- [ ] No duplica alertas

**Estimación:** 3h

---

### T2.4: Autenticación JWT
- [ ] Endpoint POST /api/auth/login
- [ ] Generar JWT token (48h expiry)
- [ ] Refresh token en Redis
- [ ] Middleware para validar en endpoints

**Estructura:**
```
auth/jwt.py: generate_token, verify_token
api/routes/auth.py: /login, /refresh
```

**Tests:**
- [ ] Token válido → acceso concedido
- [ ] Token expirado → 401

**Estimación:** 2h

---

## Sprint 3: Frontend

### T3.1: Setup React + Vite
- [ ] Crear app con Vite
- [ ] Configurar Tailwind CSS
- [ ] Instalar React Query, Axios, Recharts
- [ ] Componentes base: Layout, Card, Button
- [ ] Estructura de carpetas

**Estimación:** 1.5h

---

### T3.2: Dashboard principal
- [ ] Componente Dashboard.jsx
- [ ] Grid de SensorCard (3 cols)
- [ ] Cada SensorCard muestra últimas lecturas
- [ ] Indicador de status (online/offline)

**Data source:** GET /api/readings (cada 10s)

**Tests:**
- [ ] Renderizado correcto con mock data

**Estimación:** 2h

---

### T3.3: WebSocket client (real-time)
- [ ] Hook `useSensorData` que conecta a `/ws/live`
- [ ] Actualiza estado con nuevos datos
- [ ] Reconexión automática si falla
- [ ] Logs de desconexión

**Contexto para Copilot:**
```
Referencia: specification HU-001
Stack: React hooks, WebSocket
```

**Tests:**
- [ ] Conexión establece correctamente
- [ ] Datos se renderizan en < 500ms

**Estimación:** 2.5h

---

### T3.4: Página de alertas
- [ ] AlertForm: crear/editar alertas
- [ ] Lista de alertas activas
- [ ] Botón "editar threshold"
- [ ] Historial de alertas disparadas

**API:** POST/GET/PATCH /api/alerts

**Tests:**
- [ ] CRUD completo

**Estimación:** 3h

---

### T3.5: Gráficos históricos
- [ ] Componente Chart usando Recharts
- [ ] Ejes X (timestamps), Y (valor de sensor)
- [ ] Filtro de rango de fechas
- [ ] Datos vienen de `/api/readings?from=&to=`

**Tests:**
- [ ] Renderizado correcto
- [ ] Zoom/pan funciona

**Estimación:** 2.5h

---

## Sprint 4: Integración + Deployment

### T4.1: E2E testing (Playwright)
- [ ] Test: usuario accede → ve data en tiempo real
- [ ] Test: usuario crea alerta → recibe notificación
- [ ] Test: desconexión y reconexión de Arduino

**Estimación:** 3h

---

### T4.2: Docker + CI/CD
- [ ] Dockerfile backend
- [ ] Dockerfile frontend (nginx)
- [ ] docker-compose.yml (app + db + redis + mqtt)
- [ ] GitHub Actions: test on push, build on merge a main

**Estimación:** 2h

---

### T4.3: Deployment a producción
- [ ] Variables de entorno (.env)
- [ ] HTTPS (Let's Encrypt)
- [ ] Deploy en DigitalOcean App Platform
- [ ] Monitoreo y logs (Sentry)

**Estimación:** 2h

---

## Métricas de Ejecución

| Sprint | Estimación | Prioridad |
|--------|-----------|-----------|
| 1 (Infra) | 10h | 🔴 Alta |
| 2 (Backend) | 12h | 🔴 Alta |
| 3 (Frontend) | 13h | 🟡 Media |
| 4 (Deploy) | 7h | 🟡 Media |

**Total:** ~42h

---

## Cómo usar este documento con Copilot

1. Abrí VS Code
2. Abrí `speckit/tasks.md` en un tab
3. Abrí `speckit/constitution.md` en otro tab
4. Al pedirle a Copilot que implemente T1.1:
   - "Basándote en los contextos abiertos, generá el setup inicial de FastAPI para T1.1"
   - Copilot tendrá acceso a constitución y especificaciones

---

## Próximo paso

👉 Implementar Sprint 1, siguiendo el contexto de `constitution.md` y esta lista de tareas.
