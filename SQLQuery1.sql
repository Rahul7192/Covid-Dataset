SELECT *
FROM PortfolioProject ..CovidDeaths
where continent is not null
Order by 3,2

--SELECT *
--FROM PortfolioProject ..CovidVaccinations
--Order by 3,2


-- Selecting data

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases Vs Total Deaths
-- Chances of getting infected with COVID 19 in India

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
where location like '%India%'

--Total Cases Vs Population

Select Location, date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%India%'


--Countries with Highest Infection Rate as compared to Population

Select Location,population, MAX(total_cases)as HighestInfectionCount ,MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%India%'
GROUP By population,location
order by PercentPopulationInfected desc


-- Countries with Highest Deaths as compared to Population

Select Location,MAX(cast(total_deaths as int))as Death_Count
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
GROUP By location
order by Death_Count desc;


-- Lets Perform the continent analysis

Select location,MAX(cast(total_deaths as int))as Death_Count
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is null
GROUP By location
order by Death_Count desc;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Let us now Join the Deaths and Vaccination table

Select *
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations Vac
on dea.location=Vac.location
and dea.date=Vac.date

--Total Population Vs Vaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 






