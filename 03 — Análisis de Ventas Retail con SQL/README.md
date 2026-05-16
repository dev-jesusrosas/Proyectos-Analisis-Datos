# Análisis de Ventas Retail con SQL — Nova Perú 2024
 
**Herramientas:** MySQL 8.0 · JOINs · Subconsultas · CTEs · Window Functions
 
## El problema
 
Tener datos de ventas en una sola tabla plana limita el análisis. Este proyecto
construye una base de datos relacional desde cero, carga 561 transacciones reales,
aplica limpieza de datos y ejecuta un pipeline de análisis completo que cruza
vendedores, productos y clientes en una sola consulta.
 
## Modelo de datos
 
3 tablas conectadas mediante foreign keys:
 
- **sales** — tabla de hechos: 561 transacciones con fecha, producto, cliente, cantidad y precio
- **customers** — 50 clientes con región y segmento
- **products** — 25 productos con categoría y costo real para calcular margen
## Pipeline de análisis
 
```
Creación de BD → Carga de datos → Limpieza → Análisis → Detección de anomalías
```
 
## Resultados principales
 
| Análisis | Resultado |
|----------|-----------|
| Total revenue 2024 | S/. 789,677 en 561 transacciones |
| Ticket promedio | S/. 1,407.62 por transacción |
| Categoría dominante | Electrónica — 71.7% del revenue total |
| Vendedor top | Rosa Mendoza — S/. 129,459 |
| Mes pico | Mayo — S/. 101,539 (+94.3% vs abril) |
| Mayor caída mensual | Febrero — -65.2% vs enero |
| Anomalías detectadas | Transacciones fuera de 2σ del promedio |
 
## Técnicas aplicadas
 
- `INNER JOIN` entre 3 tablas para cruzar ventas con productos y clientes
- Subconsultas en `FROM` y `WHERE` para filtrar clientes sobre el promedio
- CTEs múltiples encadenados para análisis acumulado por vendedor
- `RANK()` con `PARTITION BY` para ranking por categoría
- `LAG()` para variación mensual vs período anterior
- `SUM()` acumulado con `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`
- `CROSS JOIN` con `STDDEV()` para detección estadística de anomalías
- Limpieza: eliminación de nulos y deduplicación con `DELETE` + `INNER JOIN`
## Archivos
 
```
03-Analisis-SQL-Ventas-Retail/
├── README.md
├── analisis_ventas_retail.sql
├── data/
│   ├── customers.csv
│   ├── products.csv
│   └── sales.csv
└── imagenes/
    ├── 01-estructura-tablas.png
    ├── 02-analisis-general.png
    ├── 03-ventas-por-vendedor.png
    ├── 04-ranking-productos.png
    └── 05-deteccion-anomalias.png
```
 
## Cómo ejecutarlo
 
1. Importa los tres CSVs desde la carpeta `/data` usando el Table Data Import Wizard de MySQL Workbench
2. Configura el encoding como `utf8mb4` antes de importar
3. Ejecuta el archivo `analisis_ventas_retail.sql` sección por sección
## Autor
 
Jesus Muñoz Rosas · [LinkedIn](https://www.linkedin.com/in/jesus-mu%C3%B1oz-rosas-8180b5242/)
