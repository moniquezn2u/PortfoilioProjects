Select *
From PortfolioProject..OwidCovidData
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..OwidCovidData
--order by 1,2

--Total cases vs Total Loss

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as LossPercentage
From PortfolioProject..OwidCovidData
--Where location like '%states%'
order by 1,2 

--what percentage got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..OwidCovidData
--Where location like '%states%'
order by 1,2

--countries with highest infection rate
Select Location, Population, Max(total_cases) as HighestInfectionRate, Max((total_cases/population))*100 as
PopulationPercentage
From PortfolioProject..OwidCovidData
--Where location like '%states%'
Group by Location, Population 
order by PopulationPercentage desc



--covid by continent
Select continent, Max(cast(total_deaths as int)) as TotalLossCount
From PortfolioProject..OwidCovidData
Where continent is not null
Group by continent
order by TotalLossCount desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 as LossPercentage
From PortfolioProject..OwidCovidData
Where continent is not null
--Group by date
order by 1,2

--population  vs vaccinations

Select *
From PortfolioProject..OwidCovidData dat
Join PortfolioProject..CovidVaccinations vac
	On dat.location = vac.location
	and dat.date = vac.date 

--by continent CTE example

;With PopvsVac (continent, location, date, population, NumberPeopleVaccinated)
as
(
Select dat.continent, dat.location, dat.date, dat.population
, SUM(CONVERT(int, vac.date)) OVER (Partition by dat.location) as NumberPeopleVaccinated
From PortfolioProject..OwidCovidData dat
Join PortfolioProject..CovidVaccinations vac
	On dat.location = vac.location
	and dat.date = vac.date 
Where dat.continent is not null
--order by 2,3
)

Select *, (NumberPeopleVaccinated/population)*100
From PopvsVac

-- Insert Temp table 

DROP Table if exists #PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NumberPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dat.continent, dat.location, dat.date, dat.population
,  SUM(CONVERT(int, vac.date)) OVER (Partition by dat.location) as NumberPeopleVaccinated
From PortfolioProject..OwidCovidData dat
Join PortfolioProject..CovidVaccinations vac
	On dat.location = vac.location
	and dat.date = vac.date
Where dat.continent is not null

Select *, (NumberPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated

--Creating stored data for visualization

Go
Create View PercentPopulationVaccinated as
Select dat.continent, dat.location, dat.date, dat.population
, SUM(CONVERT(int, vac.date)) OVER (Partition by dat.location) as NumberPeopleVaccinated
From PortfolioProject..OwidCovidData dat
Join PortfolioProject..CovidVaccinations vac
	On dat.location = vac.location
	and dat.date = vac.date
Where dat.continent is not null
Go
--order by 2,3

Select *
From PercentPopulationVaccinated

exec sp_refreshview [PercentPopulationVaccinated]
go
Select *
From PercentPopulationVaccinated
go
