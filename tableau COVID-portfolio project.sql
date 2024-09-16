/*
PORTFOLIO PROJECT 2/4
Queries used for tableau Project

*/

--1

--numeros globales
--Global numbers

SELECT
	  SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths,
	 SUM(NULLIF(new_deaths,0))/SUM(new_cases)*100 AS deathsNew_percentage
FROM coviddeaths
WHERE continent IS NOT null
AND new_cases IS NOT NULL
AND new_deaths IS NOT NULL
ORDER BY 1,2

-- Just a double check based off the data provided 
-- numbers are extremly closed so we will keep them - the second includes "International" location


--2.

--We take these  out as they are not include in the above queries and want to stay consistent
--European Union is part of Europe
SELECT
	continent, SUM(new_deaths) AS totalDeathCount
FROM coviddeaths
	WHERE continent IS NOT NULL
	AND location NOT IN ('World','European Union','International')
	AND new_deaths IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount DESC



--3.

SELECT
	location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
	--WHERE continent IS NOT NULL
	--AND new_deaths IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



--4.

SELECT
	location, population,date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
	WHERE continent IS NOT NULL
	AND total_cases IS NOT NULL
	AND total_cases <> 0
GROUP BY location, population,date
ORDER BY PercentPopulationInfected DESC






--Queries I originally had, but excluded some because it created too long of video 
-- Here only in case you want to check them out

--1.

SELECT
dea.continent,dea.location,dea.date, dea.population,
MAX(vac.total_vaccinations) AS rollingPeopleVaccinated
FROM 
CovidDeaths dea
	INNER JOIN
CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND total_vaccinations IS NOT NULL
AND total_vaccinations <> 0
GROUP BY dea.continent,dea.location,dea.date, dea.population
ORDER BY rollingPeopleVaccinated DESC


--2.
SELECT
	  SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths,
	  SUM(NULLIF(new_deaths,0))/SUM(new_cases)*100 AS deathspercentage
FROM coviddeaths
WHERE continent IS NOT null
AND new_cases IS NOT NULL
AND new_deaths IS NOT NULL
ORDER BY 1,2



--3.

--We take these  out as they are not include in the above queries and want to stay consistent
--European Union is part of Europe

SELECT
	location, SUM(new_deaths) AS totalDeathCount
FROM coviddeaths
	WHERE continent IS NOT NULL
	AND location NOT IN ('World','European Union','International')
	AND new_deaths IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC


--that's it

