--3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuálně meziroční nárůst)?
	--Odpověď:
WITH price_growth AS (
	SELECT
   		YEAR,
		category,
    	ROUND((value - LAG(value) OVER (PARTITION BY category ORDER BY year
        	)) / LAG(value) OVER (PARTITION BY category ORDER BY year
 			), 4) AS percent_growth
FROM  t_marketa_stastna_project_sql_primary_final
WHERE metric_type = 'prices'
),
avg_growth AS (
	SELECT 
		category,
		ROUND(AVG(percent_growth), 4) AS avg_percent_growth
	FROM price_growth
	WHERE percent_growth IS NOT NULL 
	GROUP BY
		category
)
SELECT
	category,
	avg_percent_growth
FROM avg_growth
ORDER BY avg_percent_growth
LIMIT 1;