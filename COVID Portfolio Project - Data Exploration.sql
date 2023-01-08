/*

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


*/


Select *
FROM PortfolioProject..covid_deaths
order by 3,4

-- Select *
-- FROM PortfolioProject..covid_vaccinations
-- order by 3,4

-- Select data that we are going to be using
Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..covid_deaths
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contrct covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
Where  location like '%United States%'
and continent is not null
order by 1,2 



-- looking at total deaths vs Population
--shows wht percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Where  location like '%states%'
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as
	PercentPopulationInfected
From PortfolioProject..covid_deaths
--Where  location like '%states%'
group by population, location
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population


Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
--Where  location like '%states%'
Where continent is not null
group by population, location
order by TotalDeathCount desc

-- LET'S BREAK DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
--Where  location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc



-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
--Where  location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc



-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
--Where  location like '%United States%'
Where continent is not null
--group by date
order by 1,2 


-- Looking at totl Popukation vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3






-- Use CTE

With PopvsVac (continent, Location, Date, Population, new_vaccintions, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac




-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




--Creating view to store data for later visualization


Drop View PercentPopulationVaccinated


Create View PercentPopulationVaccinated
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated