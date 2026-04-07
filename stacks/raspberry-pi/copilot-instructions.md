# 🍓 Raspberry Pi (Python) — Instrucciones de Copilot

> Copia este archivo a `.github/copilot-instructions.md` en tu proyecto Raspberry Pi.

---

## Stack: Raspberry Pi + Python

### Especificaciones
- Placa: Raspberry Pi 4 (4GB+ recomendado)
- OS: Raspberry Pi OS (Debian based)
- Python: 3.9+
- Conexión: WiFi o Ethernet, GPIO para periféricos

### Roles
RPi puede actuar como:
1. **Bridge MQTT:** Conectar Arduino vía USB/Serial → MQTT
2. **Backend local:** Ejecutar servicio Python (Flask, FastAPI)
3. **Gateway:** Procesar datos antes de subir a nube

---

## Setup Inicial

### 1. Preparar OS
```bash
# SSH a RPi
ssh pi@raspberrypi.local

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y python3-pip python3-venv git
```

### 2. Crear proyecto Python
```bash
cd ~/projects
python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip setuptools wheel
pip install fastapi uvicorn sqlalchemy redis paho-mqtt
```

### 3. Estructura de proyecto
```
rpi-backend/
├── .env
├── .env.example
├── requirements.txt
├── src/
│   ├── main.py
│   ├── models/
│   ├── services/
│   └── config.py
├── tests/
├── systemd/
│   └── rpi-service.service
└── README.md
```

---

## Convenciones de Código Python (ver: stacks/python/copilot-instructions.md)

Aplicar las mismas que en `stacks/python/` — en RPi solo ejecutamos Python.

---

## Servicios en RPi (systemd)

### Crear servicio que inicie al boot

Archivo: `systemd/rpi-service.service`

```ini
[Unit]
Description=RPi IoT Backend Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/projects/rpi-backend
ExecStart=/home/pi/projects/rpi-backend/venv/bin/python3 src/main.py
Restart=on-failure
RestartSec=5

Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-user.target
```

### Instalar y activar
```bash
sudo cp systemd/rpi-service.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable rpi-service
sudo systemctl start rpi-service

# Ver logs
sudo journalctl -u rpi-service -f
```

---

## I/O y GPIO

### Lectura de GPIO (botones, sensores digitales)
```python
import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)  # Usar BCM pin numbering
GPIO.setup(17, GPIO.IN)  # Pin 17 como entrada

try:
    while True:
        if GPIO.input(17):
            print("Botón presionado")
        time.sleep(0.1)
finally:
    GPIO.cleanup()
```

### Control de GPIO (LEDs, relés)
```python
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setup(27, GPIO.OUT)  # Pin 27 como salida

GPIO.output(27, GPIO.HIGH)   # Encender LED
time.sleep(1)
GPIO.output(27, GPIO.LOW)    # Apagar LED

GPIO.cleanup()
```

### I2C (sensores BMP280, HTU21D, etc.)
```python
import smbus
import time

bus = smbus.SMBus(1)  # Bus I2C 1 (pines 2 y 3)

# Escribir a dirección 0x77 (BMP280)
data = [0xF7]  # Registro de presión
bus.write_i2c_block_data(0x77, 0, data)

# Leer respuesta
response = bus.read_i2c_block_data(0x77, 0xF7, 3)
print(f"Presión: {response}")
```

### UART Serial (conectar Arduino a RPi)
```python
import serial
import time

# Conectar a Arduino vía USB
ser = serial.Serial(
    port='/dev/ttyUSB0',      # Puerto serial (verificar con lsusb)
    baudrate=115200,
    timeout=1
)

while True:
    if ser.in_waiting:
        line = ser.readline().decode('utf-8').strip()
        print(f"Arduino: {line}")
    time.sleep(0.1)

ser.close()
```

---

## Lectura de Sensores

### DHT22 (temperatura/humedad)
```python
import board
import adafruit_dht

# Crear sensor en pin D17
dhtDevice = adafruit_dht.DHT22(board.D17)

try:
    temperature = dhtDevice.temperature
    humidity = dhtDevice.humidity
    print(f"Temp: {temperature}°C, Humedad: {humidity}%")
except RuntimeError as e:
    print(f"Error leyendo DHT22: {e}")
```

### BMP280 (presión/altitud)
```python
import board
import busio
import adafruit_bmp280

i2c = busio.I2C(board.SCL, board.SDA)
bmp280 = adafruit_bmp280.Adafruit_BMP280_I2C(i2c, address=0x77)

print(f"Presión: {bmp280.pressure} hPa")
print(f"Temperatura: {bmp280.temperature}°C")
print(f"Altitud: {bmp280.altitude} m")
```

---

## Documentación de Código

Al basarse fuertemente en backend Python, utilizar obligatoriamente **Google Style Docstrings** en módulos, clases y funciones que interactúen con puertos I/O o hardware. (Ver detalles completos en `stacks/python/copilot-instructions.md`).

```python
def setup_i2c_bus(channel: int) -> smbus.SMBus:
    """Configura e intercepta el bus I2C del hardware para lectura de sensores.
    
    Args:
        channel: El canal físico SMBus a conectar (ej. 1 para Raspberry Pi 4).
        
    Returns:
        smbus.SMBus: El objeto de bus inicializado y listo para bloquear.
    """
    pass
```

---

## Monitoreo y Logs

### Logging a archivo
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/rpi-backend.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
logger.info("Sistema iniciado")
logger.error("Error crítico", exc_info=True)
```

### Rotación de logs
```bash
# Configurar logrotate para RPi backend
# Archivo: /etc/logrotate.d/rpi-backend

/var/log/rpi-backend.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0664 pi pi
    sharedscripts
    postrotate
        systemctl reload rpi-service > /dev/null 2>&1 || true
    endscript
}
```

---

## Conectektividad MQTT (Bridge)

### Escuchar Arduino vía Serial y publicar MQTT
```python
import serial
import paho.mqtt.client as mqtt
import json
from datetime import datetime

mqtt_client = mqtt.Client("rpi_bridge")
mqtt_client.connect("mosquitto.local", 1883, 60)

ser = serial.Serial(port='/dev/ttyUSB0', baudrate=115200, timeout=1)

def on_data_from_arduino(line):
    """Arduino envía: {temp: 23.5, humidity: 65}"""
    try:
        data = json.loads(line)
        payload = {
            **data,
            "device_id": "rpi_01",
            "timestamp": datetime.now().isoformat()
        }
        mqtt_client.publish("sensors/rpi/data", json.dumps(payload))
    except json.JSONDecodeError:
        logger.error(f"JSON inválido: {line}")

mqtt_client.loop_start()

try:
    while True:
        if ser.in_waiting:
            line = ser.readline().decode().strip()
            on_data_from_arduino(line)
except KeyboardInterrupt:
    mqtt_client.loop_stop()
    ser.close()
```

---

## Cron Jobs

### Ejecutar tareas periódicamente
```bash
# Ver cron jobs actuales
crontab -l

# Editar
crontab -e

# Ejemplos:
# Ejecutar script cada 5 min
*/5 * * * * /home/pi/jobs/sync-to-cloud.py

# Backup diario a las 2 AM
0 2 * * * /home/pi/jobs/backup.sh

# Reiniciar servicio cada lunes a las 4 AM
0 4 * * 1 sudo systemctl restart rpi-service
```

---

## Performance en RPi

### Consideraciones
- **CPU:** Limited (ARM Cortex-A72, 4 cores)
- **RAM:** 1-8GB
- **Storage:** SD card (puede ser lento)

### Optimizaciones
```python
# 1. Usar Async para I/O
import asyncio

async def read_sensor():
    # Lectura no-blocking
    pass

# 2. Usar ProcessPoolExecutor para CPU-bound
from concurrent.futures import ProcessPoolExecutor

executor = ProcessPoolExecutor(max_workers=2)
result = executor.submit(heavy_computation)

# 3. Caché agresivo (Redis en RAM)
# Config: maxmemory 256MB (suficiente en RPi)

# 4. Evitar large dataframes (Pandas es pesado)
# Preferir: SQLAlchemy directamente + cálculos en SQL
```

---

## Troubleshooting RPi

### Problema: "Permiso denegado" en GPIO
```bash
# Solución: Agregar usuario a grupo gpio
sudo usermod -aG gpio pi
# Relogin

# O correr como root (menos recomendado)
sudo python3 script.py
```

### Problema: "/dev/ttyUSB0: No such file or  device"
```bash
# Verificar qué puerto está usando Arduino
ls -l /dev/tty*
dmesg | grep usb

# Usualmente es /dev/ttyUSB0 o /dev/ttyACM0
```

### Problema: RPi se calienta
```bash
# Ver temperatura
vcgencmd measure_temp

# Solución: Agregar heatsink, mejorar ventilación
# O throttle CPU:
# /boot/config.txt:
temp_limit=80  # Bajar a 80°C
```

---

## Security

### Conectar sin password con SSH keys
```bash
# En RPi:
mkdir -p ~/.ssh
cat << 'EOF' >> ~/.ssh/authorized_keys
[tu public key SSH]
EOF

# En tu máquina:
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@raspberrypi.local
```

### Firewall
```bash
sudo ufw enable
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 8000/tcp    # API
sudo ufw allow 5900/tcp    # VNC (opcional)
```

### .env profection
```bash
# Permisos restrictivos
chmod 600 .env
chmod 600 .env.example
```

---

## Ejemplos Completos

### Backend FastAPI en RPi

```python
# src/main.py
from fastapi import FastAPI
import logging
from src.services.mqtt_service import MqttService
from src.services.gpio_service import GpioService

logger = logging.getLogger(__name__)

app = FastAPI(title="RPi Backend")

mqtt_service = None
gpio_service = None

@app.on_event("startup")
async def startup():
    global mqtt_service, gpio_service
    
    mqtt_service = MqttService(mqtt_broker="mosquitto.local")
    mqtt_service.start()
    logger.info("MQTT service iniciado")
    
    gpio_service = GpioService()
    gpio_service.setup_pins()
    logger.info("GPIO setup completado")

@app.on_event("shutdown")
async def shutdown():
    mqtt_service.stop()
    gpio_service.cleanup()

@app.get("/health")
async def health():
    return {"status": "ok", "service": "rpi-backend"}

if __name__ == "__main__":
    import uvicorn
    logging.basicConfig(level=logging.INFO)
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
```

---

## Checklist RPi

- [ ] Python 3.9+ instalado
- [ ] Venv creado y activado
- [ ] Dependencias instaladas (pip install -r requirements.txt)
- [ ] .env configurado
- [ ] WiFi conectado
- [ ] Sensores funcionan
- [ ] MQTT conectado
- [ ] Servicio systemd creado e iniciado
- [ ] Logs configurados
- [ ] SSH sin password funciona

---

*Recuerda: Raspberry Pi es una computadora Linux completa. Mantener backups y updateada.*
