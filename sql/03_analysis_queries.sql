-- =============================================================
-- Business questions a streaming service would ask before
-- licensing titles for its catalog (Oracle SQL)
-- Run after 02_data_quality_checks.sql.
-- =============================================================


-- Q1. Which 5 directors have the highest total box-office gross?
SELECT d.DirectorID,
       d.DirectorFirstName,
       d.DirectorLastName,
       SUM(m.Gross) AS TotalGross
FROM Director d
JOIN MovieDirector md ON d.DirectorID = md.DirectorID
JOIN Movie m          ON md.MovieID   = m.MovieID
GROUP BY d.DirectorID, d.DirectorFirstName, d.DirectorLastName
ORDER BY TotalGross DESC NULLS LAST
FETCH FIRST 5 ROWS ONLY;


-- Q2. Which movies are rated above the average Crime-genre rating?
SELECT MovieTitle, IMDbRating
FROM Movie
WHERE IMDbRating > (
        SELECT AVG(m.IMDbRating)
        FROM Movie m
        JOIN MovieGenre mg ON m.MovieID  = mg.MovieID
        JOIN Genre g       ON mg.GenreID = g.GenreID
        WHERE g.GenreName = 'Crime'
      )
ORDER BY IMDbRating DESC;


-- Q3. Top 10 highest-grossing movies rated above 8.0
SELECT MovieTitle, Gross, IMDbRating
FROM Movie
WHERE IMDbRating > 8.0
ORDER BY Gross DESC NULLS LAST
FETCH FIRST 10 ROWS ONLY;


-- Q4. Top 10 highest-rated movies released since 2000
SELECT MovieTitle, IMDbRating, ReleaseYear
FROM Movie
WHERE ReleaseYear >= 2000
ORDER BY IMDbRating DESC
FETCH FIRST 10 ROWS ONLY;


-- Q5. Top 5 genres by total gross
--     A movie with several genres counts toward each of them, so these
--     totals overlap. Use them to rank genres, not to sum box office.
SELECT g.GenreName, SUM(m.Gross) AS TotalGross
FROM Movie m
JOIN MovieGenre mg ON m.MovieID  = mg.MovieID
JOIN Genre g       ON mg.GenreID = g.GenreID
GROUP BY g.GenreName
ORDER BY TotalGross DESC NULLS LAST
FETCH FIRST 5 ROWS ONLY;


-- Q6. Top 5 highest-grossing movies within each of the top 5 genres
--     One query: pick the top genres, then rank movies inside each
--     genre with a window function.
WITH top_genres AS (
    SELECT g.GenreID, g.GenreName, SUM(m.Gross) AS GenreGross
    FROM Genre g
    JOIN MovieGenre mg ON g.GenreID  = mg.GenreID
    JOIN Movie m       ON mg.MovieID = m.MovieID
    GROUP BY g.GenreID, g.GenreName
    ORDER BY GenreGross DESC NULLS LAST
    FETCH FIRST 5 ROWS ONLY
),
ranked AS (
    SELECT tg.GenreName,
           tg.GenreGross,
           m.MovieTitle,
           m.Gross,
           ROW_NUMBER() OVER (PARTITION BY tg.GenreID ORDER BY m.Gross DESC) AS rank_in_genre
    FROM top_genres tg
    JOIN MovieGenre mg ON tg.GenreID = mg.GenreID
    JOIN Movie m       ON mg.MovieID = m.MovieID
    WHERE m.Gross IS NOT NULL
)
SELECT GenreName, rank_in_genre, MovieTitle, Gross
FROM ranked
WHERE rank_in_genre <= 5
ORDER BY GenreGross DESC, rank_in_genre;


-- Q7. Top 10 actors by total gross of the movies they appear in
--     Grouped by ActorID so two people who share a name stay separate.
SELECT a.ActorID,
       a.ActorFirstName,
       a.ActorLastName,
       SUM(m.Gross) AS TotalGross
FROM Actor a
JOIN MovieActor ma ON a.ActorID  = ma.ActorID
JOIN Movie m       ON ma.MovieID = m.MovieID
WHERE m.Gross IS NOT NULL
GROUP BY a.ActorID, a.ActorFirstName, a.ActorLastName
ORDER BY TotalGross DESC
FETCH FIRST 10 ROWS ONLY;


-- Q8. Directors with the most movies rated 8.0 or higher
SELECT d.DirectorID,
       d.DirectorFirstName,
       d.DirectorLastName,
       COUNT(*) AS HighRatedMovies
FROM Director d
JOIN MovieDirector md ON d.DirectorID = md.DirectorID
JOIN Movie m          ON md.MovieID   = m.MovieID
WHERE m.IMDbRating >= 8.0
GROUP BY d.DirectorID, d.DirectorFirstName, d.DirectorLastName
ORDER BY HighRatedMovies DESC;


-- Q9. Directors with the most movies scoring 90+ on Metacritic
SELECT d.DirectorID,
       d.DirectorFirstName,
       d.DirectorLastName,
       COUNT(m.MovieID) AS TotalMovies
FROM Director d
JOIN MovieDirector md ON d.DirectorID = md.DirectorID
JOIN Movie m          ON md.MovieID   = m.MovieID
WHERE m.MetaScore >= 90
GROUP BY d.DirectorID, d.DirectorFirstName, d.DirectorLastName
ORDER BY TotalMovies DESC;


-- Q10. Which genre has the most movies rated 8.0 or higher?
SELECT g.GenreID, g.GenreName, COUNT(m.MovieID) AS TotalMovies
FROM Genre g
JOIN MovieGenre mg ON g.GenreID  = mg.GenreID
JOIN Movie m       ON mg.MovieID = m.MovieID
WHERE m.IMDbRating >= 8.0
GROUP BY g.GenreID, g.GenreName
ORDER BY TotalMovies DESC
FETCH FIRST 1 ROW ONLY;
