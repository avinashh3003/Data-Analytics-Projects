select Location,date, total_cases, new_cases, total_deaths, population 
from Projs..CovidDeaths
order by 1,2

select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPers 
from Projs..CovidDeaths
where location='India'
order by 1,2

select Location,date, population, total_cases, (total_cases/population)*100 AS CovidPers 
from Projs..CovidDeaths
where location='India'
order by 1,2

select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PopulationInfectedPers 
from Projs..CovidDeaths
Group by location, population
order by PopulationInfectedPers desc

select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from Projs..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from Projs..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

select date, sum(new_cases) as tot_cases, sum(cast(new_deaths as int)) as tot_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPers
from Projs..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as tot_cases, sum(cast(new_deaths as int)) as tot_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPers
from Projs..CovidDeaths
where continent is not null
order by 1,2

select * from Projs..CovidVaccinations

select * from
Projs..CovidDeaths dea
join Projs..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPplVaccinated
from Projs..CovidDeaths dea
join Projs..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPplVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPplVaccinated
from Projs..CovidDeaths dea
join Projs..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPplVaccinated/population)*100
from PopvsVac

drop table if exists #PercantagePopulVaccinated
create table #PercantagePopulVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPplVaccinated numeric
)
insert into #PercantagePopulVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPplVaccinated
from Projs..CovidDeaths dea
join Projs..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPplVaccinated/population)*100
from #PercantagePopulVaccinated

drop view PercantagePopulVaccinated
create view PercantagePopulVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPplVaccinated
from Projs..CovidDeaths dea
join Projs..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercantagePopulVaccinated