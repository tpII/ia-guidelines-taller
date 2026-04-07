# 📝 Specify — Requerimientos e Historias de Usuario

> Define QUÉ hay que construir antes de decirle a Copilot CÓMO hacerlo.

---

## Objetivo General

[Completar con tu proyecto]

Ejemplo: "Sistema IoT de monitoreo de temperatura y humedad con dashboard en tiempo real".

---

## Requerimientos Funcionales

### RF-001: Captura de datos
- **Actor:** Sistema Arduino
- **Descripción:** El Arduino captura temperatura y humedad cada 5 segundos mediante sensores
- **Resultado esperado:** Los datos se envían a través de MQTT al servidor central
- **Criterio de aceptación:**
  - El Arduino lee sensores sin errores
  - Los datos llegan con timestamp correcto
  - Se reintenta 3 veces si falla la conexión

### RF-002: Almacenamiento en backend
- **Actor:** Servidor Python
- **Descripción:** Los datos MQTT se persisten en BD y se almacenan en caché
- **Criterio de aceptación:**
  - Los últimos 1000 registros están en caché
  - Se configura rotación de logs cada 7 días
  - Consultas < 100ms

### RF-003: Visualización en tiempo real
- **Actor:** Usuario (app React)
- **Descripción:** El dashboard muestra gráficos actualizados de los sensores
- **Criterio de aceptación:**
  - Actualización cada 2 segundos
  - Soporte para 10+ simultáneos sin lag
  - Responsive en móvil

---

## Requerimientos No Funcionales

### Rendimiento
- Latencia API: < 200ms (p95)
- Uptime: 99%
- Throughput: 1000 lecturas/min

### Seguridad
- Credenciales en .env
- HTTPS en producción
- Validación de entrada en todas las APIs

### Escalabilidad
- Soportar 50+ dispositivos Arduino
- Caché distribuida (Redis)
- Indices en BD para queries frecuentes

---

## Historias de Usuario

### HU-001: Como usuario, quiero ver la temperatura actual

**Given** que estoy en el dashboard  
**When** cargo la página  
**Then** veo la lectura de temperatura más reciente en grandes caracteres  

**Criterios de aceptación:**
- [ ] La temperatura se actualiza cada 2 segundos
- [ ] Se muestra la unidad (°C)
- [ ] Hay un indicador de hace cuánto tiempo se actualizó

### HU-002: Como técnico, quiero recibir alertas si la temperatura sale de rango

**Given** que he configurado alerts entre 18°C y 28°C  
**When** la temperatura excede ese rango  
**Then** recibo una notificación push en la app  

**Criterios de aceptación:**
- [ ] La alerta se dispara en < 10 segundos
- [ ] Se muestra el valor que exceede
- [ ] Se puede desactivar la alerta temporalmente

### HU-003: Como desarrollador, quiero acceder a datos históricos

**Given** que tengo acceso a la API  
**When** hago GET /api/readings?from=2024-01-01&to=2024-01-31  
**Then** obtengo JSON con datos filtrados y paginados  

**Criterios de aceptación:**
- [ ] La respuesta incluye metadata (total, pages)
- [ ] Los datos están ordenados por timestamp DESC
- [ ] Se soportan filtros por sensor_id

---

## Casos de Uso Críticos

### CU-1: Fallo de conexión del Arduino

```
1. Sistema pierde conexión WiFi
2. Arduino intenta reconectar (backoff exponencial)
3. Mientras tanto, bufferea datos en memoria/EEPROM
4. Al reconectar, envía buffer y sigue normal
5. Backend detecta timestamp saltados y dispara alerta
```

### CU-2: Pico de trafico en dashboard

```
1. 50 usuarios simultáneos en dashboard
2. Backend agrega datos en ventanas de 10s
3. Frontend recibe datos agregados via WebSocket
4. Se renderiza sin re-computar todo
```

---

## Mockups / Wireframes

[Agregar descripciones de UI layouts]

Ejemplo:
```
Dashboard Principal
┌──────────────────────────────┐
│ 🌡️ Temperatura: 23.5°C       │
│ 💧 Humedad: 65%              │
│                              │
│ [Gráfico últimas 24h]        │
│                              │
│ [Botón Configurar Alertas]   │
└──────────────────────────────┘
```

---

## Dependencias Externas

- [ ] MQTT Broker (Mosquitto o HiveMQ)
- [ ] Base de datos PostgreSQL
- [ ] Redis para caché
- [ ] Hosting: AWS/DigitalOcean

---

## Métricas de Éxito

- ✅ Dashboard carga en < 2s
- ✅ 99% uptime en primer mes
- ✅ Usuarios pueden crear proyectos en < 5 min
- ✅ Cero datos perdidos en transiciones Arduino ↔️ servidor
- ✅ Cobertura de tests ≥ 80%

---

## Próximo paso

👉 Completa este documento con tu equipo y luego genera el `plan.md` con Copilot.
