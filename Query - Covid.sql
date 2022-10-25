
SELECT *
FROM PortfolioProject..CovidDeaths
--If continent is null which implies locations can be Europe, Asia etc. 
WHERE continent is not  null 
ORDER BY 3,4 

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4 

--SELECT Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases v.s Total Deaths 
--Shows likelihood of dying if you contract covid in your country  

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Taiwan'
ORDER BY 1,2

--Looking at Total Cases v.s Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases ,(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like 'GERMANY'
ORDER BY 1,2


--Looking at countries with highest infecction rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like 'Taiwan'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--Showing countries with highest death count per population

SELECT location, MAX(cast(Total_deaths AS int )) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount desc

--Let's break things down by continent 

--SELECT location, MAX(cast(Total_deaths AS int )) AS TotalDeathCount 
--FROM CovidDeaths
--Where location like '%states%'
--WHERE continent is  null  
--GROUP BY location
--ORDER BY TotalDeathCount desc



--Showing continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths AS int )) AS TotalDeathCount 
FROM CovidDeaths
--Where location like '%states%'
WHERE continent is not null  
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global numbers 

SELECT  SUM(total_cases)AS Total_Cases, SUM(cast(new_deaths AS int)) as Total_Deaths, SUM(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent  is not null
--GROUP BY date
ORDER BY 1,2



-- Looking at Total population v.s Vaccinations 
-- Join two tables	
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea 
JOIN  PortfolioProject..CovidVaccinations  vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null  
ORDER BY 2,3




-- Use WITH clause 
-- Use CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
	(
	-- Rolling vaccination
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

	FROM PortfolioProject..CovidDeaths dea 
	JOIN  PortfolioProject..CovidVaccinations  vac 
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null  

	)
SELECT *, (RollingPeopleVaccinated/population)* 100 
FROM PopvsVac




--TEM Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

	INSERT INTO #PercentPopulationVaccinated
	-- Rolling vaccination by Over clause 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

	FROM PortfolioProject..CovidDeaths dea 
	JOIN  PortfolioProject..CovidVaccinations  vac 
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null  

SELECT * , (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated

--creating view to store data for later visualisations 

Create View PercentPopulationVaccinated AS
-- Rolling vaccination by Over clause 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN  PortfolioProject..CovidVaccinations  vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null  

SELECT * 
FROM PercentPopulationVaccinated 