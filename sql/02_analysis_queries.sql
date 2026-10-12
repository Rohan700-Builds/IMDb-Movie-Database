-- =============================================================
-- Business questions a streaming service would ask before
-- licensing titles for its catalog (Oracle SQL)
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
ORDER BY TotalGross DESC
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
ORDER BY Gross DESC
FETCH FIRST 10 ROWS ONLY;


-- Q4. Top 10 highest-rated movies released since 2000
SELECT MovieTitle, IMDbRating, ReleaseYear
FROM Movie
WHERE ReleaseYear >= 2000
ORDER BY IMDbRating DESC
FETCH FIRST 10 ROWS ONLY;


-- Q5. Top 5 genres by total gross
SELECT g.GenreName, SUM(m.Gross) AS TotalGross
FROM Movie m
JOIN MovieGenre mg ON m.MovieID  = mg.MovieID
JOIN Genre g       ON mg.GenreID = g.GenreID
GROUP BY g.GenreName
ORDER BY TotalGross DESC
FETCH FIRST 5 ROWS ONLY;


-- Q6. Top 5 highest-grossing movies within each of the top 5 genres
--     Original approach: one query per genre (Adventure shown), run five
--     times for Adventure, Drama, Action, Comedy and Sci-Fi.
--     A single-query version is in 03_improvements.sql.
SELECT m.MovieID, m.MovieTitle, m.Gross
FROM Movie m
JOIN MovieGenre mg ON m.MovieID  = mg.MovieID
JOIN Genre g       ON mg.GenreID = g.GenreID
WHERE g.GenreName = 'Adventure'
ORDER BY m.Gross DESC
FETCH FIRST 5 ROWS ONLY;


-- Q7. Top 10 actors by total gross of the movies they appear in
SELECT a.ActorFirstName,
       a.ActorLastName,
       SUM(m.Gross) AS TotalGross
FROM Actor a
JOIN MovieActor ma ON a.ActorID  = ma.ActorID
JOIN Movie m       ON ma.MovieID = m.MovieID
WHERE m.Gross IS NOT NULL
GROUP BY a.ActorFirstName, a.ActorLastName
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
