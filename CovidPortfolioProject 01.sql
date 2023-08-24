			/* COVID DATA ANALYSIS */

-- Source Table: CovidDeaths
SELECT * FROM PortfolioProjectSQL..CovidDeaths
--WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Source Table: CovidVaccinations
SELECT * FROM PortfolioProjectSQL..CovidVaccinations
--WHERE continent IS NOT NULL
ORDER BY 3, 4

/* Select the needed data*/
SELECT location, date, total_cases, new_cases, total_deaths, population					
FROM PortfolioProjectSQL..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

/* Death Percentage: Total Death vs Total Cases */
SELECT
		location, date, total_cases, total_deaths, 
		ROUND((CAST(total_deaths AS int)/total_cases)*100,2) AS DeathPercentage					
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL
ORDER BY 1, 2

/* Percent Infected: Total Cases vs Population */
SELECT location, date, population, total_cases,  ROUND((total_cases / population)*100,2) AS PercentInfected				
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL
ORDER BY 4 DESC

/* Countries with Highest Infection rate vs Population */
SELECT 
	location, population, 
	MAX(total_cases) AS HighestInfectionCount,  
	MAX(ROUND((total_cases / population)*100,2)) 
	AS PercentPopulationInfected					
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY 1
ORDER BY 3 DESC

/* Countries with Highest Death Count */
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount		-- CAST convert the total deaths data type from nvarchar into int		
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

/* Continents with Highest Death Count */
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount				
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL						
GROUP BY continent
ORDER BY 2 DESC

/* Global Values */

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount				
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

/* Global DeathPercentage */

SELECT 
	SUM(new_cases) AS Total_Cases, 
	SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
	ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100, 2) AS DeathPercentage
FROM PortfolioProjectSQL..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2


/* Total Population vs Vaccinations */
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CAST(vax.new_vaccinations AS int))	-- SUM(CONVERT(int,vax.new_vaccinations)) -- Calculate vaccinations running total
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	AS VaccinatedRunningTotal
	--,(VaccinatedRunningTotal/population)*100		--Can't use column just created to be used the same line
FROM PortfolioProjectSQL..CovidDeaths dea
JOIN PortfolioProjectSQL..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
--WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE instead
WITH PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, VaccinatedRunningTotal)
AS
(
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CAST(vax.new_vaccinations AS int))	-- SUM(CONVERT(int,vax.new_vaccinations)) -- Calculate vaccinations running total
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	AS VaccinatedRunningTotal
	--,(VaccinatedRunningTotal/population)*100		--Can't use column just created to be used the same line
FROM PortfolioProjectSQL..CovidDeaths dea
JOIN PortfolioProjectSQL..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, ROUND((VaccinatedRunningTotal/population) * 100,2) AS PercentTotalVaccinated
FROM PercentPopulationVaccinated

-- or use Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(Continent varchar(255), 
	Location varchar(255), 
	Date datetime, 
	Population float, 
	New_vaccinations float, 
	VaccinatedRunningTotal float)
--SELECT * FROM #PercentPopulationVaccinated

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	AS VaccinatedRunningTotal
	--,(VaccinatedRunningTotal/population)*100		--Can't use column just created to be used the same line
FROM PortfolioProjectSQL..CovidDeaths dea
JOIN PortfolioProjectSQL..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, ROUND((VaccinatedRunningTotal/population) * 100, 2) AS PercentTotalVaccinated
FROM #PercentPopulationVaccinated

/* Create VIEW to store data for later visualizations */

CREATE VIEW PercentPopulationVaccinated
AS
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	AS VaccinatedRunningTotal
	--,(VaccinatedRunningTotal/population)*100		--Can't use column just created to be used the same line
FROM PortfolioProjectSQL..CovidDeaths dea
JOIN PortfolioProjectSQL..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated

CREATE VIEW DeathPercentage
AS
/* Death Percentage: Total Death vs Total Cases */
SELECT
		location, date, total_cases, total_deaths, 
		ROUND((CAST(total_deaths AS int)/total_cases)*100,2) AS DeathPercentage					
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL
--ORDER BY 1, 2

CREATE VIEW PercentInfected
AS
/* Percent Infected: Total Cases vs Population */
SELECT location, date, population, total_cases,  ROUND((total_cases / population)*100,2) AS PercentInfected				
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL
--ORDER BY 4 DESC

CREATE VIEW InfectionRatebyCountry
AS
/* Countries with Highest Infection rate vs Population */
SELECT 
	location, population, 
	MAX(total_cases) AS HighestInfectionCount,  
	MAX(ROUND((total_cases / population)*100,2)) 
	AS PercentPopulationInfected					
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY 1
--ORDER BY 3 DESC

DROP VIEW IF EXISTS DeathCountbyCountry
CREATE VIEW DeathCountbyCountry
AS
/* Countries with Highest Death Count */
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount		-- CAST convert the total deaths data type from nvarchar into int		
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY 2 DESC

CREATE VIEW GlobalDeathCount AS
/* Global Values */

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount				
FROM PortfolioProjectSQL..CovidDeaths
--WHERE location LIKE '%Phil%'
WHERE continent IS NULL
GROUP BY location
--ORDER BY 2 DESC