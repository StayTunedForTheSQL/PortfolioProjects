

																-- To view all data --

SELECT * 
FROM PortfolioProject..CovidDeaths

Select *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4


														-- Selecting Data that we are going to be using --

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL
AND new_cases IS NOT NULL
AND total_deaths IS NOT NULL
ORDER BY 1,2


														-- Looking at total cases versus total deaths --
												-- Shows likelihood of dying if you contract covid in your country --
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
WHERE location LIKE '%states%'
order by 1,2


													-- Looking at Total Cases vs Population --
												  --Shows what Percentage of population had Covid--
Select location, date, population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
WHERE location LIKE '%states%'
order by 1,2



										-- Looking at countries with highest infection rates compared to population --

Select location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc


												-- Showing Countries with Highest Death Count per Population -- 

Select location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount desc



												-- Continent with Highest Death Count by Population --

Select continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS not NULL
GROUP BY continent
order by TotalDeathCount desc


														-- Global Count -- 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


													-- Total Population vs Vaccinations -- 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
and new_vaccinations IS NOT NULL
order by 2,3

													-- Total Population with Reported Vaccinations --
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
and new_vaccinations IS NOT NULL
order by 2,3


													--	Total Population vs Vaccinations --

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER
(PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
and new_vaccinations IS NOT NULL
order by 2,3

														-- USING CTE --

WITH PopcVsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER
(PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
and new_vaccinations IS NOT NULL
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated / population) * 100
FROM PopcVsVac



													-- Using Temp Table -- 
DROP TABLE if EXISTS #PercentPoulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locatrion nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER
(PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
and new_vaccinations IS NOT NULL
--order by 2,3

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated


								
													
													-- Creating Views to store data for visualization --

CREATE VIEW PercentPopulationVaccinatedVaxNulls AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER
(PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
--order by 2,3

--SELECT *
--FROM PercentPopulationVaccinatedVaxNulls

CREATE VIEW WorldRate AS
Select continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS not NULL
GROUP BY continent
--order by TotalDeathCount desc

--SELECT * 
--FROM WorldRate