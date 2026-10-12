-- =============================================================
-- IMDb Top 1000 — streaming catalog database (Oracle)
-- Schema in Third Normal Form, built in Oracle APEX for
-- UB MGS 613: Database Management Systems
--
-- Create order: parent tables first, then associative tables.
-- Business rules are enforced with CHECK constraints.
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
    CONSTRAINT Movie_PK        PRIMARY KEY (MovieID),
    CONSTRAINT Movie_Rating_CK CHECK (IMDbRating BETWEEN 0 AND 10),
    CONSTRAINT Movie_Gross_CK  CHECK (Gross >= 0),
    CONSTRAINT Movie_Votes_CK  CHECK (UserVotes >= 1),
    CONSTRAINT Movie_Run_CK    CHECK (RunTime > 0)
);

-- ---------- Associative (many-to-many) tables ----------

-- BillingOrder replaces the source file's Star1..Star4 columns
CREATE TABLE MovieActor (
    MovieID       VARCHAR2(10) NOT NULL,
    ActorID       VARCHAR2(10) NOT NULL,
    BillingOrder  NUMBER(1)    NOT NULL,
    CONSTRAINT MovieActor_PK      PRIMARY KEY (MovieID, ActorID),
    CONSTRAINT MovieActor_FK1     FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
    CONSTRAINT MovieActor_FK2     FOREIGN KEY (ActorID) REFERENCES Actor(ActorID),
    CONSTRAINT MovieActor_Bill_CK CHECK (BillingOrder BETWEEN 1 AND 4),
    CONSTRAINT MovieActor_Bill_UQ UNIQUE (MovieID, BillingOrder)
);

-- A movie can have more than one director (e.g. the Russo brothers)
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

INSERT INTO Director (DirectorID, DirectorFirstName, DirectorLastName)
VALUES ('D0001', 'J.J.', 'Abrams');

INSERT INTO Genre (GenreID, GenreName)
VALUES ('G001', 'Action');

INSERT INTO Movie (MovieID, MovieTitle, Overview, ReleaseYear, ContentRating,
                   RunTime, Gross, IMDbRating, UserVotes, MetaScore)
VALUES ('m001', 'Star Wars: Episode VII - The Force Awakens',
        'As a new threat to the galaxy rises, Rey, a desert scavenger, and Finn, an ex-stormtrooper, must join Han Solo and Chewbacca to search for the one hope of restoring peace.',
        2015, 'U', 138, 936662225, 7.9, 860823, 80);

INSERT INTO Actor (ActorID, ActorFirstName, ActorLastName) VALUES ('A00001', 'Daisy', 'Ridley');
INSERT INTO Actor (ActorID, ActorFirstName, ActorLastName) VALUES ('A00002', 'John', 'Boyega');
INSERT INTO Actor (ActorID, ActorFirstName, ActorLastName) VALUES ('A00003', 'Oscar', 'Isaac');
INSERT INTO Actor (ActorID, ActorFirstName, ActorLastName) VALUES ('A00004', 'Domhnall', 'Gleeson');

INSERT INTO MovieActor (MovieID, ActorID, BillingOrder) VALUES ('m001', 'A00001', 1);
INSERT INTO MovieActor (MovieID, ActorID, BillingOrder) VALUES ('m001', 'A00002', 2);
INSERT INTO MovieActor (MovieID, ActorID, BillingOrder) VALUES ('m001', 'A00003', 3);
INSERT INTO MovieActor (MovieID, ActorID, BillingOrder) VALUES ('m001', 'A00004', 4);

INSERT INTO MovieDirector (MovieID, DirectorID) VALUES ('m001', 'D0001');
INSERT INTO MovieGenre    (MovieID, GenreID)    VALUES ('m001', 'G001');
