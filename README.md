# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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

```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
-- filter 2020
-- only movies

SELECT *
FROM netflix
WHERE 
	type = 'Movie' 
	AND 
	release_year = 2020;

```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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

```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT *
FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
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

```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
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

```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
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
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ' ')) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;

```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month, DD, YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*) :: numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India') :: numeric * 100 
	, 2) AS avg_content_per_year
FROM netflix	
WHERE country = 'India'
GROUP BY 1;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director IS NULL;

```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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


```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Wilson Lakra

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media and join our community:

## Contact

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/wilson-lakra-639ab92a4/)

Thank you for your interest in this project!
