# ⚛️ ReactJS — Instrucciones de Copilot

> Copia este archivo a `.github/copilot-instructions.md` en tu proyecto React.

---

## Stack: React 18 + TypeScript + Vite

### Versiones
- React: 18.2+
- Node.js: 18 LTS+ o 20 LTS+
- Vite: 5.0+
- TypeScript: 5.3+
- Tailwind CSS: 3.3+

---

## Convenciones de Código React

### Nombrado
```javascript
// Архivos de componentes: PascalCase + .jsx
// ✅ SensorCard.jsx
// ❌ sensorCard.jsx, sensor-card.jsx

// Hooks personalizados: camelCase + "use" prefix
// ✅ useSensorData.js
// ❌ sensorDataHook.js

// Utilidades: camelCase
// ✅ formatTemperature.js
// ❌ FormatTemperature.js

// Constantes: UPPER_SNAKE_CASE
// ✅ DEFAULT_TIMEOUT = 5000
// ❌ defaultTimeout = 5000

// CSS files: kebab-case
// ✅ sensor-card.css
// ❌ SensorCard.css

// Variables/funciones: camelCase
function handleSensorClick() { }
const sensorData = { }
```

### Formato
```javascript
// Line length: 100 caracteres
// Indentación: 2 espacios
// Semicolons: sí (siempre)
// Comillas: "double" en JSX, backticks si interpolación
```

### Estructura de Proyecto
```
frontend/
├── src/
│   ├── main.jsx                        # Entry point
│   ├── App.jsx                         # Root component
│   │
│   ├── components/
│   │   ├── common/                     # Componentes reutilizables
│   │   │   ├── Button.jsx
│   │   │   ├── Card.jsx
│   │   │   └── Modal.jsx
│   │   │
│   │   ├── forms/
│   │   │   ├── AlertForm.jsx
│   │   │   └── FilterForm.jsx
│   │   │
│   │   ├── dashboard/
│   │   │   ├── Dashboard.jsx
│   │   │   ├── SensorCard.jsx
│   │   │   └── Chart.jsx
│   │   │
│   │   └── layout/
│   │       ├── Header.jsx
│   │       └── Sidebar.jsx
│   │
│   ├── pages/
│   │   ├── HomePage.jsx
│   │   ├── SettingsPage.jsx
│   │   └── HistoryPage.jsx
│   │
│   ├── hooks/
│   │   ├── useSensorData.js
│   │   ├── useAlerts.js
│   │   └── useFetch.js
│   │
│   ├── services/
│   │   ├── api.js                      # Axios client
│   │   └── websocket.js
│   │
│   ├── store/
│   │   ├── sensorStore.js              # Zustand or Redux
│   │   └── appStore.js
│   │
│   ├── styles/
│   │   ├── global.css
│   │   ├── tailwind.css
│   │   └── sensors/
│   │       └── sensor-card.css
│   │
│   ├── utils/
│   │   ├── formatters.js
│   │   ├── validators.js
│   │   └── constants.js
│   │
│   └── types/
│       └── index.d.ts                  # TypeScript types
│
├── tests/
│   ├── components/
│   │   └── SensorCard.test.jsx
│   ├── hooks/
│   │   └── useSensorData.test.js
│   └── integration/
│
├── .env.example
├── .env
├── vite.config.js
├── tailwind.config.js
├── package.json
└── README.md
```

---

## Setup y Dependencias

```bash
# Create with Vite
npm create vite@latest my-react-app -- --template react

# Instalar dependencias
npm install react react-dom
npm install -D vite @vitejs/plugin-react
npm install -D tailwindcss postcss autoprefixer
npm install -D typescript @types/react @types/node

# HTTP client
npm install axios

# State management
npm install zustand
# O si usar React Query:
npm install @tanstack/react-query @tanstack/react-query-devtools

# Gráficos
npm install recharts

# Notificaciones
npm install react-toastify

# Testing
npm install -D vitest @vitest/ui
npm install -D @testing-library/react @testing-library/jest-dom
npm install -D jsdom

# Linting
npm install -D eslint eslint-plugin-react
npm install -D prettier prettier-plugin-tailwindcss
```

---

## Patrones React

### 1. Componente Funcional con Hooks

```javascript
// components/dashboard/SensorCard.jsx
import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import "./sensor-card.css";

export const SensorCard = ({ sensor, onSelect }) => {
  const [isOnline, setIsOnline] = useState(false);

  useEffect(() => {
    // Verificar si el sensor está online
    const isActive = sensor.lastReadingTime > Date.now() - 60000;
    setIsOnline(isActive);
  }, [sensor.lastReadingTime]);

  const handleClick = () => {
    if (onSelect) {
      onSelect(sensor.id);
    }
  };

  return (
    <div
      className="border border-gray-300 rounded-lg p-4 hover:shadow-lg cursor-pointer"
      onClick={handleClick}
    >
      <div className="flex justify-between items-start mb-4">
        <h3 className="text-lg font-semibold">{sensor.name}</h3>
        <span
          className={`px-2 py-1 rounded text-sm ${
            isOnline
              ? "bg-green-100 text-green-800"
              : "bg-gray-100 text-gray-800"
          }`}
        >
          {isOnline ? "🟢 Online" : "⚪ Offline"}
        </span>
      </div>

      <div className="text-3xl font-bold text-blue-600 mb-2">
        {sensor.currentValue}°C
      </div>

      <p className="text-gray-500 text-sm">
        Última lectura: {new Date(sensor.lastReadingTime).toLocaleTimeString()}
      </p>
    </div>
  );
};

SensorCard.propTypes = {
  sensor: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    currentValue: PropTypes.number.isRequired,
    lastReadingTime: PropTypes.number.isRequired,
  }).isRequired,
  onSelect: PropTypes.func,
};

SensorCard.defaultProps = {
  onSelect: null,
};
```

### 2. Custom Hook para WebSocket

```javascript
// hooks/useSensorData.js
import { useState, useEffect, useCallback } from "react";

export const useSensorData = (sensorId) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setLoading(true);

    const ws = new WebSocket("wss://api.example.com/ws/live");

    ws.onopen = () => {
      console.log("[useSensorData] WebSocket conectado");
    };

    ws.onmessage = (event) => {
      try {
        const message = JSON.parse(event.data);

        if (message.sensor_id === sensorId) {
          setData(message);
          setLoading(false);
          setError(null);
        }
      } catch (err) {
        console.error("[useSensorData] Error parseando mensaje:", err);
        setError(err.message);
      }
    };

    ws.onerror = (err) => {
      console.error("[useSensorData] WebSocket error:", err);
      setError("WebSocket error");
    };

    ws.onclose = () => {
      console.log("[useSensorData] WebSocket cerrado");
    };

    // Cleanup
    return () => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.close();
      }
    };
  }, [sensorId]);

  return { data, loading, error };
};
```

### 3. API Client (Axios)

```javascript
// services/api.js
import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:8000/api";

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// Agregar token JWT si existe
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem("authToken");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Manejo de errores
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error("[API Error]", error.response?.status, error.message);
    if (error.response?.status === 401) {
      // Redirigir a login
      window.location.href = "/login";
    }
    return Promise.reject(error);
  }
);

export const readingApi = {
  getReadings: (sensorId, limit = 100) =>
    apiClient.get("/readings", { params: { sensor_id: sensorId, limit } }),

  getReadingsInRange: (sensorId, fromTs, toTs) =>
    apiClient.get("/readings/range", {
      params: { sensor_id: sensorId, from: fromTs, to: toTs },
    }),

  createReading: (data) => apiClient.post("/readings", data),
};

export const sensorApi = {
  getAll: () => apiClient.get("/sensors"),

  getById: (id) => apiClient.get(`/sensors/${id}`),

  update: (id, data) => apiClient.patch(`/sensors/${id}`, data),
};

export default apiClient;
```

### 4. Componente con React Query

```javascript
// components/dashboard/Dashboard.jsx
import React from "react";
import { useQuery } from "@tanstack/react-query";
import { sensorApi } from "../../services/api";
import { SensorCard } from "./SensorCard";

const REFETCH_INTERVAL = 10000; // 10 segundos

export const Dashboard = () => {
  const {
    data: sensors,
    isPending,
    isError,
    error,
  } = useQuery({
    queryKey: ["sensors"],
    queryFn: async () => {
      const response = await sensorApi.getAll();
      return response.data;
    },
    refetchInterval: REFETCH_INTERVAL,
  });

  if (isPending) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-blue-500" />
      </div>
    );
  }

  if (isError) {
    return (
      <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
        Error cargando sensores: {error?.message}
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">Sensores</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {sensors?.map((sensor) => (
          <SensorCard key={sensor.id} sensor={sensor} onSelect={() => {}} />
        ))}
      </div>
    </div>
  );
};
```

### 5. Formulario con Validación

```javascript
// components/forms/AlertForm.jsx
import React, { useState } from "react";
import PropTypes from "prop-types";

export const AlertForm = ({ onSubmit, initialData = null }) => {
  const [formData, setFormData] = useState(
    initialData || {
      sensorId: "",
      threshold: 30,
      condition: "greater_than",
    }
  );
  const [errors, setErrors] = useState({});

  const validate = () => {
    const newErrors = {};

    if (!formData.sensorId) {
      newErrors.sensorId = "Sensor es requerido";
    }

    if (!formData.threshold || formData.threshold < -50 || formData.threshold > 150) {
      newErrors.threshold = "Threshold debe estar entre -50 y 150";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === "threshold" ? parseFloat(value) : value,
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (validate()) {
      onSubmit(formData);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow">
      <div className="mb-4">
        <label className="block text-gray-700 font-bold mb-2">Sensor:</label>
        <select
          name="sensorId"
          value={formData.sensorId}
          onChange={handleChange}
          className={`w-full px-3 py-2 border rounded ${
            errors.sensorId ? "border-red-500" : "border-gray-300"
          }`}
        >
          <option value="">Seleccionar sensor</option>
          <option value="1">Sensor 1</option>
          <option value="2">Sensor 2</option>
        </select>
        {errors.sensorId && (
          <p className="text-red-500 text-sm mt-1">{errors.sensorId}</p>
        )}
      </div>

      <div className="mb-4">
        <label className="block text-gray-700 font-bold mb-2">
          Threshold (°C):
        </label>
        <input
          type="number"
          name="threshold"
          value={formData.threshold}
          onChange={handleChange}
          className={`w-full px-3 py-2 border rounded ${
            errors.threshold ? "border-red-500" : "border-gray-300"
          }`}
        />
        {errors.threshold && (
          <p className="text-red-500 text-sm mt-1">{errors.threshold}</p>
        )}
      </div>

      <button
        type="submit"
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
      >
        Guardar Alerta
      </button>
    </form>
  );
};

AlertForm.propTypes = {
  onSubmit: PropTypes.func.isRequired,
  initialData: PropTypes.object,
};
```

---

## Documentación de Código

Utilizar **JSDoc (o TSDoc)** obligatorio en Componentes Compartidos, Custom Hooks y Utilidades.

### Componentes (Explicación de Props)
```javascript
/**
 * Componente que renderiza la tarjeta principal de métricas del sensor.
 * 
 * @component
 * @param {Object} props
 * @param {Object} props.sensor - Objeto con los detalles del sensor actual.
 * @param {number} props.sensor.id - El ID único del sensor.
 * @param {Function} [props.onSelect] - Callback opcional ejecutado al clickear.
 * @returns {JSX.Element} La tarjeta renderizada lista para DOM.
 */
export const SensorCard = ({ sensor, onSelect }) => { ... }
```

### Custom Hooks
```javascript
/**
 * Hook para suscribirse a cambios en vivo de un sensor vía WebSocket.
 * 
 * @param {number} sensorId - El ID del sensor al que queremos engancharnos.
 * @returns {{ data: Object|null, loading: boolean, error: string|null }} 
 *          Contiene la carga reactiva junto a su layout state.
 */
export const useSensorData = (sensorId) => { ... }
```

---

## Testing con Vitest (TDD y Cobertura >80%)

El desarrollo de componentes debe orientarse obligatoriamente bajo **Test-Driven Development (TDD)**. El Asistente IA debe crear/sugerir Component Tests usando `@testing-library/react` antes o a la par del código funcional, renderizando inputs vacíos y evaluando accesibilidad (ARIA roles).

Asimismo, el límite inferior es de >80% de **Line Coverage** configurado en el scope global. El asistente siempre velará porque el `vite.config.js` tenga encendido el coverage (ya sea vía `v8` o `istanbul`).

```javascript
// tests/components/SensorCard.test.jsx
import { render, screen } from "@testing-library/react";
import { SensorCard } from "../../components/dashboard/SensorCard";
import { describe, it, expect } from "vitest";

describe("SensorCard", () => {
  const mockSensor = {
    id: 1,
    name: "Sensor 1",
    currentValue: 23.5,
    lastReadingTime: Date.now(),
  };

  it("renderiza el nombre del sensor", () => {
    render(<SensorCard sensor={mockSensor} />);
    const nameElement = screen.getByText("Sensor 1");
    expect(nameElement).toBeInTheDocument();
  });

  it("muestra el valor actual", () => {
    render(<SensorCard sensor={mockSensor} />);
    const valueElement = screen.getByText("23.5°C");
    expect(valueElement).toBeInTheDocument();
  });

  it("muestra 'Online' si fue actualizado recientemente", () => {
    render(<SensorCard sensor={mockSensor} />);
    const statusElement = screen.getByText(/Online/);
    expect(statusElement).toBeInTheDocument();
  });
});
```

---

## Configuración Tailwind

```javascript
// tailwind.config.js
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#3b82f6",
        secondary: "#10b981",
      },
    },
  },
  plugins: [],
};
```

---

## Checklist Antes de Commit

- [ ] Código compila sin errores (`npm run build`)
- [ ] Lints pasan (`npm run lint`)
- [ ] Tests pasan (`npm run test`)
- [ ] Cobertura >= 80% (`npm run test --coverage`)
- [ ] Nombres de componentes: PascalCase
- [ ] PropTypes o TypeScript para props
- [ ] Componentes reutilizables en `common/`
- [ ] No hay console.log() en production
- [ ] Handles de error implementados
- [ ] WebSocket/API con timeout

---

*Recuerda: React es declarativo. Pensar en estado, no en cambios DOM.*
