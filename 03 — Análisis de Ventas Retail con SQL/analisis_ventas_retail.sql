
-- ANÁLISIS DE VENTAS RETAIL — Nova Perú
-- Autor: Jesús Muñoz Rosas
-- Herramientas: MySQL 8.0
-- Descripción: Análisis completo de ventas con limpieza de
--              datos, consultas avanzadas, JOINs, subconsultas,
--              CTEs y window functions.

CREATE DATABASE IF NOT EXISTS retail_analysis;
USE retail_analysis;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name        VARCHAR(100),
    email       VARCHAR(100),
    region      VARCHAR(50),
    segment     VARCHAR(50)
);


CREATE TABLE products (
    product_id  INT PRIMARY KEY,
    product     VARCHAR(100),
    category    VARCHAR(50),
    cost        DECIMAL(10,2)
);

CREATE TABLE sales (
    id          INT PRIMARY KEY,
    date        DATE,
    customer_id INT,
    product_id  INT,
    quantity    INT,
    price       DECIMAL(10,2),
    salesperson VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
);


-- 2. LIMPIEZA DE DATOS


SET SQL_SAFE_UPDATES = 0;

-- Eliminar registros con datos críticos nulos
DELETE FROM sales
WHERE quantity IS NULL OR price IS NULL OR date IS NULL;

-- Normalizar categorías a mayúsculas
UPDATE products
SET category = UPPER(category);

-- Eliminar duplicados conservando el registro más reciente
DELETE s1 FROM sales s1
INNER JOIN sales s2
WHERE s1.id < s2.id
  AND s1.customer_id = s2.customer_id
  AND s1.date = s2.date
  AND s1.product_id = s2.product_id;

SET SQL_SAFE_UPDATES = 1;


-- 3. ANÁLISIS GENERAL


-- Total de ventas brutas
SELECT
    COUNT(*)                        AS total_transacciones,
    SUM(quantity * price)           AS venta_bruta_total,
    AVG(quantity * price)           AS ticket_promedio,
    MAX(quantity * price)           AS venta_maxima,
    MIN(quantity * price)           AS venta_minima
FROM sales;

-- 4. ANÁLISIS POR VENDEDOR CON JOIN


SELECT
    s.salesperson,
    COUNT(s.id)                     AS transacciones,
    SUM(s.quantity * s.price)       AS revenue,
    AVG(s.quantity * s.price)       AS ticket_promedio,
    SUM(s.quantity * p.cost)        AS costo_total,
    SUM(s.quantity * s.price)
        - SUM(s.quantity * p.cost)  AS margen_bruto
FROM sales s
INNER JOIN products p ON s.product_id = p.product_id
GROUP BY s.salesperson
ORDER BY revenue DESC;


-- 5. ANÁLISIS POR CATEGORÍA Y REGIÓN CON JOIN


SELECT
    p.category,
    c.region,
    COUNT(s.id)                     AS transacciones,
    SUM(s.quantity * s.price)       AS venta_neta,
    ROUND(
        SUM(s.quantity * s.price) /
        SUM(SUM(s.quantity * s.price)) OVER () * 100
    , 2)                            AS porcentaje_total
FROM sales s
INNER JOIN products  p ON s.product_id  = p.product_id
INNER JOIN customers c ON s.customer_id = c.customer_id
GROUP BY p.category, c.region
ORDER BY venta_neta DESC;


-- 6. TENDENCIA MENSUAL DE VENTAS


SELECT
    YEAR(date)                      AS anio,
    MONTH(date)                     AS mes,
    SUM(quantity * price)           AS ventas_mes,
    LAG(SUM(quantity * price))
        OVER (ORDER BY YEAR(date), MONTH(date))
                                    AS ventas_mes_anterior,
    ROUND(
        (SUM(quantity * price) -
         LAG(SUM(quantity * price))
             OVER (ORDER BY YEAR(date), MONTH(date))) /
         LAG(SUM(quantity * price))
             OVER (ORDER BY YEAR(date), MONTH(date)) * 100
    , 2)                            AS variacion_pct
FROM sales
GROUP BY YEAR(date), MONTH(date)
ORDER BY anio, mes;

-- 7. RANKING DE PRODUCTOS CON WINDOW FUNCTIONS


SELECT
    p.product,
    p.category,
    SUM(s.quantity)                 AS unidades_vendidas,
    SUM(s.quantity * s.price)       AS revenue,
    RANK() OVER (
        ORDER BY SUM(s.quantity * s.price) DESC
    )                               AS ranking_general,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(s.quantity * s.price) DESC
    )                               AS ranking_por_categoria
FROM sales s
INNER JOIN products p ON s.product_id = p.product_id
GROUP BY p.product, p.category
ORDER BY ranking_general;


-- 8. CLIENTES CON MAYOR VALOR — SUBCONSULTA


SELECT
    c.name,
    c.region,
    c.segment,
    ventas.total_compras,
    ventas.revenue
FROM customers c
INNER JOIN (
    SELECT
        customer_id,
        COUNT(*)            AS total_compras,
        SUM(quantity * price) AS revenue
    FROM sales
    GROUP BY customer_id
) ventas ON c.customer_id = ventas.customer_id
WHERE ventas.revenue > (
    SELECT AVG(revenue)
    FROM (
        SELECT customer_id, SUM(quantity * price) AS revenue
        FROM sales
        GROUP BY customer_id
    ) avg_table
)
ORDER BY ventas.revenue DESC;


-- 9. ANÁLISIS ACUMULADO CON CTE


WITH ventas_por_vendedor AS (
    SELECT
        salesperson,
        SUM(quantity * price)   AS revenue,
        COUNT(*)                AS transacciones
    FROM sales
    GROUP BY salesperson
),
totales AS (
    SELECT
        SUM(revenue)            AS revenue_total,
        SUM(transacciones)      AS transacciones_total
    FROM ventas_por_vendedor
)
SELECT
    v.salesperson,
    v.revenue,
    v.transacciones,
    ROUND(v.revenue / t.revenue_total * 100, 2)         AS pct_revenue,
    ROUND(v.transacciones / t.transacciones_total * 100, 2) AS pct_transacciones,
    SUM(v.revenue) OVER (
        ORDER BY v.revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                   AS revenue_acumulado
FROM ventas_por_vendedor v
CROSS JOIN totales t
ORDER BY v.revenue DESC;


-- 10. DETECCIÓN DE ANOMALÍAS — VENTAS FUERA DE RANGO


SELECT
    s.id,
    s.date,
    c.name AS cliente,
    p.product,
    s.quantity,
    s.price,
    s.quantity * s.price AS venta_total,
    stats.promedio,
    stats.desviacion,
    CASE
        WHEN s.quantity * s.price > stats.promedio + 2 * stats.desviacion
            THEN 'Venta inusualmente alta'
        WHEN s.quantity * s.price < stats.promedio - 2 * stats.desviacion
            THEN 'Venta inusualmente baja'
        ELSE 'Normal'
    END AS clasificacion
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
INNER JOIN products  p ON s.product_id  = p.product_id
CROSS JOIN (
    SELECT
        AVG(quantity * price)    AS promedio,
        STDDEV(quantity * price) AS desviacion
    FROM sales
) stats
WHERE s.quantity * s.price > stats.promedio + 2 * stats.desviacion
   OR s.quantity * s.price < stats.promedio - 2 * stats.desviacion
ORDER BY venta_total DESC;