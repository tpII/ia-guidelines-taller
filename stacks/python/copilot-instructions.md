# 🐍 Python (Backend) — Instrucciones de Copilot

> Copia este archivo a `.github/copilot-instructions.md` en tu proyecto Backend.

---

## Workflow: Spec-Driven Development

Este proyecto usa un flujo de trabajo Spec-Driven. Antes de generar código, seguí estas reglas:

### Archivos de contexto (leer siempre)
- `speckit/constitution.md` — convenciones y restricciones del proyecto. **Tienen prioridad sobre este archivo.**
- `speckit/specify.md` — requerimientos e historias de usuario. Usalo para entender QUÉ construir.
- `speckit/plan.md` — arquitectura técnica. Usalo para entender CÓMO está estructurado el sistema.
- `speckit/tasks.md` — tareas asignadas. Usalo para entender en qué tarea estás trabajando.

### Comportamiento por fase

**Fase specify** — Si te piden completar `speckit/specify.md`:
- Ayudá a redactar requerimientos funcionales (RF-NNN) e historias de usuario (HU-NNN)
- Usá el formato Given/When/Then para historias
- No generes código todavía

**Fase plan** — Si te piden completar `speckit/plan.md`:
- Proponé arquitectura de componentes basada en specify.md
- Identificá las capas: models, services, api, ws
- Describí flujos de datos, no implementaciones
- Mencioná qué decisiones técnicas merecen un ADR

**Fase tasks** — Si te piden completar `speckit/tasks.md`:
- Desglosá el plan en tareas por sprint
- Cada tarea debe tener: descripción, archivos afectados, criterio de done, estimación
- Asegurate que cada tarea es implementable en 1-4 horas

**Fase implement** — Cuando generás código:
- Consultá `speckit/constitution.md` para convenciones específicas del proyecto
- Referenciá la tarea de `speckit/tasks.md` que estás implementando
- Generá tests junto con el código, nunca por separado
- Si detectás que estás tomando una decisión técnica importante (framework, patrón, librería), sugerí crear un ADR antes de seguir

### Cuándo sugerir un ADR

Sugerí crear un ADR (Architecture Decision Record) cuando:
- Se elige entre dos frameworks o librerías con trade-offs reales
- Se define la estrategia de autenticación o autorización
- Se elige un patrón de comunicación entre capas (HTTP, eventos, colas)
- Se toma una decisión que afecta múltiples módulos

Formato de sugerencia:
```
⚠️ Esta decisión merece un ADR.
Ejecutá: cp adr/template.md adr/ADR-NNN-[tema].md
Documentá: [qué opciones consideraste y por qué elegiste esta]
```

---

## Stack: Python + FastAPI + SQLAlchemy

### Versiones
- Python: 3.11+ (recomendado 3.12)
- FastAPI: 0.104+
- SQLAlchemy: 2.0+
- PostgreSQL: 14+
- Redis: 7+

---

## Convenciones de Código Python

> **Context Pointer (Clean Code):** Para cualquier duda sobre formato estructural, nombrado de variables, principios SOLID o refactorizaciones de algoritmos, el estándar técnico absoluto del proyecto reside en `stacks/python/clean-code-python.md`. El asistente debe leer estrictamente este documento y usarlo como _System Prompt_ prioritario antes de generar cualquier tipo de código backend python.

### Nombrado
```python
# Módulos y archivos: snake_case
# ✅ user_service.py
# ❌ UserService.py

# Clases: PascalCase
class SensorManager:
    pass

# Funciones y métodos: snake_case
def read_sensor_data():
    pass

# Constantes: UPPER_SNAKE_CASE
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30

# Variables privadas: _leading_underscore
_internal_state = {}
```

### Formato

#### Max Line Length: 88 caracteres
```python
# Black (formatter estándar Python)
# Configurar en pyproject.toml:
[tool.black]
line-length = 88
target-version = ['py311']
```

#### Imports (Estricto PEP-8 e Isort)
La gestión de los encabezados es vital para la limpieza arquitectónica.
*   **Regla 1:** Prohibido hacer global imports (`import *`).
*   **Regla 2:** Seguir el estándar agrupando en 3 bloques separados por una línea vacía: Nativas, de Terceros, y Módulos Locales.
*   **Regla 3:** Ordenar alfabéticamente dentro de cada bloque. Todos los códigos sugeridos deben emular el output de la herramienta `isort`.

```python
# 1. Nativas (stdlib)
import json
import os
from datetime import datetime
from typing import List, Optional

# 2. Terceros
import sqlalchemy
from fastapi import Depends, FastAPI
from pydantic import BaseModel

# 3. Locales Absolutas (jamás relativas)
from src.config import settings
from src.models import Reading, User
```

#### Type Hints (obligatorio en public APIs)
```python
# ✅ CORRECTO: con hints
def get_reading(sensor_id: int, limit: int = 100) -> List[dict]:
    """Obtener lecturas de un sensor.
    
    Args:
        sensor_id: ID del sensor
        limit: Cantidad máxima de registros
        
    Returns:
        Lista de lecturas en formato dict
    """
    pass

# ❌ INCORRECTO: sin hints
def get_reading(sensor_id, limit=100):
    pass
```

### Estructura de Proyecto
```
proyecto-backend/
├── src/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app
│   ├── config.py               # Config desde .env
│   │
│   ├── models/                 # SQLAlchemy ORM
│   │   ├── __init__.py
│   │   ├── base.py             # Base class
│   │   ├── user.py
│   │   └── reading.py
│   │
│   ├── schemas/                # Pydantic models (validación)
│   │   ├── __init__.py
│   │   ├── user_schema.py
│   │   └── reading_schema.py
│   │
│   ├── services/               # Lógica de negocio
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   ├── sensor_service.py
│   │   └── mqtt_service.py
│   │
│   ├── api/
│   │   ├── routes/             # Endpoints
│   │   │   ├── __init__.py
│   │   │   ├── users.py
│   │   │   └── readings.py
│   │   │
│   │   └── ws/                 # WebSocket
│   │       ├── __init__.py
│   │       └── events.py
│   │
│   ├── auth/
│   │   ├── __init__.py
│   │   └── jwt.py
│   │
│   └── utils/
│       ├── __init__.py
│       └── helpers.py
│
├── tests/
│   ├── __init__.py
│   ├── conftest.py             # Fixtures
│   ├── test_users.py
│   ├── test_readings.py
│   └── test_mqtt.py
│
├── migrations/                  # Alembic
│   └── ...
│
├── .env.example
├── .env
├── requirements.txt
├── pyproject.toml
├── pytest.ini
└── README.md
```

---

## Librerías Recomendadas

```
# Core
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
pydantic-settings==2.1.0

# Database
sqlalchemy==2.0.23
alembic==1.12.1
psycopg[binary]==3.17.0

# Cache & Broker
redis==5.0.0
paho-mqtt==1.6.1

# Auth
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4

# Validation & Serialization
python-multipart==0.0.6

# Testing
pytest==7.4.3
pytest-cov==4.1.0
pytest-asyncio==0.21.1
httpx==0.25.2

# Code Quality
black==23.11.0
isort==5.12.0
flake8==6.1.0
mypy==1.7.1

# Logging
python-json-logger==2.0.7
```

---

## Patrones FastAPI

### 1. Modelo ORM + Schema Pydantic

```python
# models/reading.py (SQLAlchemy)
from sqlalchemy import Column, Integer, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from src.models.base import Base
from datetime import datetime

class Reading(Base):
    __tablename__ = "readings"
    
    id = Column(Integer, primary_key=True)
    sensor_id = Column(Integer, ForeignKey("sensors.id"), nullable=False)
    value = Column(Float, nullable=False)
    unit = Column(String(10), nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "sensor_id": self.sensor_id,
            "value": self.value,
            "unit": self.unit,
            "timestamp": self.timestamp.isoformat(),
        }

# schemas/reading_schema.py (Pydantic)
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class ReadingCreate(BaseModel):
    sensor_id: int
    value: float = Field(..., ge=-50, le=150)
    unit: str = Field(..., min_length=1, max_length=10)

class ReadingResponse(BaseModel):
    id: int
    sensor_id: int
    value: float
    unit: str
    timestamp: datetime

    class Config:
        from_attributes = True  # ORM compatibility
```

### 2. Endpoint con validación
```python
# api/routes/readings.py
from fastapi import APIRouter, Query, Depends, HTTPException
from sqlalchemy.orm import Session
from src.models import Reading
from src.schemas import ReadingCreate, ReadingResponse
from src.config import get_db
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/readings", tags=["readings"])

@router.get("/", response_model=list[ReadingResponse])
async def list_readings(
    sensor_id: int | None = Query(None),
    limit: int = Query(100, le=1000),
    offset: int = Query(0),
    db: Session = Depends(get_db),
) -> list[ReadingResponse]:
    """Obtener lecturas con filtros opcionales."""
    
    query = db.query(Reading)
    
    if sensor_id:
        query = query.filter(Reading.sensor_id == sensor_id)
    
    total = query.count()
    readings = query.order_by(Reading.timestamp.desc()).offset(offset).limit(limit).all()
    
    logger.info(f"Retornando {len(readings)} lecturas (total: {total})")
    
    return readings

@router.post("/", response_model=ReadingResponse, status_code=201)
async def create_reading(
    reading: ReadingCreate,
    db: Session = Depends(get_db),
) -> ReadingResponse:
    """Crear una nueva lectura."""
    
    db_reading = Reading(**reading.dict())
    db.add(db_reading)
    db.commit()
    db.refresh(db_reading)
    
    logger.info(f"Lectura creada: {db_reading.id}")
    
    return db_reading
```

### 3. Servicio (lógica de negocio)
```python
# services/sensor_service.py
from sqlalchemy.orm import Session
from src.models import Reading, Sensor
from typing import List
import logging

logger = logging.getLogger(__name__)

class SensorService:
    """Servicio para operaciones con sensores."""
    
    @staticmethod
    def get_latest_reading(sensor_id: int, db: Session) -> Reading | None:
        """Obtener la lectura más reciente de un sensor."""
        return db.query(Reading)\
                 .filter(Reading.sensor_id == sensor_id)\
                 .order_by(Reading.timestamp.desc())\
                 .first()
    
    @staticmethod
    def get_readings_range(
        sensor_id: int,
        from_ts: int,
        to_ts: int,
        db: Session,
    ) -> List[Reading]:
        """Obtener lecturas en rango de timestamp."""
        return db.query(Reading)\
                 .filter(Reading.sensor_id == sensor_id)\
                 .filter(Reading.timestamp >= from_ts)\
                 .filter(Reading.timestamp <= to_ts)\
                 .order_by(Reading.timestamp.desc())\
                 .all()
    
    @staticmethod
    def check_alert_conditions(readings: List[Reading]) -> List[dict]:
        """Verificar si alguna lectura excede thresholds."""
        alerts = []
        
        for reading in readings:
            if reading.value > 30:  # Ejemplo
                alerts.append({
                    "sensor_id": reading.sensor_id,
                    "value": reading.value,
                    "reason": "Temperatura alta",
                })
                logger.warning(f"ALERT: Sensor {reading.sensor_id} = {reading.value}")
        
        return alerts
```

### 4. Dependencias inyectadas
```python
# Inyectar sesión de BD
from sqlalchemy.orm import Session
from src.config import SessionLocal

def get_db() -> Session:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Inyectar usuario actual (JWT)
from fastapi.security import HTTPBearer, HTTPAuthCredentials
from src.auth.jwt import decode_token

security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthCredentials = Depends(security)):
    user = decode_token(credentials.credentials)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user

# Usar en endpoint
@router.get("/my-data")
async def get_my_data(current_user = Depends(get_current_user), db = Depends(get_db)):
    # current_user está disponible
    pass
```

### 5. WebSocket
```python
# api/ws/events.py
from fastapi import APIRouter, WebSocket, Depends
from sqlalchemy.orm import Session
import json
import asyncio

router = APIRouter()

@router.websocket("/ws/live")
async def websocket_live(websocket: WebSocket):
    """Stream de eventos en tiempo real."""
    await websocket.accept()
    
    try:
        while True:
            # Simulación: podría ser redis.lpop("event_stream")
            data = {"sensor_id": 1, "value": 23.5, "timestamp": "2024-01-15T10:00:00"}
            
            await websocket.send_json(data)
            await asyncio.sleep(2)  # Update cada 2 segundos
            
    except Exception as e:
        logger.error(f"WS error: {e}")
    finally:
        await websocket.close()
```

---

## Documentación de Código

El estándar oficial de documentación en Python es el **PEP 257**. El asistente debe cumplir obligatoriamente lo siguiente:

1. **Module Docstrings Principales:** Absolutamente todo nuevo archivo `.py` creado o intervenido DEBE arrancar en su Primera Línea con un Docstring general resumiendo qué hace ese módulo o archivo. Jamás un archivo puede arrancar directamente por los `imports`.
2. **Componentes Internos (Google Style):** Usar la notación estándar de Google para documentar Clases y Funciones Públicas. Evitar sintaxis anticuadas como Sphinx (reST).
3. **Tests Unitarios:** Las funciones que vivan dentro de `/tests` no están eximidas; **deben obligatoriamente** poseer su própio docstring (`"""Verifica que..."""`) para evitar que linters como Pylint estallen de enojo.
4. **Imports Basura (Unused Imports):** Es mandatorio que después de cualquier ciclo de refactorización el asistente repase y elimine las librerías importadas arriba (`import json`, `import os`, etc) que hayan dejado de utilizarse por los cambios en el código. Esto prevendrá errores de IDE y Pylint.

```python
class MqttPublisher:
    """Clase encargada de inyectar datos en el broker MQTT.
    
    Attributes:
        host (str): La IP del broker MQTT.
        port (int): El puerto de conexión.
    """
    
    def publish(self, topic: str, payload: dict) -> bool:
        """Publica un mensaje codificado en JSON al tópico dado.
        
        Args:
            topic (str): El tópico destino (ej. 'sensor/temp').
            payload (dict): El diccionario de datos a enviar.
            
        Returns:
            bool: True si se encoló correctamente, False de lo contrario.
            
        Raises:
            ConnectionError: Si el broker se encuentra offline.
        """
        pass
```

---

## Testing con Pytest (TDD y Cobertura >80%)

El desarrollo debe orientarse mandatoriamente hacia la práctica de **Test-Driven Development (TDD)**. El Asistente IA debe proponer Unit Tests para cada servicio o regla de negocio antes o en simultáneo de generar código, focalizando en comportamiento puro y sin acoplamiento duro a bases de datos o brokers externos.

Asimismo, existe el piso intransigente de >80% de **Line Coverage** verificable con `pytest-cov`. El Asistente debe garantizar tests de flujos de error (Sad Path) para no perjudicar la métrica global.

### Estructura de tests
```python
# tests/conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.models.base import Base
from src.config import get_db
from main import app
from fastapi.testclient import TestClient

@pytest.fixture(scope="session")
def db_engine():
    """BD de test (SQLite en memoria)."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    yield engine

@pytest.fixture
def db(db_engine):
    """Session para cada test."""
    session = sessionmaker(bind=db_engine)()
    yield session
    session.rollback()

@pytest.fixture
def client(db):
    """Cliente HTTP para tests."""
    def override_get_db():
        return db
    
    app.dependency_overrides[get_db] = override_get_db
    
    with TestClient(app) as client:
        yield client

# tests/test_readings.py
def test_create_reading(client):
    response = client.post(
        "/api/readings",
        json={"sensor_id": 1, "value": 23.5, "unit": "C"}
    )
    assert response.status_code == 201
    assert response.json()["value"] == 23.5

def test_list_readings(client, db):
    # Setup
    reading = Reading(sensor_id=1, value=23.5, unit="C")
    db.add(reading)
    db.commit()
    
    # Test
    response = client.get("/api/readings?sensor_id=1")
    assert response.status_code == 200
    assert len(response.json()) > 0
```

---

## Logging

```python
# src/config.py
import logging
from logging.handlers import RotatingFileHandler

def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    
    # Formato
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Archivo (rotativo)
    file_handler = RotatingFileHandler(
        'app.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5
    )
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    
    # Console
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

# En main.py
from src.config import setup_logging

setup_logging()
logger = logging.getLogger(__name__)
```

---

## Checklist Previo a Commit

### Coherencia con speckit
- [ ] El código implementa una tarea definida en `speckit/tasks.md`
- [ ] Las convenciones siguen `speckit/constitution.md`
- [ ] Si hubo decisión arquitectónica: hay ADR creado en `adr/`

### Calidad técnica
- [ ] Code formateado con Black (`black .`)
- [ ] Imports organizados con isort (`isort .`)
- [ ] Type hints en public APIs
- [ ] Docstrings en funciones importantes
- [ ] Tests pasen (`pytest -v --cov`)
- [ ] Cobertura >= 80%
- [ ] No hay hardcoding de secrets
- [ ] `.env` en .gitignore

---

*Recuerda: Python requiere disciplina. Sin estructura, crece caótico.*
