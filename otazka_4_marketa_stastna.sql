-- ukol 4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
	--Odpověď 4.1 výsledek pro 10% nárůst cen oproti mzdám
WITH salary_data AS (
	SELECT
		year,
       	round(avg(value)::NUMERIC, 2) AS avg_salary
	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'salary'
	GROUP BY YEAR
),
salary_growth AS (
	SELECT 
		YEAR,
		round((avg_salary - LAG(avg_salary) OVER (ORDER BY year))
        	/ LAG(avg_salary) OVER (ORDER BY year), 2) AS salary_growth
   	FROM salary_data
),
prices_data AS (
	SELECT 
		YEAR,
		round(avg(value)::NUMERIC, 2) AS avg_price
   	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'prices'
	GROUP BY 
		year
),
prices_growth AS (
	SELECT
		YEAR,
		round((avg_price - LAG(avg_price) OVER (ORDER BY YEAR)) 
		/ LAG(avg_price) OVER (ORDER BY year), 2) AS prices_growth
   	FROM prices_data
)
SELECT 
	pg.YEAR,
	salary_growth,
	prices_growth,
    ROUND(pg.prices_growth - sg.salary_growth, 2) AS diff
FROM prices_growth pg
JOIN salary_growth sg ON pg.year = sg.YEAR
WHERE pg.prices_growth IS NOT NULL			--Rok 2006 je prvním rokem sledovaného období, nemá tedy předchozí rok, 
	AND sg.salary_growth IS NOT NULL		--se kterým by se mohl porovnat,  a proto se v přehledu neukáže.
	AND pg.prices_growth - sg.salary_growth >= 0.1
ORDER BY year
;

	-- Odpověď 4.2 Dotaz, který vrátí výsledek pro 5% hladinu významnosti (ve statistice často používanou)
WITH salary_data AS (
	SELECT
		year,
       	round(avg(value)::NUMERIC, 2) AS avg_salary
	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'salary'
	GROUP BY YEAR
),
salary_growth AS (
	SELECT 
		YEAR,
		round((avg_salary - LAG(avg_salary) OVER (ORDER BY year))
        	/ LAG(avg_salary) OVER (ORDER BY year), 2) AS salary_growth
   	FROM salary_data
),
prices_data AS (
	SELECT 
		YEAR,
		round(avg(value)::NUMERIC, 2) AS avg_price
   	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'prices'
	GROUP BY 
		year
),
prices_growth AS (
	SELECT
		YEAR,
		round((avg_price - LAG(avg_price) OVER (ORDER BY YEAR)) 
		/ LAG(avg_price) OVER (ORDER BY year), 2) AS prices_growth
   	FROM prices_data
)
SELECT 
	pg.YEAR,
	salary_growth,
	prices_growth,
    ROUND(pg.prices_growth - sg.salary_growth, 2) AS diff
FROM prices_growth pg
JOIN salary_growth sg ON pg.year = sg.YEAR
WHERE pg.prices_growth IS NOT NULL
	AND sg.salary_growth IS NOT NULL
	AND pg.prices_growth - sg.salary_growth >= 0.05
ORDER BY year
;