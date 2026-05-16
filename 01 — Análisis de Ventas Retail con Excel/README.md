# Análisis de Ventas Retail con Excel — Nova Perú 2024
 
**Herramientas:** Excel · SUMPRODUCT · INDICE+COINCIDIR · BUSCARV · Tablas dinámicas
 
## El problema
 
Analizar 243 transacciones de ventas manualmente para identificar qué vendedor,
categoría y región generan más revenue es un proceso lento y propenso a errores.
Este proyecto consolida todo en un dashboard que responde esas preguntas en segundos.
 
## Qué construí
 
Un archivo Excel con tres hojas conectadas:
 
- **Base de Datos** — 243 transacciones con fecha, vendedor, región, categoría,
  producto, unidades, precio unitario, descuento y venta neta. Las fórmulas de
  venta bruta y neta son dinámicas y se calculan automáticamente.
- **Dashboard KPIs** — 5 tarjetas de indicadores: venta neta total, ticket promedio,
  transacciones completadas, porcentaje de devoluciones y mejor categoría por volumen.
  Tablas de ventas por mes con variación vs mes anterior, ranking por categoría y
  top vendedores con participación porcentual.
- **Análisis Funciones** — Demostración de funciones avanzadas aplicadas a casos
  reales: clasificación de rendimiento por vendedor, bonos calculados con lógica
  condicional, búsqueda dinámica, estadísticas de distribución y resumen ejecutivo
  cruzando región con categoría.
## Resultados principales
 
| Indicador | Resultado |
|-----------|-----------|
| Venta neta total | S/. 224,240.50 |
| Ticket promedio | S/. 1,359.03 |
| Transacciones completadas | 165 de 243 |
| Mejor categoría | Electrónica (71.7% del revenue) |
| Vendedor top | Rosa Mendoza — S/. 129,459 |
| Mes de mayor venta | Mayo — S/. 101,539 |
 
## Funciones implementadas
 
- `SUMPRODUCT` — KPIs cruzando múltiples condiciones sin columnas auxiliares
- `SI` anidados — clasificación automática de rendimiento (Alto / Medio / Bajo)
- `INDICE + COINCIDIR` — búsqueda dinámica por vendedor
- `BUSCARV` — consultas de datos por criterio
- `RANK` — ranking de categorías por revenue
- `MAX`, `MIN`, `PROMEDIO`, `MEDIANA`, `DESVEST` — análisis estadístico
- Funciones de texto: `CONCATENAR`, `MAYUSC`, `MINUSC`, `EXTRAE`, `LEN`
## Archivos
 
```
01-Analisis-Ventas-Retail-Excel/
├── README.md
├── Analisis_Ventas_Retail_NovaPeru_2024.xlsx
└── imagenes/
    ├── 01-dashboard-kpis.png
    └── 02-analisis-funciones.png
```
 
## Autor
 
Jesus Muñoz Rosas · [LinkedIn](https://www.linkedin.com/in/jesus-mu%C3%B1oz-rosas-8180b5242/)
