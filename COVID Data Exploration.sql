--Check to see the data in the database is accurate

select *     
from Projects..CovidDeath
order by 3,4;

--select * , ISNULL(continent, " ")    
--from Projects..CovidDeath
--order by 3,4;

--select *
--from Projects..CovidVacc
--order by 3,4;

select Location, date, total_cases, new_cases, total_deaths, population
from Projects..CovidDeath
order by 1,2

--Check for Total cases vs Total Deaths by Locations
--Showing the likelihood of death if contacted Covid in your country
select Location, date, total_cases, total_deaths, (CONVERT(int,total_deaths)/NULLIF(CONVERT(int,total_cases),0))*100 as PercentageDeath   -- I was unable to perform the query due to incompatible datatypes detected so I had to convert the datatype in order to execute the query
from Projects..CovidDeath
--where continent is not null
order by 1,2

select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as PercentageDeath   
from Projects..CovidDeath
where Location like '%canada%'
order by 1,2

select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as PercentageDeath   
from Projects..CovidDeath
where Location like '%states%'
and continent is not null
order by 1,2

select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as PercentageDeath   
from Projects..CovidDeath
where Location like '%nigeria%'
order by 1,2

--Check the total Cases vs Population
select Location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentagePopulationInfected   
from Projects..CovidDeath
where continent is not null
--where Location like '%canada%'
order by 1,2

--Check Countries with Highest Infection rate vs Population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentagePopulationInfected   
from Projects..CovidDeath
where continent is not null
group by Location, Population
order by PercentagePopulationInfected DESC


--This shows the Highest Death Rate by  Location
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount   
from Projects..CovidDeath

group by Location
order by TotalDeathCount DESC

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount   
from Projects..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount DESC

--Global Numbers
select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Projects..CovidDeath
order by 1,2

select SUM(cast(new_cases as int)) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(CONVERT(float,new_deaths)/NULLIF(CONVERT(float,new_cases),0))*100 as DeathPercentage
from Projects..CovidDeath
order by 1,2


select *
from Projects..CovidVacc
order by 3,4;

--What's the Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Projects..CovidDeath dea
Join Projects..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeath dea
Join Projects..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

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
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeath dea
Join Projects..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeath dea
Join Projects..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

