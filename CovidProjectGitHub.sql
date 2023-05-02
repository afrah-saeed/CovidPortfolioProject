--Select *
--From PortfolioProject..CovidDeaths
order by 3,4;

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases Vs. Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases Vs. Population
--Shows what percentage of population has gotten covid
Select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL --(null continent entries have continents listed in the location column instead of country names)
group by location, population
order by TotalDeathCount desc

--Breaking Things Down By Continent
--Showing continents with highest death count per population
--Correct Way(come back and double check numbers)
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NULL 
group by location

--Incorrect Way, using for now:
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL 
group by continent
order by TotalDeathCount desc

--Global Numbers
Select date, sum(new_cases)
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select date, sum(new_cases), sum(cast(new_deaths as int))
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs. Vaccination

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on 
   dea.location=vac.location
   and 
   dea.date=vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on 
   dea.location=vac.location
   and 
   dea.date=vac.date
where dea.continent is not null
order by 2,3

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

--USE CTE
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

Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--add in a few of your own examples

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
--where dea.continent is not null



Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later vizualizations

Create View PercentPopulationVaccinated as
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
From PercentPopulationVaccinated
