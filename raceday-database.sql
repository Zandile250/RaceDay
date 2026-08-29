/* ============================================================
   RaceDay Database Script
   Part 1, Section C — matches the ERD in erd.png exactly.
   Target: SQL Server (run in SSMS)
   ============================================================ */

IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

/* ------------------------------------------------------------
   Drop tables if they already exist (child -> parent order)
   so this script can be re-run cleanly during development.
   ------------------------------------------------------------ */
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

/*    TABLE: Roles
   */
CREATE TABLE dbo.Roles (
    RoleId      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    VARCHAR(20) NOT NULL UNIQUE
);
GO

/* 
   TABLE: Users
   */
CREATE TABLE dbo.Users (
    UserId          INT IDENTITY(1,1) PRIMARY KEY,
    RoleId          INT NOT NULL,
    FullName        VARCHAR(100) NOT NULL,
    Email           VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255) NOT NULL,
    PhoneNumber     VARCHAR(20) NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId)
        REFERENCES dbo.Roles(RoleId)
);
GO

/*    TABLE: Events
    */

CREATE TABLE dbo.Events (
    EventId         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId     INT NOT NULL,
    EventName       VARCHAR(150) NOT NULL,
    Description     VARCHAR(1000) NULL,
    EventDate       DATETIME NOT NULL,
    Location        VARCHAR(150) NOT NULL,
    RouteInfo       VARCHAR(500) NULL,
    ImageUrl        VARCHAR(500) NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId)
        REFERENCES dbo.Users(UserId)
);
GO

/*    TABLE: Categories
   */

CREATE TABLE dbo.Categories (
    CategoryId       INT IDENTITY(1,1) PRIMARY KEY,
    EventId          INT NOT NULL,
    CategoryName     VARCHAR(100) NOT NULL,
    DistanceKm       DECIMAL(5,2) NOT NULL,
    Price            DECIMAL(8,2) NOT NULL DEFAULT 0,
    MaxParticipants  INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId)
);
GO

/*
   TABLE: Enrolments
    */

CREATE TABLE dbo.Enrolments (
    EnrolmentId      INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId    INT NOT NULL,
    CategoryId       INT NOT NULL,
    EnrolmentDate    DATETIME NOT NULL DEFAULT GETDATE(),
    Status           VARCHAR(20) NOT NULL DEFAULT 'Confirmed',
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantId)
        REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId)
        REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT UQ_Enrolments_Participant_Category UNIQUE (ParticipantId, CategoryId)
);
GO

/* 
   TABLE: Results  (one-to-one with Enrolments)
    */

CREATE TABLE dbo.Results (
    ResultId       INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId    INT NOT NULL UNIQUE,
    FinishTime     TIME NULL,
    Position       INT NULL,
    Status         VARCHAR(20) NOT NULL DEFAULT 'Finished',
    CapturedAt     DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId)
        REFERENCES dbo.Enrolments(EnrolmentId)
);
GO

/* 
   SEED DATA
    */

-- Roles
INSERT INTO dbo.Roles (RoleName) VALUES ('Organiser'), ('Participant');
GO

-- Users: 2 Organisers, 2 Participants
INSERT INTO dbo.Users (RoleId, FullName, Email, PasswordHash, PhoneNumber)
VALUES
    (1, 'Sipho Mahlangu',   'sipho.mahlangu@raceday.co.za', 'HASHED_PASSWORD_1', '0821234567'),
    (1, 'Anél Coetzee',     'anel.coetzee@raceday.co.za',   'HASHED_PASSWORD_2', '0837654321'),
    (2, 'Thandi Nkosi',     'thandi.nkosi@example.com',     'HASHED_PASSWORD_3', '0731112222'),
    (2, 'Johan van der Merwe', 'johan.vdm@example.com',     'HASHED_PASSWORD_4', '0793334444');
GO

-- Events: 3 events, organised by the two Organisers above
INSERT INTO dbo.Events (OrganiserId, EventName, Description, EventDate, Location, RouteInfo)
VALUES
    (1, 'Joburg City Marathon', 'Annual road marathon through downtown Johannesburg.', '2026-10-18 06:00:00', 'Johannesburg, Gauteng', 'Flat city-centre loop, closed roads, water points every 3km'),
    (1, 'Soweto Community Fun Run', 'Charity fun run supporting local youth sports programmes.', '2026-11-08 07:00:00', 'Soweto, Gauteng', 'Out-and-back route through Vilakazi Street precinct'),
    (2, 'Cape Winelands Cycle Tour', 'Scenic cycling tour through the Cape winelands.', '2026-09-27 06:30:00', 'Stellenbosch, Western Cape', 'Rolling hills, two categorised climbs, fully marshalled');
GO

-- Categories: at least one per event (multiple for the marathon and cycle tour)
INSERT INTO dbo.Categories (EventId, CategoryName, DistanceKm, Price, MaxParticipants)
VALUES
    (1, 'Full Marathon 42km', 42.20, 350.00, 5000),
    (1, 'Half Marathon 21km', 21.10, 250.00, 4000),
    (2, '5km Fun Run', 5.00, 80.00, 2000),
    (3, '109km Long Route', 109.00, 450.00, 1500),
    (3, '60km Short Route', 60.00, 300.00, 1500);
GO

-- Enrolments: sample participants entering categories
INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, Status)
VALUES
    (3, 2, 'Confirmed'),  -- Thandi -> Half Marathon
    (4, 1, 'Confirmed'),  -- Johan  -> Full Marathon
    (3, 3, 'Confirmed'),  -- Thandi -> Soweto 5km Fun Run
    (4, 4, 'Confirmed');  -- Johan  -> Cape Winelands 109km
GO

-- Results: sample captured results for two of the enrolments above
INSERT INTO dbo.Results (EnrolmentId, FinishTime, Position, Status)
VALUES
    (1, '01:45:32', 214, 'Finished'),
    (2, '03:58:07', 891, 'Finished');
GO
