# 📋 Constitution — Principios del Proyecto

> Este documento define los principios, restricciones y convenciones de tu proyecto. Es el **contexto base** que Copilot usa para toda sugerencia de código.

---

## 1. Stack Tecnológico

### Principal
- **Backend:** Python 3.11+
- **Frontend:** ReactJS 18+
- **Dispositivos:** Arduino, Raspberry Pi

### Dependencias clave
- **Python:** Flask/FastAPI, SQLAlchemy, pytest
- **ReactJS:** Vite, Tailwind CSS, React Query
- **Arduino:** Arduino IDE 2.x
- **RPi:** Python venv, systemd para servicios

---

## 2. Convenciones de Código

### Python
```python
# Nombrado
- Módulos: snake_case
- Clases: PascalCase
- Funciones/variables: snake_case
- Constantes: UPPER_SNAKE_CASE

# Formato
- Usar Black para formateo automático
- Max line length: 88 caracteres
- Imports ordenados: isort
- Type hints obligatorios en public APIs

# Estructura de proyecto
proyecto/
├── src/
│   ├── models/
│   ├── services/
│   ├── api/
│   └── utils/
├── tests/
├── requirements.txt
└── pyproject.toml
```

### JavaScript/React
```javascript
// Nombrado
- Componentes: PascalCase (MyButton.jsx)
- Funciones/variables: camelCase
- Constantes: UPPER_SNAKE_CASE
- Archivos CSS: kebab-case (my-button.css)

// Formato
- Usar Prettier para formateo automático
- Max line length: 100 caracteres
- Imports organizados con grupos: React, libs, components, utils

// Estructura
src/
├── components/
│   ├── forms/
│   ├── widgets/
│   └── layouts/
├── pages/
├── hooks/
├── services/
├── styles/
└── utils/
```

### Arduino
```cpp
// Nombrado
- Funciones/variables: camelCase
- Constantes: UPPER_SNAKE_CASE
- Defines: UPPER_SNAKE_CASE

// Estructura
- setup() y loop() siempre presentes
- Declaración de pins como constantes al inicio
- Funciones auxiliares antes de setup()
- Comentarios para cada sección

// Librerías
- Preferir librerías estándar (Wire, SPI, Serial)
- Documentar cualquier librería externa
```

---

## 3. Criterios de Calidad

### Testing
- **Python:** Mínimo 80% cobertura con pytest
- **React:** Mínimo 70% cobertura con Vitest
- **Arduino:** Simulación con Wokwi (si aplica), tests funcionales en hardware

### Documentación
- Docstrings en Python (Google style)
- JSDoc en JavaScript
- Comentarios en Arduino solo para lógica no obvia
- README con setup instructions

### Performance
- Python: Perfiles con cProfile en funciones críticas
- React: Lighthouse score mín 85
- Arduino: Latencia < 100ms en loops críticos

---

## 4. Restricciones

### ❌ Prohibido
- Hardcodear credenciales o secrets
- Usar `var` en JavaScript (solo `const`, `let`)
- Funciones Python > 20 líneas sin refactor
- Componentes React con múltiples efectos no documentados

### ✅ Obligatorio
- .env.example en la raíz (sin valores)
- Versionado semántico en tags
- ADRs para decisiones arquitectónicas
- Commits con mensajes descriptivos (Conventional Commits)

---

## 5. Mensajes de Commit

Usar Conventional Commits:

```
type(scope): description

[optional body]

[optional footer]
```

### Tipos
- `feat:` nueva funcionalidad
- `fix:` corrección de bug
- `docs:` cambios en documentación
- `style:` cambios de formato (no logic)
- `refactor:` refactorización sin cambios funcionales
- `test:` agregando o actualizando tests
- `chore:` cambios en build, deps, etc.

### Ejemplos
```
feat(auth): agregar soporte para JWT
fix(api): corregir validación de email inválido
docs: actualizar instrucciones de setup
refactor(models): simplificar lógica de búsqueda
```

---

## 6. Flujo de Desarrollo

1. **Especificación:** escribir requerimientos claros
2. **Plan:** desglosar en componentes y capas
3. **ADR:** documentar decisiones técnicas
4. **Implementación:** código + tests + docs
5. **Review:** al menos un reviewer antes de merge

---

## 7. Herramientas Recomendadas

### IDE
- VS Code + Copilot + Pylance (Python) + ESLint

### Pre-commit hooks
- black, isort, flake8 (Python)
- prettier, eslint (JavaScript)
- Arduino: verificación de sintaxis

### CI/CD
- GitHub Actions para tests on push
- Deploy automático a staging en PRs

---

## 8. Monitoreo y Logs

### Python
```python
import logging

logger = logging.getLogger(__name__)
logger.info("Evento normal")
logger.error("Error con contexto", exc_info=True)
```

### React
```javascript
console.log("[ComponentName]", "mensaje con contexto");
```

### Arduino
```cpp
Serial.print("INIT: Sistema iniciado\n");
Serial.print("ERROR: Sensor no disponible\n");
```

---

## Próximo paso

👉 Completá este documento con especificidades de tu proyecto y copialo a `.github/copilot-instructions.md`.
