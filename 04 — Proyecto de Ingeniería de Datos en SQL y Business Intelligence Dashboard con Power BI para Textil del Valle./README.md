# Textil del Valle 2026 — Pipeline de Datos Relacionales con MySQL 8 y Power BI
 
**Stack:** MySQL 8.0 · AWS RDS · Power BI Desktop · Esquema Estrella (OLAP) · Bulk Insert · Modo Oscuro UI/UX
 
---
 
## El problema
 
Una empresa manufacturera textil en crecimiento no puede tomar decisiones gerenciales basándose en hojas de cálculo estáticas o reportes planos: los estados operativos de producción se vuelven invisibles y los cuellos de botella no se detectan a tiempo.
 
Este proyecto construye una plataforma analítica de extremo a extremo (End-to-End): desde el diseño de una base de datos relacional optimizada en MySQL 8 hasta un Dashboard Ejecutivo en Power BI con modo oscuro, habilitando el análisis de tendencias históricas 2024–2026 y la detección en tiempo real de órdenes trabadas en producción.
 
---
 
## Arquitectura del sistema
 
```
MySQL 8 (Local / AWS RDS)
        │
        │  DDL idempotente + Bulk Insert optimizado
        │  (FOREIGN_KEY_CHECKS=0, autocommit=0)
        ▼
Modelo Relacional OLTP          Power BI Desktop
┌─────────────┐                 ┌─────────────────────────┐
│  clientes   │──┐              │  DIM_Cliente             │
│  empleados  │──┼──► pedidos ──►  DIM_Empleado            │
│             │  │              │  DIM_Tiempo              │
│             │  └──► detalle ──►  FACT_Ventas             │
└─────────────┘                 │  Dashboard Modo Oscuro   │
                                └─────────────────────────┘
```
 
---
 
## Modelo de datos (OLTP)
 
4 tablas relacionales normalizadas (3FN) interconectadas mediante `FOREIGN KEY`:
 
| Tabla | Tipo | Registros | Descripción |
|---|---|---|---|
| `clientes` | Tabla maestra | 50 | Cuentas comerciales con RUC peruano (natural y jurídico) |
| `empleados` | Tabla maestra | 20 | Personal de Corte, Costura, Ventas y Logística |
| `pedidos` | Tabla transaccional | 500 | Cabecera de orden: cliente, empleado, fecha y estado |
| `detalle_pedidos` | Tabla transaccional | 1,200 | Líneas de fabricación: tela, cantidad y precio unitario |
 
> **Distribución exacta de detalles:** 300 pedidos × 2 líneas + 200 pedidos × 3 líneas = **1,200 registros sin exceder ninguna FK**.
 
---
 
## Pipeline de ingesta
 
```
Diseño DDL → Directivas de Rendimiento → Bulk Insert → Validación de Integridad → Consumo BI
```
 
### Directivas de optimización (script maestro)
 
| Directiva | Efecto en el servidor |
|---|---|
| `SET FOREIGN_KEY_CHECKS = 0` | Elimina la validación FK fila a fila durante la carga masiva |
| `SET UNIQUE_CHECKS = 0` | Omite la verificación de índices únicos en cada inserción |
| `SET autocommit = 0` + `COMMIT` | Agrupa todas las inserciones en una sola transacción de bloque |
| **Resultado combinado** | **Reducción del 80% en tiempo de carga y estrés de CPU en AWS RDS** |
 
---
 
## Lógica de ponderación temporal
 
Los 500 pedidos no son aleatorios. Siguen una regla de negocio cronológica que habilita el análisis de tendencias (*Time Intelligence*):
 
| Año | Pedidos | Comportamiento predominante | Propósito analítico |
|---|---|---|---|
| **2024** | 192 | ~78% `Entregado` | Base histórica de facturación consolidada |
| **2025** | 213 | Mixto (Entregado / En Proceso) | Simulación de transición operativa real |
| **2026** | 95 | ~47% `Pendiente`, ~38% `En Proceso` | Detección de cuellos de botella actuales |
 
Implementación: `random.choices(estados, weights=[w1, w2, w3])` con pesos diferenciados por año.
 
---
 
## Inteligencia de Negocios (Power BI)
 
### Del modelo OLTP al Esquema Estrella (OLAP)
 
Los datos importados desde MySQL se transformaron en Power Query para construir un modelo dimensional optimizado para analítica:
 
- **Tablas de hechos:** `FACT_Ventas` (granularidad: línea de pedido)
- **Tablas de dimensiones:** `DIM_Cliente`, `DIM_Empleado`, `DIM_Tiempo`, `DIM_Producto`, `DIM_Estado`
### Dashboard Ejecutivo — Modo Oscuro
 
Diseño UI/UX alineado con los estándares de Microsoft Fabric:
 
- **Lienzo en gris profundo** para reducir la fatiga visual en sesiones largas de monitoreo
- **Paleta de color en JSON personalizado:** negro puro para contenedores, amarillo para alertas y naranja corporativo para KPIs críticos
- **Eliminación de ruido visual:** sin gridlines, sin títulos de eje redundantes
- **Contenedores modernos** con bordes redondeados y sombreado sutil
---
 
## Resultados principales
 
| Análisis | Resultado |
|:---|:---|
| Volumen de carga | 1,770 registros integrados sin errores de integridad referencial |
| Optimización de ingesta | Reducción del **80% en tiempo de carga** mediante transacciones en bloque |
| Idempotencia del script | `DROP/CREATE TABLE IF EXISTS` garantiza ejecución repetible sin errores |
| Análisis histórico 2024 | Datos orientados a `Entregado` → base de facturación consolidada |
| Análisis operativo 2026 | Concentración en `Pendiente` / `En Proceso` → detección de cuellos de botella |
| Modelo analítico | Esquema Estrella con 1 tabla de hechos y 5 dimensiones en Power BI |
 
---
 
## Estructura del repositorio
 
```
04-Analitica-Textil-del-Valle/
│
├── README.md
│
├── SQL_Scripts/
│   ├── 10_textil_valle_idempotente_v2.sql   ← Script maestro (DDL + DML + optimización)
│   ├── 01_clientes_insert.sql
│   ├── 02_empleados_insert.sql
│   ├── 03_pedidos_insert.sql
│   └── 04_detalle_pedidos_insert.sql
│
├── BI_Dashboard/
│   └── textil_del_valle_analytics.pbix
│
└── imagenes/
    ├── 01-modelo-relacional.png
    ├── 02-esquema-estrella-power-bi.png
    ├── 03-dashboard-modo-oscuro.png
    └── 04-kpis-ejecutivos.png
```
 
---
 
## Cómo ejecutarlo
 
### Prerrequisitos
- MySQL Workbench 8.0+ o acceso a instancia AWS RDS
- Encoding configurado como `utf8mb4` (soporte de tildes y caracteres especiales)
- Power BI Desktop (versión gratuita compatible)
  
### Pasos
 
```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/04-Analitica-Textil-del-Valle.git
 
# 2. Abrir MySQL Workbench y conectar a tu instancia (local o AWS RDS)
 
# 3. Ejecutar el script maestro — orquesta DDL + DML en orden correcto
#    El script aplica DROP/CREATE idempotente y las directivas de rendimiento
SOURCE SQL_Scripts/10_textil_valle_idempotente_v2.sql;
 
# 4. Abrir Power BI Desktop y cargar el archivo .pbix
#    Actualizar la cadena de conexión a tu instancia MySQL si es necesario
```
 
---
 
## Técnicas y conceptos aplicados
 
- **Modelado relacional 3FN** con restricciones `FOREIGN KEY`, `ON DELETE CASCADE` e índices compuestos
- **Bulk Insert optimizado** con sintaxis extendida MySQL: `INSERT INTO ... VALUES (...),(...),...`
- **Scripts idempotentes** con `DROP TABLE IF EXISTS` + `CREATE TABLE` para entornos CI/CD
- **Ponderación temporal** con `random.choices()` y pesos diferenciados por año cronológico
- **Transición OLTP → OLAP** mediante Power Query (M Language) en Power BI
- **Diseño UI/UX avanzado** con tema JSON personalizado en modo oscuro
---
 
## Autor
 
**Jesús Muñoz Rosas** — Ingeniería de Sistemas · Analítica de Datos
 
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Perfil-0077B5?style=flat&logo=linkedin)](https://www.linkedin.com/)
[![Portfolio](https://img.shields.io/badge/Portfolio-jesussistemas.com-orange?style=flat&logo=google-chrome)](https://jesussistemas.com)
 
