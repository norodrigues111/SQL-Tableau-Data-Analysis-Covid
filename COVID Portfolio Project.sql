
SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations
WHERE Continent IS NOT NULL
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2

-- Total Cases Vc Total Deaths by Country
--Indicates the probability of mortality upon contracting COVID-19 in the United States.
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2

--Shows what percentage of the population got COVID-19
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
ORDER BY 1,2

--Shows what percentage of the population got COVID-19
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
ORDER BY 1,2

--Shows countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

-- Shows Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS int)) as TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathsCount DESC

-- Shows breakdown of total deaths by Continent
SELECT Location, MAX(CAST(total_deaths AS int)) as TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NULL
GROUP BY Location
ORDER BY TotalDeathsCount DESC

SELECT Continent, MAX(CAST(total_deaths AS int)) as TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathsCount DESC

--Shows the breakdown globaly
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int))as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentageGlobaly
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2

--Shows the TOTAL CASES globaly
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int))as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentageGlobaly
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL 
ORDER BY 1,2

-- Join tables to compare Deaths Vs Vaccinations data
SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Shows the total Population Vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Shows rolling count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Shows Rolling People Vaccinated Count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE: Shows Rolling People Vaccinated Count Per Population
WITH PopvsVac(Continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creates view for store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3