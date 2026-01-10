--2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první 
--a poslední srovnatelné období v dostupných datech cen a mezd?
	--Odpvěď:
WITH salary_data AS (
	SELECT
		YEAR,
		round(avg(value)::numeric, 2) AS avg_salary
	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'salary'
	GROUP BY YEAR
),
prices_data AS (
	SELECT 
		YEAR,
		category,
		round(avg(value)::NUMERIC, 2) AS avg_price,
		unit_value,
		unit
	FROM t_marketa_stastna_project_sql_primary_final
	WHERE category_code IN ('111301', '114201')
	GROUP BY
		YEAR,
		category,
		unit_value,
		unit
),
years_data AS (
    SELECT MIN(sd.year) AS first_year,
           MAX(sd.year) AS last_year
    FROM salary_data sd
    JOIN prices_data pd ON sd.year = pd.YEAR
)  
SELECT 
	sd.YEAR,
	category AS price_category,
	ROUND(sd.avg_salary / pd.avg_price, 2) AS quantity,
	pd.unit
FROM salary_data sd
JOIN prices_data pd ON sd.YEAR = pd.YEAR
JOIN years_data yd ON sd.YEAR IN (yd.first_year, yd.last_year)
ORDER BY 
	price_category,
	sd.year
;