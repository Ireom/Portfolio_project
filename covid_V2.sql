SELECT *
FROM "Covid_deaths"
ORDER BY 3,4;



SELECT *
FROM "Covid_vaccination"
ORDER BY 3,4;


----SELECT DATA THAT I WILL BE USING FOR THIS PROJECT---

SELECT location, date, total_cases, new_cases, total_deaths,
population
FROM "Covid_deaths"
ORDER BY 1,2

---I WILL BE LOOKING AT THE TOTAL CASES VS TOTAL DEATHS
SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACTED COVID IN AFRICA---

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 AS deathpercentage
FROM "Covid_deaths"
WHERE location LIKE 'Africa'
ORDER BY 1,2

----LOOKING AT THE TOTAL CASES VS THE POPULATION
---SHOWS WHAT PERCENTAGE OF NIGERIA POPULATION GOT COVID---
SELECT population, location, date, total_cases, (total_cases/population)* 100 AS totalpercentage
FROM "Covid_deaths"
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2


-----LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION----

SELECT population, location, MAX(total_cases) AS highestinfectioncount,
MAX((total_cases/population))* 100 AS populationinfected
FROM "Covid_deaths"
GROUP BY population, location
ORDER BY populationinfected DESC


-----SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION----
SELECT location,  MAX(CAST(total_deaths AS int)) AS highestdeathcount
FROM "Covid_deaths"
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highestdeathcount DESC


---LET'S BREAK THINGS DOWN BY CONTINENT---
SELECT continent,  MAX(CAST(total_deaths AS int)) AS highestdeathcount
FROM "Covid_deaths"
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highestdeathcount DESC


SELECT continent,  MAX(CAST(total_deaths AS int)) AS highestdeathcount
FROM "Covid_deaths"
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highestdeathcount DESC


-----SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION--
SELECT continent,  MAX(CAST(total_deaths AS int)) AS highestdeathcount
FROM "Covid_deaths"
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highestdeathcount DESC


----GLOBAL NUMBERS--work on this
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT)) /SUM(new_cases)* 100 AS deathpercentage
FROM "Covid_deaths"
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT)) /SUM(new_cases)* 100 AS deathpercentage
FROM "Covid_deaths"
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT *
FROM "Covid_vaccination"


-----LOOKING AT POPULATION VS VACCINATIONS
SELECT *
FROM "Covid_deaths" dea
JOIN "Covid_vaccination" vac
ON dea.location = vac.location
AND dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM "Covid_deaths" dea
JOIN "Covid_vaccination" vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location)
FROM "Covid_deaths" dea
JOIN "Covid_vaccination" vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS rollingpeoplevaccinated
FROM "Covid_deaths" dea
JOIN "Covid_vaccination" vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---USE A CTE
WITH popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS rollingpeoplevaccinated
FROM "Covid_deaths" dea
JOIN "Covid_vaccination" vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *
FROM popvsvac;

WITH popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS rollingpeoplevaccinated
FROM "Covid_deaths" dea
JOIN "Covid_vaccination" vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac;

----TEMP TABLE---

CREATE TEMP TABLE percentpopulationvaccinated
(
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevaccinated NUMERIC
);

INSERT INTO percentpopulationvaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INTEGER)) OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM
    "Covid_deaths" dea
    JOIN "Covid_vaccination" vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

SELECT *, (rollingpeoplevaccinated / population) * 100
FROM percentpopulationvaccinated;

----CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS---
CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) AS rollingpeoplevaccinated
FROM "Covid_deaths" dea
JOIN "Covid_vaccination" vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM percentpopulationvaccinated;



