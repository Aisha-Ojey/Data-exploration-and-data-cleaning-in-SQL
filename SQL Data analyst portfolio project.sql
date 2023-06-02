--Covid 19 Data Exploration as at may 2021, using the filtered dataset gotten from *******
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From PortfolioProject1..coviddeaths
Where continent is not null 
order by 3,4


-- Select columns to work with

Select date, Location, population, total_cases, new_cases, total_deaths
From portfolioproject1..coviddeaths
Where continent is not null 
order by 1,2


-- Relationship between new Cases and Total Deaths
-- dispaly the chances of dying if you contract covid in your country based on the availabe data

Select date, Location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject1..coviddeaths
Where continent is not null and location like '%kingdom%'
order by 1,2


-- comparing Total Cases per Population
-- Shows what percentage of population got infected with Covid

Select date, Location, total_cases, total_deaths, (total_cases/population)*100 as PopulationInfected_percentage
From portfolioproject1..coviddeaths
Where continent is not null and location like '%kingdom%'
order by 1,2

-- Countries(location) with Highest Infection Rate per Population

Select Location, Population, MAX(total_cases) as Highest_case_per_location,  Max((total_cases/population))*100 as PopulationInfected_percentage_per_country
From PortfolioProject1..Coviddeaths
Group by Location, Population
order by PopulationInfected_percentage_per_country desc


-- Countries(loacation) with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount_per_country
From portfolioproject1..coviddeaths
Where continent is not null
Group by Location
--order by TotalDeathCount desc
order by 2 desc


-- Exploring data based on CONTINENT
-- display contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount_per_continent
From portfolioproject1..coviddeaths
Where continent is not null 
Group by continent
order by 2 desc



-- Global exploration (total cases, total death and total death percentage)

Select SUM(new_cases) as covid_total_cases, SUM(cast(new_deaths as int)) as covid_total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..coviddeaths
where continent is not null 


-- comparing the total population of different places to the number of COVID-19 vaccinations given using the covid death and covid vaccination table
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(int,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as People_vaccinated_continuously
From PortfolioProject1..coviddeaths death
Join portfolioproject1..covidvaccinations vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date
where death.continent is not null 
order by 2,3


--Using CTE(common table expression) to perform Calculation on Partition By in the above query and showing the percentage of people vaccinated base on population

With Population_vs_Vaccination (Continent, Location, Date, Population, New_Vaccinations, People_vaccinated_continuously)
as
(
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(int,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as People_vaccinated_continuously
From portfolioproject1..CovidDeaths death
Join portfolioproject1..CovidVaccinations vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date
where death.continent is not null 
)
Select *, (People_vaccinated_continuously/Population)*100 as vaccination_population_percentage

From Population_vs_Vaccination



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #vaccination_population_percentage
Create Table #vaccination_population_percentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
People_vaccinated_continuously numeric
)

Insert into #vaccination_population_percentage
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(int,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as People_vaccinated_continuously
From PortfolioProject1..CovidDeaths death
Join PortfolioProject1..CovidVaccinations vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date
Select *, (People_vaccinated_continuously/Population)*100 as People_vaccinated_continuously_population_percentage
From #vaccination_population_percentage



-- Creating View to store data for later visualizations

Create View vaccination_population_percentage as
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(int,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as People_vaccinated_continuously
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths death
Join PortfolioProject1..CovidVaccinations vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date
where death.continent is not null 

select * from vaccination_population_percentage

