# 🗺️ Plan — Arquitectura Técnica

> Desglose arquitectónico del proyecto. Se genera basándose en `specify.md` y `constitution.md`.

---

## Arquitectura General

```
┌──────────────────┐         ┌─────────────────┐         ┌──────────────────┐
│   Arduino        │         │ Raspberry Pi    │         │   React Dashboard│ 
│   + Sensores     │         │   (Bridge)      │         │   + WebSocket    │ 
└────────┬─────────┘         └────────┬────────┘         └────────┬─────────┘
         │                            │                           │
         │ Serial                     │ WiFi                      │ HTTPS
         │                            │                           │
         └────────────────────────────┼───────────────────────────┘
                                      │
                        ┌─────────────┴─────────────┐
                        │                           │
                  ┌─────▼─────┐           ┌─────────▼────────┐
                  │   MQTT    │           │  Python Backend  │
                  │  Broker   │           │  (FastAPI)       │
                  └───────────┘           ├──────────────────┤
                                          │ Routes, Auth     │
                        ┌─────────────────┤ Services, ORM    │
                        │                 │ WebSocket        │
                  ┌─────▼─────┐           └──────────────────┘
                  │PostgreSQL │                   │
                  │  + Redis  │───────────────────┘
                  └───────────┘
```

---

## Componentes Principales

### 1. Capa IoT (Arduino + RPi)

#### Arduino
```
Responsabilidades:
- Leer sensores (DHT22, BMP280, etc.)
- Conectarse a WiFi
- Publicar a MQTT cada 5s
- Buffer local si pierde conexión
- Indicadores LED de estado

Dependencias:
- Wire.h (I2C)
- WiFi.h
- PubSubClient.h (MQTT)
- EEPROM (persistencia)

Estructura de mensaje MQTT:
{
  "device_id": "arduino_001",
  "timestamp": 1704067200,
  "temperature": 23.5,
  "humidity": 65.2,
  "pressure": 1013.25
}
```

#### Raspberry Pi (Optional Bridge)
```
Responsabilidades:
- Gateway MQTT (si no hay WiFi directo)
- Agregación de datos si hay múltiples Arduino
- Mantenimiento de logs locales
- Sincronización a servidor

Servicios:
- systemd: servicio Python de listener
- cron: rotación de logs diaria
```

### 2. Backend (Python + FastAPI)

```
src/
├── models/
│   ├── sensor.py          # ORM: Sensor, Reading
│   └── user.py            # ORM: User, Alert
├── services/
│   ├── mqtt_service.py    # Listener MQTT
│   ├── alert_service.py   # Lógica de alertas
│   └── cache_service.py   # Redis wrapper
├── api/
│   ├── routes/
│   │   ├── readings.py    # GET /readings
│   │   ├── alerts.py      # CRUD /alerts
│   │   └── devices.py     # Gestión de dispositivos
│   └── ws/
│       └── events.py      # WebSocket broadcast
├── auth/
│   └── jwt.py             # JWT validation
└── main.py                # FastAPI app
```

**Endpoints principales:**
```
GET    /api/devices                    # Listar dispositivos
POST   /api/devices                    # Registrar nuevo Arduino
GET    /api/readings?device_id=X       # Datos históricos
POST   /api/alerts                     # Crear alerta
WS     /ws/live                        # WebSocket streaming
```

**Stack:**
- FastAPI 0.104+
- SQLAlchemy 2.0 + PostgreSQL
- Redis (caché + pub/sub)
- paho-mqtt (listener)
- python-jose (JWT)

### 3. Frontend (React)

```
src/
├── components/
│   ├── SensorCard.jsx      # Muestra un sensor
│   ├── AlertForm.jsx       # Crear/editar alertas
│   └── Dashboard.jsx       # Layout principal
├── pages/
│   ├── HomePage.jsx
│   ├── SettingsPage.jsx
├── hooks/
│   ├── useSensorData.js    # Custom hook para WebSocket
│   ├── useAlerts.js
├── services/
│   └── api.js              # Axios client
└── styles/
    └── dashboard.css       # Tailwind modules
```

**Librerías:**
- React 18
- Vite (builder)
- Axios (HTTP client)
- TanStack Query (state management)
- Tailwind CSS (estilos)
- Recharts (gráficos)

---

## Flujos de Datos Principales

### Flujo 1: Lectura de sensor en tiempo real
```
Arduino (DHT read)
  ↓ (Serial → WiFi)
MQTT Broker
  ↓ (publish)
Backend (mqtt_service.py)
  ↓ (valida, guarda)
PostgreSQL + Redis
  ↓ (broadcast vía WebSocket)
React Dashboard (useSensorData hook)
  ↓ (renderiza SensorCard)
Browser (gráfico actualizado)
```

### Flujo 2: Sistema de alertas
```
Backend (alert_service.py monitorea cada 10s)
  ↓ (if value > threshold)
Redis (publica evento de alerta)
  ↓ (WebSocket broadcast)
React (muestra notificación)
  ↓
Usuario (recibe push notification)
```

---

## Integración backend-frontend

### WebSocket (Real-time)
```javascript
// Cliente (React)
const ws = new WebSocket('wss://api.example.com/ws/live');
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  setSensorData(data);
};
```

```python
# Servidor (backend)
@app.websocket("/ws/live")
async def websocket_endpoint(websocket):
    await websocket.accept()
    while True:
        data = await redis_client.lpop("sensor_stream")
        await websocket.send_json(data)
```

### HTTP (Queries históricas)
```
GET /api/readings?sensor_id=1&from=2024-01-01&to=2024-01-31&limit=1000

Response:
{
  "data": [...],
  "pagination": {"current_page": 1, "total_pages": 5},
  "metadata": {"timezone": "UTC"}
}
```

---

## Decisiones Clave Documentadas (ADRs)

- ✅ ADR-001: ¿Por qué MQTT y no HTTP polling?
- ✅ ADR-002: ¿Por qué FastAPI y no Django?
- ✅ ADR-003: ¿Por qué caché Redis?
- ✅ ADR-004: ¿Actor model vs eventos sincronizados?

---

## Criterios de Testing

### Backend (pytest)
```
tests/
├── test_mqtt_service.py      # Mocking de MQTT broker
├── test_api_readings.py      # Endpoints HTTP
├── test_alert_logic.py       # Lógica de alertas
└── test_cache.py             # Caché Redis
```

### Frontend (Vitest)
```
tests/
├── SensorCard.test.jsx       # Renderizado
├── useSensorData.test.js     # Hook logic
└── integration.test.js       # E2E simulado
```

### Arduino
```
tests/
├── sensor_read_mock.cpp      # Simulación DHT22
└── mqtt_publish_mock.cpp     # Mock de broker
```

---

## Próximos pasos

1. Crear ADRs para decisiones no obvias
2. Generar `tasks.md` desglosando en sprints
3. Iniciar implementación (primer spike: MQTT listener)

