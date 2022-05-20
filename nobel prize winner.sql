select * 
from Nobel_Prize_Winners

--country of birth with most award won by category
with A2 
as (
	select *,
	ROW_NUMBER() over (partition by category order by prizewon desc) as rownum
	from (
		select category,born_country_code, COUNT(born_country_code) as prizewon
		from Nobel_Prize_Winners
		group by category,born_country_code)as A1
	     )
select category,born_country_code,prizewon
from A2 
where rownum = 1

--lauretes total prize's won and list of categories
select firstname+' '+surname as name,COUNT(firstname) as prizewon,
       stuff((select  distinct (',' + category) 
			  from Nobel_Prize_Winners B1
			  where B1.firstname = B2.firstname and B1.surname = B2.surname
		      for xml path('')),
		1,1,'') as category
from Nobel_Prize_Winners B2
group by firstname,surname 
order by 2 desc

--universities and total prize won
select isnull(name_of_university,'Unknown') as name_of_university, 
	   isnull(country_of_university,'Unknown') as country_of_university,
	   count(firstname) as prizewon 
from Nobel_Prize_Winners
group by name_of_university, country_of_university
order by prizewon desc

--total laureate
select count( distinct laureatename) as 'Total laureate' 
from  (select isnull(firstname+' '+surname,firstname) as laureatename 
	   from Nobel_Prize_Winners) as name

--total laureate in each category
select category, count( distinct laureate_name) as 'Total laureate' 
from (select isnull(firstname+' '+surname,firstname) as laureate_name, category 
	  from Nobel_Prize_Winners) as name
	  group by category

--first prize winners in each category
select category, firstname+' '+surname as Name, gender,year 
from Nobel_Prize_Winners
where year = (select MIN(year) 
			  from Nobel_Prize_Winners)
union
select category, firstname+' '+surname as Name, gender,year 
from Nobel_Prize_Winners
where category = 'economics' and year = (select MIN(year) 
										 from Nobel_Prize_Winners 
										 where category = 'economics')
order by year,category

--recent prize winners in each category
select category, firstname+' '+surname as Name, gender,year 
from Nobel_Prize_Winners
where year = (select MAX(year) from Nobel_Prize_Winners)

--gender distribtion in each category
with C1 as (
	select category,laureatename, case when gender = 'male' then ('male') else null end as Male, 
		      case when gender = 'female' then ('female') else null end as Female
	from  (select distinct(isnull(firstname+' '+surname,firstname)) as laureatename,category,gender 
		   from Nobel_Prize_Winners) as name
		   )
select category,count(male) as Male, count(female) as Female
from C1
group by category