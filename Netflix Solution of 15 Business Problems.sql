-- Netflix Data Analysis using SQL
-- Netflix Solution of 15 Business Problems

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix 
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(210),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(80),
	description VARCHAR(260)
);


-- Retrieve all rows and columns from the netflix table
SELECT * 
FROM netflix;

-- Count the total number of rows (entries) in the netflix table. 
SELECT 
	COUNT(*) AS total_content 
FROM netflix;

-- Different type of content on Netflix
SELECT DISTINCT TYPE
FROM netflix;


-- 1. Count the number of Movies vs TV Shows
SELECT type,
		COUNT(*) AS total_content
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
SELECT 
	type,
	rating
FROM 
(
	SELECT 
			type,
			rating,
			COUNT(*),
			RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1, 2
) AS t1
WHERE 
	ranking = 1


-- 3. List all movies released in a specific year (e.g., 2020)

-- filter 2020
-- only movies

SELECT *
FROM netflix
WHERE 
	type = 'Movie' 
	AND 
	release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


/*
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country
FROM netflix;
*/
/*
Explanation:
1. STRING_TO_ARRAY(country, ','): Splits the country column (a string) into an array of substrings based on 
the comma (,) delimiter.
2. UNNEST(): Converts the array produced by STRING_TO_ARRAY into a set of individual rows.
3. AS new_country: Assigns an alias (new_country) to the output column for readability.
*/


-- 5. Identify the longest movie
SELECT *
FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);


-- 6. Find content added in the last 5 years
SELECT *,
	TO_DATE(date_added, 'Month DD, YYYY')
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


/*
SELECT *,
	TO_DATE(date_added, 'Month DD, YYYY')
FROM netflix;	
*/
/*
Explanation:
Converts the date_added column in the netflix table into a proper DATE format using the TO_DATE function 
in PostgreSQL. This is helpful if the date_added column is stored as a TEXT type but you want to work with it 
as a DATE type.
*/

-- SELECT  CURRENT_DATE - INTERVAL '5 years';  -- date_five_years_ago
/*
Explanation:
1. CURRENT_DATE: Retrieves the current date without a time component.
2. INTERVAL '5 years': Specifies a time interval of 5 years.
3. -: Subtracts the interval from the current date to compute the date 5 years ago.
*/


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- NOTE: The ILIKE operator is used for case-insensitive pattern matching.


SELECT *
FROM (
	SELECT *,
	UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
	FROM netflix
	) AS t
WHERE director_name = 'Rajiv Chilaka';


-- 8. List all TV shows with more than 5 seasons
SELECT * 
FROM netflix
WHERE type = 'TV Show'
	AND SPLIT_PART(duration, ' ', 1)::INT > 5;   -- ::INT Casts the extracted string (e.g., '6') into an integer 
												  -- so it can be used in numerical comparisons.
/*
SELECT
	SPLIT_PART('Apple Banana Cherry', ' ', 1);  -- Apple
*/
/*
Explanation:
1. SPLIT_PART(string, delimiter, field):
	Splits the string into parts using the specified delimiter.
	Returns the part specified by the field (an integer indicating the 1-based index of the part to extract).
2. Arguments:
	'Apple Banana Cherry': The string to split.
	' ' (space): The delimiter used to separate the string.
	1: Specifies that the first part (word) is to be returned.
*/


-- 9. Count the Number of Content Items in Each Genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ' ')) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;


-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month, DD, YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*) :: numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India') :: numeric * 100 
	, 2) AS avg_content_per_year
FROM netflix	
WHERE country = 'India'
GROUP BY 1;


-- 11. List All Movies that are Documentaries
SELECT *
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';


-- 12. Find All Content Without a Director
SELECT *
FROM netflix
WHERE director IS NULL;


-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
	COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
AND type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- Second Method
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
	COUNT(*)
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;


-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords in the description field.
-- Label content containing these keywords as 'Bad' and all other content as 'Good'. 
-- Count how many items fall into each category.
WITH new_table
AS
(
SELECT *,
	CASE
	WHEN 
		description ILIKE '%Kill%' OR 
		description ILIKE '%Violence%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1;


-- Second Method
SELECT 
	category,
	COUNT(*) AS total_content
FROM (
SELECT 
	CASE
		WHEN description ILIKE '%Kill%' OR description ILIKE '%Violence%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END AS category
FROM netflix
) AS categorised_content
GROUP BY category;


