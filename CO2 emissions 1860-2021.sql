--This Projects uses data from https://ourworldindata.org/co2/country/finland to follow Finlands CO2 emissions by following the global emissions and fuel emissions. 
--Creating an understanding of the emissions over the years between 1860 to 2021.
--Showcasing the difference of continents in 2021 emissions as well as top 3 countries with the highest emissions.





---------------------------------------------------------------------------------------------------------------------------------------
--Here we colect data from two tables to be able to count the percentages of fuel sources from the total emissions between 1860-2021.
--Also sorted by the highest emissions by year.
---------------------------------------------------------------------------------------------------------------------------------------

select 
--FuelEmissions.Entity as Country, 
FuelEmissions.Year, 
	[Annual CO2 emissions from oil] CO2_from_Oil, 
	[Annual CO2 emissions from coal] CO2_from_Coal,
	[Annual CO2 emissions from cement] CO2_from_Cement,
	[Annual CO2 emissions from gas] CO2_from_Gas,
	[Annual CO2 emissions from other industry] CO2_from_Other,
	[Annual CO2 emissions] Annual_CO2

From Portfolio..co2_emissions_by_fuel_line FuelEmissions

--Here we join the tables to compare the Fuel emissions amounts against the annual total CO2 emissions.
Inner Join Portfolio..annual_co2_emissions_per_country TotalEmissions
	ON FuelEmissions.Entity = TotalEmissions.Entity
	AND FuelEmissions.Code = TotalEmissions.Code
	AND FuelEmissions.Year = TotalEmissions.Year

Where FuelEmissions.Entity = 'Finland'
Order by [Annual CO2 emissions] DESC;



---------------------------------------------------------------------------------------------------------------------------------------
--Finlands CO2 emissions based on fuel sources in percentages compared against the years total annual CO2 emissions between 1860-2021.--
---------------------------------------------------------------------------------------------------------------------------------------

With CTE_Precentages AS (
select 
FuelEmissions.Entity as Country, 
FuelEmissions.Year,
[Annual CO2 emissions] Total_Annual_CO2,

		([Annual CO2 emissions from oil]/[Annual CO2 emissions])*100 as OilPercentage,
		([Annual CO2 emissions from coal]/[Annual CO2 emissions])*100 as CoalPercentage,
		([Annual CO2 emissions from cement]/[Annual CO2 emissions])*100 as CementPercentage,
		([Annual CO2 emissions from gas]/[Annual CO2 emissions])*100 as GasPercentage,
		([Annual CO2 emissions from other industry]/[Annual CO2 emissions])*100 as OtherPercentage

From Portfolio..co2_emissions_by_fuel_line FuelEmissions

Inner Join Portfolio..annual_co2_emissions_per_country TotalEmissions
	ON FuelEmissions.Entity = TotalEmissions.Entity
	AND FuelEmissions.Code = TotalEmissions.Code
	AND FuelEmissions.Year = TotalEmissions.Year
	Where FuelEmissions.Entity = 'Finland')

select Year, Total_Annual_CO2,
		Round(OilPercentage,2) as OilPercentage,
		Round(CoalPercentage,2) as CoalPercentage,
		Round(CementPercentage,2) as CementPercentage,
		Round(GasPercentage,2) as GasPercentage,
		Round(OtherPercentage,2) as OtherPercentage

From CTE_Precentages
Order by Year DESC




---------------------------------------------------------------------------------------------------------------------------------------
--World and Finland Annual CO2 emissions
---------------------------------------------------------------------------------------------------------------------------------------


select Entity, Year, [Annual CO2 emissions]
From Portfolio..annual_co2_emissions_per_country
Where Entity = 'World'
AND year = 2021 
OR Entity ='Finland'
AND year = 2021 
Order by [Annual CO2 emissions] DESC
--The Worlds and Finlands Annual CO2 emissions from 2021.


-------------------------------------------------------------------------------------------------------------------------
--Next two temporary tables are used to help determine Finlands percentage of the total world CO2 emissions from 2021.--
-------------------------------------------------------------------------------------------------------------------------

Drop Table IF EXISTS #CO2_FIN
SELECT
    Entity,
    Year,
	[Annual CO2 emissions] as FinEmissions
INTO #CO2_FIN --- temporary table
FROM
    Portfolio..annual_co2_emissions_per_country
WHERE
    Entity ='Finland'
	AND Year = 2021

Drop Table IF EXISTS #CO2_WORLD
SELECT
    Entity,
    Year,
	[Annual CO2 emissions] as WorldEmissions
INTO #CO2_WORLD --- temporary table
FROM
    Portfolio..annual_co2_emissions_per_country
WHERE
    Entity ='World'
	AND Year = 2021

--Now we are able to calculate Finlands percentage of the world CO2 emissions from 2021.
	select Entity as Country,(FinEmissions/(select WorldEmissions from #CO2_WORLD))* 100.0 Precentage
from #CO2_FIN
Group by Entity, FinEmissions
Order by Precentage




---------------------------------------------------------------------------------------------------------------------------------------
--The top 3 countries of 2021 with the highest individual Annual CO2 emission.
---------------------------------------------------------------------------------------------------------------------------------------


select top 3 Entity as Country, Code, Year, [Annual CO2 emissions]
From Portfolio..annual_co2_emissions_per_country
Where year = 2021 
AND Code is not null
AND Entity <> 'World'
Order by [Annual CO2 emissions] DESC


---------------------------------------------------------------------------------------------------------------------------------------
--China's percentage of total annual CO2 emissions as the top emission contributor in 2021.
---------------------------------------------------------------------------------------------------------------------------------------


select Entity as Country, Year,[Share of global annual CO2 emissions]
From Portfolio..annual_share_of_co2_emissions 
Where Entity = 'China'
AND year = 2021
Order by year DESC
--Chinas Share of global annual CO2 emissions by year from 2021 to 1860 so we can then see its percentage of the world CO2 emissions in 2021.



---------------------------------------------------------------------------------------------------------------------------------------
--CO2 emissions total and by fuel source separated into all continents from 2021. 
---------------------------------------------------------------------------------------------------------------------------------------

select 
FuelEmissions.Entity as Continent, 
FuelEmissions.Year, 
[Annual CO2 emissions] Total_CO2_Annually,
[Annual CO2 emissions from oil] CO2_From_Oil, 
[Annual CO2 emissions from coal] CO2_From_Coal, 
[Annual CO2 emissions from cement] CO2_From_Cement,
[Annual CO2 emissions from gas] CO2_From_Gas, 
[Annual CO2 emissions from other industry] CO2_From_Other

From Portfolio..co2_emissions_by_fuel_line as FuelEmissions
Join Portfolio..annual_co2_emissions_per_country as TotalEmissions
	ON FuelEmissions.Entity = TotalEmissions.Entity
	AND FuelEmissions.Year = TotalEmissions.Year
Where FuelEmissions.Entity IN ('Asia','North America', 'Europe', 'Africa', 'South America','Oceania')
AND FuelEmissions.Year = 2021
Order by [Annual CO2 emissions] DESC
--Annual CO2 emissions by continent in 2021.



---------------------------------------------------------------------------------------------------------------------------------------
--All 2021 CO2 emissions based on Country
---------------------------------------------------------------------------------------------------------------------------------------

select Entity as Country, Year, [Annual CO2 emissions]
From Portfolio..annual_co2_emissions_per_country
Where year = 2021
And Code is not null
And Entity <> 'World'
Order by [Annual CO2 emissions] DESC


---------------------------------------------------------------------------------------------------------------------------------------
--Average of the total world CO2 emissions from 2021--
---------------------------------------------------------------------------------------------------------------------------------------

select avg([Annual CO2 emissions])Average_Emissions
From Portfolio..annual_co2_emissions_per_country
Where year = 2021
AND Entity <> 'World'
AND Code is not null


---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

