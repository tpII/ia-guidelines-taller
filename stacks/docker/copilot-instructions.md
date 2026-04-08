# 🐳 Docker & Contenedores — Instrucciones de Copilot

> Copia este archivo a `.github/copilot-instructions.md` en tu proyecto basado en contenedores (o añadilo a tus instrucciones globales).

---

## Workflow: Spec-Driven Development

Este proyecto usa un flujo de trabajo Spec-Driven. Antes de generar configuraciones de Docker, seguí estas reglas:

### Archivos de contexto (leer siempre)
- `speckit/constitution.md` — convenciones y restricciones del proyecto. **Tienen prioridad sobre este archivo.**
- `speckit/plan.md` — arquitectura técnica. Usalo para entender la topología de la red y los servicios requeridos.

### Cuándo sugerir un ADR
Sugerí crear un ADR (Architecture Decision Record) cuando:
- Se decide cambiar la estrategia de orquestación (ej. pasar de Docker Compose a Kubernetes o Swarm).
- Se adopta una nueva técnica de gestión de secretos (enviroment vs vault docker secrets).
- Se decide unificar varios procesos en un mismo contenedor (anti-patrón justificable).

Formato de sugerencia:
```
⚠️ Esta decisión de orquestación merece un ADR.
Ejecutá: cp adr/template.md adr/ADR-NNN-[tema].md
Documentá: [qué opciones consideraste y por qué elegiste esta]
```

---

## 🔒 Best Practices Oficiales de Docker

El Asistente IA debe cumplir estrictamente estos lineamientos al momento de sugerir, generar o refactorizar archivos `Dockerfile` o `docker-compose.yml`.

### 1. Multi-stage Builds Obligatorios
Nunca dejes herramientas de compilación o desarrollo en la imagen final de producción.
- Usa una etapa `builder` o `compiler` para descargar dependencias y compilar.
- Copia únicamente los binarios o artefactos finales y sus librerías de runtime a la imagen final.

```dockerfile
# ❌ INCORRECTO: Todo en una misma capa (pesado e inseguro)
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]

# ✅ CORRECTO: Multi-stage build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm ci --only=production
CMD ["node", "dist/main.js"]
```

### 2. Principio de Privilegios Mínimos (Non-Root User)
El asistente **nunca** debe sugerir correr la aplicación como usuario `root` a menos que sea estrictamente indispensable.
Siempre crear y exponer un usuario dedicado de menores privilegios antes de ejecutar el comando CMD o ENTRYPOINT.

```dockerfile
# ✅ CORRECTO: Usuario no root
FROM python:3.11-slim
RUN useradd --create-home --shell /bin/bash appuser
WORKDIR /home/appuser
COPY . .
RUN chown -R appuser:appuser /home/appuser
USER appuser
CMD ["python", "app.py"]
```

### 3. Imágenes Ligeras y Específicas
- No uses `latest`. Pinea (fija) siempre la versión específica (ej. `node:18.17.0` o `python:3.11.4`).
- Privilegia el uso de imágenes `alpine` (basadas en Alpine Linux) o `slim` para reducir drásticamente la superficie de ataque y el peso final.

### 4. Cache y Orden de las Capas (Layers)
El código fuente cambia más seguido que las dependencias. Ordená los comandos para maximizar el cacheo del propio daemon de Docker.
1. `WORKDIR` y Variables de entorno.
2. Copiar archivos de dependencias (`package.json`, `requirements.txt`).
3. Instalar dependencias (`npm install`, `pip install`).
4. Copiar el resto del código (`COPY . .`).

### 5. .dockerignore es Mandatorio
Todo proyecto debe generar un archivo `.dockerignore`, excluyendo:
- `.git`
- Carpetas de dependencias como `node_modules`, `venv`, `__pycache__`
- Tokens y Secrets: `.env`, claves privadas `*.pem`.

---

## 🐙 Docker Compose Best Practices

Aplica reglas estrictas a las infraestructuras orquestadas localmente.

### 1. Restricciones y Cuotas (Resource Limits)
Incluir límites lógicos para que un contenedor que falle o pierda recursos (memory leak) no voltee al host.
```yaml
services:
  api:
    image: my-api:1.0.0
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
```

### 2. Variables de Entorno Seguras
No hardcodear contraseñas en el YAML. Referenciarlas siempre desde archivos `.env` externos.
```yaml
# ❌ INCORRECTO
environment:
  - DB_PASSWORD=supersecret_dev123

# ✅ CORRECTO
environment:
  - DB_PASSWORD=${DB_PASSWORD}
```

### 3. Networking Seguro  
No expongas servicios de Bases de Datos o Cachés a la máquina Host al menos que se justifique (usando `ports`). Deja únicamente comunicación interna a través de `networks`.
```yaml
services:
  db:
    image: postgres:15
    # En vez de "ports", usamos expose para que solo sea visible dentro de docker
    expose:
      - "5432"
    networks:
      - private_backend_net
```

---

## Checklist Previo a Commit (Docker)

- [ ] ¿El Dockerfile corre sin usuario `root`?
- [ ] ¿Se está usando un multi-stage build para aligerar la imagen de producción?
- [ ] ¿Hay un archivo `.dockerignore` configurado y protegiendo `.env` y `.git`?
- [ ] ¿Se fijó la versión (tag) base de la imagen o se usó `latest`? (PROHIBIDO `latest`)
- [ ] (Si aplica) En el docker-compose, ¿las bases de datos están aisladas de interaces públicas?
