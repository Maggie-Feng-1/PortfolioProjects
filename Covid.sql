-- Table: public.CovidDeaths

-- Select * 
-- from public."CovidDeaths" 
-- where continent is not null
-- order by 3, 4;
-- Select * from public."CovidVaccinations" order by 3, 4;


-- ## Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From public."CovidDeaths" order by 1, 2;

-- Looking at total casese vs total deaths, whats the percentage of people who died and who didnt
-- shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as deathpercentage
From public."CovidDeaths" 
Where Location ILIKE '%states%'
order by 1, 2;

-- SELECT COUNT(*) FROM public."CovidDeaths";

-- Looking at total cases vs. Population
-- Shows what percentage of population got Covid
Select Location, date, population, total_cases, (total_deaths / population)*100 as PercentPopulationInfected
From public."CovidDeaths" 
Where Location ILIKE '%states%'
order by 1, 2;


-- Looking at countires with Highest Infection Rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From public."CovidDeaths"
Group by location, population
order by PercentPopulationInfected desc;

-- Showing countires with highest death count per population
-- we add where clause because it shows locations where continent and location is the same or NULL confusing scripts
Select Location, MAX(total_deaths) as TotalDeathCount
From public."CovidDeaths"
Where continent is not null
Group by location
order by TotalDeathCount desc NULLS last;

-- LETS BREAK THINGS DOWN BY CONTINENT (but it doesnt seem to be accurate, doesnt include all continents)
-- This is showing the continents with the highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
From public."CovidDeaths"
Where continent is not null
Group by continent
order by TotalDeathCount desc NULLS last;

-- these are the right numbers on each continent (since above is not correct, but we use that for the project bc of drilldown storytelling effect)
-- Select location, MAX(total_deaths) as TotalDeathCount
-- From public."CovidDeaths"
-- Where continent is null
-- Group by location
-- order by TotalDeathCount desc NULLS last;

-- Global Numbers 

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
	SUM(new_deaths) / SUM(new_cases)*100 as DeathPercentage
From public."CovidDeaths" 
-- Where Location ILIKE '%states%'
Where continent is not null
Group By date
order by 1, 2;

-- Select *
-- From public."CovidDeaths" deaths
-- LEFT Join public."CovidVaccinations" vac
-- 	on deaths.location = vac.location 
-- 	and deaths.date = vac.date;

SELECT *
FROM public."CovidDeaths" deaths
JOIN public."CovidVaccinations" vac
  ON deaths.location = vac.location
 AND deaths.date = vac.date;

-- Looking at population vs vaccinations (new vaccinations per day)
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
FROM public."CovidDeaths" deaths
JOIN public."CovidVaccinations" vac
  ON deaths.location = vac.location
 AND deaths.date = vac.date
 WHERE deaths.continent is not null
 order by 2, 3;

-- we add up in sequence the total new vaccinations since the first date.
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by deaths.Location order by deaths.location, deaths.date) as NewTotalVaccinations
FROM public."CovidDeaths" deaths
JOIN public."CovidVaccinations" vac
  ON deaths.location = vac.location
 AND deaths.date = vac.date
 WHERE deaths.continent is not null
order by 2, 3;

-- want to know percentage of people are vaccinated in the population, use Common Table Expression (CTE) a temporary result set
-- USE CTE (make sure number of columns are the same on WITH and SELECT line)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, NewTotalVaccinations)
as 
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by deaths.Location order by deaths.location, deaths.date) as NewTotalVaccinations
FROM public."CovidDeaths" deaths
JOIN public."CovidVaccinations" vac
  ON deaths.location = vac.location
 AND deaths.date = vac.date
 WHERE deaths.continent is not null)
SELECT *, (NewTotalVaccinations/Population)*100 as PercentVaccinated
FROM PopvsVac;
-- these are just increasing percentages because new vaccinations increase by the day


-- TEMP TABLE instead of CTE
-- Create Table public."PercentPopulationVaccinated" (
-- 	Continent varchar(225),
-- 	Location varchar(222),
-- 	Date date,
-- 	Population numeric,
-- 	New_vaccinations numeric, 
-- 	NewTotalVaccinations numeric);
-- Insert into public."PercentPopulationVaccinated"
-- SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
-- SUM(vac.new_vaccinations) OVER (Partition by deaths.Location order by deaths.location, deaths.date) as NewTotalVaccinations
-- FROM public."CovidDeaths" deaths
-- JOIN public."CovidVaccinations" vac
--   ON deaths.location = vac.location
--  AND deaths.date = vac.date;
-- SELECT *, (NewTotalVaccinations/Population)*100 as PercentVaccinated
-- FROM public."PercentPopulationVaccinated"


-- CREATE A VIEW to store data for later visualizations (after the TABLES tab, can open up like a table)
Create view PercentPopulationVaccinated as 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by deaths.Location order by deaths.location, deaths.date) as NewTotalVaccinations
FROM public."CovidDeaths" deaths
JOIN public."CovidVaccinations" vac
  ON deaths.location = vac.location
 AND deaths.date = vac.date
 WHERE deaths.continent is not null


Select *
PercentPopulationVaccinated