-- =============================================================
-- IMDb Top 1000 — streaming catalog database (Oracle)
-- Schema in Third Normal Form, built in Oracle APEX for
-- UB MGS 613: Database Management Systems
--
-- Create order: parent tables first, then associative tables.
-- =============================================================

-- ---------- Parent tables ----------

CREATE TABLE Actor (
    ActorID         VARCHAR2(10)  NOT NULL,
    ActorFirstName  VARCHAR2(100) NOT NULL,
    ActorLastName   VARCHAR2(100),
    CONSTRAINT Actor_PK PRIMARY KEY (ActorID)
);

CREATE TABLE Director (
    DirectorID         VARCHAR2(10)  NOT NULL,
    DirectorFirstName  VARCHAR2(100) NOT NULL,
    DirectorLastName   VARCHAR2(100) NOT NULL,
    CONSTRAINT Director_PK PRIMARY KEY (DirectorID)
);

CREATE TABLE Genre (
    GenreID    VARCHAR2(10)  NOT NULL,
    GenreName  VARCHAR2(100) NOT NULL,
    CONSTRAINT Genre_PK PRIMARY KEY (GenreID)
);

CREATE TABLE Movie (
    MovieID        VARCHAR2(10)  NOT NULL,
    MovieTitle     VARCHAR2(150) NOT NULL,
    Overview       VARCHAR2(500) NOT NULL,
    ReleaseYear    NUMBER(4,0)   NOT NULL,
    ContentRating  VARCHAR2(20),             -- NULL when no certificate
    RunTime        NUMBER        NOT NULL,   -- minutes ("142 min" -> 142)
    Gross          NUMBER,                   -- USD; NULL when unreported
    IMDbRating     NUMBER(3,1)   NOT NULL,
    UserVotes      NUMBER        NOT NULL,
    MetaScore      NUMBER(3),                -- NULL when unreported
    Star1          VARCHAR2(100),
    Star2          VARCHAR2(100),
    Star3          VARCHAR2(100),
    Star4          VARCHAR2(100),
    CONSTRAINT Movie_PK PRIMARY KEY (MovieID)
);

-- ---------- Associative (many-to-many) tables ----------

CREATE TABLE MovieActor (
    MovieID  VARCHAR2(10) NOT NULL,
    ActorID  VARCHAR2(10) NOT NULL,
    CONSTRAINT MovieActor_PK  PRIMARY KEY (MovieID, ActorID),
    CONSTRAINT MovieActor_FK1 FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
    CONSTRAINT MovieActor_FK2 FOREIGN KEY (ActorID) REFERENCES Actor(ActorID)
);

CREATE TABLE MovieDirector (
    MovieID     VARCHAR2(10) NOT NULL,
    DirectorID  VARCHAR2(10) NOT NULL,
    CONSTRAINT MovieDirector_PK  PRIMARY KEY (MovieID, DirectorID),
    CONSTRAINT MovieDirector_FK1 FOREIGN KEY (MovieID)    REFERENCES Movie(MovieID),
    CONSTRAINT MovieDirector_FK2 FOREIGN KEY (DirectorID) REFERENCES Director(DirectorID)
);

CREATE TABLE MovieGenre (
    MovieID  VARCHAR2(10) NOT NULL,
    GenreID  VARCHAR2(10) NOT NULL,
    CONSTRAINT MovieGenre_PK  PRIMARY KEY (MovieID, GenreID),
    CONSTRAINT MovieGenre_FK1 FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
    CONSTRAINT MovieGenre_FK2 FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
);

-- ---------- Example rows (one movie across every table) ----------

INSERT INTO Actor (ActorID, ActorFirstName, ActorLastName)
VALUES ('A00001', 'Daisy', 'Ridley');

INSERT INTO Director (DirectorID, DirectorFirstName, DirectorLastName)
VALUES ('D0001', 'J.J.', 'Abrams');

INSERT INTO Genre (GenreID, GenreName)
VALUES ('G001', 'Action');

INSERT INTO Movie (MovieID, MovieTitle, Overview, ReleaseYear, ContentRating,
                   RunTime, Gross, IMDbRating, UserVotes, MetaScore,
                   Star1, Star2, Star3, Star4)
VALUES ('m001', 'Star Wars: Episode VII - The Force Awakens',
        'As a new threat to the galaxy rises, Rey, a desert scavenger, and Finn, an ex-stormtrooper, must join Han Solo and Chewbacca to search for the one hope of restoring peace.',
        2015, 'U', 138, 936662225, 7.9, 860823, 80,
        'Daisy Ridley', 'John Boyega', 'Oscar Isaac', 'Domhnall Gleeson');

INSERT INTO MovieActor    (MovieID, ActorID)    VALUES ('m001', 'A00001');
INSERT INTO MovieDirector (MovieID, DirectorID) VALUES ('m001', 'D0001');
INSERT INTO MovieGenre    (MovieID, GenreID)    VALUES ('m001', 'G001');
