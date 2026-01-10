--tabulka pro data o Evropskych statech
--Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států 
--ve stejném období, jako primární přehled pro ČR.

CREATE TABLE t_marketa_stastna_project_SQL_secondary_final AS (
WITH countries_data AS (
	SELECT 
		country
FROM countries
	WHERE continent = 'Europe'
),
economies_data AS (
	SELECT 
		country,
		YEAR,
		gdp,
		gini,
		population
	FROM economies
),
common_years AS (
    SELECT
        MIN(year) AS first_year,
        MAX(year) AS last_year
    FROM t_marketa_stastna_project_sql_primary_final
)
SELECT 
	cd.country,
	ed.YEAR,
	ed.gdp,
	ed.gini,
	ed.population
FROM countries_data cd
LEFT JOIN economies_data ed ON cd.country = ed.country
JOIN common_years cy ON ed.YEAR BETWEEN cy.first_year AND cy.last_year
ORDER BY country, ed.YEAR
);

SELECT *
FROM t_marketa_stastna_project_SQL_secondary_final;
