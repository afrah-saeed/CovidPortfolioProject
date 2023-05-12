--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4;

--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4;

--Looking at Covid Deaths Table:
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases Vs. Total Deaths:
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2

--In the United States:
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases Vs. Population (United States)
--Shows what percentage of population has gotten covid
Select location, date, population, total_cases, 
(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population 
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc


--Showing Countries with the Highest Death Count
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL 
group by location, population
order by TotalDeathCount desc


--Breaking Things Down By Continent:
--Showing continents with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NULL 
group by location
order by TotalDeathCount desc

--Global Numbers:
--Total Cases, Deaths and Death Percentage Worldwide:
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is null
order by 1,2 


--Looking at Covid Vaccinations Table

--Showing accesss to health facilities in every country:
Select dea.continent, dea.location, dea.population, dea.date, vac.handwashing_facilities, 
vac.hospital_beds_per_thousand
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.continent = vac.continent
 and  dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,4

--Comparing positive rate to new and total vaccinations:
Select location, date, positive_rate, new_vaccinations, total_vaccinations
from PortfolioProject..CovidVaccinations
where continent is not null
order by 1,2

--Looking at Total People Vaccinated per Country:
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by 
dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on 
   dea.location=vac.location
   and 
   dea.date=vac.date
where dea.continent is not null
order by 2,3

--United States:
Select Location, date, positive_rate, new_vaccinations, total_vaccinations
from PortfolioProject..CovidVaccinations
where location like '%States%'
order by 1,2

--USE CTE:
--Positive Rate vs Vaccinations:
With RateVsVac
(location,date, positive_rate, new_vaccinations, RollingVaccinations)
as 
 (
 Select location, date, positive_rate, new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by location order by location, date) as RollingVaccinations
from PortfolioProject..CovidVaccinations
)

Select *
From RateVsVac

--Rollling People Vaccinated:
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by 
dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on 
   dea.location=vac.location
   and 
   dea.date=vac.date
where dea.continent is not null

)
Select *
From PopvsVac

--Percent of Population Vaccinated:
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by 
dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on 
   dea.location=vac.location
   and 
   dea.date=vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopVsVac


--Showing accesss to health facilities in every country:
With FacilityAccess
(continent, location,date, population, total_deaths, handwashing_facilities, hospital_beds_per_thousand)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, dea.total_deaths, vac.handwashing_facilities, 
vac.hospital_beds_per_thousand
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.continent = vac.continent
 and  dea.location = vac.location
 and  dea.date = vac.date
where dea.continent is not null
)

Select *
From FacilityAccess

--TEMP Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by 
dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on 
   dea.location=vac.location
   and 
   dea.date=vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later vizualizations:

Create View RollingPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by 
dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on 
   dea.location=vac.location
   and 
   dea.date=vac.date
where dea.continent is not null

Select *
From RollingPeopleVaccinated

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
From RollingPeopleVaccinated


