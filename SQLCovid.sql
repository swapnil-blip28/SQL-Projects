Select * 
from Covidproject..CovidDeaths
Where continent is not null


Select * 
from Covidproject..CovidVaccinations


--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Covidproject..CovidDeaths
order by 1,2



--Looking at total case vs total deaths
--Likelihood of dying if you contract covid in Canada

select location, date, total_cases, total_deaths, (Total_deaths/total_cases) as Deathpercentage
from Covidproject..CovidDeaths
order by 1,2

SELECT location, date, total_cases, total_deaths, 
ROUND(CONVERT(FLOAT, total_deaths) / total_cases * 100, 2) AS PercentPopulationInfected
FROM Covidproject..CovidDeaths
WHERE location like '%Canada%'
order by 1,2



--Looking at total cases vs population
--Shows what % of pulation got covid

SELECT location, date, population,total_cases,
ROUND(CONVERT(FLOAT, total_cases) / population * 100, 2) AS PercentPopulationInfected
FROM Covidproject..CovidDeaths
WHERE LOCATION LIKE '%Canada%'
order by 1,2



--Looking at countries with highest infection rate compared to population

SELECT location, population,MAX (total_cases) as HighestInfectionCount,
ROUND(CONVERT(FLOAT, MAX(total_cases)) / population * 100, 2) AS PercentPopulationInfected
FROM Covidproject..CovidDeaths
--WHERE location like '%Canada%'
Group by location, population
Order by PercentPopulationInfected desc



--Showing countries with highest death count per population

SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM Covidproject..CovidDeaths
--WHERE location like '%Canada%'
Where continent is not null
Group by location
Order by TotalDeathCount desc



-- Showing continent with the highest death count per population

SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM Covidproject..CovidDeaths
--WHERE location like '%Canada%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Global numbers (total deaths and total death %)

SELECT  
SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
ROUND(SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(new_cases), 0) * 100, 2) AS DeathPercentage
FROM Covidproject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date 
ORDER BY 1,2



-- Global numbers

SELECT  
Date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
ROUND(SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(new_cases), 0) * 100, 2) AS DeathPercentage
FROM Covidproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2



-- Join the two tables

Select *
From Covidproject.dbo.CovidDeaths dea
Join Covidproject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date



--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Covidproject.dbo.CovidDeaths dea
Join Covidproject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3



--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccintions, RollingPeopleVaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Covidproject.dbo.CovidDeaths dea
Join Covidproject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/ Population) * 100
from PopvsVac



--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Covidproject.dbo.CovidDeaths dea
Join Covidproject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/ Population) * 100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select	
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
From Covidproject.dbo.CovidDeaths dea
Join Covidproject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3









