SELECT * FROM netflix_raw where show_id = 's2327';

truncate table netflix_raw;

-- Identify Duplicates

select * from netflix_raw
where concat(type,title,country) in (
	select concat(type,title,country)
	from netflix_raw
	group by concat(type,title,country)
	having count(1) > 1
)
order by title;

-- Get rid of duplicates
with cte as (
	select *,
		ROW_NUMBER() over(partition by title, type, country order by show_id) as rn
	from netflix_raw
)
select * from cte
where rn = 1;

-- Split comma separated values (cols - director, country, cast)

select show_id, trim(value) as director
into netflix_directors
from netflix_raw 
cross apply string_split(director, ',');

select * from netflix_directors;

select show_id, trim(value) as country
into netflix_countries
from netflix_raw
cross apply string_split(country, ',');

select * from netflix_countries;

select show_id, trim(value) as cast
into netflix_casts
from netflix_raw
cross apply string_split(cast, ',');

select * from netflix_casts;

select show_id, trim(value) as genre
into netflix_genres
from netflix_raw
cross apply string_split(listed_in, ',');

select * from netflix_genres;

-- Missing value imputation

-- For country column
select distinct director, country
from netflix_directors nd
join netflix_countries nc
on nd.show_id = nc.show_id;

insert into netflix_countries
select show_id, mp.country
from netflix_raw nr 
join
(
	select distinct director, country
	from netflix_directors nd
	join netflix_countries nc
	on nd.show_id = nc.show_id
) mp on nr.director = mp.director
where nr.country is null;

select * from netflix_raw where duration is null;

-- Query to create final table with no duplicates and other changes in place
with cte as (
	select *,
		row_number() over(partition by title, type, country order by show_id) as rn
	from netflix_raw
)
select show_id, type, title, cast(date_added as date) as date_added, release_year, rating,
	   case when duration is null then rating else duration end as duration, description
into netflix_final
from cte
where rn = 1;

select * from netflix_final;
