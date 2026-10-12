-- =============================================================
-- Post-course improvements (written after the project was graded)
-- See "What I'd change" in the README for the reasoning.
-- =============================================================


-- 1. Enforce the business rules in the database, not just on paper.
--    The design document required a 0-10 rating, non-negative gross
--    and at least one vote; the original DDL did not check them.
ALTER TABLE Movie ADD CONSTRAINT Movie_Rating_CK CHECK (IMDbRating BETWEEN 0 AND 10);
ALTER TABLE Movie ADD CONSTRAINT Movie_Gross_CK  CHECK (Gross >= 0);
ALTER TABLE Movie ADD CONSTRAINT Movie_Votes_CK  CHECK (UserVotes >= 1);


-- 2. Q6 as one query instead of five.
--    Pick the top 5 genres by gross, then rank movies inside each genre
--    with a window function and keep the top 5 per genre.
WITH top_genres AS (
    SELECT g.GenreID, g.GenreName, SUM(m.Gross) AS GenreGross
    FROM Genre g
    JOIN MovieGenre mg ON g.GenreID  = mg.GenreID
    JOIN Movie m       ON mg.MovieID = m.MovieID
    GROUP BY g.GenreID, g.GenreName
    ORDER BY GenreGross DESC
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


-- 3. Q7 grouped by ActorID instead of by name, so two different
--    people who share a name are never merged into one total.
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
