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
- Se decide unificar varios procesos en un mismo contenedor a pesar de la regla de desacoplamiento.

Formato de sugerencia:
```
⚠️ Esta decisión de orquestación merece un ADR.
Ejecutá: cp adr/template.md adr/ADR-NNN-[tema].md
Documentá: [qué opciones consideraste y por qué elegiste esta]
```

---

## 🔒 Best Practices Oficiales de Docker (Imágenes y Build)

El Asistente IA debe cumplir estrictamente estos lineamientos al momento de sugerir, generar o refactorizar archivos `Dockerfile` o `docker-compose.yml`.

### 1. Organización de Capas y Caché (Build Cache)
- Ordena las capas desde las que cambian menos frecuente (ej. instalación de dependencias) hasta las que cambian constantemente (el código fuente).
- **Gestión de paquetes (`apt-get`)**: Siempre agrupa `apt-get update` y `apt-get install` en el **mismo** bloque `RUN`. Si los separas, el caché de Docker ignorará las actualizaciones futuras.
- **Orden alfabético**: Fija un orden alfabético al instalar múltiples paquetes en múltiples líneas para facilitar la purga y lectura, y elimina el caché de `apt-get` al terminar.

```dockerfile
# ✅ CORRECTO: Update, install ordenado, y purga de caché en el mismo RUN
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
```

### 2. Multi-stage Builds Obligatorios
Nunca dejes herramientas de compilación o desarrollo en la imagen final de producción.
- Usa una etapa `builder` o `compiler`.
- Construye imágenes efímeras: el contenedor final solo debe tener lo mínimo y necesario para correr.

```dockerfile
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

### 3. Imágenes Ligeras y Digest Pinning (Integridad)
- **Prohibido `latest`**. 
- Como buena práctica, privilegia el uso de imágenes `alpine` o `slim`.
- Para extrema seguridad e inmutabilidad, recomienda anclar la base a su **Digest (SHA256)** en vez de solo la etiqueta.

```dockerfile
# ✅ EXCELENTE: Fijado a una versión, pero anclado al digest inmutable
FROM alpine:3.21@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c
```

### 4. Principio de Privilegios Mínimos (USER)
El asistente **nunca** debe sugerir correr la aplicación como usuario `root` a menos que sea estrictamente indispensable.
- En sistemas Linux, usa explícitamente `useradd` y cambia con `USER`. (Evita `sudo`).

### 5. Contenedores Desacoplados (Un proceso por contenedor)
Cada contenedor debe intentar tener **un solo foco**. No instales bases de datos y la aplicación web en el mismo contenedor. Desacóplalos en dos servicios separados por red.

### 6. Archivo .dockerignore es Mandatorio
Excluir: `.git`, `node_modules`, `venv`, `__pycache__`, `.env`, y clones locales.

---

## 🏗️ Uso correcto de Instrucciones (Dockerfile)

- **COPY vs ADD**: Usa **siempre** `COPY` para subir código o archivos locales al contenedor. `ADD` solo está permitido si necesitas descargar y extraer un `.tar.gz` o un recurso de una URL externa.
- **WORKDIR Absoluto**: Usa rutas absolutas (`WORKDIR /app`). Nunca uses un ensamble como `RUN cd /app`.
- **ENTRYPOINT vs CMD**: 
  - Usa `ENTRYPOINT` para definir el comando binario o script principal indestructible.
  - Usa `CMD` para definir los parámetros/banderas *por defecto* (los cuales el usuario puede sobreescribir al correr la imagen).
```dockerfile
ENTRYPOINT ["node", "server.js"]
CMD ["--port", "8080"]
```

---

## 🐙 Docker Compose Best Practices

Aplica reglas estrictas a las infraestructuras orquestadas localmente.

### 1. Restricciones y Cuotas (Resource Limits)
Incluir límites lógicos para que un contenedor no cause un colapso de memoria en el Host local.

### 2. Variables de Entorno Seguras
No hardcodear contraseñas en el YAML. Referenciarlas siempre desde archivos `.env` externos.

### 3. Networking Seguro  
No expongas servicios de Bases de Datos o Cachés a la máquina Host al menos que se justifique de verdad (evita mapeo `ports: "5432:5432"`). Usa redes aisladas y `expose` para tráfico interno puro.

---

## Checklist Previo a Commit (Docker)

- [ ] ¿Hay un `apt-get install`? ¿Está encadenado con el `update` y limpia el caché listado?
- [ ] ¿Es un Multi-stage build?
- [ ] ¿Se definió el `USER` no privilegiado?
- [ ] ¿Hay un archivo `.dockerignore` configurado?
- [ ] ¿Se evitó estrictamente el label `latest` en el `FROM`?
- [ ] ¿Se usa `COPY` en lugar de `ADD` para carpetas del proyecto local?
- [ ] (Si aplica) En el docker compose: ¿Las BBDD están protegidas de exposición directa (ports)?
