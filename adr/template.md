# 📋 Template — Architecture Decision Record

> Copia este archivo para crear un nuevo ADR.
>
> Archivo: `adr/ADR-NNN-titulo-corto.md`

---

## ADR-NNN: [Titulo de la Decisión]

**Estado:** Propuesta | Aceptada | Rechazada | Deprecada

**Fecha:** YYYY-MM-DD

**Autores:** (nombre del equipo) + Asistencia de Copilot: sí/no

---

## Contexto

[Describe el escenario, las presiones de negocio o técnicas que requieren tomar esta decisión]

[Qué problema estábamos enfrentando]

[Restricciones o requerimientos que influyen]

### Antecedentes

- Contexto proyecto: [breve]
- Tamaño del equipo: [N personas]
- Stack actual: [tecnologías involucradas]

---

## Problema a Resolver

[Explica claramente cuál es el problema específico que esta decisión aborda]

[Por qué importa para el proyecto]

---

## Opciones Consideradas

### Opción A: [Nombre/Descripción]

**Descripción:**
[Breve explicación de cómo funcionaría]

**Ventajas:**
- [ ] Ventaja 1
- [ ] Ventaja 2
- [ ] Ventaja 3

**Desventajas:**
- [ ] Desventaja 1
- [ ] Desventaja 2
- [ ] Desventaja 3

**Evidencia/Ejemplos:**
```
[Código, benchmark, o referencia técnica si aplica]
```

**Costo estimado:**
- Implementación: [X horas]
- Mantenimiento: [bajo/medio/alto]
- Escalabilidad: [limitaciones conocidas]

---

### Opción B: [Nombre/Descripción]

[Repetir estructura de Opción A]

---

### Opción C: [Nombre/Descripción]

[Repetir estructura de Opción A]

---

## Comparativa Resumida

| Aspecto | Opción A | Opción B | Opción C |
|---------|-----------|-----------|-----------|
| Complejidad | Baja | Media | Alta |
| Performance | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Mantenibilidad | Alta | Media | Baja |
| Escalabilidad | Media | Alta | Alta |
| Costo inicial | Bajo | Medio | Alto |

---

## Decisión

**SE ELIGE:** Opción [X] - [Nombre]

**Fecha de decisión:** YYYY-MM-DD

---

## Rationale

[Explica POR QUÉ elegiste esta opción en lugar de las otras]

[Alineamiento con principios del proyecto]

[Si Copilot participó: ¿cómo? ¿qué sugirió específicamente?]

### Justificación Técnica

[Detalles técnicos que apoyan la decisión]

### Justificación de Negocio

[Cómo alinea con objetivos del proyecto]

---

## Implicaciones

### Positivas
- [ ] Beneficio 1
- [ ] Beneficio 2
- [ ] Beneficio 3

### Negativas
- [ ] Costo/trade-off 1
- [ ] Costo/trade-off 2
- [ ] Riesgo conocido

### Riesgos
- [ ] Riesgo 1: [descripción] → Mitigación: [cómo lo evitamos]
- [ ] Riesgo 2: [descripción] → Mitigación: [cómo lo evitamos]

### Acciones Requeridas

- [ ] Tarea 1: [descripción]
- [ ] Tarea 2: [descripción]
- [ ] Documentar en constitution.md: [qué]

---

## Consecuencias Observadas

[Después de implementar: qué pasó realmente]

[Cambios inesperados]

[Feedback del equipo]

(Llenar después de 1-2 sprints)

---

## Alternativas Futuras

[Si en el futuro queremos cambiar de decisión, qué sería necesario]

[Puntos de salida si esto no funciona]

---

## Referencias

- [Link a documentación oficial o paper]
- [Link a código fuente (si aplica)]
- [Link a  ADR relacionada (si existe)]
- Inspiración: [si Copilot sugirió basado en estándares industry]

---

## Notas Adicionales

[Cualquier contexto adicional relevante]

[Decisiones que dependen de esta]

[Follow-up tasks]

---

## Historial

| Fecha | Autor | Cambio |
|-------|-------|--------|
| YYYY-MM-DD | Username | Decisión inicial |
| YYYY-MM-DD | Username | Cambio de estado a Aceptada |

---

## Checklist antes de Finalizar

- [ ] Se consultó con el equipo (si aplica)
- [ ] Se validaron los trade-offs
- [ ] Se tiene plan de acción
- [ ] Se documentó en código
- [ ] Se planificó revisión en [X] sprints

---

*Este ADR será revisado en: [fecha o sprint]* 

*Responsable de seguimiento: [nombre]*
