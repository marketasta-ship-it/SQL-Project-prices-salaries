-- ukol č. 1	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
	--Rok 2006 je prvním rokem sledovaného období, nemá tedy předchozí rok, se kterým by se mohl porovnat, a proto se v přehledu neukáže.

	--Odpověď 1.1. Tento dotaz zobrazí rozdíl mezd oproti předchozímu roku pro každé odvětví. 
	WITH salary_data AS (
	SELECT
    	year,
    	category_code,
    	category,
    	avg(value) AS avg_salary
	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'salary'
	GROUP BY 
		year,
    	category_code,
    	category
),
salary_diff AS (
	SELECT
		YEAR,
		category,
		avg_salary,
		avg_salary - LAG(avg_salary) OVER (PARTITION BY category_code
        	ORDER BY year) AS salary_diff
FROM salary_data
)
SELECT 
	category,
	YEAR,
	avg_salary,
	salary_diff
FROM salary_diff
WHERE salary_diff IS NOT NULL
ORDER BY category, year;

	--Odpověď 1.2 tento dotaz zobrazí odvětví, ve kterých za celé sledované období nedošlo k poklesu mezd
WITH salary_data AS (
	SELECT
    	year,
    	category_code,
    	category,
    	avg(value) AS avg_salary
	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'salary'
	GROUP BY 
		year,
    	category_code,
    	category
),
salary_diff AS (
	SELECT
		YEAR,
		category,
		avg_salary,
		avg_salary - LAG(avg_salary) OVER (PARTITION BY category_code ORDER BY YEAR
		) AS salary_diff
FROM salary_data
)
SELECT 
	category,
	min(salary_diff) AS min_salary_diff
FROM salary_diff
WHERE salary_diff IS NOT NULL
GROUP BY category
HAVING MIN(salary_diff) >= 0
ORDER BY category;

-- Odpověď 1.3 tento dotaz zobrazí roky, kdy bylo nejvíc poklesů mezd
WITH salary_data AS (
	SELECT
    	year,
    	category_code,
    	category,
    	avg(value) AS avg_salary
	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'salary'
	GROUP BY 
		year,
    	category_code,
    	category
),
salary_diff AS (
	SELECT
		YEAR,
		category,
		avg_salary,
		avg_salary - LAG(avg_salary) OVER (PARTITION BY category_codeORDER BY year
    	) AS salary_diff
FROM salary_data
)
SELECT 
	category,
	YEAR,
	salary_diff,
	count(salary_diff) OVER (PARTITION BY category) AS salary_decrease_per_category_total	
FROM salary_diff
WHERE salary_diff IS NOT NULL
	AND salary_diff < 0
ORDER BY 
	category,
	YEAR;

-- Odpověď 1.4 tento dotaz zobrazí, ve kterých letech nejčastěji docházelo k poklesu mezd
WITH salary_data AS (
	SELECT
    	year,
    	category_code,
    	category,
    	avg(value) AS avg_salary
	FROM t_marketa_stastna_project_sql_primary_final
	WHERE metric_type = 'salary'
	GROUP BY 
		year,
    	category_code,
    	category
),
salary_diff AS (
	SELECT
		YEAR,
		category,
		avg_salary,
		avg_salary - LAG(avg_salary) OVER (PARTITION BY category_code ORDER BY year
    	) AS salary_diff
FROM salary_data
)
SELECT 
	category,
	YEAR,
	salary_diff,
	count(salary_diff) OVER (PARTITION BY year) AS high_salary_desrease	
FROM salary_diff
WHERE salary_diff IS NOT NULL
	AND salary_diff < 0
ORDER BY high_salary_desrease desc;
