--Data for Tableau
SELECT *
FROM covidde1..CovidDeaths;

SELECT *
FROM covidde1..CovidVaccinations;

--1.
SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int))as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM covidde1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

--2.
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM covidde1..CovidDeaths
WHERE continent is null and location not in ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
GROUP BY location
ORDER BY TotalDeathCount desc;

--3.
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covidde1..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

--4.
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covidde1..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc;