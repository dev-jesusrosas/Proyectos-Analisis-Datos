# 🏦 Pipeline Bancario de Auditoria y Calidad de Datos — InkaBank 2026
 
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Pandas](https://img.shields.io/badge/Pandas-2.x-150458?style=for-the-badge&logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![Status](https://img.shields.io/badge/Estado-Produccion-28a745?style=for-the-badge)]()
[![License](https://img.shields.io/badge/Licencia-MIT-yellow?style=for-the-badge)]()
 
> Motor de auditoria ETL en memoria para sanear, validar y conciliar transacciones bancarias crudas antes de su inyeccion en dashboards de riesgo o almacenamiento relacional definitivo.
 
---
 
## Tabla de Contenidos
 
- [El Problema](#el-problema)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Estructura de Datos](#estructura-de-datos-core-bancario)
- [Pipeline de Ingesta y Calidad](#pipeline-de-ingesta-y-calidad)
- [Analisis de Casos Criticos](#analisis-de-casos-criticos-en-produccion)
- [Resultados Principales](#resultados-principales)
- [Estructura del Repositorio](#estructura-del-repositorio)
- [Como Ejecutarlo](#como-ejecutarlo)
- [Tecnicas y Conceptos Aplicados](#tecnicas-y-conceptos-aplicados)
- [Autor](#autor)
---
 
## El Problema
 
Los canales digitales de un banco (Cajeros Automaticos, Apps Moviles, Pasarelas de Pago) procesan millones de transacciones por segundo. En entornos de alta concurrencia, las microcaidas de red o fallos de latencia de bases de datos generan tres problemas criticos:
 
| # | Problema | Impacto Real |
|---|----------|--------------|
| 1 | **Doble procesamiento de registros** | Duplicacion exacta de transacciones que impactan los saldos reales de los clientes (dobles cobros). |
| 2 | **Inconsistencias y corrupcion de datos** | Campos monetarios nulos (`NaN`) o montos negativos imposibles que desbalancean la contabilidad diaria del cierre de caja. |
| 3 | **Falta de trazabilidad** | Transacciones huerfanas asociadas a identificadores de clientes no registrados o inexistentes en el Core Bancario. |
 
Este proyecto construye un **Pipeline ETL automatizado en Python + Pandas** que actua como motor de auditoria en la memoria RAM, aplicando reglas de negocio financiero antes de que los datos lleguen a Power BI o al almacenamiento relacional definitivo.
 
---
 
## Arquitectura del Sistema
 
```
Transacciones Crudas (Cajeros / Apps Moviles)
          |
          v
+-----------------------------------------+
|      PIPELINE ETL --- Python + Pandas   |
|      Filtros de Calidad en RAM          |
|                                         |
|  +-----------------+                   |
|  | 01 Deduplicacion| -> Evita doble cobro
|  +--------+--------+                   |
|           v                             |
|  +-----------------+                   |
|  | 02 Sanacion     | -> Nulos + ISO dates
|  +--------+--------+                   |
|           v                             |
|  +-----------------+                   |
|  | 03 Auditoria DQ | -> Purga montos <= 0
|  +--------+--------+                   |
|           v                             |
|  +-----------------+  maestro_clientes  |
|  | 04 LEFT JOIN    | <-----[ CSV ]----  |
|  +--------+--------+                   |
|           v                             |
|  +-----------------+                   |
|  | 05 Alerta       | -> Clientes huerfanos
|  |    Huerfanos    |   (CLI no registrado)
|  +--------+--------+                   |
+-----------+-----------------------------+
            v
   auditoria_final_banco.csv
   ----------------------------------------->
          Power BI / Dashboard de Riesgos
```
 
---
 
## Estructura de Datos Core Bancario
 
El sistema interconecta de forma relacional dos fuentes de datos en formato plano:
 
| Archivo | Tipo de Entidad | Registros | Descripcion |
|---------|----------------|-----------|-------------|
| `transacciones_sucias.csv` | Transaccional (OLTP) | 7 | Registro crudo de operaciones con duplicados por red, montos nulos y valores negativos. |
| `maestro_clientes.csv` | Tabla Maestra | 4 | Catalogo centralizado de clientes con nombres y cuentas indexadas por `id_cliente`. |
 
### Muestra de datos crudos
 
| id_transaccion | id_cliente | tipo_operacion | monto_pen | fecha_operacion |
|---------------|------------|----------------|-----------|-----------------|
| 9001 | CLI_101 | Retiro | 500.00 | 2026-05-18 |
| 9002 | CLI_102 | Deposito | **None** ⚠️ | 2026/05/18 ⚠️ |
| 9003 | CLI_101 | Retiro | 500.00 | 2026-05-18 |
| **9001** | CLI_101 | Retiro | 500.00 | 2026-05-18 **← DUPLICADO** ⚠️ |
| 9004 | **CLI_999** | Transferencia | 1200.00 | 2026-05-19 **← HUERFANO** ⚠️ |
| 9005 | CLI_103 | Retiro | **-50.00** ⚠️ | 2026-05-19 |
| 9006 | CLI_102 | Deposito | 350.00 | **None** ⚠️ |
 
---
 
## Pipeline de Ingesta y Calidad
 
Flujo completo: **Ingesta → Deduplicacion → Homologacion → Filtrado DQ → Enriquecimiento → Alertas → Carga**
 
| Fase | Funcion en Pandas | Regla de Negocio | Impacto Comercial |
|------|-------------------|------------------|-------------------|
| **01. Deduplicacion** | `.drop_duplicates(subset='id_transaccion')` | Elimina replicas por `id_transaccion`, no solo filas completas. Evita que un doble timestamp cuele un cobro duplicado. | Evita sobrecargos erroneos, multas regulatorias y reclamos ante INDECOPI. |
| **02. Sanacion de Nulos** | `.fillna(0.0)` | Reemplaza montos vacios por valor neutral flotante. Equivale a `COALESCE` en SQL. | Consistencia contable: evita el colapso de funciones matematicas y cuadra balances diarios. |
| **03. Estandarizacion** | `pd.to_datetime(..., errors='coerce')` | Fuerza conversion de fechas corruptas o en formatos mixtos al estandar ISO 8601. Fechas irrecuperables se marcan como `NaT`. | Time Intelligence: garantiza trazabilidad cronologica correcta en auditorias. |
| **04. Data Quality (DQ)** | `df[df['monto_pen'] > 0]` | Admite unicamente montos positivos y reales. Montos nulos convertidos a `0.0` son descartados por esta regla. | Control de fraude: aisla bugs del sistema informatico y previene desfalcos por saldos negativos. |
| **05. Enriquecimiento** | `pd.merge(..., how='left')` | LEFT JOIN por `id_cliente` contra el catalogo del Core Bancario. | Auditoria interna: inyecta nombres y **detecta cuentas huerfanas** (`NaN` en `nombre_cliente`). |
| **06. Alerta de Huerfanos** | `.isna()` + log de seguridad | Cuantifica y reporta transacciones con `id_cliente` no registrado en el maestro. Calcula % del lote comprometido. | Seguridad: dinero real moviendose desde cuentas fantasma activa protocolo de revision manual. |
 
---
 
## Analisis de Casos Criticos en Produccion
 
### Caso 1 — Cliente Huerfano (CLI_999)
 
El pipeline proceso exitosamente una transferencia de **S/. 1,200.00**. Al realizar el LEFT JOIN contra el maestro, no encontro registro para `CLI_999`. En lugar de romper la ejecucion, asigno `NaN` al campo `nombre_cliente` y emitio una **alerta de seguridad automatica**.
 
```
[ALERTA DE SEGURIDAD] Clientes NO REGISTRADOS en el Core Bancario detectados:
    -> Transacciones con cuenta huerfana: 1 de 4 (25.00% del lote final)
    -> Accion requerida: Revision manual urgente por el area de Cumplimiento.
```
 
> Dinero real moviendose desde una cuenta no registrada representa un riesgo regulatorio de primer nivel (SBS, UIF-Peru).
 
### Caso 2 — Reduccion del Lote por Reglas DQ
 
```
Lote inicial        ->  7 filas
Tras deduplicacion  ->  6 filas  (-1 por id_transaccion 9001 duplicado)
Tras filtro DQ      ->  4 filas  (-1 por monto negativo -50.00, -1 por monto nulo -> 0.00)
Lote final valido   ->  4 filas  [OK]
```
 
La transaccion nula no desaparecio silenciosamente: fue convertida a `0.0` (rastreable en logs) y **luego** descartada por la regla de integridad `monto > 0`. Trazabilidad completa del rechazo.
 
---
 
## Resultados Principales
 
| Metrica | Resultado | Impacto en el Negocio |
|---------|-----------|----------------------|
| **Eficiencia Operativa** | Procesamiento total < 15 ms | Optimizacion del 95%+ frente a conciliaciones manuales en Excel. |
| **Integridad Referencial** | 6 columnas unificadas y limpias | Datos listos para Power BI sin transformaciones adicionales en destino. |
| **Tolerancia a Fallos** | `errors='coerce'` — nunca crashea | Pipeline "Crash-Proof": aisla datos corruptos manteniendo el flujo activo. |
| **Alerta de Huerfanos** | Deteccion automatica con % del lote | Activa protocolo de revision de cumplimiento sin intervencion humana. |
 
---
 
## Estructura del Repositorio
 
```
pipeline-etl-bancario-pandas/
|
|-- README.md                  <- Documentacion ejecutiva e impactos del negocio
|-- .gitignore                 <- Exclusion de CSVs locales y archivos temporales
|
|-- 00_generador_datos.py      <- Simulador del Core transaccional (genera data sucia)
|-- pipeline_inkabank.py       <- Orquestador ETL: calidad, auditoria y consolidacion
```
 
> Los archivos CSV generados (`transacciones_sucias.csv`, `maestro_clientes.csv`, `auditoria_final_banco.csv`) estan en `.gitignore` por contener datos simulados sensibles.
 
---
 
## Como Ejecutarlo
 
### Prerrequisitos
 
- Python **3.10** o superior
- Libreria Pandas
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
 
# 3. Ejecutar el pipeline ETL de auditoria
python pipeline_inkabank.py
```
 
Al finalizar el paso 3, la consola imprimira el reporte completo de auditoria y se creara automaticamente el archivo `auditoria_final_banco.csv` listo para Power BI.
 
### Salida esperada en consola
 
```
  PIPELINE BANCARIO Y CALIDAD DE DATOS — INKA_BANK 2026
======================================================
[INFO] Cargando transacciones de los canales digitales...
[EXITO] Registros iniciales: 7 filas.
...
[EXITO] Auditoria completada. Registros validos: 4 filas.
[ALERTA DE SEGURIDAD] Clientes NO REGISTRADOS detectados: 1 (25.00%)
[EXITO] auditoria_final_banco.csv generado.
```
 
---
 
## Tecnicas y Conceptos Aplicados
 
- **Arquitectura de Software** — Scripts idempotentes y desacoplados: el generador de datos es independiente del orquestador de reglas de control.
- **Data Quality (DQ)** — Deduplicacion selectiva por clave de negocio (`id_transaccion`), normalizacion tipologica y manejo avanzado de estructuras nulas (`NaN` / `NaT`).
- **Logica Relacional sobre DataFrames** — Simulacion nativa de `DISTINCT`, `COALESCE` y `LEFT JOIN` sin necesidad de una base de datos SQL.
- **Gestion de Rutas con `pathlib`** — Rutas absolutas independientes del sistema operativo (compatible Windows / Linux / macOS).
- **Alertas de Seguridad Automatizadas** — Deteccion y cuantificacion de cuentas huerfanas con porcentaje de exposicion del lote.
- **Documentacion Tecnica** — Logs de consola con `f-strings` formateados para operadores de TI y analistas de riesgos.
---
 
## Autor
 
**Jesus Munoz Rosas**
Ingenieria de Sistemas · Analitica de Datos · Ciberseguridad e Infraestructura IT
 
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Conectar-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/jesus-mu%C3%B1oz-rosas-data/)
 
---
 
<div align="center">
<sub>Desarrollado como proyecto de demostracion para Control Interno, Auditoria Informatica y Gestion de Riesgos Financieros &middot; Peru 2026</sub>
</div>
