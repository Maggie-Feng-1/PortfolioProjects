-- View: public.percentpopulationvaccinated

-- DROP VIEW public.percentpopulationvaccinated;

-- CREATE OR REPLACE VIEW public.percentpopulationvaccinated
--  AS
--  SELECT deaths.continent,
--     deaths.location,
--     deaths.date,
--     deaths.population,
--     vac.new_vaccinations,
--     sum(vac.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS newtotalvaccinations
--    FROM "CovidDeaths" deaths
--      JOIN "CovidVaccinations" vac ON deaths.location::text = vac.location::text AND deaths.date = vac.date
--   WHERE deaths.continent IS NOT NULL;

-- ALTER TABLE public.percentpopulationvaccinated
--     OWNER TO postgres;

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From public."CovidDeaths"
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(new_deaths) as TotalDeathCount
From public."CovidDeaths"
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From public."CovidDeaths"
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From public."CovidDeaths"
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;