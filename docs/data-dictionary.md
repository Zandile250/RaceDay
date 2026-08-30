This document describes each table and column in the RaceDay database in plain English, as a complement to `erd.pdf` and `raceday-database.sql`. It is there so that anyone reading the project (including future-me in Part 2/3) can know what each field is without having to re-derive it from the SQL.

---

## Roles

| Column   | Type              | Description |
|----------|-------------------|--------------|
| RoleId   | INT (PK)          | Unique identifier for the role. |
The name of the role (either `Organiser` or `Participant`) — VARCHAR(20), UNIQUE. It is stored in its own table, not as a plain text column on Users, so that the system can enforce exactly which roles exist and role-based logic remains centralised.

---

## Users

| Column        | Type                | Description |
|---------------|---------------------|--------------|
| UserId        | INT (PK)            | Unique identifier for the user account. |
RoleId (FK → Roles) | INT | Which role this user has, determines what he/she can do in the system.
FullName | VARCHAR(100) | The user's full name as displayed on profiles, rosters and results. |
Email         | VARCHAR(150), UNIQUE | Used to log in; must be unique so no two accounts share an email.
PasswordHash  | VARCHAR(255)        | A secure hash of the user's password (not stored in plain text).
PhoneNumber   | VARCHAR(20), NULL   | Optional contact number.
CreatedAt     | DATETIME            | The date and time the account was created (defaults to the current date and time). |

Note: There is a single Users table for both Organisers and Participants — the RoleId is what distinguishes their permissions, not two tables. This prevents redundant data (name, email, password) in two tables.

---

## Events

| Column       | Type                 | Description |
|--------------|----------------------|--------------|
| EventId      | INT (PK)             | Unique identifier for the event. |
OrganiserId  | INT (FK → Users)     | The Organiser that created and owns this event. It can only be edited or deleted by this user.
| EventName    | VARCHAR(150)         | The name of the event, e.g. "Joburg City Marathon". |
Free-text details about the event. |
| EventDate    | DATETIME             | The date and time the event takes place. |
| Location     | VARCHAR(150)         | Where the event is held. |
RouteInfo VARCHAR(500), NULL | Static description of the route (terrain, water points, closures). This is not where live weather is stored, it is handled separately in Part 3.
ImageUrl     | VARCHAR(500), NULL   | URL of an event image in Azure Blob Storage (Part 3). |
| CreatedAt    | DATETIME             | When the event record was created. |

---

## Categories

| Column          | Type                 | Description |
|-----------------|----------------------|--------------|
| CategoryId      | INT (PK)             | Unique identifier for the category. |
EventId is an INT (foreign key) that references Events. There may be multiple categories for an event (10km, 21km, 42km).
| CategoryName    | VARCHAR(100)         | Name of the category, e.g. "Half Marathon 21km". |
| DistanceKm      | DECIMAL(5,2)         | The race distance in kilometres. |
| Price           | DECIMAL(8,2)         | Entry fee for this category. |
MaxParticipants | INT                  | Maximum number of participants that can enroll in this category.

---

## Enrolments

| Column         | Type                    | Description |
|----------------|-------------------------|--------------|
| EnrolmentId    | INT (PK)                | Unique identifier for the enrolment record. |
ParticipantId  | INT (FK → Users)        | The Participant who entered the event.
CategoryId (FK → Categories) | INT | Which category they entered.
EnrolmentDate  | DATETIME                | Date and time of enrolment (defaults to current date and time). |
| Status         | VARCHAR(20)              | `Confirmed` or `Cancelled` — tracks whether the entry is still active. |

The UNIQUE constraint (ParticipantId, CategoryId) prevents the same participant from enrolling in the same category twice, but it does not prevent him or her from enrolling in multiple categories or events.

---

## Results

| Column       | Type                        | Description |
|--------------|-----------------------------|--------------|
| ResultId     | INT (PK)                    | Unique identifier for the result record. |
EnrolmentId  | INT (FK → Enrolments), UNIQUE | This is a link to a single enrolment — a participant may have only one result for each enrolment.
FinishTime   | TIME, NULL                  | The time the participant took to finish the race, recorded after the race.
| Position     | INT, NULL                   | Their placing in the category (e.g. 214th). |
| Status       | VARCHAR(20)                  | `Finished`, `DNF` (did not finish), or `DSQ` (disqualified). |
| CapturedAt   | DATETIME                    | When the Organiser captured this result. |

Note: Results is a separate table from Enrolments, not additional columns on Enrolments — a participant enrols before the race, and the result does not exist until after the race. This allows an enrolment to have no result at all, which is a nullable relationship in practice, instead of having empty result columns from the beginning of the enrolment row.