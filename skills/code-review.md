# 🧠 Code Review — Evaluación Asistida con IA

> Archivo de contexto para usar cuando revisas código. Abrilo en un tab de VS Code junto con el código a revisar.

---

## Checklist de Code Review

Cuando Copilot revise tu código, usá estas preguntas:

### 1. Correctitud
- [ ] ¿La lógica hace lo que promete?
- [ ] ¿Hay edge cases sin manejar?
- [ ] ¿Podría causar errores en runtime?

### 2. Rendimiento
- [ ] ¿Hay loops O(n²) que podrían ser O(n)?
- [ ] ¿Se hace múltiples queries a BD cuando podría ser una sola?
- [ ] ¿Se cachean resultados que deberían cachearse?

### 3. Seguridad
- [ ] ¿Hay validación de entrada?
- [ ] ¿Se protege contra SQL injection?
- [ ] ¿Hay autenticación/autorización donde se necesita?

### 4. Legibilidad
- [ ] ¿El código es autoexplicativo?
- [ ] ¿Los nombres de variables/funciones son claros?
- [ ] ¿Hablaban mejor comentarios?

### 5. Mantenibilidad
- [ ] ¿Se puede extender fácilmente?
- [ ] ¿Hay repetición que debería abstraerse?
- [ ] ¿Hay magic numbers o hardcoding?

### 6. Tests
- [ ] ¿Hay tests para el código nuevo?
- [ ] ¿Los tests son confiables (no flaky)?
- [ ] ¿Se cubren los caminos feliz y de error?

---

## Preguntas Específicas por Lenguaje

### Python
```python
# ❌ Preguntar sobre esto
- Variables globales
- Modificaciones en-place de estructuras mutables
- Falta de type hints
- Excepciones genéricas (except Exception)
- Falta de logging

# ✅ Buscar esto
- Type hints completos
- Manejo específico de excepciones
- Docstrings en Google style
- Constantes en UPPER_SNAKE_CASE
- Tests con pytest
```

### JavaScript/React
```javascript
// ❌ Preguntar sobre esto
- Usar 'var'
- Props drilling sin context
- useEffect sin dependencias correctas
- Renders innecesarios en componentes
- Falta de key en listas

// ✅ Buscar esto
- Hooks bien estructurados
- React.memo donde corresponde
- Constantes en componentes funcionales
- PropTypes o TypeScript
- Tests con React Testing Library
```

### Arduino
```cpp
// ❌ Preguntar sobre esto
- Delays extensos (sin millis())
- Sin manejo de errores en lecturas de sensores
- Sin documentación de pinout
- Buffer sin bounds checking

// ✅ Buscar esto
- Uso de millis() para timing
- Validación de datos leídos
- Comentarios en cada sección
- Manejo de edge cases (sensor desconectado)
```

---

## Flujo de Review Asistido

### Paso 1: Seleccionar código
Copiá el diff o archivo a revisar.

### Paso 2: Contexto a Copilot
```
Estoy revisando [archivo] de un proyecto [tipo: backend/frontend/iot]
Stack: [Python/JavaScript/Arduino]

Este código hace: [breve descripción]

Necesito que identifiques:
1. Problemas de seguridad
2. Posibles bugs
3. Oportunidades de optimización
4. Violaciones de convención (referencia: constitution.md)

Sé específico con números de línea si es posible.
```

### Paso 3: Análisis de Copilot
Copilot dirá qué revisó y qué encontró.

### Paso 4: Dicisión
- ✅ Aceptar cambios
- 🔄 Pedir correcciones
- 📝 Agregar ADR si fue decisión arquitectónica

---

## Anti-patterns a Buscar

### Backend (Python/FastAPI)
```python
# ❌ Anti-pattern 1: N+1 query problem
for user in users:
    orders = db.query(Order).filter(Order.user_id == user.id).all()  # Queries!

# ✅ Correcto: Join o eager load
users = db.query(User).options(joinedload(User.orders)).all()

# ❌ Anti-pattern 2: Giant functions
def process_data(x):  # 300 líneas aquí...
    pass

# ✅ Correcto: Descomponer en funciones
def validate_data(x):
    pass

def transform_data(x):
    pass

def persist_data(x):
    pass
```

### Frontend (React)
```javascript
// ❌ Anti-pattern 1: Prop drilling
<Component1 data={data} setData={setData}>
  <Component2 data={data} setData={setData}>
    <Component3 data={data} setData={setData} />

// ✅ Correcto: Context API
const DataContext = createContext();

// ❌ Anti-pattern 2: useEffect con lógica compleja
useEffect(() => {
  fetchData();
  updateUI();
  logAnalytics();
  // ... 40 líneas más
}, []);

// ✅ Correcto: useEffect pequeños y enfocados
useEffect(() => { fetchData(); }, []);
useEffect(() => { updateUI(); }, [data]);
```

### Arduino
```cpp
// ❌ Anti-pattern 1: Delays que bloquean
delay(5000);  // Bloquer = no puede leer botones, etc.

// ✅ Correcto: Usar millis()
unsigned long lastRead = 0;
if (millis() - lastRead > 5000) {
  readSensor();
  lastRead = millis();
}

// ❌ Anti-pattern 2: Sin validación
int temp = sensor.readTemp();
return temp;

// ✅ Correcto: Validar antes de usar
int temp = sensor.readTemp();
if (temp > -50 && temp < 150) {
  return temp;
}
```

---

## Severidad de Issues

### 🔴 Crítica (Bloquea merge)
- Vulnerabilidades de seguridad
- Bugs que causan crashes
- Violación de contrato de API

### 🟡 Mayor (Requiere cambio)
- Rendimiento degradado (>10%)
- Falta de tests significativa
- Código muy difícil de entender

### 🟢 Menor (Sugerencia)
- Style inconsistente
- Oportunidad de refactorización
- Mejora menor de performance

---

## Ejemplo: Review Completo

### Código a revisar
```python
# api/routes/users.py
@router.get("/users/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return {"error": "NOT_FOUND"}
    
    # Obtener pedidos del usuario
    orders = db.query(Order).filter(Order.user_id == user.id).all()
    
    return {
        "id": user.id,
        "name": user.name,
        "orders": orders,
    }
```

### Review con Copilot

Prompt:
```
Revisar el endpoint GET /users/{user_id}
Stack: Python + FastAPI
Referencia: constitution.md

Identifica:
1. Bugs de seguridad
2. Performance issues
3. Formato de error inconsistente
4. Falta de type hints
```

Respuesta (simulada):
```
🔴 Crítica:
- Falta validación: ¿user_id puede ser negativo?
- Respuesta de error no es HTTPException (inconsistente con API)

🟡 Mayor:
- N+1 query problem: se hace order_query separado
  Solución: usar joinedload

🟢 Menor:
- Falta type hint en retorno
- Sin docstring
```

### Corrección
```python
@router.get("/users/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)) -> dict:
    """Obtener un usuario con sus órdenes.
    
    Args:
        user_id: ID del usuario (debe ser > 0)
        
    Returns:
        dict con datos del usuario y órdenes
        
    Raises:
        HTTPException 404 si usuario no existe
    """
    if user_id <= 0:
        raise HTTPException(status_code=400, detail="user_id debe ser positivo")
    
    user = db.query(User)\
            .options(joinedload(User.orders))\
            .filter(User.id == user_id)\
            .first()
    
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    logger.info(f"Usuario {user_id} accedido")
    
    return {
        "id": user.id,
        "name": user.name,
        "orders": [o.to_dict() for o in user.orders],
    }
```

---

## Tips para Reviews Cuidadosos Mejor

1. **Revisar con contexto:** Siempre tenés abiertos `constitution.md`
2. **No aceptes "probablemente funciona":** Pedí tests
3. **Si Copilot sugiere un refactor:** Preguntale por qué es mejor
4. **Documenta la decisión:** Si aceptás algo no-standard, anotalo en ADR
5. **Tests primero:** No mergues sin cobertura ≥ 80%

---

## Preguntas a Copilot Durante Review

- "¿Este código violaría constitution.md?"
- "¿Hay performance issue que no veo?"
- "¿Cómo testaría esto en pytest?"
- "¿Hay manera más simple?"
- "¿Esto es un anti-pattern?"

---

*Recuerda: Copilot es tu asistente de review, no juez. La decisión final es tuya.*
