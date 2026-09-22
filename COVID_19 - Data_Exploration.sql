/* 
Covid 19 Data Exploration 
*/

select * from PORTFOLIO_PROJECT.CovidVaccinations ;


SELECT * FROM PORTFOLIO_PROJECT.CovidDeaths;



select location,date,total_cases,new_cases,population
from PORTFOLIO_PROJECT.CovidDeaths
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 

select location,date,total_cases,new_cases,round((total_deaths/total_cases)*100,2) as Death_Perccentage
from PORTFOLIO_PROJECT.CovidDeaths
order by 1,2;


select location,date,population,total_cases,round((total_deaths/population)*100,2) as Death_Perccentage
from PORTFOLIO_PROJECT.CovidDeaths
order by 1,2;

-- Total deaths vs Population
select location,population,max(total_deaths) as HighestInfecCount,max(round((total_deaths/population)*100,2)) as population_infected
from PORTFOLIO_PROJECT.CovidDeaths
group by location,population
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location,population,max(total_cases) as HighestInfecCount,max(round((total_cases/population)*100,2)) as percent_population_infected
from PORTFOLIO_PROJECT.CovidDeaths
group by location,population
order by percent_population_infected;


-- Countries with Highest Death Count per Population
SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM PORTFOLIO_PROJECT.CovidDeaths
where continent <> ''
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Showing contintents with the highest death count per population
SELECT 
    continent,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM PORTFOLIO_PROJECT.CovidDeaths
where continent = ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PORTFOLIO_PROJECT.CovidDeaths
where continent <> ''
order by 1,2;


--  Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PORTFOLIO_PROJECT.CovidDeaths dea
Join PORTFOLIO_PROJECT.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' 
order by 2,3 ;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PORTFOLIO_PROJECT.CovidDeaths dea
Join PORTFOLIO_PROJECT.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TEMPORARY TABLE IF EXISTS PORTFOLIO_PROJECT.PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PORTFOLIO_PROJECT.PercentPopulationVaccinated
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Population DECIMAL(20,2),
    New_vaccinations DECIMAL(20,2),
    RollingPeopleVaccinated DECIMAL(20,2)
);

INSERT INTO PORTFOLIO_PROJECT.PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,

    CAST(NULLIF(dea.population, '') AS DECIMAL(20,2)) AS Population,

    CAST(NULLIF(vac.new_vaccinations, '') AS DECIMAL(20,2)) AS New_vaccinations,

    SUM(
        CAST(NULLIF(vac.new_vaccinations, '') AS DECIMAL(20,2))
    ) OVER (
        PARTITION BY dea.location
        -- ORDER BY STR_TO_DATE(dea.date, '%m-%d-%y')
    ) AS RollingPeopleVaccinated

FROM PORTFOLIO_PROJECT.CovidDeaths dea

JOIN PORTFOLIO_PROJECT.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date

WHERE dea.continent <> '';

Select *, (RollingPeopleVaccinated/Population)*100
From PORTFOLIO_PROJECT.PercentPopulationVaccinated ;




-- Creating View to store data for later visualizations

Create View PORTFOLIO_PROJECT.PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PORTFOLIO_PROJECT.CovidDeaths dea
Join PORTFOLIO_PROJECT.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' ;


