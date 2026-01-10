# Úvod do projektu

## Projekt byl vypracován na základě následujícího zadání:

Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují **dostupnost základních potravin široké veřejnosti**. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás **připravit robustní datové podklady**, ve kterých bude možné vidět **porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období**.

Jako dodatečný materiál **připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období**, jako primární přehled pro ČR.


## Výstupy z projektu

Pomozte kolegům s daným úkolem. Výstupem by měly být **dvě tabulky v databázi**, ze kterých se požadovaná data dají získat. Tabulky pojmenujte *t_jmeno_prijmeni_project_SQL_primary_final* (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a *t_jmeno_prijmeni_project_SQL_secondary_final* (pro dodatečná data o dalších evropských státech).

Dále **připravte sadu SQL**, které z vámi připravených tabulek získají datový podklad k zodpovězení na vytyčené otázky. Pozor, otázky/hypotézy mohou vaše výstupy podporovat i vyvracet! Záleží na tom, co říkají data.

# Postup tvoření tabulek

## Postup: Tabulka mezd a cen

Pro vytvoření této tabulky jsem vycházela z dat hlavních zdrojových tabulek *czechia_price* a *czechia_payroll* a dále dalších k nim přidružených číselníků.

1. Nejprve jsem si zjistila, kterým rokem data v obou tabulkách začínají a končí. Použila jsem k tomu funkce *MIN* a *MAX* (viz posstup pod dotazem na vytvoření tabulky). V tabulce *czechia_price* bylo rozmezí let menší (2006-2018), proto je toto časové období použito pro všechny další výpočty.
2. V tabulce *czechia_payroll* jsem podle sloupce *value_type_code* zjistila, že kromě údajů o výši mezd se v tabulce nachází také údaje o počtu zaměstnanců, proto jsem pro další postup použila *value_type_code = 5958*, což vybralo pouze údaje o mzdách.
3. Dále jsem v tabulce *czechia_payroll* narazila na chybná data, kdy pro *unit_code = 200*, který se nacházel u všech mezd, bylo v číselníku *czechia_payroll_unit* name *tis.osob* a u počtu zaměstnanců naopak bylo *Kč*. Proto jsem ve výsledné tabulce použila *UPDATE TABLE*, kde jsem údaj změnila na Kč.
4. Z tabulky *czechia_payroll* jsem také vyfiltrovala data na základě sloupce *calculation_code*, kde jsem použila filtr na *calculation_code = 100*, což v číselníku *czechia_payroll_calculation* odpovídá fyzickým mzdám, oproti přepočteným. Zvolila jsem fyzické mzdy, které odpovídají skutečné mzdě za výši úvazku, který daný zaměstnanec opravdu měl. Ačkoli obě varianty mohou do jisté míry zkreslit výsledek, je tato volba doporučena i na stránkách ČSSZ v článku o výpočtu průměrné mzdy, viz: <https://www.mpsv.cz/statistika-prumerne-mzdy>.
5. Protože údaje o regionech jsou obsaženy pouze v *czechia_price* a nebyly předmětem analýzy, informace o nich jsem nepoužila a ceny jsem použila zprůměrované.
6. Data z číselníků jsem připojila pomocí JOIN na základě společných klíčů *code*.
7. Pro vytvoření finální tabulky jsem pro spojení dat z *czechia_payroll* a *czechia_price* použila *UNION ALL*, protože *JOIN* by duplikoval data. Abych mohla použít *UNION ALL*, přetypovala jsem vybrané sloupce u obou tabulek na stejné datové typy, aby bylo možné sloučení provést. *Timestamp* v *czechia_price* byl proto převeden na rok.
8. Po vytvoření tabulky jsem provedla *UPDATE TABLE*, abych nastavila jednotku na měnu, viz bod č.3.

## Postup: Tabulka informací o evropských zemích

Pro vytvoření této tabulky jsem vycházela z dat zdrojových tabulek *economies* a *countries*.

1. Prostudováním tabulek jsem zjistila, že v tabulce *countries* se nacházejí dva odlišné sloupce *country* a *continent*, které umožní vyfiltrovat pouze země Evropy, zatímco v tabulce *economies* jsou země, kontinenty a jiná geografická členění všechny ve sloupci *country*.
2. Proto jsem si v tabulce *country* vyfiltrovala pouze země, kde *continent = 'Europe'*, a pomocí společného klíče *country* jsem provedla *LEFT JOIN* a připojila údaje z tabulky *economies* jen pro vybrané země.
3. Abych zajistila, že se časové období této tabulky bude shodovat s tabulkou mezd a cen, připojila jsem pomocí *JOIN MIN(year) a MAX(year)* z tabulky mezd a cen. Stačilo by použít statický filtr *WHERE year BETWEEN 2006 and 2018*, ale toto dynamické propojení zajistí správnost dat, kdyby se období v první tabulce změnilo.

# Výzkumné otázky a odpovědi

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
- Mzdy v průběhu sledovaného období, mezi lety 2006 a 2018, **nerostly ve všech odvětvích** *(Odpověď 1.1)*. Z 19 analyzovaných odvětví pouze v 5 odvětvích rostly mzdy po celé sledované období.
- Odvětví, ve kterých **mzdy rostly po celou dobu** *(Odpověď 1.2)*:
  - administrativní a podpůrné činnosti
  - doprava a skladování
  - zdravotní a sociální péče
  - zpracovatelský průmysl a ostatní činnosti
- Odvětví s **nejčastějším poklesem mezd** *(Odpověď 1.3)*:
  - těžba a dobývání
- Top 3 roky, ve kterých byl **pokles mezd v nevětším počtu odvětví** *(Odpověď 1.4)*:
  1. 2013  (10 odvětví)
  2. 2009  (4 odvětví)
  3. 2010  (3 odvětví)

**2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**
- Množství mléka a chleba, které je možné koupit za průměrnou mzdu v **roce 2006** (první srovnatelné období):
  - 1408,75 l mléka
  - 1261,93 kg chleba
- Množství mléka a chleba, které je možné koupit za průměrnou mzdu v **roce 2018** (poslední srovnatelné období):
  - 1613,53 l mléka
  - 1319,32 kg chleba

**3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuálně meziroční nárůst)?**
- Kategorie potravin, která zdražuje nejpomaleji, je **cukr krystalový** - jeho percentuální meziroční nárust je -1,92 %.

**4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**
- Pro rozdíl nárůstu **větší než 10 % takový rok neexistuje** *(Odpověď 4.1)*. Nicméně hranice 10 % je hodně striktní.
- Pokud bychom hranici významnosti snížili na 5 %, což je často používaná hranice ve statistice, vyjde nám **rok 2013 se 7% rozdílem mezi nárůstem cen a mezd při hranici 5%** *(Odpověď 4.2)*. Je to stejný rok, který v otázce 1 vyšel jako rok s největším počtem odvětví, ve kterých klesala mzda.  

**5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin ve stejném nebo následujícím roce výraznějším růstem?**
- Pozn. Jako výrazný růst byla pro účely této analýzy stanovena hladina 5 % pro HDP, ceny potravin i mzdy.
- Podle výsledků analýzy **neplatí vždy, že pokud HDP vzroste výrazněji v jednom roce, vzrostou výrazněji ceny potravin nebo mzdy ve stejném nebo následujícím roce**.
- Během sledovaného období nastal růst HDP o 5 % a víc ve třech letech a vliv na růst cen potravin a mzdy byl následující:
  - V roce 2007 vzrostly výrazněji ceny potravin i mzdy ve stejném i následujícím roce
  - V roce 2015 nevzrostly ani ceny potravin ani mzdy ve stejném ani v následujícím roce
  - V roce 2017 vzrostly výrazněji ceny potravin i mzdy ve stejném i následujícím roce
- Zároveň byly i roky, během kterých HPD výrazně nerostlo nebo dokonce klesalo a ceny potravin nebo mzdy výrazně rostly.
- Z toho vyplývá, že výrazný růst HDP nemá přímý vliv na změny ve mzdách a cenách potravin.
