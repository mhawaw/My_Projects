select * from [My Projects]..CovidDeaths
order by 3,4 desc;


select Location, date, total_cases,new_cases,total_deaths,population from [My Projects]..CovidDeaths
order by 1,2;

--looking at total cases vs total Deaths
select Location, date, total_cases,total_deaths,ROUND(total_deaths/total_cases,3)*100 as Perc_Death
from [My Projects]..CovidDeaths
order by 1,2;

--looking at total cases vs population
select Location, date, total_cases,population,ROUND(total_cases/population,3)*100 as Perc_Case
from [My Projects]..CovidDeaths
--where location like '%States%'
order by 1,2;

--looking at countries with highest infection rate vs population
select Location, max(total_cases) HIC,population,MAX(ROUND(total_cases/population,4))*100 as Perc_Infected_Pop
from [My Projects]..CovidDeaths
Group by location, population
order by Perc_Infected_Pop desc

--looking at countries with highest Death rate vs population
select Location, max(cast(total_deaths as int)) HDC,population,MAX(ROUND(cast(total_deaths as int)/population,4))*100 as Perc_Death_Pop
from [My Projects]..CovidDeaths
where continent != 'NULL'
Group by location, population
order by HDC desc

--looking at countries with highest Death rate vs population: Breaking down by Continent
select continent, max(cast(total_deaths as int)) HDC,MAX(ROUND(cast(total_deaths as int)/population,4))*100 as Perc_Death_Pop
from [My Projects]..CovidDeaths
where continent != 'NULL'
Group by continent
order by HDC desc


--joining CovidDeaths Table and Vaccinations Table.
--Looking at total population vs Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, sum(convert(int, Vac.new_vaccinations)) over (partition by Dea.Location order by Dea.location, Dea.date) Rolling_People_Vaccinated
from [My Projects]..CovidDeaths Dea
join [My Projects]..CovidVaccinations Vac
	on Dea.location=Vac.location
	and Dea.date=Vac.date
where Dea.continent <> 'NULL'
order by 2,3

--To get the % of people vaccinated over the population, we use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, sum(convert(int, Vac.new_vaccinations)) over (partition by Dea.Location order by Dea.location, Dea.date) Rolling_People_Vaccinated
from [My Projects]..CovidDeaths Dea
join [My Projects]..CovidVaccinations Vac
	on Dea.location=Vac.location
	and Dea.date=Vac.date
where Dea.continent <> 'NULL'
--order by 2,3
)
select *, round((Rolling_People_Vaccinated/Population)*100,3) PercVaccinated
from PopvsVac

--CREATE TEMP TABLE

Drop table if exists #PercVaccinated

Create table #PercVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, sum(convert(int, Vac.new_vaccinations)) over (partition by Dea.Location order by Dea.location, Dea.date) Rolling_People_Vaccinated
from [My Projects]..CovidDeaths Dea
join [My Projects]..CovidVaccinations Vac
	on Dea.location=Vac.location
	and Dea.date=Vac.date
where Dea.continent <> 'NULL'
--order by 2,3

select *, round((Rolling_People_Vaccinated/Population)*100,3) PercVaccinated
from #PercVaccinated

--Create View for later Visualization

Create view PercVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, sum(convert(int, Vac.new_vaccinations)) over (partition by Dea.Location order by Dea.location, Dea.date) Rolling_People_Vaccinated
from [My Projects]..CovidDeaths Dea
join [My Projects]..CovidVaccinations Vac
	on Dea.location=Vac.location
	and Dea.date=Vac.date
where Dea.continent <> 'NULL'
--order by 2,3