--PORTFOLIO PROJECT - SQL DATA EXPLORATION - PROJECT 1/4

-- CREATE TABLE 'CovidVaccinations'
-- CREATE TABLE 'CovidDeaths'

-- Observando la data completa
-- Looking whole data
SELECT
	*
FROM coviddeaths
WHERE continent IS NOT null
order by 3,4
--

-- Vamos a seleccionar la data que vamos a estar usando 
-- Let's seleccion data that we're going to be using
SELECT
	location, date, total_cases, new_cases, total_Deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
AND total_cases IS NOT NULL
ORDER BY 1,2,3


--Observamos 'total_cases' vs 'total_deaths'
--Looking at 'total_cases' vs 'total_deaths'

SELECT
	location, date, total_cases, total_Deaths, (total_Deaths/NULLIF(total_cases,0))*100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT null
AND total_cases IS NOT NULL
AND total_cases <> 0
AND location ilike 'per%'
ORDER BY 1,2


-- Paises con la infeccion más alta respecto a su población 
-- Countries with highest infection per population

SELECT
	location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationinfected
FROM coviddeaths
--WHERE location ilike '%states'
ORDER BY 1,2


-- Que países tienen las tasas de infeccion mas altas
-- Which countries with highest percent infection per population

SELECT
	location, population, MAX(total_cases) As total_InfectionCases,
	MAX((total_cases/population))*100 AS infectionpercentage_per_country
FROM coviddeaths
WHERE total_cases IS NOT NULL
AND continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


--Mostrando los países con la cantidad de muertes más alta por poblacion 
--Showing countries with highest death count per population
SELECT
	location, --population 
	MAX(total_Deaths) As Total_Deaths_Count
	--MAX(total_Deaths)/population*100 AS Deathpercentage_per_country
FROM coviddeaths
WHERE continent IS NOT null
AND total_Deaths IS NOT NULL
GROUP BY location--, population
ORDER BY 2 DESC


--Observamos los datos por continentes
--Showing the dates per continents

--Mostrando los continentes con la cantidad de muerte mas alta por poblacion
--showing continents with highest deaths count per population
SELECT
	continent,
	MAX(total_Deaths) As TotalDeaths_COUNT_per_continent
FROM coviddeaths
WHERE Continent IS NOT NULL
AND total_Deaths IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--numeros globales
--Global numbers

SELECT
	  SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths,
	 SUM(NULLIF(new_deaths,0))/SUM(new_cases)*100 AS deathsNew_percentage
FROM coviddeaths
WHERE continent IS NOT null
AND new_cases IS NOT NULL
AND new_deaths IS NOT NULL
--AND date < '03/05/2021'  
--GROUP by date
ORDER BY 1,2

--Hasta junio de 2024
-- El total de casos nuevos en el mundo 775'888'147
-- total de nuevas muertes 6'990'824
-- porcentaje de muertes nuevas 0.90 %


--Uniendo las dos tablas : 'CovidDeaths' y 'CovidVaccinations'
--Join two tables: 'CovidDeaths' and 'CovidVaccinations'

-- Observamos la poblacion total vs la vacunación
--Looking at total population vs vaccinations

SELECT
dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS new_vaccinations_per_location_acumulate,
(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)/dea.population)*100 AS vaccinations_per_habitant
FROM 
CovidDeaths dea
	INNER JOIN
CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND dea.date < '01/05/2021'
AND new_vaccinations IS NOT NULL
--AND dea.location = 'Peru'
ORDER BY 2,3 ASC

--Creamos una tabla temporal con 'WITH'
--Create a temporal table to 'WITH'

WITH PopvsVac (continent,location, date, population, new_vaccinations,new_vaccinations_per_location_acumulate, vaccinations_percentage_habitants)
AS (

	SELECT
	dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS new_vaccinations_per_location_acumulate,
	(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)/dea.population)*100 AS vaccinations_percentage_habitants	
FROM 
CovidDeaths dea
	INNER JOIN
CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	--AND dea.date < '01/05/2021'
	AND new_vaccinations IS NOT NULL
--AND dea.location = 'Peru'
ORDER BY 2,3

)

SELECT
	*
FROM PopvsVac
-- GUARDAMOS LA DATA ANALIZADA: 'PercentagePopulationVaccinated'
-- SAVE ANALYZED DATA: 'PercentagePopulationVaccinated'

--CREAMOS UNA NUEVA TABLA SOLO CON LOS DATOS ANALIZADOS
--CREATE A NEW TABLE WITH DATA ANALYZED

--ELIMINAMOS LA TABLA SI EXISTE
--DELETE TABLE IF EXISTS
DROP TABLE IF EXISTS PercentagePopulationVaccinated
--CREAMOS LA NUEVA TABLA
--CREATE NEW TABLE
CREATE TABLE PercentagePopulationVaccinated(

continent VARCHAR(20), 
location VARCHAR(100), 
date DATE, 
population NUMERIC, 
new_vaccinations NUMERIC, 
new_vaccinations_per_location_acumulate NUMERIC,
vaccinations_percentage_habitants NUMERIC
)


--COPIAMOS LOS DATOS ANALIZADOS A LA NUEVA TABLA
--COPY ANALYZED DATA TO NEW TABLE
COPY PercentagePopulationVaccinated 
FROM 'C:\Users\LENOVO\Desktop\PORTAFOLIO\COVID\PercentagePopulationVaccinated.csv'
DELIMITER ','
CSV HEADER

--OBSERVANDO LA NUEVA TABLA 
--LOOKING AT NEW TABLE
SELECT
	*
FROM PercentagePopulationVaccinated

--SI DESEAS LIMPIAR LA TABLA AGREGADA
--IF YOU WANT CLEANING THE NEW TABLE
DROP TABLE IF EXISTS PercentagePopulationVaccinated 


--that's it

