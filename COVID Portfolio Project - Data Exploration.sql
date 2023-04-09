--select * from PortolioProject..CovidDeaths
--select data the we are going to be using
select Death.location, Death.date,Death.total_cases,Death.total_deaths,Death.population
from CovidDeaths as Death
order by 1,2 

--Looking at Total Cases vs Total Cases Death

select Death.location, Death.date,Death.total_cases,Death.total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths as Death
where location like '%states%'
order by 1,2 

--Looking at Total Cases vs Population 

select Death.location, Death.date,Death.total_cases,Death.population, (total_cases/population)*100 as populationPercentage
from CovidDeaths as Death
where location like '%states%'
order by 1,2 

--Looking at Countries with Highest Infection Rate

	select Death.location,Death.population,MAX(Death.total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentagepopulationInfected
	from CovidDeaths as Death
	where location like '%sau%'
	group by Death.location,Death.population
order by PercentagepopulationInfected desc

--Showing Countries with Highest Death Rate

	select Death.location,MAX(Death.total_deaths ) as HighestDeathCount
	from CovidDeaths as Death
	--where location like '%states%' and
	where continent is not null
	group by Death.location
order by HighestDeathCount desc

-- Looking at  Total Population vs Vaccinations
select dea.date,dea.population ,max(dea.total_deaths)
from PortolioProject..CovidDeaths dea
--join PortolioProject..CovidVaccinations vac
  --on dea.location = vac.location
  --and dea.date = vac.date
--where dea.continent is not null 
where dea.location like 'sudan'
group by dea.date,dea.total_deaths,dea.population
order by 3 desc


-- use CTE

with PopVsVac (continent,location,date,population,new_vaccinations,rollingPeople)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as rollingPeople
from PortolioProject..CovidDeaths dea
join PortolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
)
select * ,(rollingPeople/Population)*100
from PopVsVac


-- Global number
SELECT SUM(new_cases) total_cases,sum(new_deaths) total_deaths,(sum(new_deaths)/SUM(new_cases))*100 DeathPercentage
FROM PortolioProject..CovidDeaths

--Creating View to store data for later visualization
drop view if exists PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingPeopleVaccinated
FROM PortolioProject..CovidDeaths dea
JOIN PortolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


select * from PercentPopulationVaccinated


-- Creating TempTable
create table #TempTable
(continent varchar(255),
location varchar(255),
date dateTime,
population int,
new_vaccinations int,
rollingPeople float
)

insert into #TempTable
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as rollingPeople
from PortolioProject..CovidDeaths dea
join PortolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null

select * ,(rollingPeople/Population)*100
from #TempTable