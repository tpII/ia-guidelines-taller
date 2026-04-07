# 🔌 Arduino — Instrucciones de Copilot

> Copia este archivo a `.github/copilot-instructions.md` en tu proyecto Arduino.

---

## Stack: Arduino + Sensores IoT

### Versión y Librerías
- Arduino IDE: 2.x
- Lenguaje: C++
- Placa: Arduino Uno, Nano, Mega
- Librerías estándar: Wire, SPI, Serial, EEPROM
- Librerías externas:
  - PubSubClient (MQTT)
  - DHT (sensores temperatura/humedad)
  - Adafruit_BMP280 (presión)

---

## Convenciones de Código Arduino

### Nomenclatura
```cpp
// Pines: UPPER_SNAKE_CASE (constantes)
#define DHT_PIN 2
#define LED_RED 10

// Variables: camelCase
unsigned long lastReadTime = 0;
int sensorValue = 0;

// Funciones: camelCase
void readSensor()
void validateData(int value)
bool reconnectWiFi()
```

### Estructura General
```cpp
// 1. Includes
#include <Wire.h>
#include <DHT.h>

// 2. Defines (pins, constantes)
#define DHT_PIN 2
#define MQTT_BROKER "broker.example.com"
#define READ_INTERVAL 5000

// 3. Variables globales
DHT dht(DHT_PIN, DHT22);
WiFiClient client;

// 4. Funciones helper
void readAndPublish() { ... }
void setLedStatus() { ... }

// 5. setup()
void setup() { ... }

// 6. loop()
void loop() { ... }
```

### Timing (Nunca usar delay() largo)
```cpp
// ✅ CORRECTO: Usar millis()
unsigned long lastRead = 0;
const unsigned long INTERVAL = 5000;

void loop() {
  if (millis() - lastRead >= INTERVAL) {
    readSensor();
    lastRead = millis();
  }
}

// ❌ INCORRECTO: delay() bloquea todo
void loop() {
  delay(5000);  // No puedes leer botones mientras esperas
  readSensor();
}
```

### Validación de Datos
```cpp
// Siempre validar lecturas de sensores
float temp = dht.readTemperature();

if (isnan(temp)) {
  Serial.println("ERROR: Lectura DHT inválida");
  return;
}

if (temp < -50 || temp > 70) {
  Serial.println("ERROR: Temperatura fuera de rango");
  return;
}

// Procesar valor válido
```

### Formato de Mensaje Serial/MQTT
```cpp
// Para debugging: incluir sección al inicio del mensaje
Serial.print("INIT: Sistema iniciado\n");
Serial.print("WIFI: Conectando a network\n");
Serial.print("ERROR: Sensor no disponible\n");
Serial.print("DATA: Temperatura 23.5°C, Humedad 65%\n");

// JSON para MQTT
char message[200];
snprintf(message, sizeof(message),
  "{\"device_id\":\"arduino_001\",\"temp\":%.1f,\"humidity\":%.1f,\"ts\":%lu}",
  temp, humidity, millis());
```

### Manejo de Errores
```cpp
// Reconexión con backoff
int reconnectAttempts = 0;
const int MAX_ATTEMPTS = 10;

bool reconnectWiFi() {
  while (WiFi.status() != WL_CONNECTED && reconnectAttempts < MAX_ATTEMPTS) {
    delay(500);
    reconnectAttempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    reconnectAttempts = 0;
    return true;
  }
  return false;
}
```

### Buffer Local (si MQTT falla)
```cpp
// EEPROM para persistencia temporal
#include <EEPROM.h>

// Guardar último valor si no puedo publicar
void saveToBuffer(float temp) {
  EEPROM.write(0, (byte)temp);  // Simple approach
  // En producción: usar library tipo FlashStorage
}
```

---

## Librerías Recomendadas

| Librería | Uso | Archivo | Instalación |
|---|---|---|---|
| DHT | Sensor temperatura/humedad | `DHT_sensor.h` | Adafruit DHT Library |
| Wire | I2C communication | Estándar | Incluído |
| PubSubClient | MQTT | `mqtt_publish.h` | Nick O'Leary |
| WiFi | WiFi Shield | Estándar | Incluído |
| Adafruit_BMP280 | Sensor presión | `sensor_pressure.h` | Adafruit BMP280 |

---

## Documentación de Código

Utilizar **Doxygen Style** obligatorio para explicar funciones que lean hardware, bloqueen el procesador o realicen comunicación I2C/SPI/MQTT pesada.

```cpp
/**
 * @brief Lee la temperatura y humedad del bus I2C y la procesa.
 * 
 * Invoca la librería externa para leer registros vía Wire. Posee 
 * un mecanismo fail-safe si el wire lock no responde.
 * 
 * @param limit_retries Cantidad máxima de intentos de lectura antes de fallar.
 * @return true Si la lectura fue exitosa y parseada.
 * @return false Si el checksum falló o el módulo físico está desconectado.
 */
bool readAndPublish(int limit_retries) { ... }
```

---

## Testing en Arduino

### Simulación con Wokwi
```cpp
// Usar Wokwi (wokwi.com) para simular circuito
// Crear archivo wokwi.toml en raíz del proyecto
// Ventajas:
// - Simular sin hardware
// - Visualizar Serial output
// - Integrar con GitHub

// Ejemplo: LEDs parpadeando
void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(13, HIGH);
  delay(1000);
  digitalWrite(13, LOW);
  delay(1000);
}
```

### Tests Funcionales en Hardware
```cpp
// Siempre verificar en hardware real:
// 1. Sensores leen valores
// 2. WiFi conecta
// 3. MQTT publica sin errores
// 4. Reconexión funciona

void test_sensor() {
  float temp = dht.readTemperature();
  assert(temp != NAN);
  assert(temp > -50 && temp < 70);
  Serial.println("TEST: Sensor test pasó");
}
```

---

## Troubleshooting Común

### Problema: Arduino se resetea frecuentemente
```cpp
// Causa: Watchdog activado
// Solución: Deshabilitar o usar delays cortos
#include <avr/wdt.h>
wdt_disable();  // Si necesitas
```

### Problema: WiFi desconectado
```cpp
// Siempre verificar estado en loop
if (WiFi.status() != WL_CONNECTED) {
  reconnectWiFi();
}
```

### Problema: MQTT no publica
```cpp
// Verificar:
// 1. Credenciales correctas
// 2. Broker accesible
// 3. Topic format correcto
if (!client.publish("sensors/data", message)) {
  Serial.println("MQTT publish falló");
  // Reintentar luego
}
```

---

## Ejemplo: Sketch Completo

```cpp
#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>

// Config
const char* SSID = "MyNetwork";
const char* PASS = "MyPassword";
const char* MQTT_BROKER = "mosquitto.local";
const int MQTT_PORT = 1883;

// Pins
#define DHT_PIN 2
#define LED_STATUS 13

// Timing
#define READ_INTERVAL 5000
unsigned long lastRead = 0;

// Setup
DHT dht(DHT_PIN, DHT22);
WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

void setup() {
  Serial.begin(115200);
  pinMode(LED_STATUS, OUTPUT);
  
  dht.begin();
  WiFi.begin(SSID, PASS);
  
  // Esperar WiFi (máx 10 segundos)
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    digitalWrite(LED_STATUS, HIGH);
    delay(250);
    digitalWrite(LED_STATUS, LOW);
    delay(250);
    attempts++;
  }
  
  Serial.println("INIT: Sistema listo");
  
  mqttClient.setServer(MQTT_BROKER, MQTT_PORT);
}

void loop() {
  // Mantener conexión
  if (!mqttClient.connected()) {
    reconnectMqtt();
  }
  mqttClient.loop();
  
  // Leer datos cada 5 segundos
  if (millis() - lastRead >= READ_INTERVAL) {
    readAndPublish();
    lastRead = millis();
  }
}

void readAndPublish() {
  float temp = dht.readTemperature();
  float humid = dht.readHumidity();
  
  if (isnan(temp) || isnan(humid)) {
    Serial.println("ERROR: DHT read failed");
    return;
  }
  
  char msg[256];
  snprintf(msg, sizeof(msg),
    "{\"device_id\":\"ard_001\",\"temp\":%.1f,\"humidity\":%.1f}",
    temp, humid);
  
  if (mqttClient.publish("sensors/ard_001/data", msg)) {
    digitalWrite(LED_STATUS, HIGH);
    delay(100);
    digitalWrite(LED_STATUS, LOW);
    Serial.print("DATA: ");
    Serial.println(msg);
  }
}

void reconnectMqtt() {
  if (!mqttClient.connect("arduino_1")) {
    Serial.println("MQTT conexión falló");
    return;
  }
  Serial.println("MQTT: Conectado");
}
```

---

## Checklist Antes de Commit

- [ ] El sketch compila sin errores
- [ ] Probado en hardware o simulador (Wokwi)
- [ ] Sensor funciona (lee valores válidos)
- [ ] WiFi conecta
- [ ] MQTT publica correctamente
- [ ] Reconexión funciona
- [ ] No hay delay() largo
- [ ] Comentarios en secciones principales
- [ ] Nombres de variables claros

---

*Recuerda: Arduino es limitado en memoria. Usa String con cuidado, prefiere `char arrays`.*
