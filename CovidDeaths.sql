--SELECT *
--FROM PortfolioProjects..coviddeath
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProjects..covidvaccinations
--ORDER BY 3,4

SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM 
	PortfolioProjects..coviddeath
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT 
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM 
	PortfolioProjects..coviddeath
WHERE location = 'Vietnam'
ORDER BY 1,2

--Looking at total cases vs population
--show what percentage of population got covid

SELECT 
	location, date, population, total_cases, (total_cases/population)*100 AS GotCovidPercentage
FROM 
	PortfolioProjects..coviddeath
WHERE location = 'Vietnam'
ORDER BY 1,2

--Looking at contries with highest infection rate compared to population

SELECT 
	location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM 
	PortfolioProjects..coviddeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--showing the countries with highest death count per population

SELECT 
	location, population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
	PortfolioProjects..coviddeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT 
	continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
	PortfolioProjects..coviddeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing the continent with highest death count per population

SELECT 
	continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
	PortfolioProjects..coviddeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT 
	SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeath, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM 
	PortfolioProjects..coviddeath
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date

--Looking at total population vs vaccinations

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM
	coviddeath DEA JOIN covidvaccinations VAC 
	ON 
		DEA.location = VAC.location AND DEA.date = VAC.date
ORDER BY 2,3

---

WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProjects..coviddeath DEA
	JOIN PortfolioProjects..covidvaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE 
	DEA.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
) 
INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProjects..coviddeath DEA
	JOIN PortfolioProjects..covidvaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE 
	DEA.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated
WHERE location = 'Vietnam'
ORDER BY date DESC

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProjects..coviddeath DEA
	JOIN PortfolioProjects..covidvaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE 
	DEA.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
ORDER BY RollingPeopleVaccinated DESC
