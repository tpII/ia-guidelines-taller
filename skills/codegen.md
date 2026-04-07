# 🔧 Code Generation — Creación Asistida de Código

> Contexto para usar cuando generas código nuevo con Copilot.

---

## Principios de Code Generation

1. **Contexto completo:** Copilot hace mejor código si sabe el contexto
2. **Ejemplo en el prompt:** Mostrar patrón que querés seguir
3. **Especificidad:** Cuanto más específico, mejor el output
4. **Revisión obligatoria:** Todo output de IA requiere human review

---

## Template de Prompt Efectivo

```
📋 CONTEXTO
- Estoy trabajando en [componente/módulo]
- Stack: [tecnología]
- Archivo de referencia: [constitution.md sección]

📝 QUÉ NECESITO
[Descripción clara de qué tiene que hacer]

💾 INPUT/OUTPUT
Input: [formato de datos entrada]
Output: [formato esperado salida]

✅ CRITERIOS
- [Criterio 1]
- [Criterio 2]
- Seguir convenciones de [constitution.md]

📚 EJEMPLO (opcional)
[Mostrar código similar que ya existe]
```

---

## Generación por Lenguaje

### 🐍 Python

#### Caso: Generar servicio MQTT

```
Contexto:
- Backend FastAPI, archivo: src/services/mqtt_service.py
- Quiero un listener MQTT escalable

Necesito:
- Clase MqttService que:
  1. Lee topic "sensors/+/data"
  2. Parsea JSON
  3. Valida schema (usar Pydantic)
  4. Persiste en PostgreSQL via SQLAlchemy
  5. Loguea con logging

- Manejo de errores:
  1. Reconexión exponencial backoff
  2. Mensajes mal formados se dropean y logean
  
- Integración:
  dependency injection en FastAPI (startup event)

Criterios:
- Type hints completos
- Docstrings Google style
- Logs en puntos clave
- Constructor inyecta: db_session, mqtt_broker
```

#### Prompt a Copilot

```
Generar en src/services/mqtt_service.py una clase MqttService que:

1. Constructor:
   - __init__(self, db: Session, mqtt_broker: str)

2. Lifecycle:
   - start(): conecta a broker y comienza listener
   - stop(): desconecta gracefully

3. Listener (privado):
   - _on_message(self, client, msg)
   - Parsea payload JSON
   - Valida con Pydantic schema
   - Guarda Reading en BD
   - Logea con logging

4. Manejo de errores:
   - Si JSON inválido: log error, continúa
   - Si conexión falla: reconectar con backoff

5. Tests en tests/test_mqtt_service.py:
   - Mock MQTT broker
   - Verificar persistencia en BD
   - Verificar reconexión

Referencia: constitution.md (Python conventions)
```

#### Output esperado
```python
# src/services/mqtt_service.py
import json
import logging
from typing import Callable
from paho.mqtt.client import Client
from sqlalchemy.orm import Session
from pydantic import ValidationError
from src.models import Reading
from schemas.reading import ReadingSchema

logger = logging.getLogger(__name__)

class MqttService:
    """Listener para mensajes MQTT y persistencia en BD."""
    
    def __init__(self, db: Session, mqtt_broker: str, port: int = 1883):
        """Inicializa el servicio MQTT.
        
        Args:
            db: Sesión SQLAlchemy
            mqtt_broker: Hostname del broker MQTT
            port: Puerto (default 1883)
        """
        self.db = db
        self.client = Client()
        self.client.on_message = self._on_message
        self.mqtt_broker = mqtt_broker
        self.port = port
        self._reconnect_attempts = 0
        
    def start(self):
        """Conectar y comenzar a escuchar."""
        try:
            self.client.connect(self.mqtt_broker, self.port, keepalive=60)
            self.client.subscribe("sensors/+/data")
            self.client.loop_start()
            logger.info(f"MQTT conectado a {self.mqtt_broker}:{self.port}")
        except Exception as e:
            logger.error(f"Error conectando a MQTT: {e}")
            raise
    
    def stop(self):
        """Desconectar gracefully."""
        self.client.loop_stop()
        self.client.disconnect()
        logger.info("MQTT desconectado")
    
    def _on_message(self, client, userdata, msg):
        """Callback para mensajes MQTT."""
        try:
            payload = json.loads(msg.payload.decode())
            reading_data = ReadingSchema(**payload)
            
            reading = Reading(
                sensor_id=reading_data.sensor_id,
                value=reading_data.value,
                unit=reading_data.unit,
                timestamp=reading_data.timestamp,
            )
            self.db.add(reading)
            self.db.commit()
            logger.debug(f"Reading guardada: {reading_data}")
            
        except json.JSONDecodeError:
            logger.error(f"JSON inválido en topic {msg.topic}")
        except ValidationError as e:
            logger.error(f"Validación falló: {e}")
        except Exception as e:
            logger.error(f"Error procesando mensaje: {e}")
            self.db.rollback()
```

---

### ⚛️ JavaScript/React

#### Caso: Generar componente de dashboard

```
Contexto:
- Frontend React, archivo: src/components/Dashboard.jsx
- Diseño con Tailwind CSS
- Data via React Query

Necesito:
- Componente Dashboard que:
  1. Fetch datos de /api/sensors con useQuery
  2. Renderiza grid de SensorCard (3 cols en desktop, 1 en mobile)
  3. Muestra loading state mientras fetch
  4. Muestra error si falla
  5. Auto-refresca cada 10s

- SensorCard sub-component:
  1. Muestra nombre, última lectura, timestamp
  2. Indicador visual de status (online/offline)
  3. Link a histórico

Criterios:
- Componentes funcionales con hooks
- PropTypes o TypeScript
- Responsive con Tailwind
- Tests con Vitest
```

#### Prompt a Copilot

```
Generar Dashboard.jsx (React component):

1. Imports:
   - useQuery de @tanstack/react-query
   - Axios para fetch
   - Tailwind para styles

2. Lógica:
   - useQuery({ queryKey: ['sensors'], ...})
   - refetchInterval: 10000 (10s)
   - isPending: mostrar loader
   - isError: mostrar error message

3. Layout:
   - Header con título "Sensores"
   - Grid: grid-cols-1 md:grid-cols-3
   - Cada card: SensorCard component

4. Sub-component SensorCard:
   - Props: sensor (object)
   - Muestra: nombre, última lectura, timestamp
   - Estilo: border, padding, shadow (Tailwind)
   - Status badge: verde (online) / gris (offline)

5. Tests en Dashboard.test.jsx:
   - Mock useQuery
   - Verificar renderizado con data
   - Verificar loader state
   - Verificar error state
```

#### Output esperado
```javascript
// src/components/Dashboard.jsx
import React from 'react';
import { useQuery } from '@tanstack/react-query';
import axios from 'axios';
import SensorCard from './SensorCard';

const Dashboard = () => {
  const { data: sensors, isPending, isError, error } = useQuery({
    queryKey: ['sensors'],
    queryFn: async () => {
      const response = await axios.get('/api/sensors');
      return response.data;
    },
    refetchInterval: 10000,
  });

  if (isPending) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-blue-500"></div>
      </div>
    );
  }

  if (isError) {
    return (
      <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
        Error cargando sensores: {error.message}
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">Sensores Activos</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {sensors.map((sensor) => (
          <SensorCard key={sensor.id} sensor={sensor} />
        ))}
      </div>
    </div>
  );
};

export default Dashboard;

// src/components/SensorCard.jsx
const SensorCard = ({ sensor }) => {
  const isOnline = sensor.last_reading_timestamp > Date.now() - 60000;

  return (
    <div className="border border-gray-300 rounded-lg shadow-md p-6 hover:shadow-lg transition">
      <div className="flex justify-between items-start mb-4">
        <h2 className="text-xl font-semibold">{sensor.name}</h2>
        <span className={`px-3 py-1 rounded text-sm font-medium ${
          isOnline 
            ? 'bg-green-100 text-green-800' 
            : 'bg-gray-100 text-gray-800'
        }`}>
          {isOnline ? '🟢 Online' : '⚪ Offline'}
        </span>
      </div>
      
      <div className="space-y-2">
        <p className="text-3xl font-bold text-blue-600">{sensor.last_value}°C</p>
        <p className="text-gray-500 text-sm">
          Última lectura: {new Date(sensor.last_reading_timestamp).toLocaleTimeString()}
        </p>
        <p className="text-gray-400 text-xs">ID: {sensor.device_id}</p>
      </div>
      
      <a href={`/sensors/${sensor.id}/history`}
         className="mt-4 inline-block text-blue-500 hover:underline text-sm">
        Ver histórico →
      </a>
    </div>
  );
};
```

---

### 🔌 Arduino

#### Caso: Generar sketch de sensor DHT22

```
Contexto:
- Proyecto IoT, Arduino con WiFi + sensor DHT22
- Publicar a MQTT cada 5 segundos
- Manejar desconexión

Necesito:
- Sketch que:
  1. Inicializa WiFi y MQTT
  2. Lee DHT22 cada 5s
  3. Formatea JSON: {"temp": XX.X, "humidity": YY.Y}
  4. Publica a "sensors/arduino_001/data"
  5. LED intermitente muestra status
  
- Manejo de errores:
  1. Si WiFi falla: LED rojo, intenta reconectar
  2. Si sensor falla: no envía, loguea a Serial
  3. Buffer local si MQTT desconectado

Criterios:
- Usar millis() no delay()
- Validar lecturas del sensor
- Comentarios en cada sección
```

#### Prompt a Copilot

```
Generar sketch Arduino para:

Hardware:
- Arduino Uno + WiFi Shield + DHT22 en pin 2

Funcionalidad:
1. Conectar a WiFi (SSID/password en define)
2. Conectar a MQTT broker
3. Leer DHT22 cada 5 segundos
4. Publicar JSON a topic "sensors/arduino_001/data"
5. LED verde: WiFi + MQTT OK
   LED amarillo: WiFi OK pero no MQTT
   LED rojo: Error

Estructura:
- setup(): inicializar pins, WiFi, MQTT
- loop(): timing con millis(), leer sensor, publicar
- Funciones helper: readSensor(), publishData(), reconnect()

Librerias:
- WiFi
- PubSubClient
- DHT (Adafruit)

Criterios:
- Sin delay blocking
- Validar sensor lectura (> -50 y < 70)
- Serial debug messages
```

#### Output esperado
```cpp
#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>

// WiFi config
const char* ssid = "YourSSID";
const char* password = "YourPassword";
const char* mqtt_broker = "broker.hivemq.com";

// Pins
#define DHT_PIN 2
#define LED_GREEN 8
#define LED_YELLOW 9
#define LED_RED 10
#define DHT_TYPE DHT22

// MQTT
WiFiClient espClient;
PubSubClient client(espClient);
DHT dht(DHT_PIN, DHT_TYPE);

// Timing
unsigned long lastReadTime = 0;
const unsigned long READ_INTERVAL = 5000; // 5 segundos

void setup() {
  Serial.begin(115200);
  delay(100);
  
  // Inicializar pines
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);
  setLedStatus("init");
  
  // Inicializar DHT
  dht.begin();
  Serial.println("INIT: DHT22 inicializado");
  
  // Conectar WiFi
  connectWiFi();
  
  // Configurar MQTT
  client.setServer(mqtt_broker, 1883);
  client.setCallback(onMqttMessage);
  
  Serial.println("INIT: Sistema listo");
}

void loop() {
  // Asegurar conexión WiFi
  if (WiFi.status() != WL_CONNECTED) {
    setLedStatus("no_wifi");
    connectWiFi();
  }
  
  // Asegurar conexión MQTT
  if (!client.connected()) {
    setLedStatus("no_mqtt");
    reconnectMqtt();
  }
  
  client.loop();
  
  // Leer sensor cada 5 segundos
  if (millis() - lastReadTime >= READ_INTERVAL) {
    lastReadTime = millis();
    readAndPublishSensor();
  }
}

void connectWiFi() {
  Serial.print("WIFI: Conectando a ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWIFI: Conectado!");
    Serial.print("IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWIFI: Falló la conexión");
  }
}

void reconnectMqtt() {
  if (!client.connect("arduino_001")) {
    Serial.println("MQTT: Fallo reconexión");
    return;
  }
  Serial.println("MQTT: Conectado");
  client.subscribe("sensors/arduino_001/command");
}

void readAndPublishSensor() {
  float temp = dht.readTemperature();
  float humidity = dht.readHumidity();
  
  // Validar lecturas
  if (isnan(temp) || isnan(humidity)) {
    Serial.println("ERROR: Lectura DHT inválida");
    setLedStatus("error");
    return;
  }
  
  if (temp < -50 || temp > 70 || humidity < 0 || humidity > 100) {
    Serial.print("ERROR: Valor fuera de rango - Temp: ");
    Serial.print(temp);
    Serial.print(", Humidity: ");
    Serial.println(humidity);
    return;
  }
  
  // Formatear JSON
  char message[200];
  sprintf(message, "{\"device_id\":\"arduino_001\",\"temp\":%.1f,\"humidity\":%.1f,\"timestamp\":%lu}",
          temp, humidity, millis());
  
  // Publicar
  if (client.publish("sensors/arduino_001/data", message)) {
    Serial.print("DATA: ");
    Serial.println(message);
    setLedStatus("ok");
  } else {
    Serial.println("ERROR: Fallo publish MQTT");
  }
}

void setLedStatus(const char* status) {
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);
  
  if (strcmp(status, "ok") == 0) {
    digitalWrite(LED_GREEN, HIGH);
  } else if (strcmp(status, "no_mqtt") == 0) {
    digitalWrite(LED_YELLOW, HIGH);
  } else if (strcmp(status, "error") == 0 || strcmp(status, "no_wifi") == 0) {
    digitalWrite(LED_RED, HIGH);
  }
}

void onMqttMessage(char* topic, byte* payload, unsigned int length) {
  Serial.print("MSG: ");
  for (unsigned int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}
```

---

## Checklist Post-Generación

Siempre después de que Copilot genere código:

- [ ] Leí el código completo
- [ ] Entiendo qué hace cada línea
- [ ] No hay hardcoding de críticas valores
- [ ] Hay manejo de errores
- [ ] Hay logging/debugging
- [ ] Sigue convenciones de constitution.md
- [ ] Escribí tests para ciertas funciones
- [ ] Compilar sin errores (Arduino) o import sin errores (Python/JS)

---

## Patrones Reusables

### 1. Generar modelo + serializer + tests

Request con estructura:
```
Generar:
1. models/my_model.py con SQLAlchemy ORM
2. schemas/my_schema.py con Pydantic (para validación de entrada)
3. tests/test_my_model.py con CRUD tests
```

### 2. Generar API completa (GET/POST/PATCH)

Request:
```
Generar endpoints en api/routes/my_route.py:
- GET /my_resource: lista recursos
- POST /my_resource: crear (validar con schema)
- PATCH /my_resource/{id}: actualizar
- DELETE /my_resource/{id}: eliminar

Tests por cada endpoint
```

### 3. Generar componente React + hook + tests

Request:
```
Generar:
1. components/MyComponent.jsx
2. hooks/useMyData.js (custom hook)
3. tests/MyComponent.test.jsx con Vitest

Usar Tailwind, React Query, PropTypes
```

---

## Tips Avanzados

1. **Mostrar ejemplo:** Si decís "similar al que ya existe en X", Copilot genera más consistente
2. **Especificar error handling:** Cuanto más específico ("si BD falla, reintentar 3 veces"), mejor
3. **Mencionar tests:** Si dices "quiero tests", genera con tests
4. **Usar enumerados:** En vez de "status puede ser X o Y", decir `enum Status` es más claro

---

## Cuándo NO generar

- ❌ Código que no sabés revisar
- ❌ Cosas complejas sin context (ADR disponible)
- ❌ Código que ya existe similar (mejor refactorizar)

---

*Recuerda: La máquina genera, pero TÚ revisant y decidís.*
