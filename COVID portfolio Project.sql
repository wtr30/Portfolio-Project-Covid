Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

--Select Data that we are going to use 

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1, 2

--lets look at total cases vs. total deaths in the US
--likelihood of dying after contracting covid in your country. Change like to specified country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%' and continent is not null
order by 1, 2



--next lets look at total cases vs. population
--shows percentage of population contracted covid
Select location, date, total_cases, population, (total_cases/population)* 100 as PercentCovidByPop
From [Portfolio Project]..CovidDeaths
Where location like '%states%' and continent is not null
order by 1, 2


--next lets check for countries for highest infection rate vs. population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentInfectedByPop
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location, population
order by PercentInfectedByPop desc

--Countries w/ highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

--showing continents with highest death counts
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
order by 1, 2

--this shows total number of both
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1, 2

--Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3



--USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3
)
Select *, (rollingpeoplevaccinated/population)*100
From PopVsVac



--TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated


--Creating Views to store for Tableau visulatization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


Select *
From PercentPopulationVaccinated