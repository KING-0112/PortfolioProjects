/*
COVID 19 Data Exploration

Skills used: JOINS, CTEs, Temp Tables, Windows functions,
	Aggregate functions, Creating Views, Converting data types
*/

Select *
From PortfolioProjectV2..CovidDeaths
Where continent is NOT NULL
Order by 3,4

Select *
From PortfolioProjectV2..CovidDeaths
Where continent is NULL
Order by 3,4


-- Select data that we're going to start with

Select location, date, new_cases, total_cases, total_deaths, population
From PortfolioProjectV2..CovidDeaths
Where continent is NOT NULL
Order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
-- On this example, we used location = 'Philippines'

Select location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathRate
From PortfolioProjectV2..CovidDeaths
Where continent is NOT NULL
AND location like 'Philippines'
Order by 2


-- Total Cases vs Population
-- Shows what percentage of population was infected with COVID

Select location, date, population, total_cases, ((cast(total_cases as float))/population)*100 as InfectionRate
From PortfolioProjectV2..CovidDeaths
Where continent is NOT NULL
AND location = 'Philippines'
Order by 1,2


-- Countries with Highest Infection Rate compared to population

Select location, population, MAX(cast(total_cases as float)) as HighestInfectionCount
, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectV2..CovidDeaths
Where continent is not NULL
Group by location, population
Order by HighestInfectionCount desc


-- Countries with Highest Death Count per population

Select location, population, MAX(cast(total_deaths as float)) as HighestDeathCount
, MAX(total_deaths/population) as DeathPercentage
From PortfolioProjectV2..CovidDeaths
Where continent is not NULL
Group by location, population
Order by HighestDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

 -- Showing Continents with the Highest Death Count per Population

 Select location, population, MAX(cast(total_deaths as float)) as HighestDeathCount
 From PortfolioProjectV2..CovidDeaths
 Where continent is NULL
 AND location not like '%income'
 AND location <> 'World'
 AND location <> 'European Union'
 Group by location, population
 Order by HighestDeathCount desc

 Select location, population, MAX(cast(total_deaths as float)) as HighestDeathCount
 From PortfolioProjectV2..CovidDeaths
 Where continent is NULL
 AND location not IN ('World','European Union')
 AND location not like '%income'
 Group by location, population
 Order by HighestDeathCount desc



 -- GLOBAL NUMBERS


 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
 SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
 From PortfolioProjectV2..CovidDeaths
 Where continent is NOT NULL
 Order by 1,2


 -- Total Population vs Vaccinations
 -- Shows percentage of population that has received at least one COVID Vaccine

 Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as newVaccinations
 , SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
 From PortfolioProjectV2..CovidDeaths dea
 JOIN PortfolioProjectV2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
Order by 2,3


-- Using CTE to perform calculation on Partition by in previous query

With PopuvsVacc (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as newVaccinations
 , SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
 From PortfolioProjectV2..CovidDeaths dea
 JOIN PortfolioProjectV2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
)

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentageOverPop
From PopuvsVacc


-- Using temp table to perform calculation on partition by in previous query

DROP table if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as newVaccinations
 , SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
 From PortfolioProjectV2..CovidDeaths dea
 JOIN PortfolioProjectV2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentageOverPop
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as newVaccinations
 , SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
 From PortfolioProjectV2..CovidDeaths dea
 JOIN PortfolioProjectV2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL