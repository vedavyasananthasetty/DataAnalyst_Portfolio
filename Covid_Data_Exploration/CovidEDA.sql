--viewing the imported data from deaths and vaccinations tables
SELECT *
FROM covidde1..CovidVaccinations
ORDER BY 3,4;

select *
from covidde1..CovidDeaths
ORDER BY 3,4;

select location,population,MAX(cast(total_cases as int)) as highest
from covidde1..CovidDeaths
group by location,population
ORDER BY 1,2;

--COVID Deaths analysis
--Selecting data that will be used for the Deaths analysis
select location,date,total_cases,new_cases,total_deaths,population
from covidde1..CovidDeaths
ORDER BY 1,2;


--Looking at total cases, total deaths and calculating percentage of deaths occured. We are converting the total_cases and total_deaths to integers and then converting one of them to float as they are in nvarchar
--Likelihood of dying in a particular country
select location,date,total_cases,total_deaths, (CAST(total_deaths AS int)/CAST(CAST(total_cases AS int) AS float)*100) AS percentage_deaths
from covidde1..CovidDeaths
--WHERE location = 'India'
ORDER BY 1,2;


--Now calculating percentage of cases
select location,date,population,total_cases, cast(cast(total_cases as int)as float)/population AS percentage_cases
from covidde1..CovidDeaths
ORDER BY 1,2;



--Countries with highest infection rate with their population
select location,population,MAX(cast(total_cases as int)) AS HighestInfectionCount, MAX(total_cases/population)*100 AS percentage_cases
from covidde1..CovidDeaths
Group BY location,population
ORDER BY percentage_cases desc;


--Countries with highest death count per population
select location,population,MAX(cast(total_deaths as int)) AS HighestDeathCount, (MAX(cast(cast(total_deaths as int) as float))/population)*100 AS percentage_deaths
from covidde1..CovidDeaths
where continent is not null
Group BY location,population
ORDER BY percentage_deaths desc;



--Breaking it by continent

select location,MAX(cast(total_deaths as int)) AS HighestDeathCount
from covidde1..CovidDeaths
where continent is null
Group BY location
ORDER BY HighestDeathCount desc;



--Continents with highest death counts

select continent,MAX(cast(total_deaths as int)) AS HighestDeathCount
from covidde1..CovidDeaths
where continent is not null
Group BY continent
ORDER BY HighestDeathCount desc;


--Global numbers
select date,SUM(new_cases)as Cases_worldwide, SUM(new_deaths)as Deaths_worldwide, SUM(new_deaths)/SUM(new_cases) as DeathPercentage--total_cases,total_deaths, (CAST(total_deaths AS int)/CAST(CAST(total_cases AS int) AS float)*100) AS percentage_deaths
from covidde1..CovidDeaths
where new_cases is not null and new_deaths is not null and new_cases!=0 and new_deaths!=0 and continent is not null
group by date
ORDER BY 1

select SUM(new_cases)as Cases_worldwide, SUM(new_deaths)as Deaths_worldwide, SUM(new_deaths)/SUM(new_cases) as DeathPercentage--total_cases,total_deaths, (CAST(total_deaths AS int)/CAST(CAST(total_cases AS int) AS float)*100) AS percentage_deaths
from covidde1..CovidDeaths
where new_cases is not null and new_deaths is not null and new_cases!=0 and new_deaths!=0 and continent is not null
ORDER BY 1


--COVID vaccinations analysis
--joining two tables to better analyse the data
select *
from covidde1..CovidDeaths dea
join covidde1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Total population vs Vaccinations calculating vaccination rolling count
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationRollingCount
--, (VaccinationRollingCount/population)*100
from covidde1..CovidDeaths dea
join covidde1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and vac.new_vaccinations is not null --and dea.location='Canada'
order by 2,3;




--Using a CTE to create a refined table

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinationRollingCount)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationRollingCount
from covidde1..CovidDeaths dea
join covidde1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and vac.new_vaccinations is not null --and dea.location='Canada'
--order by 2,3
)

select *, (VaccinationRollingCount/Population)*100 as Percentage_vaccinated_rolling
from PopvsVac;



--Doing the same thing as CTE but using a TEMP table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationRollingCount numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationRollingCount
--, (VaccinationRollingCount/population)*100
from covidde1..CovidDeaths dea
join covidde1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null --and vac.new_vaccinations is not null --and dea.location='Canada'
--order by 2,3;

select *, (VaccinationRollingCount/Population)*100 as Percentage_vaccinated_rolling
from #PercentPopulationVaccinated;


--cerating a view to store data for visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationRollingCount
--, (VaccinationRollingCount/population)*100
from covidde1..CovidDeaths dea
join covidde1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and vac.new_vaccinations is not null --and dea.location='Canada'



select * 
from PercentPopulationVaccinated;

