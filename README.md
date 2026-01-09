# Úvod do projektu

## Projekt byl vypracován na základě následujícího zadání:

Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují **dostupnost základních potravin široké veřejnosti**. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás **připravit robustní datové podklady**, ve kterých bude možné vidět **porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období**.

Jako dodatečný materiál **připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období**, jako primární přehled pro ČR.


## Výstupy z projektu

Pomozte kolegům s daným úkolem. Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat, Tabulky pojmenujte *t_jmeno_prijmeni_project_SQL_primary_final* (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a *t_jmeno_prijmeni_project_SQL_secondary_final* (pro dodatečná data o dalších evropských státech).

Dále připravte sadu SQL, které z vámi připravených tabulek získají datový podklad k zodpovězení na vytyčené otázky. Pozor, otázky/hypotézy mohou vaše výstupy podporovat i vyvracet! Záleží na tom, co říkají data.

# Postup tvoření tabulek

## Tabulka mezd a cen

Pro vytvoření této tabulky jsem jsem vycházela z dat hlavních zdrojových tabulek *czechia_price* a *czechia_payroll* a dále dalších k nim přidružených číselníků.

1. Nejprve jsem si zjistila, kterým rokem data v obou tabulkách začínají a končí. Použila jsem k tomu funkce *MIN* a *MAX*. V tabulce *czechia_price* bylo rozmezí let menší (2006-2018), proto jsem se rozhodla použít toto časové období pro všechny další výpočty.
2. V tabulce *czechia_payroll* jsem podle sloupce *value_type_code* zjistila, že kromě údaj
