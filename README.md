# Portafolio de Análisis de Datos · Jesús Muñoz Rosas

**Data Analyst Jr.** con enfoque en SQL, Power BI y Python aplicados 
a contextos reales del mercado peruano — retail, banca y logística.

Este repositorio documenta 5 proyectos con ciclo completo de datos:
ingesta → limpieza → modelado → visualización → insight accionable.

📍 Lima, Perú · 🌐 portafolio.jesussistemas.com · 
💼 linkedin.com/in/jesus-muñoz-rosas-data

---
## 01 — Análisis de Ventas Retail · Excel

> **Impacto:** Consolidación de 243 transacciones en un dashboard de KPIs 
> que elimina la revisión manual fila por fila — filtros en segundos.

Dashboard que unifica 8 vendedores, 5 categorías y 5 regiones en una 
sola vista. Incluye automatización de reportería con funciones avanzadas.

**Hallazgo clave:** Electrónica concentra el 71.7% del revenue total 
(ticket promedio S/. 1,407). El top vendedor acumula S/. 129,459 anuales, 
superando en 2.3x al promedio del equipo.

**Stack:** `Excel` `SUMPRODUCT` `INDICE+COINCIDIR` `BUSCARV` `Tablas dinámicas`

![Dashboard Excel](https://github.com/dev-jesusrosas/Proyectos-Analisis-Datos/blob/22b083903cf80f98d81ebfd79e0df0e4327aef3f/01%20%E2%80%94%20An%C3%A1lisis%20de%20Ventas%20Retail%20con%20Excel/imagenes/01-dashboard-kpis.png)

[→ Ver proyecto completo](./01%20—%20Análisis%20de%20Ventas%20Retail%20con%20Excel)
---
 
## 02 — Dashboard de Préstamos Personales · Power BI

> **Impacto:** Visibilidad en tiempo real de cartera bancaria 2021–2022 
> que antes requería cruces manuales entre áreas.

Modelo dimensional en esquema estrella con análisis de 9 distritos, 
3 tipos de crédito y segmentación por edad y género.

**Hallazgo clave:** El 74.9% del desembolso corresponde a clientes 
masculinos en 2021. Los menores de 30 años representan el 42.1% del 
volumen — segmento no identificado antes del dashboard, con potencial 
directo para campañas de fidelización.

**Stack:** `Power BI` `DAX` `Power Query` `Modelado dimensional (Star Schema)`

![Dashboard Power BI](https://github.com/dev-jesusrosas/Proyectos-Analisis-Datos/blob/22b083903cf80f98d81ebfd79e0df0e4327aef3f/02%20%E2%80%94%20Dashboard%20de%20Pr%C3%A9stamos%20Personales%20con%20Power%20BI/Imagenes/03-dashboard-2022-filtrado.png)

[→ Ver proyecto completo](./02%20—%20Dashboard%20de%20Préstamos%20Personales%20con%20Power%20BI)
---
 
## 03 — Análisis de Ventas Retail · SQL

> **Impacto:** Pipeline SQL completo que detecta anomalías 
> automáticamente — sin intervención humana.

Base relacional con 561 transacciones y 3 tablas conectadas mediante 
foreign keys. Incluye tendencia mensual con variación, ranking por 
categoría y detección estadística de outliers.

**Hallazgo clave:** Mayo registró S/. 101,539 en ventas (+94.3% vs mes 
anterior). El script detecta automáticamente transacciones fuera de 
2 desviaciones estándar — capacidad crítica para auditoría y control 
de fraude en retail.

**Stack:** `MySQL 8.0` `JOINs` `CTEs` `Window Functions` `RANK` `LAG`

![Pipeline SQL](https://github.com/dev-jesusrosas/Proyectos-Analisis-Datos/blob/22b083903cf80f98d81ebfd79e0df0e4327aef3f/03%20%E2%80%94%20An%C3%A1lisis%20de%20Ventas%20Retail%20con%20SQL/Imagenes/05-deteccion-anomalias.png)

[→ Ver proyecto completo](./03%20—%20Análisis%20de%20Ventas%20Retail%20con%20SQL)
 
---

## 04 — Pipeline de Datos Relacionales · MySQL 8 + Power BI

> **Impacto:** Reducción del 80% en tiempo de carga a AWS RDS 
> mediante bulk insert y transacciones agrupadas.

Caso simulado de empresa textil peruana (sector con alta rotación de 
inventario y complejidad logística). Base relacional con 1,770 
transacciones, 4 tablas interconectadas y pipeline completo de carga 
en la nube. Dashboard ejecutivo en modo oscuro con JSON Themes.

**Hallazgo clave:** El modelo detecta que ~85% de la carga operativa 
del 2026 se concentra en estados Pendiente y En Proceso — cuello de 
botella visible solo con modelado analítico estrella.

**Stack:** `MySQL 8.0` `AWS RDS` `Bulk Insert` `DDL Idempotente` 
`Power Query` `JSON Themes`

![Dashboard Textil](https://github.com/dev-jesusrosas/Proyectos-Analisis-Datos/blob/22b083903cf80f98d81ebfd79e0df0e4327aef3f/04%20%E2%80%94%20Proyecto%20de%20Ingenier%C3%ADa%20de%20Datos%20en%20SQL%20y%20Business%20Intelligence%20Dashboard%20con%20Power%20BI%20para%20Textil%20del%20Valle./imagenes/01-dashboard-modo-oscuro.png)

[→ Ver proyecto completo](04%20—%20Proyecto%20de%20Ingeniería%20de%20Datos%20en%20SQL%20y%20Business%20Intelligence%20Dashboard%20con%20Power%20BI%20para%20Textil%20del%20Valle.)
 
---

## 05 — Pipeline Bancario de Auditoría y Calidad de Datos · Python + Pandas

> **Impacto:** Motor ETL que detecta el 100% de duplicados y cuentas 
> huérfanas sin intervención humana — diseñado para escalar a 
> volúmenes de producción.

Caso simulado de core bancario peruano (InkaBank) con datos 
intencionalmente corruptos (duplicados, nulos, negativos, clientes 
huérfanos). Pipeline de auditoría idempotente con 6 reglas de calidad 
encadenadas y alertas automáticas alineadas a normativa SBS / UIF-Perú.

**Hallazgo clave:** El 25% del lote procesado corresponde a movimientos 
desde cuentas no registradas en el Core, activando protocolo de 
cumplimiento regulatorio. Arquitectura replicable a datasets de 
producción con ajuste mínimo de parámetros.

**Stack:** `Python 3.12` `Pandas 2.x` `ETL` `Data Quality` 
`Deduplicación` `LEFT JOIN` `pathlib`

![Output Pipeline](https://github.com/dev-jesusrosas/Proyectos-Analisis-Datos/blob/741d13a87916d1b85109300fac5a04a6e1bbce88/05%20%E2%80%94%20Pipeline%20Bancario%20de%20Auditor%C3%ADa%20y%20Calidad%20de%20Datos%20InkaBank%202026/imagen/Calidad_de_Datos_InkaBank_2026.png)

[→ Ver proyecto completo](05%20—%20Pipeline%20Bancario%20de%20Auditoría%20y%20Calidad%20de%20Datos%20InkaBank%202026)

---

## Stack tecnológico

| Área | Herramientas |
|------|-------------|
| Análisis & BI | SQL · Power BI · Excel Avanzado |
| Bases de datos | MySQL 8.0 · AWS RDS · Modelado estrella |
| Programación | Python 3.12 · Pandas 2.x · ETL |
| Nube | AWS RDS · Bulk Insert · DDL Idempotente |

---

> *Datos utilizados en todos los proyectos son sintéticos, diseñados 
> para simular escenarios reales del mercado peruano (retail, banca, 
> logística textil). Ningún dato corresponde a información confidencial 
> real.*

📩 contacto@jesussistemas.com · 
🌐 [portafolio.jesussistemas.com](http://portafolio.jesussistemas.com)
