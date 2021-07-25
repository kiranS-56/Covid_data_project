
--Changing datatype from varchar to integer or float (for nuerical values)

	ALTER TABLE Covid_data
	ALTER COLUMN population float

	ALTER TABLE Covid_data
	ALTER COLUMN total_cases float

	ALTER TABLE Covid_data
	ALTER COLUMN new_cases float

	ALTER TABLE Covid_data
	ALTER COLUMN total_deaths float

	ALTER TABLE Covid_data
	ALTER COLUMN new_deaths float

	ALTER TABLE Covid_data
	ALTER COLUMN icu_patients float

	ALTER TABLE Covid_data
	ALTER COLUMN hosp_patients float

	ALTER TABLE Covid_data
	ALTER COLUMN weekly_icu_admissions float

	ALTER TABLE Covid_data
	ALTER COLUMN weekly_hosp_admissions float

--Checking datatype of all columns

	SELECT 
	TABLE_CATALOG,
	TABLE_SCHEMA,
	TABLE_NAME, 
	COLUMN_NAME, 
	DATA_TYPE 
	FROM INFORMATION_SCHEMA.COLUMNS
	where TABLE_NAME = 'Covid_data'


--Covid data related to cases and death
	select location, date, total_cases, new_cases, total_deaths, population
	from Covid_data
	order by location, date

	
--Covid death percentage in India
--Death percentage = likelyhood of dying due to covid if a person has covid
    select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
	from Covid_data
	where location = 'India'
	order by date

--Cases vs population
--percentage of population of India who tested positive
    select location, date, population, total_cases, (total_cases/population)*100 as Positive_Percentage
	from Covid_data
	where location = 'India'
	order by date
	
--Determining the countries with highest positive cases
    select location, population, max(total_cases) as max_total_cases, max((total_cases/population))*100 as Infection_Percentage
	from Covid_data
	where population > 0
	group by location, population
	order by Infection_Percentage desc

--Determining the countries with highest deaths
    select location, max(total_deaths) as max_total_deaths
	from Covid_data
	where population > 0 and continent <> ''
	group by location
	order by max_total_deaths desc

--Determining the deaths by continents 
    select continent, max(total_deaths) as max_total_deaths
	from Covid_data
	where continent <> ''
	group by continent
	order by max_total_deaths desc

--new cases and deaths by date
    select date, sum(new_cases) as cases, sum(new_deaths) as deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
	from Covid_data
	where continent <> '' and new_cases <> 0
	group by date
	order by date

-- total cases and death (world numbers)
    select sum(new_cases) as cases, sum(new_deaths) as deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
	from Covid_data
	where continent <> '' and new_cases <> 0

-- Eyeballing the data in covid_vaccination table
   select * from covid_vaccination_data

-- useful columns are the ones related to test numbers and vaccination numbers
	
-- joining the 2 tables to determine total population vs new vaccinations each day

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from Covid_data dea
join covid_vaccination_data vac
   on dea.location = vac.location 
   and dea.date = vac.date
where dea.continent <> ''
order by 1,2,3

-- determining total vaccinations in a country and percentage of population vaccinated
with PopulationVaccinated (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) 
as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 ,SUM(vac.new_vaccinations) Over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
 from Covid_data dea
 join covid_vaccination_data vac
      on dea.location = vac.location 
      and dea.date = vac.date
 where dea.continent <> '' AND dea.population > 0
 ) 

select *, (rolling_people_vaccinated/population)*100 as percentage_vaccinated from PopulationVaccinated 
order by 1,2,3

-- creating a view for visualization

Create View percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 ,SUM(vac.new_vaccinations) Over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
 from Covid_data dea
 join covid_vaccination_data vac
      on dea.location = vac.location 
      and dea.date = vac.date
 where dea.continent <> '' AND dea.population > 0
  
select * from percentpopulationvaccinated



	
