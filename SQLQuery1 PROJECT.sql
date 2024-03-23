select * 
from project..coviddeaths
where continent is not null
order by 3,4

select * 
from project..covidvacination
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from project..coviddeaths
order by 1,2

--total_cases vs total_death

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From project..coviddeaths
where location like '%india'
order by 1,2

--total cases vs population

Select Location, date,population,total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as percentpopulation
From project..coviddeaths
where location like '%india'
order by 1,2

--highest infected rate compared to population

Select Location,population,max(total_cases)as highestinfectioncount,max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as percentpopulation
From project..coviddeaths
--where location like '%india'
Group by population,location
order by percentpopulation desc

--Countries with highest death count per population

Select Location,max(cast(total_deaths as int)) as totaldeathcount
From project..coviddeaths
--where location like '%india'
where continent is not null
Group by location
order by totaldeathcount desc

-- Total Death count by Continent 

Select continent,max(cast(total_deaths as int)) as totaldeathcount
From project..coviddeaths
where continent is not null
Group by continent
order by totaldeathcount desc

--*GLOBAL NUMBERS*

Select date,sum(cast(total_cases as int))as total_cases,sum(cast(total_deaths as int)) as total_death,
sum(cast(total_deaths as int))/sum(cast(total_cases as int))*100 as deathpercentage
From project..coviddeaths
where continent is not null
Group by date
order by 1,2

--covid vacination
select *
from project..covidvacination

--total polpulation vs vacination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from project..coviddeaths dea
join project..covidvacination vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVacinated
from project..coviddeaths dea
join project..covidvacination vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVacinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVacinated
--(RollingPeopleVacinated/population)*100
from project..coviddeaths dea
join project..covidvacination vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVacinated/population)*100
from popvsvac as percentpeoplevac



--TEMP TABLE
Drop Table if exists #PercntPopulationVacinated
create table #PercntPopulationVacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVacinated numeric
)

insert into #PercntPopulationVacinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVacinated
--(RollingPeopleVacinated/population)*100
from project..coviddeaths dea
join project..covidvacination vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVacinated/population)*100
from #PercntPopulationVacinated


--creating view 

Create View PercntPopulationVacinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVacinated
--(RollingPeopleVacinated/population)*100
from project..coviddeaths dea
join project..covidvacination vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

CREATE VIEW deathpercentage as
Select date,sum(cast(total_cases as int))as total_cases,sum(cast(total_deaths as int)) as total_death,
sum(cast(total_deaths as int))/sum(cast(total_cases as int))*100 as deathpercentage
From project..coviddeaths
where continent is not null
Group by date
--order by 1,2
