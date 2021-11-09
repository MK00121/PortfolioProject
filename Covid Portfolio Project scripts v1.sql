SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM covidVaccinations
--ORDER BY 3,4

--selectdata we are going to be using
SELECT location, date, total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total cases Vs Total deaths
--Shows likelihood of dying if you contract covidin your country
SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Total cases Vs Population
--shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at infection rates

SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at countries with highest Infection Rate

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location like '%states%' 
GROUP BY Location, population
ORDER BY 4 desc

--Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%' 
where continent is not null
GROUP BY Location
ORDER BY 2 desc

-- LETS BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%' 
where continent is null
GROUP BY location
ORDER BY 2 desc


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%' 
where continent is not null
GROUP BY continent
ORDER BY 2 desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)) /SUM(new_cases) *100 as DeathPercenage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION
SELECT dea.continent,dea.location,dea.date,dea.population, new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN covidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE
With PopvsVac(continent,location,date,population,new_vaccinations, RollongPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN covidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
select *
FROM popvsvac

--Temp table
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN covidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *, (RollingPeopleVaccinated/population) *100
from #PercentPopulationVaccinated


--Create view to store data for later vizualization
Create view PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN covidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated
