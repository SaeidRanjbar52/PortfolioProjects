select *
from [Covid-Project]..CovidDeath
where continent is not Null
order by  3,4

--select *
--from [Covid-Project]..Covidaccinations
--order by  3,4

--**select data that we are going to use***

select location, date,total_cases,new_cases,total_deaths,population
from [Covid-Project]..CovidDeath
where continent is not Null
order by 1,2

--Looking at total cases and total deaths:
--shows likelihood of death if you contract covid in USA

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Covid-Project]..CovidDeath
where location like '%states%'
and  continent is not Null
order by 1,2


--Looking at total cases vs Population
--Shows what percentage of population got covid:

select location, date,total_cases,population ,(total_cases /population)*100 as PercentPopulationInfected
from [Covid-Project]..CovidDeath
where location like '%states%'
order by 1,2

--Looking for countries with highest infection rate compared to population

select location,population,max(total_cases ) as HighestInfectionCount, max((total_cases /population))*100 as PercentPopulationInfected
from [Covid-Project]..CovidDeath
Group by location,population
order by PercentPopulationInfected desc

--Looking for countries with highest death count per populaition:
select location,max(cast(total_deaths as int)) As TotalDeathCount
from [Covid-Project]..CovidDeath
where continent is not Null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent:

select continent ,max(cast(total_deaths as int)) As TotalDeathCount
from [Covid-Project]..CovidDeath
where continent is not Null
Group by continent
order by TotalDeathCount desc


----Looking for continent with highest death count per populaition:
select continent ,max(cast(total_deaths as int)) As TotalDeathCount
from [Covid-Project]..CovidDeath
where continent is not Null
Group by continent
order by TotalDeathCount desc


---Global Numbers:

--shows likelihood of death if you contract covid in world by detail
select date,SUM(new_cases  )as Total_Cases,sum(cast(new_deaths as int))as Total_deaths,SUM( new_cases )/SUM(cast(new_deaths as int))* 100 as DeathPercentageContinent
from [Covid-Project]..CovidDeath
where continent is not Null
group by date
order by 1,2

--shows likelihood of death if you contract covid in world overall:
select SUM(new_cases  )as Total_Cases,sum(cast(new_deaths as int))as Total_deaths,SUM( new_cases )/SUM(cast(new_deaths as int))* 100 as DeathPercentageContinent
from [Covid-Project]..CovidDeath
where continent is not Null
order by 1,2

------joining 2data sets:


select *
from [Covid-Project]..CovidDeath dea
join [Covid-Project]..CovidVaccination vac
on dea.location= vac.location
and dea.date= vac.date

--looking at total population vs vaccinations:
--use CTE

with PopvsVac (continent ,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date  )
as RollingPeopleVaccinated---, (RollingPeopleVaccinated/population)*100
from [Covid-Project]..CovidDeath dea
join [Covid-Project]..CovidVaccination vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not Null
--order by 2,3
)

select *,(  RollingPeopleVaccinated/population)*100 as PopulationVaccinatedPercentage
from PopvsVac





--TEMP Table

create table #percentPopulationVaccinated
(continent nvarchar (255),
location  nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date  )
as RollingPeopleVaccinated---, (RollingPeopleVaccinated/population)*100
from [Covid-Project]..CovidDeath dea
join [Covid-Project]..CovidVaccination vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not Null
--order by 2,3
select *,(  RollingPeopleVaccinated/population)*100 as PopulationVaccinatedPercentage
from #percentPopulationVaccinated

---Temp table without  where dea.continent is not null


drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(continent nvarchar (255),
location  nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date  )
as RollingPeopleVaccinated---, (RollingPeopleVaccinated/population)*100
from [Covid-Project]..CovidDeath dea
join [Covid-Project]..CovidVaccination vac
on dea.location= vac.location
and dea.date= vac.date
--where dea.continent is not Null
--order by 2,3
select *,(  RollingPeopleVaccinated/population)*100 as PopulationVaccinatedPercentage
from #percentPopulationVaccinated





---Creating view to stor data for later visualations:

create view percentPopulationVaccinated as

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date  )
as RollingPeopleVaccinated---, (RollingPeopleVaccinated/population)*100
from [Covid-Project]..CovidDeath dea
join [Covid-Project]..CovidVaccination vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not Null
--order by 2,3

select * from percentPopulationVaccinated