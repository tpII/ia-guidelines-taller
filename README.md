# 🤖 IA Guidelines — Taller de Proyectos 2

> Lineamientos, templates y flujos de trabajo para integrar IA asistida (GitHub Copilot) en el desarrollo de proyectos de software de forma **estructurada, trazable y profesional**.

> **¿Sos nuevo? Empezá por [INICIO.md](INICIO.md) — es la única hoja que necesitás leer primero.**

---

## ¿Para qué sirve este repo?

Trabajar con IA sin estructura produce código que nadie entiende, decisiones que nadie recuerda y proyectos que no escalan.

Este repositorio te da el **andamiaje** para que Copilot sea un colaborador más del equipo — uno que conoce el contexto del proyecto, respeta las convenciones y ayuda a documentar decisiones, no solo a autocompletar líneas.

Lo que vas a encontrar acá:

| Sección | Para qué |
|---|---|
| `speckit/` | Flujo de trabajo Spec-Driven: de la idea al código con IA |
| `stacks/` | Instrucciones de Copilot por tecnología (Arduino, RPi, Python, Java, React) |
| `skills/` | Archivos de contexto para tareas específicas: code review, codegen, arquitectura |
| `adr/` | Templates y ejemplos de Architecture Decision Records |
| `how-to/` | Guías de setup e integración al repo del grupo |

---

## Flujo de trabajo recomendado

Este repo adopta el enfoque **Spec-Driven Development** con IA. La idea es simple: antes de pedirle código a Copilot, le das contexto. Cuanto mejor sea el contexto, mejor es el output.

```
constitution → specify → plan → tasks → implement
```

| Paso | Qué hacés | Archivo de referencia |
|---|---|---|
| `/speckit.constitution` | Definís los principios del proyecto: stack, convenciones, restricciones | `speckit/constitution.md` |
| `/speckit.specify` | Escribís requerimientos e historias de usuario | `speckit/specify.md` |
| `/speckit.plan` | Generás el plan técnico con Copilot | `speckit/plan.md` |
| `/speckit.tasks` | Descomponés el plan en tareas accionables | `speckit/tasks.md` |
| `/speckit.implement` | Implementás con Copilot abierto y contexto cargado | `speckit/implement.md` |

> **Consejo:** No saltees pasos. Un `specify` vago produce un `plan` vago y código que hay que tirar.

---

## Primeros pasos para tu grupo

### 1. Copiá las instrucciones de Copilot para tu stack

```bash
# Ejemplo para Python
cp stacks/python/copilot-instructions.md .github/copilot-instructions.md
```

Copilot lee ese archivo automáticamente en VS Code. Es tu **constitución base** — editala con las convenciones específicas de tu proyecto.

### 2. Arrancá con la constitución del proyecto

Abrí `speckit/constitution.md` y completalo con tu equipo. Este archivo va a vivir en el repo del grupo y va a ser el contexto principal que Copilot usa.

### 3. Incorporá los ADRs desde el inicio

Cada vez que el equipo tome una decisión técnica importante (¿usamos JWT o sesiones? ¿monolito o módulos separados? ¿qué ORM?), registrala en `adr/`. No al final del proyecto: **en el momento de la decisión**.

```bash
cp adr/template.md adr/ADR-001-nombre-de-la-decision.md
```

### 4. Usá las skills como contexto adicional

Cuando vayas a hacer una tarea específica, abrí el archivo de skill correspondiente en VS Code junto con tu código. Copilot lo toma como contexto:

- Revisando un PR → abrí `skills/code-review.md`
- Generando una feature nueva → abrí `skills/codegen.md`
- Documentando una decisión → abrí `skills/architecture-decision.md`

---

## Stacks disponibles

| Stack | Archivo de instrucciones |
|---|---|
| 🔌 Arduino | `stacks/arduino/copilot-instructions.md` |
| 🍓 Raspberry Pi (Python) | `stacks/raspberry-pi/copilot-instructions.md` |
| 🐍 Python | `stacks/python/copilot-instructions.md` |
| ☕ Java | `stacks/java/copilot-instructions.md` |
| ⚛️ ReactJS | `stacks/reactjs/copilot-instructions.md` |

Si tu proyecto combina stacks (ej: Python en Raspberry Pi + React en frontend), copiá el archivo base del stack principal y agregá una sección de "Stack secundario" a mano.

---

## Estructura del repo de tu grupo

Se recomienda que el repo de cada grupo tenga al menos esta estructura mínima:

```
mi-proyecto/
├── .github/
│   └── copilot-instructions.md     ← copiado y editado desde stacks/
├── adr/
│   ├── ADR-001-eleccion-de-stack.md
│   └── ADR-002-...
├── speckit/
│   ├── constitution.md
│   ├── specify.md
│   └── plan.md
├── src/
│   └── ...
└── README.md
```

---

## Principios de uso de IA en el taller

1. **La IA no reemplaza el razonamiento — lo amplifica.** Si no entendés lo que Copilot generó, no lo commiteés.

2. **Todo output de IA es un borrador.** El equipo es responsable del código, no la herramienta.

3. **El contexto es tu responsabilidad.** Copilot es tan bueno como el contexto que le das. `speckit/constitution.md` y los ADRs son ese contexto.

4. **Documentá las decisiones que tomaste *con* IA.** Si Copilot propuso una arquitectura y la adoptaron, eso va en un ADR. La trazabilidad importa.

5. **No uses IA para entender código que deberías entender vos.** Usala para acelerar lo que ya sabés hacer.

---

## Preguntas frecuentes

**¿Puedo usar ChatGPT o Claude además de Copilot?**
Sí. Los templates de `speckit/` y `skills/` funcionan como contexto para cualquier LLM. Copilot es el flujo principal porque está integrado al editor, pero no es excluyente.

**¿Los ADRs son obligatorios?**
En el taller, sí. Son parte de la evaluación de decisiones de diseño. Se esperan al menos 3 ADRs por proyecto al momento de la entrega.

**¿Qué pasa si el stack de mi proyecto no está en `stacks/`?**
Abrí un issue en este repo o adaptá el template de `stacks/python/copilot-instructions.md` como base genérica.

**¿Copilot ve mis archivos automáticamente?**
Copilot indexa los archivos abiertos en tu editor y el archivo `.github/copilot-instructions.md`. Para las skills, tenés que abrir el archivo en un tab de VS Code antes de pedirle ayuda.

---

## Contribuciones

Este repo es mantenido por la cátedra. Si encontrás algo desactualizado, un ejemplo que no funciona o querés proponer un nuevo stack o skill, abrí un issue o un PR.

---

*Taller de Proyectos 2 — Ingeniería en Computación — Facultad de Informática - Facultad de Ingeniería - Universidad Nacional de La Plata*
