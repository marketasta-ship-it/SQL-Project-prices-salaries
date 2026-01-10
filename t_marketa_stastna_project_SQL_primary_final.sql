-- Finální tabulku pro mzdy a ceny jsem vytvořila pomocí UNION ALL - zabrání se tím duplikaci dat.
-- v obou tabulkách byly přetypovány hodnoty ve sloupcích, aby ve výsledné tabulce byly stejné
CREATE TABLE t_marketa_stastna_project_SQL_primary_final AS ( 
	(SELECT 
		payroll_year AS year,
		'salary' AS metric_type,
		round(avg(cp.value)::NUMERIC, 2) AS value,
		NULL::numeric(10, 2) AS unit_value,
		cpu.name::varchar(50) AS unit,
		industry_branch_code::varchar(50) AS category_code,
		cpib.name::varchar(255) AS category		
	FROM czechia_payroll cp
	JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
	JOIN czechia_payroll_unit cpu ON cp.unit_code = cpu.code
	WHERE value_type_code = 5958
		AND calculation_code = 100
		AND payroll_year >= 2006
		AND payroll_year <= 2018
	GROUP BY
		payroll_year,
		cpu.name,
		industry_branch_code,
		cpib.name
	ORDER BY 
		industry_branch_code,
		payroll_year
)
UNION ALL
(
	SELECT 
		date_part('year', cpri.date_from) AS YEAR,
		'prices' AS metric_type,
		round(avg(cpri.value)::NUMERIC, 2) AS value,
		cpric.price_value::numeric(10, 2) AS unit_value,
		cpric.price_unit::varchar(50) AS unit,
		cpri.category_code::varchar(50) AS category_code,
		cpric.name::varchar(255) AS category
	FROM czechia_price cpri
	JOIN czechia_price_category cpric ON cpri.category_code = cpric.code
	GROUP BY 
		date_part('year', cpri.date_from),
		cpric.price_value,
		cpric.price_unit,
		cpri.category_code,
		cpric.name
	ORDER BY
		cpric.name::varchar(255),
		date_part('year', cpri.date_from)
));

		
SELECT *
FROM t_marketa_stastna_project_SQL_primary_final;


--> provedení změny jednotek pro mzdy - opravení chyby
UPDATE t_marketa_stastna_project_SQL_primary_final
SET unit = 'Kč'
WHERE metric_type = 'salary';

--- Zde jsou mezikroky, kterými jsem došla k vytvoření tabulky
--> zjistit, pro jake obdobi jsou data
SELECT 
	min(date_from) AS min_date_from, -- = rok 2006
	max(date_from) AS max_date_from, --	= rok 2018
	min(date_to) AS min_date_to,
	max(date_to) AS max_date_to
FROM czechia_price;

SELECT 
	min(payroll_year),		-- = rok 2000
	max(payroll_year)		-- = rok 2021
FROM czechia_payroll
WHERE value_type_code = 5958;

--> takže se data omezí jen od 2006 do 2018 - mají tam byt srovnatelná období

SELECT industry_branch_code,
	min(payroll_year),
	max(payroll_year)
FROM czechia_payroll
WHERE value_type_code = 5958
	AND payroll_year BETWEEN 2006 AND 2018
GROUP BY industry_branch_code
ORDER BY industry_branch_code;

--> ověření, že ve všech odvětvích jsou data za všechny roky

