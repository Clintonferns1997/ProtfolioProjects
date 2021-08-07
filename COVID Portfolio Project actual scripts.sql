select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

-- select *
-- from PortfolioProject..CovidVaccinations$
-- order by 3,4


-- select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking as Total cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2


-- Looking at Total cases vs population
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc


-- Showing Countries with Highes Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- LET's BREAK THINGS DOWN BY CONTINENT 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
where continent is null
Group by location 
order by TotalDeathCount desc

-- Showing continents with the highest death counts per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
-- group by date
order by 1,2                       

-- Looking at Total Population vs Vaccinations
-- Vaccination data not found hence the table is not created for vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinnations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--  Creating view to store data for later visualization

create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
 where dea.continent is not null
 -- order by 2,3

 select*
 from PercentPopulationVaccinated
