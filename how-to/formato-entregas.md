# ✅ How-To — Chequear el formato de una entrega con Claude

> Antes de mandar el plan de proyecto, un informe de avance o la entrega final, pasá el PDF
> por la skill `formato-entregas`. Aplica los **mismos criterios de forma** con los que
> corrige la cátedra y te devuelve una lista de qué arreglar, con página y con la instrucción
> para Google Docs, Word, LaTeX o Typst.

La skill revisa **forma**, no contenido: estructura (carátula, índices, bibliografía),
lenguaje (sin primera persona ni voseo, registro técnico), títulos contra el índice,
epígrafes de figuras y tablas, y tipografía (Arial, Times New Roman o Libertinus 12 pt,
interlineado 1,5, justificado). Que el chequeo dé limpio no dice nada sobre la calidad técnica
del proyecto.

---

## Paso 0: Requisitos (una vez por máquina)

| Qué | Para qué | Cómo |
|---|---|---|
| **Claude Code** | El asistente que ejecuta la skill | [claude.com/claude-code](https://claude.com/claude-code) — terminal, VS Code o app de escritorio |
| **Python 3.9+** | Corre el script de medición (sin paquetes extra) | `python3 --version` |
| **poppler** | Lee el PDF (`pdftohtml`, `pdftotext`, `pdfinfo`) | macOS: `brew install poppler` · Debian/Ubuntu: `sudo apt install poppler-utils` · Windows: `winget install oschwartz10612.Poppler` y agregar su carpeta `bin` al PATH |

Verificá poppler con:

```bash
pdfinfo -v
```

Si responde con una versión, está listo.

> ¿No tenés Claude? Podés usar solo el script (ver [Paso 3 · Sin asistente](#sin-asistente-solo-el-script)).

---

## Paso 1: Importar la skill

Hay dos lugares posibles. **Recomendado: dentro del repo del grupo**, así la tienen todos los
integrantes y queda versionada.

### Opción A — En el repo del grupo (recomendado)

Desde la raíz del repo del grupo:

**Linux, macOS o Git Bash:**

```bash
mkdir -p .claude/skills && curl -sL https://github.com/tpII/ia-guidelines-taller/archive/refs/heads/main.tar.gz | tar -xz --strip-components=2 -C .claude/skills ia-guidelines-taller-main/skills/formato-entregas
```

**Windows (PowerShell):**

```powershell
New-Item -ItemType Directory -Force .claude\skills | Out-Null
curl.exe -sL -o fe.tar.gz https://github.com/tpII/ia-guidelines-taller/archive/refs/heads/main.tar.gz
tar -xzf fe.tar.gz --strip-components=2 -C .claude/skills ia-guidelines-taller-main/skills/formato-entregas
Remove-Item fe.tar.gz
```

Si ya tenés clonado `ia-guidelines-taller`, alcanza con copiar la carpeta:

```bash
mkdir -p .claude/skills && cp -r ../ia-guidelines-taller/skills/formato-entregas .claude/skills/
```

Después commiteala para que le llegue al resto del grupo:

```bash
git add .claude/skills/formato-entregas && git commit -m "chore: agregar skill formato-entregas"
```

### Opción B — Para todos tus proyectos

Mismo comando, pero apuntando a tu carpeta personal: reemplazá `.claude/skills` por
`~/.claude/skills` (en Windows, `$HOME\.claude\skills`).

### Cómo queda

```
.claude/skills/formato-entregas/
├── SKILL.md                 instrucciones para Claude
├── README.md
├── references/rubrica.md    la rúbrica completa (leela aunque no uses IA)
└── scripts/analizar_pdf.py  la medición mecánica
```

### Verificar que Claude la ve

Abrí Claude Code en la carpeta del repo y preguntá:

```
¿Qué skills tenés disponibles?
```

Tiene que aparecer `formato-entregas`. Si no aparece, revisá que la ruta sea exactamente
`.claude/skills/formato-entregas/SKILL.md` y reiniciá Claude Code.

### Actualizarla

La cátedra ajusta la rúbrica durante la cursada. Antes de cada entrega, volvé a correr el
comando de instalación: pisa la carpeta con la versión vigente.

---

## Paso 2: Usarla

1. Exportá el documento a **PDF** (la skill mide el PDF, no el `.docx` ni el Google Doc).
2. Guardalo dentro del repo, por ejemplo `docs/informe_avance_1.pdf`.
3. En Claude Code, pedí el chequeo en lenguaje natural:

```
Chequeá el formato de docs/informe_avance_1.pdf
```

También funcionan variantes como *"revisá si este informe pasa el formato"* o *"fijate si
docs/plan.pdf está bien antes de entregarlo"*. Si Claude no activa la skill por su cuenta,
nombrala: *"Usá la skill formato-entregas sobre docs/plan.pdf"*.

Qué hace Claude, en orden:

1. **Corre el script** `analizar_pdf.py`: mide fuente, tamaño, interlineado, justificado,
   índice contra títulos, epígrafes y candidatos de primera persona.
2. **Lee el PDF completo** para lo que requiere criterio: registro de cada sección,
   carátula, bibliografía, figuras legibles, siglas y anglicismos.
3. **Escribe el informe** `informe_avance_1_chequeo.md` al lado del PDF.

Tarda unos minutos según el largo del documento. Te puede pedir permiso para ejecutar
`python3` y `pdftotext`: aceptalo.

**Recomendaciones:**

- Corrélo con tiempo, no la noche de la entrega: algunos arreglos (índice de figuras,
  epígrafes, pasar a interlineado 1,5) mueven todo el paginado.
- Después de corregir, **volvé a exportar y a chequear**. Es normal que la segunda pasada
  encuentre algo que la primera tapaba (por ejemplo, el índice desactualizado después de
  cambiar el interlineado).
- No subas el `_chequeo.md` como parte de la entrega: es para el grupo. Podés agregarlo
  al `.gitignore` con `*_chequeo.md`.

---

## Paso 3: Leer los resultados

### El informe de chequeo (`*_chequeo.md`)

Abrilo en VS Code con la vista previa de Markdown (`Ctrl+Shift+V` / `Cmd+Shift+V`). Tiene
estas secciones, y conviene leerlas en este orden:

| Sección | Qué te dice | Qué hacer |
|---|---|---|
| **Estado** (arriba) | `listo para entregar` o `con N puntos a corregir` | Si está listo, igual mirá "Para que lo mire alguien del grupo" |
| **Resumen** | Qué está en regla y qué falta, agrupado | Leerlo para dimensionar el trabajo |
| **Puntos a corregir** | Lista numerada: qué está mal, dónde (página + cita), qué se espera y **cómo arreglarlo en tu herramienta** | Repartir entre el grupo y resolver en orden: primero lo estructural, al final lo tipográfico |
| **Para que lo mire alguien del grupo** | Lo que la skill no puede decidir sola | Una persona lo revisa y decide |
| **Lo que está bien y hay que conservar** | Lo que no hay que tocar | No romperlo al corregir lo demás |
| **Detalle por criterio** | Tabla con ✅/❌/❓/ℹ️ por cada criterio de la rúbrica | Checklist final antes de entregar |

Las páginas citadas son **las impresas** en el documento (las del pie de página), salvo que
el informe diga otra cosa.

### Los símbolos

| Símbolo | Significa | ¿Hay que hacer algo? |
|---|---|---|
| ✅ | Cumple | No |
| ❌ | Incumple un criterio verificable | **Sí, corregir antes de entregar** |
| ❓ | La herramienta no puede decidir sola | Sí, que alguien del grupo lo mire |
| ℹ️ | Informativo, no se penaliza | No (anexo ausente, tablas en letra más chica, etc.) |

### Ejemplo de salida del script

Si le pedís a Claude que te muestre la salida cruda, o si corrés el script solo, vas a ver
algo así (fragmento de un plan de proyecto real, anonimizado):

```markdown
Generado con: Google Docs · Páginas: 10. Texto de cuerpo detectado: Times New Roman 11.0 pt

## 1. Tipografía y párrafo
- ✅ Fuente del cuerpo permitida: Times New Roman
- ❌ Tamaño del cuerpo 12 pt: 11.0 pt
- ❌ Interlineado 1,5: salto entre líneas 14.7 pt = 1.33× el tamaño → simple
  - Páginas cuyo interlineado predominante no es 1,5: [2, 5, 9]
- ✅ Texto justificado: 100% de las líneas largas terminan en el margen derecho

## 2. Estructura
- ✅ Carátula: TALLER DE PROYECTO 2 | … | Plan de Proyecto | G? — …
- ❌ Índice general: 0 entradas detectadas
- ❌ Índice de figuras
- ❌ Bibliografía / Referencias
- ℹ️ Anexo (opcional)

## 3. Figuras y tablas
- Tablas detectadas: 2; ❌ 2 sin epígrafe «Tabla N» cerca: p.3, p.6
- p.5 «Figura 1. Esquema …» → ✅ debajo de una imagen; ❌ el texto nunca la referencia por número
- ❌ Figura 1 (p.5) no figura en el índice de figuras

## 4. Lenguaje — 0 candidatos
```

Cómo se lee:

- **"Generado con: Google Docs"**: por eso las instrucciones de arreglo van a ser de Docs.
- **Tamaño 11 pt → ❌**: el cuerpo tiene que ser 12 pt. En Docs: Estilos → Texto normal →
  12 → "Actualizar para que coincida".
- **Interlineado 1,33× → simple**: es el "1,15" por defecto de Google Docs, que **no** es 1,5
  aunque se vea espaciado. Formato → Interlineado → 1,5.
- **0 entradas en el índice**: no hay índice general (o no se pudo leer). Insertar → Índice,
  con los títulos en estilos Título 1 / Título 2.
- **Tablas sin epígrafe**: el script detecta tablas por geometría, así que si una de esas
  "tablas" es en realidad una lista en columnas, puede ser un falso positivo; Claude lo
  revisa leyendo la página.
- **"el texto nunca la referencia"**: falta una frase del estilo *"como muestra la Figura 1"*.
- **0 candidatos de lenguaje**: el script no encontró primera persona obvia, pero Claude igual
  lee todo el texto buscando coloquialismos y registro inadecuado, que el script no ve.

### Qué es confiable y qué es pista

- **Confiable**: fuente, tamaño, interlineado (con el valor medido), justificado, presencia o
  ausencia de índices y bibliografía. Si dice ❌, está mal.
- **Pista**: todo lo marcado con ❓ o llamado "candidato". Los verbos en `-amos/-emos/-imos`
  dan falsos positivos (*"los extremos"*), y las tablas se detectan por forma. Claude los
  descarta o confirma leyendo el PDF; si queda duda, va a "Para que lo mire alguien del grupo".

---

## Sin asistente: solo el script

El script funciona solo, sin Claude:

```bash
python3 .claude/skills/formato-entregas/scripts/analizar_pdf.py docs/informe_avance_1.pdf
```

Imprime el informe mecánico de arriba. Cubre lo medible; lo que requiere lectura (registro
por sección, bibliografía bien formada, siglas, anglicismos, figuras legibles) lo tienen que
revisar ustedes con [`references/rubrica.md`](../skills/formato-entregas/references/rubrica.md)
a mano. La sección 6 de la rúbrica tiene la tabla de *cómo se corrige cada cosa* en Google
Docs, Word, LaTeX y Typst.

**Con GitHub Copilot**: Copilot no ejecuta skills, pero toma contexto. Abrí la rúbrica en una
pestaña, corré el script, pegá la salida en el chat y preguntá *"con la rúbrica abierta y esta
salida, ¿qué tengo que corregir en el PDF?"*.

---

## Problemas comunes

| Síntoma | Causa probable | Solución |
|---|---|---|
| `pdftohtml: command not found` | poppler no está instalado o no está en el PATH | Ver Paso 0; en Windows, reabrir la terminal después de agregar `bin` al PATH |
| Claude no usa la skill | No está en la ruta correcta o Claude Code se abrió en otra carpeta | Verificar `.claude/skills/formato-entregas/SKILL.md` y abrir Claude Code en la raíz del repo |
| "0 entradas" en el índice y el índice existe | Índice como imagen, o PDF exportado como imagen/escaneado | Exportar desde la herramienta (Archivo → Descargar → PDF), no "Imprimir a PDF" de una captura |
| Interlineado ❌ pero "puse 1,5" | Estilo aplicado solo a parte del texto, o el 1,5 de LaTeX mal configurado | Mirar las páginas que lista el script; en LaTeX usar `\onehalfspacing`, no `\linespread{1.15}` |
| Muchas páginas "sin justificar" | Listas, tablas o código (que legítimamente no se justifican) | Revisar las páginas listadas; si son párrafos normales, justificarlos |

---

## Checklist antes de entregar

- [ ] Instalé o actualicé la skill con el comando del Paso 1
- [ ] Exporté el PDF final (no un borrador)
- [ ] Corrí el chequeo y resolví todos los ❌
- [ ] Alguien del grupo revisó los ❓ y "Para que lo mire alguien del grupo"
- [ ] Volví a exportar y a chequear después de corregir
- [ ] El `_chequeo.md` no va en la entrega
