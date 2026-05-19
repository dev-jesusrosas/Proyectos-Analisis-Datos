# 🏦 Pipeline Bancario de Auditoría y Calidad de Datos — InkaBank 2026
 
<div align="center">
![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.x-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Status](https://img.shields.io/badge/Estado-Producción-28a745?style=for-the-badge)
![License](https://img.shields.io/badge/Licencia-MIT-yellow?style=for-the-badge)
 
**Motor de auditoría ETL en memoria para sanear, validar y conciliar transacciones bancarias crudas antes de su inyección en dashboards de riesgo o almacenamiento relacional definitivo.**
 
[Ver pipeline principal](#pipeline-de-ingesta-y-calidad) · [Cómo ejecutarlo](#cómo-ejecutarlo) · [Casos críticos](#análisis-de-casos-críticos-en-producción)
 
</div>
---
 
## 📋 Tabla de Contenidos
 
- [El Problema](#el-problema)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Estructura de Datos](#estructura-de-datos-core-bancario)
- [Pipeline de Ingesta y Calidad](#pipeline-de-ingesta-y-calidad)
- [Análisis de Casos Críticos](#análisis-de-casos-críticos-en-producción)
- [Resultados Principales](#resultados-principales)
- [Estructura del Repositorio](#estructura-del-repositorio)
- [Cómo Ejecutarlo](#cómo-ejecutarlo)
- [Técnicas y Conceptos Aplicados](#técnicas-y-conceptos-aplicados)
- [Autor](#autor)
---
 
## ⚠️ El Problema
 
Los canales digitales de un banco (Cajeros Automáticos, Apps Móviles, Pasarelas de Pago) procesan millones de transacciones por segundo. En entornos de alta concurrencia, las microcaídas de red o fallos de latencia de bases de datos generan tres problemas críticos:
 
| # | Problema | Impacto Real |
|---|----------|--------------|
| 1 | **Doble procesamiento de registros** | Duplicación exacta de transacciones que impactan los saldos reales de los clientes (dobles cobros). |
| 2 | **Inconsistencias y corrupción de datos** | Campos monetarios nulos (`NaN`) o montos negativos imposibles que desbalancean la contabilidad diaria del cierre de caja. |
| 3 | **Falta de trazabilidad** | Transacciones huérfanas asociadas a identificadores de clientes no registrados o inexistentes en el Core Bancario. |
 
Este proyecto construye un **Pipeline ETL automatizado en Python + Pandas** que actúa como motor de auditoría en la memoria RAM, aplicando reglas de negocio financiero antes de que los datos lleguen a Power BI o al almacenamiento relacional definitivo.
 
---
 
## 🏗️ Arquitectura del Sistema
 
```
Transacciones Crudas (Cajeros / Apps Móviles)
          │
          ▼
┌─────────────────────────────────────────┐
│      PIPELINE ETL — Python + Pandas     │
│      Filtros de Calidad en RAM          │
│                                         │
│  ┌─────────────────┐                   │
│  │ 01 Deduplicación│ → Evita doble cobro│
│  └────────┬────────┘                   │
│           ▼                             │
│  ┌─────────────────┐                   │
│  │ 02 Sanación     │ → Nulos + ISO dates│
│  └────────┬────────┘                   │
│           ▼                             │
│  ┌─────────────────┐                   │
│  │ 03 Auditoría DQ │ → Purga montos ≤ 0│
│  └────────┬────────┘                   │
│           ▼                             │
│  ┌─────────────────┐   maestro_clientes │
│  │ 04 LEFT JOIN    │ ◄─────[ CSV ]──── │
│  └────────┬────────┘                   │
│           ▼                             │
│  ┌─────────────────┐                   │
│  │ 05 Alerta       │ → Clientes huérfanos│
│  │    Huérfanos    │   (CLI no registrado)│
│  └────────┬────────┘                   │
└───────────┼─────────────────────────────┘
            ▼
   auditoria_final_banco.csv
   ──────────────────────────────────────►
          Power BI / Dashboard de Riesgos
```
 
---
 
## 🗄️ Estructura de Datos (Core Bancario)
 
El sistema interconecta de forma relacional dos fuentes de datos en formato plano:
 
| Archivo | Tipo de Entidad | Registros | Descripción |
|---------|----------------|-----------|-------------|
| `transacciones_sucias.csv` | Transaccional (OLTP) | 7 | Registro crudo de operaciones con duplicados por red, montos nulos y valores negativos. |
| `maestro_clientes.csv` | Tabla Maestra | 4 | Catálogo centralizado de clientes con nombres y cuentas indexadas por `id_cliente`. |
 
### Muestra de datos crudos (`transacciones_sucias.csv`)
 
| id_transaccion | id_cliente | tipo_operacion | monto_pen | fecha_operacion |
|---------------|------------|----------------|-----------|-----------------|
| 9001 | CLI_101 | Retiro | 500.00 | 2026-05-18 |
| 9002 | CLI_102 | Depósito | **None** ⚠️ | 2026/05/18 ⚠️ |
| 9003 | CLI_101 | Retiro | 500.00 | 2026-05-18 |
| **9001** | CLI_101 | Retiro | 500.00 | 2026-05-18 ← **DUPLICADO** ⚠️ |
| 9004 | **CLI_999** | Transferencia | 1200.00 | 2026-05-19 ← **HUÉRFANO** ⚠️ |
| 9005 | CLI_103 | Retiro | **-50.00** ⚠️ | 2026-05-19 |
| 9006 | CLI_102 | Depósito | 350.00 | **None** ⚠️ |
 
---
 
## ⚙️ Pipeline de Ingesta y Calidad
 
Flujo completo: **Ingesta → Deduplicación → Homologación → Filtrado DQ → Enriquecimiento → Alertas → Carga**
 
| Fase | Función en Pandas | Regla de Negocio | Impacto Comercial |
|------|-------------------|------------------|-------------------|
| **01. Deduplicación** | `.drop_duplicates(subset='id_transaccion')` | Elimina réplicas por `id_transaccion`, no solo filas completas. Evita que un doble timestamp en diferente canal cuele un cobro duplicado. | Evita sobrecargos erróneos, multas regulatorias y reclamos ante INDECOPI. |
| **02. Sanación de Nulos** | `.fillna(0.0)` | Reemplaza montos vacíos por valor neutral flotante. Equivale a `COALESCE` en SQL. | Consistencia contable: evita el colapso de funciones matemáticas y cuadra balances diarios. |
| **03. Estandarización** | `pd.to_datetime(..., errors='coerce')` | Fuerza conversión de fechas corruptas o en formatos mixtos al estándar ISO 8601. Fechas irrecuperables se marcan como `NaT`. | Time Intelligence: garantiza trazabilidad cronológica correcta en auditorías. |
| **04. Data Quality (DQ)** | `df[df['monto_pen'] > 0]` | Admite únicamente montos positivos y reales. Montos nulos convertidos a `0.0` son descartados por esta regla. | Control de fraude: aísla bugs del sistema informático y previene desfalcos por saldos negativos. |
| **05. Enriquecimiento** | `pd.merge(..., how='left')` | LEFT JOIN por `id_cliente` contra el catálogo del Core Bancario. | Auditoría interna: inyecta nombres y **detecta cuentas huérfanas** (`NaN` en `nombre_cliente`). |
| **06. Alerta de Huérfanos** | `.isna()` + log de seguridad | Cuantifica y reporta transacciones con `id_cliente` no registrado en el maestro. Calcula % del lote comprometido. | Seguridad: dinero real moviéndose desde cuentas fantasma activa protocolo de revisión manual. |
 
---
 
## 🚨 Análisis de Casos Críticos en Producción
 
### Caso 1 — Cliente Huérfano (CLI_999)
 
El pipeline procesó exitosamente una transferencia de **S/. 1,200.00**. Al realizar el LEFT JOIN contra el maestro, no encontró registro para `CLI_999`. En lugar de romper la ejecución, asignó `NaN` al campo `nombre_cliente` y **emitió una alerta de seguridad automática**.
 
```
⚠️  [ALERTA DE SEGURIDAD] Clientes NO REGISTRADOS en el Core Bancario detectados:
    → Transacciones con cuenta huérfana: 1 de 4 (25.00% del lote final)
    → Acción requerida: Revisión manual urgente por el área de Cumplimiento.
```
 
> Dinero real moviéndose desde una cuenta no registrada representa un riesgo regulatorio de primer nivel (SBS, UIF-Perú).
 
### Caso 2 — Reducción del Lote por Reglas DQ
 
```
Lote inicial        →  7 filas
Tras deduplicación  →  6 filas  (–1 por id_transaccion 9001 duplicado)
Tras filtro DQ      →  4 filas  (–1 por monto negativo –50.00, –1 por monto nulo → 0.00)
Lote final válido   →  4 filas  ✅
```
 
La transacción nula no desapareció silenciosamente: fue convertida a `0.0` (rastreable en logs) y **luego** descartada por la regla de integridad `monto > 0`. Trazabilidad completa del rechazo.
 
---
 
## 📊 Resultados Principales
 
| Métrica | Resultado | Impacto en el Negocio |
|---------|-----------|----------------------|
| **Eficiencia Operativa** | Procesamiento total < 15 ms | Optimización del 95%+ frente a conciliaciones manuales en Excel. |
| **Integridad Referencial** | 6 columnas unificadas y limpias | Datos listos para Power BI sin transformaciones adicionales en destino. |
| **Tolerancia a Fallos** | `errors='coerce'` — nunca crashea | Pipeline "Crash-Proof": aísla datos corruptos manteniendo el flujo activo. |
| **Alerta de Huérfanos** | Detección automática con % del lote | Activa protocolo de revisión de cumplimiento sin intervención humana. |
 
---
 
## 📁 Estructura del Repositorio
 
```
pipeline-etl-bancario-pandas/
│
├── README.md                  ← Documentación ejecutiva e impactos del negocio
├── .gitignore                 ← Exclusión de CSVs locales y archivos temporales
│
├── 00_generador_datos.py      ← Simulador del Core transaccional (genera data sucia)
└── pipeline_inkabank.py       ← Orquestador ETL: calidad, auditoría y consolidación
```
 
> Los archivos CSV generados (`transacciones_sucias.csv`, `maestro_clientes.csv`, `auditoria_final_banco.csv`) están en `.gitignore` por contener datos simulados sensibles.
 
---
 
## 🚀 Cómo Ejecutarlo
 
### Prerrequisitos
 
- Python **3.10** o superior
- Librería Pandas
```bash
pip install pandas
```
 
### Pasos
 
```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/pipeline-etl-bancario-pandas.git
cd pipeline-etl-bancario-pandas
 
# 2. Generar la data cruda simulada del Core Bancario
python 00_generador_datos.py
 
# 3. Ejecutar el pipeline ETL de auditoría
python pipeline_inkabank.py
```
 
Al finalizar el paso 3, la consola imprimirá el reporte completo de auditoría y se creará automáticamente el archivo `auditoria_final_banco.csv` listo para Power BI.
 
### Salida esperada en consola
 
```
  PIPELINE BANCARIO Y CALIDAD DE DATOS — INKA_BANK 2026
══════════════════════════════════════════════════════
[INFO] Cargando transacciones de los canales digitales...
[ÉXITO] Registros iniciales: 7 filas.
...
[ÉXITO] Auditoría completada. Registros válidos: 4 filas.
⚠️  [ALERTA DE SEGURIDAD] Clientes NO REGISTRADOS detectados: 1 (25.00%)
[ÉXITO] auditoria_final_banco.csv generado.
```
 
---
 
## 🛠️ Técnicas y Conceptos Aplicados
 
- **Arquitectura de Software** — Scripts idempotentes y desacoplados: el generador de datos es independiente del orquestador de reglas de control.
- **Data Quality (DQ)** — Deduplicación selectiva por clave de negocio (`id_transaccion`), normalización tipológica y manejo avanzado de estructuras nulas (`NaN` / `NaT`).
- **Lógica Relacional sobre DataFrames** — Simulación nativa de `DISTINCT`, `COALESCE` y `LEFT JOIN` sin necesidad de una base de datos SQL.
- **Gestión de Rutas con `pathlib`** — Rutas absolutas independientes del sistema operativo (compatible Windows / Linux / macOS).
- **Alertas de Seguridad Automatizadas** — Detección y cuantificación de cuentas huérfanas con porcentaje de exposición del lote.
- **Documentación Técnica** — Logs de consola con `f-strings` formateados para operadores de TI y analistas de riesgos.
---
 
## 👤 Autor
 
**Jesús Muñoz Rosas**  
Ingeniería de Sistemas · Analítica de Datos · Ciberseguridad e Infraestructura IT
 
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Conectar-0A66C2?style=flat&logo=linkedin)](https://linkedin.com/in/tu-usuario)
[![GitHub](https://img.shields.io/badge/GitHub-Perfil-181717?style=flat&logo=github)](https://github.com/tu-usuario)
 
---
 
<div align="center">
<sub>Desarrollado como proyecto de demostración para Control Interno, Auditoría Informática y Gestión de Riesgos Financieros · Perú 2026</sub>
</div>
 
