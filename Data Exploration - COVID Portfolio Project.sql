/*
Covid19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * 
FROM [SQL Portfolio]..CovidDeaths
Where continent is NUll AND location not Like '%income%'
order by 3,4


-- Total Deaths per Total Cases

Select location, date, total_cases, total_deaths, (total_deaths/CAST(total_cases as real))*100 as DeathPercentage
FROM [SQL Portfolio]..CovidDeaths
order by 1,2


--Total Cases per population

Select location, date, population, total_cases,  (CAST(total_cases as real)/population)*100 as CasesPerPolutation
FROM [SQL Portfolio]..CovidDeaths
order by 1,2


--Country with highest Infection Rate

Select location, population, Max(CAST(total_cases as real)) as HighestInfectionCount,  Max((CAST(total_cases as real)/population))*100 as CasesPerPolutation
FROM [SQL Portfolio]..CovidDeaths
Where continent is NOT NUll
Group by location, population
order by CasesPerPolutation DESC


--Country with highest death count per population

Select location, population ,Max(CAST(total_deaths as real)) as HighestDeathCount,  Max((CAST(total_deaths as real)/population))*100 as DeathsPerPolutation
FROM [SQL Portfolio]..CovidDeaths
Where continent is NOT NUll 
Group by location, population
order by DeathsPerPolutation DESC


--Continent with highest death count per population

Select location, population ,Max(CAST(total_deaths as real)) as HighestDeathCount,  Max((CAST(total_deaths as real)/population))*100 as DeathsPerPolutation
FROM [SQL Portfolio]..CovidDeaths
Where continent is NUll AND location not Like '%income%'
Group by location, population
order by DeathsPerPolutation DESC


-- Global numbers

Select SUM(CAST(total_deaths as real)) as TotalDeaths, SUM(CAST(total_cases as real)) as TotalCases, 
SUM(CAST(total_deaths as real))/SUM(CAST(total_cases as real))*100 as gl_DeathsPerCases
FROM [SQL Portfolio]..CovidDeaths 
Where continent is not NUll AND location not Like '%income%'


--Total Vaccination per Population

WITH PopulationVsVaccination (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(real,vac.new_vaccinations)) OVER (Partition by dea.location Order by 
dea.date) as RollingPeopleVaccinated
From [SQL Portfolio]..CovidDeaths as dea
Join [SQL Portfolio]..CovidVaccinations as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
Where dea.continent is not NUll AND dea.location not Like '%income%'
)

Select *, (RollingPeopleVaccinated/Population)*100 as TotalVaccinationperPopulation
From PopulationVsVaccination


-- Tests per Population 

Drop table if exists #PercentPopTested
Create Table #PercentPopTested (
continent nvarchar(255),
location nvarchar(255),
date nvarchar(255),
population real,
new_tests real,
RollingPeopleTested real)

Insert into #PercentPopTested
Select dea.continent, dea.location, dea.date, dea.population, vac.new_tests
, SUM(convert(real,vac.new_tests)) OVER (Partition by dea.location Order by 
dea.date) as RollingPeopleTested
From [SQL Portfolio]..CovidDeaths as dea
Join [SQL Portfolio]..CovidVaccinations as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
Where dea.continent is not NUll AND dea.location not Like '%income%'

Select *, (RollingPeopleTested/Population)*100 as TotalTestsPerPopulation
From #PercentPopTested
order by 2,3


-- Create View for later Visualisation

Create View PercentPopTested as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_tests
, SUM(convert(real,vac.new_tests)) OVER (Partition by dea.location Order by 
dea.date) as RollingPeopleTested
From [SQL Portfolio]..CovidDeaths as dea
Join [SQL Portfolio]..CovidVaccinations as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
Where dea.continent is not NUll AND dea.location not Like '%income%'
)

-- View VaccinationsperPopulation 

Create View VaccinationperPopulation
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(real,vac.new_vaccinations)) OVER (Partition by dea.location Order by 
dea.date) as RollingPeopleVaccinated
From [SQL Portfolio]..CovidDeaths as dea
Join [SQL Portfolio]..CovidVaccinations as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
Where dea.continent is not NUll AND dea.location not Like '%income%'
)
