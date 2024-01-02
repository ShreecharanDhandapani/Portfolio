Select *
From [Portfolio Project]..CovidDeaths$
order by 3,4

Select *
From [Portfolio Project]..CovidVaccinations$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
order by 1,2

-- Total cases vs total deaths

Select location, date, total_cases, total_deaths, (Convert(float,total_deaths/Nullif(Convert (float, total_cases),0)))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
where location like '%india%'
order by 1,2

-- cases vs population 

Select location, date, total_cases, (CONVERT(float, total_cases) / population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
where location like '%Italy%'
order by 1,2

-- countries with highest infection rate vs population
Select location, population, MAX(convert(float,total_cases)) as HighestInfectionCount, Max((convert(float,total_cases)/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
--where location like '%Italy%'
group by location,population
order by PercentPopulationInfected desc


--countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE

With PopulationVsVac(continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationVsVac

-- using Temp table

Drop table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View for later visuals

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*
from PercentPopulationVaccinated
