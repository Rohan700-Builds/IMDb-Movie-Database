-- =============================================================
-- Data-quality checks and fixes, run after loading the CSV
-- (Oracle SQL)
-- =============================================================


-- ---------- Check 1: co-directors loaded as actors ----------
-- For co-directed films the source file puts the second director in
-- the Star1 slot, so they arrive as the first-billed "actor".
-- Flag first-billed actors who share a surname with the film's
-- director but have a different first name (the Russos, the Coens).

CREATE OR REPLACE VIEW CoDirectorCandidates AS
SELECT ma.MovieID,
       a.ActorID,
       a.ActorFirstName,
       a.ActorLastName
FROM MovieActor ma
JOIN Actor a          ON a.ActorID     = ma.ActorID
JOIN MovieDirector md ON md.MovieID    = ma.MovieID
JOIN Director d       ON d.DirectorID  = md.DirectorID
WHERE ma.BillingOrder   = 1
  AND a.ActorLastName   = d.DirectorLastName
  AND a.ActorFirstName <> d.DirectorFirstName;

-- Review what was flagged before fixing it
SELECT * FROM CoDirectorCandidates;

-- Fix 1a: add any flagged person who isn't a director yet
INSERT INTO Director (DirectorID, DirectorFirstName, DirectorLastName)
SELECT 'D' || LPAD(TO_CHAR(
           (SELECT COUNT(*) FROM Director)
           + ROW_NUMBER() OVER (ORDER BY n.ActorLastName, n.ActorFirstName)), 4, '0'),
       n.ActorFirstName,
       n.ActorLastName
FROM (SELECT DISTINCT c.ActorFirstName, c.ActorLastName
      FROM CoDirectorCandidates c
      WHERE NOT EXISTS (SELECT 1 FROM Director d
                        WHERE d.DirectorFirstName = c.ActorFirstName
                          AND d.DirectorLastName  = c.ActorLastName)) n;

-- Fix 1b: credit them as directors of those movies
INSERT INTO MovieDirector (MovieID, DirectorID)
SELECT c.MovieID, d.DirectorID
FROM CoDirectorCandidates c
JOIN Director d ON d.DirectorFirstName = c.ActorFirstName
               AND d.DirectorLastName  = c.ActorLastName;

-- Fix 1c: remove the mistaken actor credit (only the flagged rows, so a
-- real actor-director like Clint Eastwood starring in his own film is kept)
DELETE FROM MovieActor ma
WHERE (ma.MovieID, ma.ActorID) IN (SELECT c.MovieID, c.ActorID
                                   FROM CoDirectorCandidates c);

-- Fix 1d: drop actors who no longer appear in any movie
DELETE FROM Actor a
WHERE NOT EXISTS (SELECT 1 FROM MovieActor ma WHERE ma.ActorID = a.ActorID);


-- ---------- Check 2: garbled characters from a wrong encoding ----------
-- Loading as Latin-1 instead of UTF-8 turns "Cuarón" into "CuarÃ³n".
-- After a UTF-8 load this should return no rows.
SELECT 'Director' AS source_table, DirectorFirstName || ' ' || DirectorLastName AS name
FROM Director
WHERE DirectorFirstName || DirectorLastName LIKE '%Ã%'
UNION ALL
SELECT 'Actor', ActorFirstName || ' ' || ActorLastName
FROM Actor
WHERE ActorFirstName || ActorLastName LIKE '%Ã%'
UNION ALL
SELECT 'Movie', MovieTitle
FROM Movie
WHERE MovieTitle LIKE '%Ã%';


-- ---------- Check 3: every movie has a director and a genre ----------
-- Business rule: each title has at least one director and one genre.
-- Should return no rows.
SELECT m.MovieID, m.MovieTitle
FROM Movie m
WHERE NOT EXISTS (SELECT 1 FROM MovieDirector md WHERE md.MovieID = m.MovieID)
   OR NOT EXISTS (SELECT 1 FROM MovieGenre mg    WHERE mg.MovieID = m.MovieID);
