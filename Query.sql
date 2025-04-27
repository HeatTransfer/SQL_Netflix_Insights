/*
1. Count no. of movies and tv shows made by each director, who have created movies and tv shows both.
*/
with cte as (
	select nd.director as director, nf.type as type
	from netflix_final nf
	join netflix_directors nd on nf.show_id = nd.show_id
),
cte2 as (
select director, 
	case when type='Movie' then 1 else 0 end as Movie,
	case when type='TV Show' then 1 else 0 end as TV
from cte)

select director, sum(movie) as movie, sum(tv) as tv
from cte2
group by director
having sum(movie) >= 1 and sum(tv) >= 1;

/* 2. Which country has highest no. of comedy movies */
select top 1 nc.country, count(1) as no_of_comedy_films
from netflix_genres ng
join netflix_final nf on ng.show_id = nf.show_id and nf.type = 'Movie'
join netflix_countries nc
on ng.show_id = nc.show_id and ng.genre in ('Comedies', 'Stand-Up Comedy')
group by nc.country
order by no_of_comedy_films desc;


/*
3. For each year (as per date added), which director has max no. of movie released?
*/
select * from netflix_final;

with cte as (
	select year(date_added) as added_year, nd.director, count(nd.show_id) as no_of_movies
	from netflix_final nf
	join netflix_directors nd on nf.show_id = nd.show_id and nf.type='Movie'
	group by year(date_added), nd.director
	--order by no_of_movies desc
)
select added_year, director, no_of_movies from
(
	select *, rank() over(partition by added_year order by no_of_movies desc) as rnk from cte
) d
where d.rnk=1;


/* 4. Average duration of movies in each genre */
select genre, avg(duration_int) as avg_duration from (
	select ng.genre, cast(replace(duration, ' min', '') as int) as duration_int
	from netflix_final nf
	join netflix_genres ng on nf.show_id = ng.show_id
	where type = 'Movie'
) d
group by genre;

/*
5. Find the list of directors who have created horror as well as comedy.
   Display names along with no. of comedy and horror movies directed by them.
*/
select nd.director, 
	sum(case when ng.genre in ('comedies','stand-up comedy') then 1 else 0 end) as comedy,
	sum(case when ng.genre = 'Horror Movies' then 1 else 0 end) as horror
from netflix_final nf
join netflix_genres ng 
on nf.show_id = ng.show_id
join netflix_directors nd on nf.show_id = nd.show_id
where type = 'Movie' and (ng.genre like '%horror%' or genre like '%comed%')
group by nd.director
having count(distinct ng.genre) > 1;


