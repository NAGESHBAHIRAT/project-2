select * from project.dbo.Sheet1

select * from project.dbo.Sheet2



-- number of rows


select count(*) from project..Sheet1

select count(*) from project..Sheet2




-- dataset for bihar and jharkhand


select * from project..Sheet1 where State in ('Jharkhand','Bihar')




-- total population of india


select sum(Population) as population from project..Sheet2




-- Average growth of india


select AVG(Growth)*100 as average_growth from project..Sheet1





-- average growth by state


select State,AVG(Growth)*100 as avg_growth from project..Sheet1 group by state




-- average sex ratio


select state,round(AVG(Sex_ratio),0) as Avg_sex_ratio from project..Sheet1 group by state




-- in decending order


select state,ROUND(AVG(sex_ratio),0) as avg_sex_ratio from project..Sheet1 group by state order by avg_sex_ratio desc




-- average literacy rate


select state,round(AVG(literacy),0) as Avg_literacy from project..Sheet1 group by state




-- average literacy rate (more than 90)


select state,round(AVG(literacy),0) as Avg_literacy from project..Sheet1
group by state having round(AVG(literacy),0)>90 order by Avg_literacy desc;





--top 3 states showing highest average growth


select top 3 State,AVG(Growth)*100 as avg_growth from project..Sheet1 group by state order by avg_growth desc;





--bottom 3 states


select top 3 State,AVG(Growth)*100 as avg_growth from project..Sheet1 group by state order by avg_growth asc;




--top and bottom 4 states litrecy ratio

drop table if exists #topstates;

create table #topstates
( state nvarchar(255),
 topstates float

 )

 insert into #topstates
 select state,round(AVG(literacy),0) as Avg_literacy from project..Sheet1 
 group by state order by Avg_literacy desc

select top 3 * from #topstates order by #topstates.topstates desc



drop table if exists #bottomstates;

create table #bottomstates
( state nvarchar(255),
 bottomstates float

 )

 insert into #bottomstates

 select state,round(AVG(literacy),0) as Avg_literacy from project..Sheet1 
 group by state order by Avg_literacy asc

select top 3 * from #bottomstates order by #bottomstates.bottomstates asc


-- using union opretor


select * from(
select top 3 * from #topstates order by #topstates.topstates desc
)a

union

select * from(
select top 3 * from #bottomstates order by #bottomstates.bottomstates asc
)b





-- states starting with letter a and b


select distinct state from project..Sheet1 where lower(state) like 'a%' or lower(state) like'b%'





-- states stating with letter m and ending at a


select distinct state from project..Sheet1 where lower(state) like 'm%' and lower(state) like'%a'





-- joining tables

select a.district,a.state,a.Sex_Ratio,b.population from project..Sheet1 a inner join project..Sheet2 b on a.district=b.district





-- number of males and females 
--females/males=sex_ratio.....1
--females+males=population.........2
--females=population-males.........3
--(population-male)=(sex_ratio)*males
--population=males(sex_ratio+1)
--males=population/(sex_ratio+1)
--females=population-population/(sex_ratio+1)



select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state,round(c.population/(c.Sex_Ratio+1),0) males,round((c.population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) females from
 ( select a.district,a.state,a.Sex_Ratio/1000 sex_ratio,b.population from project..Sheet1 a inner join project..Sheet2 b on a.district=b.district)c)d

 group by d.state;





 -- total literacy rate 
 -- total literate people/population=literacy rate 
 --total literate people=literacy ratio*population
 --total illiterate people=(1-literate_ratio)*population



 select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_illiterate_pop from
 (select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,round((1-literacy_ratio)*d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio ,b.population from project..Sheet1 a inner join project..Sheet2 b on a.district=b.district)d)c
group by c.state





-- population in previous census
--previous_census+growth*previous_census=population
--previous_census=population/(1+growth)

select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(d.growth+1),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..Sheet1 a inner join project..Sheet2 b on a.district=b.district)d)e
group by e.state


-- total polulation in previous census and current census

select sum(m.previous_census_population) total_previous_pop,sum(m.current_census_population) total_current_pop from
(select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(d.growth+1),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..Sheet1 a inner join project..Sheet2 b on a.district=b.district)d)e
group by e.state)m
