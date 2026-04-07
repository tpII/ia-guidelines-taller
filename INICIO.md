# Por dónde empezar

Sos nuevo en el taller, tenés un grupo de trabajo y no sabés por dónde arrancar. Esta es la única hoja que necesitás leer primero.

---

## Antes de hacer cualquier cosa (individual)

Necesitás tener esto instalado:

- [ ] [VS Code](https://code.visualstudio.com/)
- [ ] Extensión **GitHub Copilot** (buscarla en el marketplace de VS Code)
- [ ] Cuenta de GitHub con Copilot habilitado — la cátedra te tiene que confirmar el acceso
- [ ] Git instalado y configurado con tu usuario

Para verificar que Copilot funciona: abrí cualquier archivo `.py` en VS Code, escribí un comentario descriptivo y presioná `Tab`. Si aparece una sugerencia en gris, está funcionando.

---

## Sesión de kickoff del grupo (hacerla juntos, 1-2 horas)

### 1. Crear el repo del grupo

Una persona del grupo crea el repo en GitHub y agrega a los demás como collaborators.

```bash
# Cada integrante clona el repo del grupo
git clone https://github.com/[usuario]/[nombre-proyecto]
cd [nombre-proyecto]
```

### 2. Clonar este repo de guidelines (cada uno, una vez)

```bash
# En una carpeta separada (NO dentro del repo del grupo)
git clone https://github.com/[catedra]/ia-guidelines-taller
```

### 3. Copiar los archivos al repo del grupo

Desde dentro del repo del grupo, ejecutar:

```bash
# Estructura de especificación
mkdir -p speckit adr .github

cp ../ia-guidelines-taller/speckit/constitution.md speckit/
cp ../ia-guidelines-taller/speckit/specify.md speckit/
cp ../ia-guidelines-taller/speckit/plan.md speckit/
cp ../ia-guidelines-taller/speckit/tasks.md speckit/
cp ../ia-guidelines-taller/speckit/implement.md speckit/
cp ../ia-guidelines-taller/adr/template.md adr/
```

Ahora elegí el stack de tu proyecto y copiá las instrucciones de Copilot:

| Mi proyecto usa... | Comando |
|---|---|
| Python + FastAPI (backend) | `cp ../ia-guidelines-taller/stacks/python/copilot-instructions.md .github/` |
| Arduino + sensores | `cp ../ia-guidelines-taller/stacks/arduino/copilot-instructions.md .github/` |
| Raspberry Pi | `cp ../ia-guidelines-taller/stacks/raspberry-pi/copilot-instructions.md .github/` |
| React (frontend) | `cp ../ia-guidelines-taller/stacks/reactjs/copilot-instructions.md .github/` |
| Java | `cp ../ia-guidelines-taller/stacks/java/copilot-instructions.md .github/` |

> Si tu proyecto combina stacks (ej: Arduino + Python + React), copiá el del stack principal y después agregás secciones de los otros a mano.

### 4. Completar la constitución del proyecto

Abrí `speckit/constitution.md` **en grupo** y editenlo:

- [ ] Definir el stack real del proyecto (borrar lo que no usen)
- [ ] Acordar convenciones de código específicas del equipo
- [ ] Copiar el archivo a `.github/copilot-instructions.md` o asegurarse que el de stacks/ ya esté ahí

> Este archivo es lo que Copilot va a leer como contexto base. Si está vacío o genérico, las sugerencias van a ser genéricas.

### 5. Hacer el primer commit

```bash
git add speckit/ adr/ .github/
git commit -m "init: agregar specification kit y configuración de Copilot"
git push origin main
```

---

## La primera semana de trabajo

El flujo de trabajo es este, en orden:

```
constitution → specify → plan → tasks → implement
```

No lo hagas al revés. Si salteas `specify` y vas directo a `implement`, Copilot va a generar algo que quizás no es lo que necesitás y van a tener que tirarlo.

| Qué hacer | Tiempo estimado | Resultado |
|---|---|---|
| Completar `speckit/specify.md` con los requerimientos reales del proyecto | 2-3 horas (en grupo) | Saben exactamente qué construir |
| Completar `speckit/plan.md` con la arquitectura técnica | 2-4 horas (con Copilot) | Tienen la estructura de carpetas y los componentes definidos |
| Crear el primer ADR para la decisión de stack | 30 min | Primera decisión documentada |
| Completar `speckit/tasks.md` dividiendo el plan en tareas | 1-2 horas | Cada uno sabe qué hacer esta semana |

---

## Cómo usar Copilot día a día

Cuando vayas a trabajar en una tarea:

1. Abrí `speckit/constitution.md` en un tab de VS Code (no lo cerrés)
2. Abrí `speckit/tasks.md` posicionado en tu tarea actual
3. Abrí el archivo de código donde vas a trabajar
4. Copilot va a usar los dos primeros como contexto automáticamente

Para tareas específicas, abrí también:
- Generando código nuevo → `skills/codegen.md`
- Revisando un PR → `skills/code-review.md`
- Documentando una decisión → `skills/architecture-decision.md`

---

## Cuándo crear un ADR

Cada vez que el grupo tome una decisión técnica importante — no estética, sino estructural:

- ¿Usamos JWT o sesiones?
- ¿Monolito o servicios separados?
- ¿SQLite o PostgreSQL?
- ¿MQTT o HTTP polling?

```bash
cp adr/template.md adr/ADR-001-[tema-corto].md
# Ejemplo: adr/ADR-001-protocolo-comunicacion.md
```

La cátedra pide **mínimo 3 ADRs** por proyecto. Cuanto más temprano los creés, más fácil. No los dejés para el final.

---

## Estructura mínima esperada del repo del grupo

Al finalizar el proyecto, el repo debería tener al menos esto:

```
mi-proyecto/
├── .github/
│   └── copilot-instructions.md
├── adr/
│   ├── ADR-001-[decision].md
│   ├── ADR-002-[decision].md
│   └── ADR-003-[decision].md
├── speckit/
│   ├── constitution.md     ← editado con el proyecto real
│   ├── specify.md          ← requerimientos reales
│   ├── plan.md             ← arquitectura acordada
│   └── tasks.md            ← tareas completadas
├── src/
│   └── ...
└── README.md
```

---

## Preguntas frecuentes del arranque

**¿Cada uno clona el repo de guidelines?**
Sí, individualmente. Pero el repo del grupo es uno solo compartido.

**¿Tengo que leer todo el repo de guidelines?**
No en el arranque. Con este archivo y `how-to/setup.md` alcanza para empezar. El resto lo consultás cuando lo necesitás.

**¿El repo de guidelines va dentro del repo del grupo?**
No. Son dos repos separados en carpetas distintas. El de guidelines es solo para copiar archivos al inicio.

**¿Qué pasa si mi stack no está en `stacks/`?**
Usá `stacks/python/copilot-instructions.md` como base y adaptalo. O abrí un issue en el repo de guidelines.

**¿Puedo usar Claude o ChatGPT además de Copilot?**
Sí. Los archivos de `speckit/` y `skills/` funcionan como contexto para cualquier LLM. Copiá el contenido del archivo relevante al inicio del chat.

---

*Para más detalle sobre cada paso: [how-to/setup.md](how-to/setup.md)*
*Para entender el flujo completo: [README.md](README.md)*
