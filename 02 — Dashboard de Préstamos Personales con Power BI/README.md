# Dashboard de Seguimiento de Préstamos Personales — Power BI
 
**Herramientas:** Power BI · DAX · Power Query · Modelado dimensional
 
## El problema
 
Un área financiera necesitaba visualizar el comportamiento de sus préstamos
personales entre 2021 y 2022. Los datos estaban dispersos y no había forma
de comparar por distrito, tipo de crédito o perfil del cliente sin procesar
todo manualmente.
 
## Qué construí
 
Un dashboard interactivo con modelo dimensional en esquema estrella que permite
filtrar y comparar en tiempo real cualquier combinación de variables.
 
## Modelo de datos
 
Esquema estrella con 3 tablas:
 
- **Prestamos** — tabla de hechos con métricas de desembolso y fechas
- **Clientes** — dimensión con datos demográficos, distrito y segmento de edad
- **Tiempo** — dimensión de fechas para análisis comparativo entre períodos
## Insights que no eran visibles antes del dashboard
 
| Hallazgo | Dato |
|----------|------|
| Clientes masculinos concentran el desembolso | 74.9% en 2021 · 100% en 2022 |
| Clientes menores de 30 años | 42.1% en 2021 · 45.8% en 2022 |
| Distrito con mayor promedio de desembolso | Cayma — S/. 12,500 promedio |
| Distrito con mayor volumen | Laredo — 26% del total 2021 |
| Mes de mayor desembolso 2021 | Enero — S/. 17.5 mil |
| Mes de mayor desembolso 2022 | Septiembre — S/. 12 mil |
 
## Funcionalidades del dashboard
 
- Filtros interactivos por tipo de préstamo: CrediMoto · Crédito Consumo · Crédito Emprendimiento
- Comparación entre años: 2021 vs 2022
- Gráfico de barras de desembolso mensual
- Tabla de rendimiento por distrito con promedio y porcentajes
- Tarjetas KPI: total desembolsado y porcentaje por género
## Técnicas aplicadas
 
- Modelado dimensional en esquema estrella
- Medidas DAX para KPIs de desembolso y participación porcentual
- Power Query para limpieza y transformación de datos
- Segmentadores interactivos para análisis dinámico
- Tabla de tiempo para comparativas entre períodos
## Archivos
 
```
02-Dashboard-BI-Prestamos-Bancarios/
├── README.md
├── Seguimiento_Prestamos_Personales.pbix
├── Base_Datos_Prestamos.xlsx
└── imagenes/
    ├── 01-dashboard-2021.png
    ├── 02-modelo-datos.png
    └── 03-dashboard-2022-filtrado.png
```
 
## Autor
 
Jesus Muñoz Rosas · [LinkedIn](https://www.linkedin.com/in/jesus-mu%C3%B1oz-rosas-8180b5242/)
