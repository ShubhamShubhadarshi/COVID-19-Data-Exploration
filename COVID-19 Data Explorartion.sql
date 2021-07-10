
-- COVID-19 Deaths Analysis
--Selecting Data that we are going to use in this project

SELECT continent, location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 2,3

--Total Cases vs Total Deaths
--Death Percentage in India
SELECT  location, date, total_cases, total_deaths, (total_deaths/total_cases*100) AS death_percentage 
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Total cases vs Population
--Percentage of population infected with Covid in India
SELECT  location, date, total_cases, population, (total_cases/population*100) AS infected_population_percentage 
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Highest Infection rates by Countries compared to populations
SELECT  location, MAX(CAST(total_deaths as int)) AS highest_infection_count, population, MAX((total_cases/population*100)) AS infection_rate 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY infection_rate DESC

--Highest Death rates by countries compared  to population
SELECT  location, MAX(CAST(total_deaths as int)) AS Total_deaths, population, MAX((total_deaths/population*100)) AS death_rate 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY death_rate DESC


--LET'S BREAK DATA BY CONTINENTS


--Infection rate per continent
SELECT  location, MAX(CAST(total_deaths as int)) AS highest_infection_count, population, MAX((total_cases/population*100)) AS infection_rate 
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY population, location
ORDER BY infection_rate DESC

--Death count per continent
SELECT  continent, SUM(CAST(new_deaths as int)) AS Death_count
FROM CovidDeaths
GROUP BY continent
ORDER BY Death_count DESC

--Highest death rate by continent
SELECT  location, MAX(CAST(total_deaths as int)) AS Total_deaths, population, MAX((total_deaths/population*100)) AS death_rate 
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY population, location
ORDER BY death_rate DESC


--GLOBAL NUMBERS

--Total Cases Worldwide by Dates
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) <> 0
ORDER BY 1

--Overall Deathpercentage till 5 July 2021
SELECT  SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
HAVING SUM(new_cases) <> 0


--COVID-19 Vaccination Analysis

--Selecting the data that we are going to use
SELECT * 
FROM CovidDeaths AS cd
JOIN CovidVaccination AS cv 
ON cd.location = cv.location and cd.date = cv.date

--Fully Vaccinated people  VS population
SELECT cd.location, cd.population, MAX(CONVERT(int,cv.people_fully_vaccinated)) AS Fully_vaccinated, 
MAX(CONVERT(float,cv.people_fully_vaccinated/cd.population*100)) AS fully_vaccinated_percentage
FROM CovidDeaths AS cd
JOIN CovidVaccination AS cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cd.population
ORDER BY fully_vaccinated_percentage DESC

--People Vaccinated Atleast One Doses vs Population
SELECT cd.location, cd.population, MAX(CONVERT(int,cv.people_vaccinated)) AS People_vaccinated_atleast_1_dose, 
MAX(CONVERT(float,cv.people_vaccinated/cd.population*100)) AS people_vaccinated_percentage
FROM CovidDeaths AS cd
JOIN CovidVaccination AS cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cd.population
ORDER BY people_vaccinated_percentage DESC

--Total Vaccination doses vs Population using total_vaccinations column
SELECT cd.location, cd.population, MAX(CONVERT(int,cv.total_vaccinations)) AS Total_vaccination_doses, 
MAX(CONVERT(float,cv.total_vaccinations/cd.population*100)) AS vac_percent
FROM CovidDeaths AS cd
JOIN CovidVaccination AS cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cd.population
ORDER BY vac_percent DESC



--Total Vaccination Doses vs Population using new_vaccination column
--Using Common Table Expression (CTE)

WITH PopvsVac( location, date, population, new_vaccinations, Total_vaccinations) 
AS
( SELECT cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(int,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Total_Vaccinations
FROM CovidDeaths AS cd
JOIN CovidVaccination AS cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL 
)

SELECT location, population, MAX(Total_vaccinations) AS Total_Vaccination_tilldate, MAX((Total_vaccinations/population)*100) AS Vac_percentage
FROM PopvsVac
GROUP BY location,population
ORDER BY Vac_percentage DESC


--CREATING A TEMP TABLE

DROP TABLE IF EXISTS PercentagePopulationVaccinated
CREATE TABLE PercentagePopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_Vaccination_Doses numeric
)

INSERT INTO PercentagePopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Total_Vaccination_Doses
FROM CovidDeaths AS cd
JOIN CovidVaccination AS cv 
ON cd.location = cv.location and cd.date = cv.date
--WHERE cd.continent IS NOT NULL

SELECT * , Total_Vaccination_Doses/Population*100 AS vac_percentage
FROM PercentagePopulationVaccinated




--Creating View to store data for Visualization

CREATE VIEW PercentagePopulationVaccinatedView AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Total_Vaccination_Doses
FROM CovidDeaths AS cd
JOIN CovidVaccination AS cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL












