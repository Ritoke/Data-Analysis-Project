/*

Queries used for Tableau Project from COVID data exploration

*/



-- 1. 
--select SUM(cast(new_cases as int)) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(CONVERT(float,new_deaths)/NULLIF(CONVERT(float,new_cases),0))*100 as DeathPercentage

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(CONVERT(float,new_deaths))/SUM(CONVERT(float,new_cases)))*100 as DeathPercentage
From Projects..CovidDeath
--Where location like '%states%'
where NOT continent = '0'
--Group By date
order by 1,2



-- Query if dataset was .xlsx

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From Projects..CovidDeath
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

--

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Projects..CovidDeath
--Where location like '%states%'
--Where continent is null
where continent = '0'
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.
--MAX(cast(total_deaths as int))
--Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
select Location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentagePopulationInfected
From Projects..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentagePopulationInfected desc


-- 4.


select Location, population, date, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentagePopulationInfected
from Projects..CovidDeath
--Where location like '%states%'
group by Location, Population, date
order by PercentagePopulationInfected desc


-- Don't use
--Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((CONVERT(int,total_cases)/CONVERT(int, population)))*100 as PercentPopulationInfected
--From Projects..CovidDeath
----Where location like '%states%'
--Group by Location, Population, date
--order by PercentPopulationInfected desc









--Other Queries



-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeath dea
Join Projects..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Projects..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Projects..CovidDeath
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Projects..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From Projects..CovidDeath
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeath dea
Join Projects..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Projects..CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc




