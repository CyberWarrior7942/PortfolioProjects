--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

--To calculate death percentage per case
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like 'India'
Order by 1, 2

--Percentage of cases wrt population
Select location, date, total_cases, population, (total_cases/population)*100 as percent_contracted
From PortfolioProject..CovidDeaths
where location = 'India'
Order by 1, 2

--Countries with Highest Infection Rate
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location = 'India'
Group by location, population
Order by PercentPopulationInfected desc

--Death count percentage wrt Population
Select location, MAX(cast (total_deaths as int)) as HighestDeaths, population, MAX((total_deaths/population)*100) as PercentDeceased
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
Order by HighestDeaths desc

--Deaths by Continents
Select continent, MAX(cast (total_deaths as int)) as HighestDeaths
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by HighestDeaths desc

--GLOBAL NUMBERS BY DATE
Select date, SUM(new_cases) as TotalCasesOnDate, SUM(cast (new_deaths as int)) as TotalDeathsOnDate, (SUM(cast (new_deaths as int))/SUM(new_cases))*100 as DeathPercentByDate
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
Order by 1,4

--Global Percent in general
Select SUM(new_cases) as TotalCasesOnDate, SUM(cast (new_deaths as int)) as TotalDeathsOnDate, (SUM(cast (new_deaths as int))/SUM(new_cases))*100 as DeathPercentByDate
From PortfolioProject..CovidDeaths
where continent is not null

--Population vs Vaccination
Select dea.location, dea.continent, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 1,2,3

--USE CTE to calculate Percentage Vaccinated
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.location, dea.continent, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PopvsVac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.location, dea.continent, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualisations
Create View PopulationVaccinated as
Select dea.location, dea.continent, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--checking the recently made view
Select * 
FROM PopulationVaccinated