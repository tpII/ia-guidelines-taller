# 🚀 How-To — Setup e Integración

> Guías prácticas para integrar este repositorio en tu proyecto de grupo.

---

## Guía 1: Setup Inicial del Proyecto de Grupo

### Paso 1: Clonar o inicializar repo del grupo

```bash
# Si es nuevo proyecto
mkdir mi-proyecto
cd mi-proyecto
git init

# Si ya existe
git clone <repo-url>
cd <repo>
```

### Paso 2: Copiar archivos de este repo

```bash
# Crear estructura de speckit
mkdir -p speckit
cp ia-guidelines-taller/speckit/*.md speckit/

# Crear carpeta de ADRs
mkdir -p adr
cp ia-guidelines-taller/adr/template.md adr/

# Crear carpeta de GitHub
mkdir -p .github
# Copiar instrucciones para tu stack
cp ia-guidelines-taller/stacks/[tu-stack]/copilot-instructions.md .github/
```

### Paso 3: Personalizar constitution.md

```bash
# Abrí speckit/constitution.md
# Reemplaza placeholders con tu proyecto
nano speckit/constitution.md
```

Cambios mínimos en `constitution.md`:

- [ ] Actualizar stack tecnológico
- [ ] Agregar convenciones específicas del equipo
- [ ] Definir restricciones propias

### Paso 4: Hacer primer commit

```bash
git add speckit/ adr/ .github/
git commit -m "init: agregar specification kit y templates de IA"
git push origin main
```

---

## Guía 2: Primeros Pasos con Copilot

### 1. Instalar Extensión

En VS Code:
- Extensions marketplace
- Buscar "GitHub Copilot"
- Click "Install"
- Autenticarse con cuenta GitHub

### 2. Configurar Copilot

```json
// .vscode/settings.json
{
  "github.copilot.enable": {
    "*": true,
    "yaml": false,
    "plaintext": false
  },
  "files.exclude": {
    "**/.env": true
  }
}
```

### 3. Probar primera sugerencia

1. Abrí `speckit/constitution.md` en un tab
2. Abrí tu archivo de código `src/main.py`
3. Escribí comentario descriptivo:
   ```python
   # Función para leer datos de sensores siguiendo constitution.md
   def read_sensor
   ```
4. Presioná `Tab` → Copilot sugiere autocompletar

---

## Guía 3: Workflow Spec-Driven


### Fase 1: Especificación (2 horas)

1. Abrí `speckit/specify.md`
2. Tu equipo completa:
   - [ ] Requerimientos funcionales (RF-001, RF-002...)
   - [ ] Historias de usuario (HU-001, HU-002...)
   - [ ] Casos de uso críticos

3. Commit:
   ```bash
   git add speckit/specify.md
   git commit -m "docs(spec): requerimientos iniciales del proyecto"
   ```

### Fase 2: Planificación (4 horas)

1. Abrí `speckit/plan.md` + `speckit/constitution.md` en tabs
2. Prompt a Copilot:
   ```
   Basándote en specify.md y constitution.md, 
   generá un plan técnico detallado en plan.md
   con arquitectura, componentes, flujos de datos
   ```
3. Revisá, ajustá, aprobá con equipo
4. Commit:
   ```bash
   git add speckit/plan.md
   git commit -m "docs(plan): arquitectura técnica aprobada"
   ```

### Fase 3: Tareas (3 horas)

1. Abrí `speckit/tasks.md` + `speckit/plan.md`
2. Prompt a Copilot:
   ```
   Desglosá plan.md en sprints de 1 semana.
   Cada tarea con: descripción, contexto, estimación, tests.
   Usa formato de tasks.md
   ```
3. Luego: asignar tareas a desarrolladores

### Fase 4: Implementación (rest of time)

Para cada tarea (ej: T1.1):
1. Abrí `speckit/tasks.md` (posicionado en tarea)
2. Abrí `speckit/constitution.md`
3. Abrí `skills/codegen.md` (para tips)
4. Prompt a Copilot con contexto de task
5. Escribir + revisar + test
6. Commit siguiendo Conventional Commits

---

## Guía 4: Crear ADR

### Cuando crear
- Decisión técnica importante (ej: framework, ORM, arquitectura)
- Cambio que afecta múltiples módulos
- Trade-off entre alternativas

### Proceso

```bash
# 1. Copiar template
cp adr/template.md adr/ADR-001-[titulo-corto].md

# 2. Editar en VS Code
# Completar secciones clave

# 3. Compartir con equipo
# - Pull request o discusión en reunión
# - Recopilar feedback

# 4. Commit cuando esté aceptada
git add adr/ADR-001-*.md
git commit -m "docs(adr): decisión sobre [tema]"
```

---

## Guía 5: Code Review con Copilot

### 1. Antes del review

```bash
# En VS Code:
# 1. Abrí skills/code-review.md en tab
# 2. Abrí el PR/commit a revisar en otro tab
```

### 2. Prompt a Copilot

```
Estoy revisando este código (referencia: skills/code-review.md)
Stack: [Python/Java/React]
Referencia: constitution.md

Identifica:
- Bugs potenciales
- Performance issues
- Violaciones de convención
- Tests que falten
```

### 3. Acciones

- ✅ Si todo ok: approve
- 🔄 Si hay cambios: request changes (con comentarios claros)
- 📝 Si fue decisión no-obvia: crear ADR

---

## Guía 6: Estructura Git del Equipo

### Branching Strategy: Git Flow

```
main (stable releases)
├── develop (integration branch)
│   ├── feature/auth-jwt (dev 1)
│   ├── feature/mqtt-listener (dev 2)
│   └── bugfix/sensor-validation (dev 3)
└── release/v1.0.0
```

### Commit Message Standard (Conventional Commits)

```bash
git commit -m "type(scope): description

[optional body]

[optional footer]"
```

Tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`

Ejemplos:
```bash
git commit -m "feat(api): agregar endpoint GET /readings"
git commit -m "fix(mqtt): corregir reconexión exponencial backoff"
git commit -m "docs(adr): ADR-001 decisión sobre caché"
git commit -m "test(readings): aumentar cobertura a 85%"
```

### Pull Request Template

Crear `.github/pull_request_template.md`:

```markdown
## Descripción
[Qué hace este PR]

## Referencia
Closes #[issue number] (si aplica)

## Checklist
- [ ] Tests pasaron
- [ ] Documentación actualizada
- [ ] Seguir convention de constitution.md
- [ ] Si hay decisión: ADR creado

## Type
- [ ] Bug fix
- [ ] New feature
- [ ] Refactor
- [ ] Documentation
```

---

## Guía 7 (Opcional): CI/CD Mínimo (GitHub Actions)

### Crear `.github/workflows/tests.yml`

```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      
      - name: Run tests
        run: pytest --cov=src tests/
      
      - name: Check coverage
        run: |
          coverage report --fail-under=80
```

---

## Guía 8: Issues y Discussion

### Crear Issue para Feature

Título: `[FEAT] Nombre breve`

```markdown
## Description
[Qué necesita hacerse]

## User Story
As a [user] I want [action] so that [benefit]

## Acceptance Criteria
- [ ] Criterio 1
- [ ] Criterio 2

## Technical Notes
[Si usarás Copilot, menciona aquí]

## Estimación
[X story points]
```

### Usar Copilot para Asignar Tareas

```bash
# GitHub CLI:
gh issue view 42

# Copilot puede ayudarte a:
# 1. Descomponer la tarea
# 2. Generar subtasks
# 3. Escribir criterios de aceptación
```

---

## Guía 9: Monitoreo de Decisiones

### Cada 2 semanas

```bash
# 1. Revisar ADRs "Propuesta"
# 2. Actualizar estado en meetings

# 3. Si ADR resulta correcta:
#    Cambiar estado de "Propuesta" a "Aceptada"

# 4. Si ADR resulta incorrecta:
#    Cambiar estado a "Rechazada" con motivo
#    Crear nueva ADR con alternativa
```

Commit:
```bash
git commit -m "docs(adr): cambiar ADR-XYZ de Propuesta a Aceptada"
```

---

## Checklist de Setup Inicial del Grupo

- [ ] Repo del grupo creado
- [ ] Equipo clonó el repo localmente
- [ ] Copilot instalado en VS Code de todos
- [ ] `speckit/constitution.md` completado
- [ ] Primer ADR creado (decisión del stack)
- [ ] `.github/copilot-instructions.md` copiado
- [ ] `.github/workflows/tests.yml` configurado
- [ ] Primera tarea asignada
- [ ] Primería reunión de planning hecha

---

## Troubleshooting

### "Copilot no sugiere nada"

- Verificar que está autenticado: VS Code → GitHub Copilot → Sign In
- Verificar que archivo no está en .copilotignore
- Abrí constitución + archivo de código en tabs separados

### "Merge conflicts en ADRs"

- Copilot puede causar merge conflicts si múltiples personas editan ADRs
- **Solución:** ADR uno por usuario, revisar antes de merge

### "Tests fallan en CI"

- Verificar que `.github/workflows/tests.yml` tiene versión correcta de Python
- Verificar que `requirements.txt` está actualizado

---

*Para más ayuda, consultá el README.md principal.*
