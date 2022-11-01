-- Exploratory Data Analysis on COVID-19 data


-- Table overview

SELECT  * 
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT  * 
FROM COVIDProject..Vaccs
ORDER BY 2,3,4

-- Data selection

SELECT location, date, total_cases,  new_cases,  total_deaths,  population
FROM COVIDProject..Deaths
ORDER BY location, date


-- UNITED STATES BREAKDOWN
-- Total cases vs. Total Deaths in the US (Percentage of cases resulting in death)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM COVIDProject..Deaths
WHERE location like '%states'
ORDER BY location, date

-- Total cases vs. US Population 

SELECT location, date,  population, total_cases, (total_cases/population)*100 AS percent_infected
FROM COVIDProject..Deaths
WHERE location like '%states'
ORDER BY location, date

-- Vaccinations vs. US Population
-- vaccination count
SELECT d.location, d.date, d.population, v.new_vaccinations, 
SUM(convert(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS vaccination_count
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.location like '%states'
ORDER BY d.date
-- percent vaccinated
SELECT d.location, d.date, d.population, v.new_vaccinations, 
SUM(convert(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS vaccination_count,
(v.people_vaccinated/d.population) AS percent_vaccinated,
(v.people_fully_vaccinated/d.population) AS percent_fully_vaccinated
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.location like '%states'
ORDER BY d.date

-- US Vaccinations vs. Death 
-- Count
SELECT d.location, d.date, d.population, v.new_vaccinations, 
SUM(convert(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS vaccination_count,
v.people_vaccinated, v.people_fully_vaccinated, d.new_cases, d.total_cases, d.new_deaths, d.total_deaths
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.location like '%states'
ORDER BY d.date
-- Percentage
SELECT d.location, d.date, d.population, (d.total_cases/d.population)*100 AS percent_infected,
(v.people_vaccinated/d.population)*100 AS percent_vaccinated,
(v.people_fully_vaccinated/d.population)*100 AS percent_fully_vaccinated,
(d.total_deaths/d.total_cases)*100 AS death_rate
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.location like '%states'
ORDER BY d.date

-- Current Numbers
WITH USnumbers (location, date, vaccination_count, percent_vaccinated, percent_fully_vaccinated, total_cases, total_deaths, percent_infected)
AS
(
SELECT d.location, d.date, 
SUM(convert(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS vaccination_count,
(v.people_vaccinated/d.population) AS percent_vaccinated,
(v.people_fully_vaccinated/d.population) AS percent_fully_vaccinated, d.total_cases, d.total_deaths,
(d.total_cases/d.population)*100 AS percent_infected
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.location like '%states'
)
SELECT MAX(vaccination_count) AS vaccination_count, MAX(percent_vaccinated) AS percent_vaccinated, 
MAX(percent_fully_vaccinated) AS percent_fully_vaccinated, MAX(total_cases) AS total_cases, MAX(cast(total_deaths as int)) AS total_deaths, 
MAX(percent_infected) AS percent_pop_infected
FROM USnumbers

-- Average infections and death rate before and after vaccine
SELECT location,
(SELECT AVG(new_cases) FROM COVIDProject..Deaths WHERE date<='2021-06-01' AND location like '%states') AS avg_daily_cases_before_vacc,
(SELECT AVG(new_cases) FROM COVIDProject..Deaths WHERE date>'2021-06-01' AND location like '%states')  AS avg_daily_cases_after_vacc,
(SELECT AVG(cast(new_deaths as INT)) FROM COVIDProject..Deaths WHERE date<='2021-06-01' AND location like '%states') AS avg_daily_deaths_before_vacc,
(SELECT AVG(cast(new_deaths as INT)) FROM COVIDProject..Deaths WHERE date>'2021-06-01' AND location like '%states')  AS avg_daily_deaths_after_vacc,
(SELECT AVG((total_deaths/total_cases))*100 FROM COVIDProject..Deaths WHERE date<='2021-06-01' AND location like '%states') AS avg_death_rate_before_vacc,
(SELECT AVG((total_deaths/total_cases))*100 FROM COVIDProject..Deaths WHERE date>'2021-06-01' AND location like '%states') AS avg_death_rate_after_vacc
FROM COVIDProject..Deaths
WHERE location like '%states'
GROUP BY location

-- Average cases and deaths by year
SELECT location,
(SELECT AVG(new_cases) FROM COVIDProject..Deaths WHERE date<'2021-01-01' AND location like '%states') AS avg_daily_cases_2020,
(SELECT AVG(new_cases) FROM COVIDProject..Deaths WHERE date BETWEEN '2021-01-01' AND '2022-01-01' AND location like '%states')  AS avg_daily_cases_2021,
(SELECT AVG(new_cases) FROM COVIDProject..Deaths WHERE date>='2022-01-01' AND location like '%states')  AS avg_daily_cases_2022,
(SELECT AVG(cast(new_deaths as INT)) FROM COVIDProject..Deaths WHERE date<'2021-01-01' AND location like '%states') AS avg_daily_deaths_2020,
(SELECT AVG(cast(new_deaths as INT)) FROM COVIDProject..Deaths WHERE date BETWEEN '2021-01-01' AND '2022-01-01' AND location like '%states')  AS avg_daily_deaths_2021,
(SELECT AVG(cast(new_deaths as INT)) FROM COVIDProject..Deaths WHERE date>='2022-01-01' AND location like '%states')  AS avg_daily_deaths_2022,
(SELECT AVG((total_deaths/total_cases))*100 FROM COVIDProject..Deaths WHERE date<'2021-01-01' AND location like '%states') AS avg_death_rate_2020,
(SELECT AVG((total_deaths/total_cases))*100 FROM COVIDProject..Deaths WHERE date BETWEEN '2021-01-01' AND '2022-01-01' AND location like '%states')  AS avg_death_rate_2021,
(SELECT AVG((total_deaths/total_cases))*100 FROM COVIDProject..Deaths WHERE date>='2022-01-01' AND location like '%states')  AS avg_death_rate_2022
FROM COVIDProject..Deaths
WHERE location like '%states'
GROUP BY location

-- COUNTRY BREAKDOWN
-- Death Count and Highest Death Rate by Country

SELECT location, MAX(cast(total_deaths as int)) AS death_count, MAX((cast(total_deaths as int)/total_cases))*100 AS highest_death_rate,
(MAX(cast(total_deaths as int))/MAX(total_cases))*100 AS current_death_rate
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC


-- Infection Rate by Country
SELECT location, population, MAX(total_cases) AS total_cases, MAX((total_cases/population))*100 AS percent_infected
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_infected DESC
--by date
SELECT location, population, date, MAX(total_cases) AS total_cases, MAX((total_cases/population))*100 AS percent_infected
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY percent_infected DESC


-- Total Population vs. Vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(cast(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS vaccination_count,
	(v.people_vaccinated/d.population)*100 AS percent_vaccinated,
	(v.people_fully_vaccinated/d.population)*100 AS percent_fully_vaccinated
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

-- Temp table for percent vaccinated

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations  numeric,
vaccination_count numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(cast(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS vaccination_count
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *, (vaccination_count/population)*100 AS est_percent_vaccinated
FROM  #PercentPopulationVaccinated


-- View to store percent vaccinated data for visualizations

CREATE VIEW  PercentPopulationVaccinated  AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(cast(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS vaccination_count,
	(v.people_vaccinated/d.population)*100 AS percent_vaccinated,
	(v.people_fully_vaccinated/d.population)*100 AS percent_fully_vaccinated
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL

-- Vaccinations vs. Death Rate by Country
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(cast(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS vaccination_count,
	(v.people_vaccinated/d.population)*100 AS percent_vaccinated,
	(v.people_fully_vaccinated/d.population)*100 AS percent_fully_vaccinated,
	(d.total_deaths/d.total_cases)*100 AS death_rate
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3


-- Average Death Rate vs. GDP, Life Expectancy, Population Density
SELECT 
d.location, d.population, MAX((d.total_cases/d.population))*100 AS infection_rate, 
AVG((cast(d.total_deaths as int)/d.total_cases))*100 AS avg_death_rate, AVG(v.gdp_per_capita) AS gdp_per_capita,
AVG(v.life_expectancy) AS life_expectancy, AVG(v.population_density) AS population_density
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
WHERE d.continent IS NOT NULL
GROUP BY d.location, d.population
ORDER BY avg_death_rate DESC

-- Average cases and deaths by year
--  2020
SELECT location, population, AVG(new_cases) AS avg_daily_cases_2020, AVG(cast(new_deaths as INT)) AS avg_daily_deaths_2020,
AVG((total_deaths/total_cases))*100 AS avg_death_rate_2020
FROM COVIDProject..Deaths
WHERE date<'2021-01-01'
AND continent IS NOT NULL
GROUP BY location, population
ORDER BY 1,2
-- 2021
SELECT location, population, AVG(new_cases) AS avg_daily_cases_2021, AVG(cast(new_deaths as INT)) AS avg_daily_deaths_2021,
AVG((total_deaths/total_cases))*100 AS avg_death_rate_2021
FROM COVIDProject..Deaths
WHERE date BETWEEN '2021-01-01' AND '2022-01-01'
AND continent IS NOT NULL
GROUP BY location, population
ORDER BY 1,2
-- 2022
SELECT location, population, AVG(new_cases) AS avg_daily_cases_2022, AVG(cast(new_deaths as INT)) AS avg_daily_deaths_2022,
AVG((total_deaths/total_cases))*100 AS avg_death_rate_2022
FROM COVIDProject..Deaths
WHERE date>='2022-01-01'
AND continent IS NOT NULL
GROUP BY location, population
ORDER BY 1,2
-- Grouped by year
SELECT location, population, year(date) AS year, AVG(new_cases) AS avg_daily_cases, AVG(cast(new_deaths as INT)) AS avg_daily_deaths,
AVG((total_deaths/total_cases))*100 AS avg_death_rate
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL
GROUP BY location, population, year(date)
ORDER BY 3,1


-- CONTINENT BREAKDOWN
-- Death Count by Continent

SELECT location, MAX(cast(total_deaths as int)) AS death_count, AVG((cast(total_deaths as int)/total_cases))*100 AS avg_death_rate, 
(MAX(cast(total_deaths as int))/MAX(total_cases))*100 AS current_death_rate
FROM COVIDProject..Deaths
WHERE continent IS NULL
AND location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY death_count DESC

-- Infection Rate by Continent
SELECT location, MAX(total_cases) AS total_cases, MAX((total_cases/population))*100 AS infection_rate
FROM COVIDProject..Deaths
WHERE continent IS NULL
AND location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY infection_rate DESC

-- Vaccinations by Continent
SELECT d.location, MAX(v.people_vaccinated) AS vaccination_count,
	MAX((v.people_vaccinated/d.population))*100 AS percent_vaccinated,
	MAX((v.people_fully_vaccinated/d.population))*100 AS percent_fully_vaccinated
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NULL
AND d.location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY d.location
ORDER BY percent_vaccinated DESC

-- Vaccinations vs. Deaths vs. Infections
SELECT d.location, d.population, MAX(cast(v.people_vaccinated AS BIGINT)) AS people_vaccinated,
	MAX((cast(v.people_vaccinated AS BIGINT)/d.population))*100 AS percent_vaccinated, 
	MAX((cast(v.people_fully_vaccinated AS BIGINT)/d.population))*100 AS percent_fully_vaccinated,
	MAX(cast(total_deaths as int)) AS death_count, AVG((cast(total_deaths as int)/total_cases))*100 AS avg_death_rate, 
	(MAX(cast(total_deaths as int))/MAX(total_cases))*100 AS current_death_rate,
	MAX(total_cases) AS total_cases, MAX((total_cases/population))*100 AS infection_rate
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NULL
AND d.location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY d.location, d.population
ORDER BY percent_vaccinated DESC


-- Percentage breakdown
SELECT location, 
MAX(cast(total_deaths as float))/(SELECT SUM(cast(new_deaths as float)) FROM COVIDProject..Deaths WHERE continent IS NOT NULL) AS death_portion, 
MAX(total_cases)/(SELECT SUM(new_cases) FROM COVIDProject..Deaths WHERE continent IS NOT NULL) AS case_portion
FROM COVIDProject..Deaths 
WHERE continent IS NULL
AND location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY death_portion DESC


-- GLOBAL BREAKDOWN
-- world death rate by date

SELECT date, SUM(total_cases) AS world_total_cases, SUM(cast(total_deaths as INT)) AS world_total_deaths,  SUM(cast(total_deaths as INT))/ SUM(total_cases)*100 AS death_rate
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- current world death rate
SELECT SUM(new_cases) AS world_total_cases, SUM(cast(new_deaths as INT)) AS world_total_deaths,  SUM(cast(new_deaths as INT))/ SUM(new_cases)*100 AS death_rate
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL

-- world infection rate by date
SELECT date, SUM(population) AS world_population, SUM(total_cases) AS world_total_cases, (SUM(total_cases)/SUM(population))*100 AS infection_rate
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- current world infection rate
WITH worldinfections (date, world_population, world_total_cases, infection_rate)
AS
(
SELECT date, SUM(population) AS world_population, SUM(total_cases) AS world_total_cases, (SUM(total_cases)/SUM(population))*100 AS infection_rate
FROM COVIDProject..Deaths
WHERE continent IS NOT NULL
GROUP BY date
)
SELECT MAX(world_total_cases) AS world_total_cases, MAX(world_population) AS world_population, MAX(infection_rate) AS current_infection_rate
FROM worldinfections

-- world vaccinations by date
WITH worldvacc (date, world_population, total_people_vaccinated, percent_vaccinated, percent_fully_vaccinated)
AS
(
SELECT d.date, SUM(d.population) AS world_population, SUM(cast(v.people_vaccinated AS BIGINT)) AS total_people_vaccinated,
	(SUM(cast(v.people_vaccinated AS BIGINT))/SUM(d.population))*100 AS percent_vaccinated,
	(SUM(cast(v.people_fully_vaccinated AS BIGINT))/SUM(d.population))*100 AS percent_fully_vaccinated
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.date
)
SELECT date, world_population, MAX(total_people_vaccinated) OVER (ORDER BY date) AS total_people_vaccinated, 
MAX(percent_vaccinated) OVER (ORDER BY date)  AS percent_vaccinated, 
MAX(percent_fully_vaccinated) OVER (ORDER BY date)  as  percent_fully_vaccinated
FROM worldvacc
ORDER BY 1,2


-- current world vaccinations
WITH worldvaccinations (date, world_population, total_people_vaccinated, percent_vaccinated, percent_fully_vaccinated)
AS
(
SELECT d.date, SUM(d.population) AS world_population, SUM(cast(v.people_vaccinated AS BIGINT)) AS total_people_vaccinated,
	(SUM(cast(v.people_vaccinated AS BIGINT))/SUM(d.population))*100 AS percent_vaccinated,
	(SUM(cast(v.people_fully_vaccinated AS BIGINT))/SUM(d.population))*100 AS percent_fully_vaccinated
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.date
)
SELECT MAX(world_population) AS world_population, MAX(total_people_vaccinated) AS total_people_vaccinated, MAX(percent_vaccinated) AS percent_vaccinated, 
MAX(percent_fully_vaccinated) AS percent_fully_vaccinated
FROM worldvaccinations

-- Vaccinations vs. Death Rate

WITH worldall (date, world_population, total_people_vaccinated, percent_vaccinated, percent_fully_vaccinated, 
daily_deaths, world_total_deaths, death_rate, daily_cases, world_total_cases, infection_rate)
AS
(
SELECT d.date, SUM(d.population) AS world_population, SUM(cast(v.people_vaccinated AS BIGINT)) AS total_people_vaccinated,
	(SUM(cast(v.people_vaccinated AS BIGINT))/SUM(d.population))*100 AS percent_vaccinated,
	(SUM(cast(v.people_fully_vaccinated AS BIGINT))/SUM(d.population))*100 AS percent_fully_vaccinated, SUM(cast(d.new_deaths as INT)),
	SUM(cast(d.total_deaths as INT)) AS world_total_deaths,  SUM(cast(d.total_deaths as INT))/ SUM(d.total_cases)*100 AS death_rate,
	SUM(d.new_cases), SUM(d.total_cases) AS world_total_cases, (SUM(d.total_cases)/SUM(d.population))*100 AS infection_rate
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.date
)
SELECT date, world_population, MAX(total_people_vaccinated) OVER (ORDER BY date) AS total_people_vaccinated, 
MAX(percent_vaccinated) OVER (ORDER BY date)  AS percent_vaccinated, 
MAX(percent_fully_vaccinated) OVER (ORDER BY date)  as  percent_fully_vaccinated,
daily_deaths, world_total_deaths, death_rate, daily_cases, world_total_cases, infection_rate
FROM worldall
ORDER BY 1,2

-- current numbers
WITH worldtotal (date, world_population, total_people_vaccinated, percent_vaccinated, percent_fully_vaccinated, world_total_deaths,
world_total_cases, infection_rate)
AS
(
SELECT d.date, SUM(d.population) AS world_population, SUM(cast(v.people_vaccinated AS BIGINT)) AS total_people_vaccinated,
	(SUM(cast(v.people_vaccinated AS BIGINT))/SUM(d.population))*100 AS percent_vaccinated,
	(SUM(cast(v.people_fully_vaccinated AS BIGINT))/SUM(d.population))*100 AS percent_fully_vaccinated,
	SUM(cast(d.total_deaths as INT)) AS world_total_deaths, 
	SUM(total_cases) AS world_total_cases, (SUM(total_cases)/SUM(population))*100 AS infection_rate
FROM COVIDProject..Deaths d
JOIN COVIDProject..Vaccs v
	ON d.location =  v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY d.date
)
SELECT MAX(world_population) AS world_population, MAX(total_people_vaccinated) AS total_people_vaccinated, MAX(percent_vaccinated) AS percent_vaccinated, 
MAX(percent_fully_vaccinated) AS percent_fully_vaccinated,
MAX(world_total_deaths) AS world_total_deaths, MAX(world_total_deaths)/MAX(world_total_cases) AS death_rate, 
MAX(world_total_cases) AS world_total_cases, MAX(infection_rate) AS infection_rate
FROM worldtotal
ORDER BY 1,2
