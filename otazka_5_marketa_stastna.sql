--5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
--projeví se to na cenách potravin ve stejném nebo následujícím roce výraznějším růstem?
	
	--Odpově:
	--Pozn.: Rok 2006 je prvním rokem sledovaného období, nemá tedy předchozí rok, se kterým by se mohl porovnat, a proto se v přehledu neukáže.

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
		round ((avg_salary - LAG(avg_salary) OVER (ORDER BY year))			--takto postavená WINDOW FUNCTION ukáže relativní meziroční rozdíl,
        	/ LAG(avg_salary) OVER (ORDER BY year), 2) AS salary_growth		--který se po vynásobení 100 dá převédz na procenta
   	FROM salary_data
),
prices_data AS (
	SELECT 
		YEAR,
		round(avg(value)::NUMERIC, 2) AS avg_price
   	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'prices'
	GROUP BY year
),
prices_growth AS (
	SELECT
		YEAR,
		round((avg_price - LAG(avg_price) OVER (ORDER BY YEAR)) 		 
		/ LAG(avg_price) OVER (ORDER BY year), 2) AS prices_growth		
   	FROM prices_data
),
gdp_data AS (
	SELECT 
		YEAR,
		round(avg(gdp)::NUMERIC, 2) AS avg_gdp
	FROM t_marketa_stastna_project_SQL_secondary_final
	WHERE country = 'Czech Republic'
	GROUP BY year
),
gdp_growth AS (
	SELECT
		YEAR,
		round((avg_gdp - LAG(avg_gdp) OVER (ORDER BY YEAR)) 
		/ LAG(avg_gdp) OVER (ORDER BY year), 2) AS gdp_growth
   	FROM gdp_data
)
SELECT
	sg.year,
	sg.salary_growth,
	pg.prices_growth,
	gg.gdp_growth,
	CASE WHEN gg.gdp_growth >= 0.05 AND (sg.salary_growth >= 0.05 OR pg.prices_growth >= 0.05) THEN 'affects'
		ELSE 'doesnt affect'
	END AS gdp_affects_growth_same_year,
	CASE
    WHEN LAG(gg.gdp_growth) OVER (ORDER BY sg.year) >= 0.05
         AND (sg.salary_growth >= 0.05 OR pg.prices_growth >= 0.05)
    THEN 'affects'
    ELSE 'doesnt affect'
	END	AS gdp_affects_growth_following_year
FROM salary_growth sg
LEFT JOIN prices_growth pg ON sg.YEAR = pg.YEAR
LEFT JOIN gdp_growth gg ON sg.YEAR = gg.YEAR
WHERE sg.salary_growth IS NOT NULL				
  	AND pg.prices_growth IS NOT NULL
  	AND gg.gdp_growth IS NOT NULL;