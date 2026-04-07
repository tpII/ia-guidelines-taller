# 💻 Implement — Guía de Codificación Asistida

> Proceso paso a paso para implementar tareas con Copilot manteniendo la calidad y la trazabilidad.

---

## Principios de Implementación

1. **Contexto primero:** Siempre tenés abiertos `constitution.md` y la task que estás implementando
2. **Revisar antes de commitear:** No commiteés código que no entendes
3. **Documentar decisiones:** Si Copilot propuso algo no obvio, anotalo en un ADR
4. **Tests simultáneamente:** Escribir test junto con el código

---

## Flujo General

```
1. Seleccionar tarea (ej: T1.1)
   ↓
2. Abrir constitution.md + tasks.md en tabs
   ↓
3. Prompt a Copilot con contexto claro
   ↓
4. Revisar código generado
   ↓
5. Escribir tests
   ↓
6. Ajustar/refactorizar si es necesario
   ↓
7. Commit con mensaje descriptivo
```

---

## Ejemplo: Implementar T1.1 (Setup Backend)

### Paso 1: Preparar contexto

Abrí estos archivos en VS Code:
- `speckit/constitution.md`
- `speckit/tasks.md` (posicionado en T1.1)
- Terminal en la carpeta raíz

### Paso 2: Prompt a Copilot

```
Contexto:
- Tengo constitution.md y tasks.md abiertos
- Stack: Python 3.11, FastAPI, SQLAlchemy, PostgreSQL, Redis
- Tarea: T1.1 - Setup del proyecto backend

Necesito:
1. Crear estructura de carpetas src/models, src/services, src/api
2. requirements.txt con deps (fastapi, uvicorn, sqlalchemy, redis, paho-mqtt)
3. main.py que inicia una FastAPI app en 0.0.0.0:8000
4. Archivo de config (config.py) que lee .env
5. .env.example como template

Seguí las convenciones de constitution.md (Python style guide)
```

### Paso 3: Copilot genera

```python
# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import settings

app = FastAPI(title="IoT Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
```

### Paso 4: Revisar y ajustar

- ✅ Estructura clara
- ✅ Sigue convenciones de constitution.md
- ⚠️ Agregar logging desde el inicio
- ⚠️ Agregar health check endpoint

```python
import logging

logger = logging.getLogger(__name__)

@app.get("/health")
async def health_check():
    logger.info("Health check called")
    return {"status": "ok"}

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    ...
```

### Paso 5: Escribir test (mínimo)

```python
# tests/test_main.py
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
```

### Paso 6: Commit

```bash
git add -A
git commit -m "feat(backend): setup inicial de FastAPI con estructura base

- Crear estructura src/models, src/services, src/api
- Configurar CORS, logging, health check
- Archivo de config que lee de .env
- Requirements con dependencias principales"
```

---

## Flujo para APIs (Ej: T2.1 GET /api/readings)

### Paso 1: Especificar la tarea en Copilot

```
Voy a implementar T2.1: Endpoint GET /api/readings

Referencia: speckit/specification.md → HU-003
Query params: sensor_id, from (timestamp), to (timestamp), limit (default 100)

Requiremientos:
1. Validar parámetros
2. Query a BD con filtros
3. Ordenar por timestamp DESC
4. Paginación (offset/limit)
5. Cachear en Redis (TTL 5 min)
6. Response en JSON con metadata

Response format (según specification):
{
  "data": [...],
  "pagination": {"current_page": 1, "total_pages": 5},
  "metadata": {"query_time_ms": 45}
}
```

### Paso 2: Código generado (revisado)

```python
# src/api/routes/readings.py
from fastapi import APIRouter, Query, Depends
from sqlalchemy.orm import Session
from src.models import Reading, Sensor
from src.services import cache_service
import json
from datetime import datetime
import time

router = APIRouter(prefix="/readings", tags=["readings"])

@router.get("/")
async def get_readings(
    sensor_id: int | None = Query(None),
    from_ts: int = Query(None, alias="from"),
    to_ts: int = Query(None, alias="to"),
    limit: int = Query(100, le=1000),
    offset: int = Query(0),
    db: Session = Depends(get_db),
):
    """Obtener lecturas históricas con filtros opcionales"""
    
    # Generar cache key
    cache_key = f"readings:{sensor_id}:{from_ts}:{to_ts}:{limit}:{offset}"
    
    # Intentar obtener de caché
    cached = await cache_service.get(cache_key)
    if cached:
        return json.loads(cached)
    
    start_time = time.time()
    
    # Build query
    query = db.query(Reading)
    
    if sensor_id:
        query = query.filter(Reading.sensor_id == sensor_id)
    
    if from_ts:
        query = query.filter(Reading.timestamp >= from_ts)
    
    if to_ts:
        query = query.filter(Reading.timestamp <= to_ts)
    
    # Count total
    total = query.count()
    
    # Paginate
    readings = query.order_by(Reading.timestamp.desc())\
                    .offset(offset)\
                    .limit(limit)\
                    .all()
    
    query_time = int((time.time() - start_time) * 1000)
    
    response = {
        "data": [r.to_dict() for r in readings],
        "pagination": {
            "current_page": offset // limit + 1,
            "total_pages": (total + limit - 1) // limit,
            "total_items": total,
        },
        "metadata": {"query_time_ms": query_time}
    }
    
    # Cachear por 5 minutos
    await cache_service.set(cache_key, json.dumps(response), ttl=300)
    
    return response
```

### Paso 3: Test (antes de mergear)

```python
# tests/test_readings.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_get_readings_empty(db_session):
    response = client.get("/api/readings")
    assert response.status_code == 200
    assert response.json()["data"] == []

def test_get_readings_with_filter(db_session, sample_readings):
    response = client.get("/api/readings?sensor_id=1&limit=10")
    assert response.status_code == 200
    data = response.json()
    assert len(data["data"]) > 0
    assert data["pagination"]["total_pages"] >= 1

def test_reading_cache(db_session, sample_readings):
    # Primera llamada
    r1 = client.get("/api/readings?sensor_id=1")
    t1 = r1.json()["metadata"]["query_time_ms"]
    
    # Segunda llamada (desde caché)
    r2 = client.get("/api/readings?sensor_id=1")
    t2 = r2.json()["metadata"]["query_time_ms"]
    
    # Caché debería ser más rápido
    assert t2 < t1 or t2 < 10  # either faster or sub-10ms
```

---

## Patrones Recurrentes

### Patrón 1: Crear un modelo ORM + tests

```
1. Copilot prompt:
   "Crea modelo ORM para Sensor con campos: device_id (unique),
    name, type, location, created_at. 
    Seguí en constitution.md Python style guide"

2. Generar:
   - models/sensor.py (SQLAlchemy)
   - migration con Alembic
   - test_sensor.py (CRUD)

3. Commit: feat(models): agregar Sensor ORM
```

### Patrón 2: Crear endpoint completo

```
1. Especificar en Copilot:
   - Ruta exacta (/api/...)
   - Método (GET/POST)
   - Query/body params
   - Response format

2. Generar:
   - Función en api/routes/
   - Validación con Pydantic
   - Tests con pytest

3. Commit: feat(api): implementar endpoint X
```

### Patrón 3: Agregar feature a componente React

```
1. Especificar en Copilot:
   - Componente base
   - Funcionalidad nueva
   - Props esperadas
   - Style (Tailwind)

2. Generar:
   - Componente mejorado
   - Hook si es necesario
   - Test con Vitest

3. Commit: feat(ui): agregar [feature] a [Componente]
```

---

## Checklist Previo a Commit

- [ ] Código funciona localmente
- [ ] Pasó tests (cobertura ≥ 80%)
- [ ] Sigue convenciones de `constitution.md`
- [ ] Docstrings/JSDoc presentes
- [ ] Imports organizados
- [ ] Logs info/error en puntos estratégicos
- [ ] No hay credenciales commiteadas
- [ ] Mensaje de commit es descriptivo (Conventional Commits)

---

## Si Copilot generó código incorrecto

1. Revisá el error específico
2. Agregá más contexto al prompt (ej: "vimos este error: ...")
3. Pedile que refactorice
4. Si sigue sin funcionar, preguntale qué supone que debería pasar

**Ejemplo:**
```
❌ El endpoint devuelve 500
✅ Prompt: "El endpoint GET /api/readings devuelve 500 cuando
   sensor_id=1. El error en logs es 'column not found'.
   Verificá que el query esté usando el nombre correcto de columna."
```

---

## Registro de Decisiones

Cuando Copilot propone una arquitectura no obvia:

```
Agregar a adr/ADR-XXX-decision.md:

Titulo: "¿Por qué Redis para caché en readings?"

Contexto: Necesitábamos queries rápidas en GET /readings

Opción A: Caché en Python (in-memory)
- ✅ Simple
- ❌ No compartido entre workers

Opción B: Redis
- ✅ Compartido entre procesos
- ✅ TTL automático
- ❌ Dependencia extra

Opción C: Query directo a BD
- ✅ Datos siempre frescos
- ❌ Lento con muchos registros

Decisión: Redis (opción B)
Rationale: Copilot sugirió que para una API con múltiples
workers Uvicorn, Redis es el estándar.
```

---

## Cuándo NO usar Copilot generado

- ❌ No entendés qué hace una línea
- ❌ Código que duplica lógica existente
- ❌ Soluciones que son "mágicas" sin explicación
- ❌ Tests que solo pasan pero no verifican realmente

---

## Próximo paso

👉 Seleccionar T1.1, abrir contexto, y empezar con Copilot siguiendo este flujo.
